package com.example.arshopapp

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import io.github.sceneview.ar.ArSceneView
import io.github.sceneview.ar.node.ArModelNode
import io.github.sceneview.ar.node.PlacementMode
import io.github.sceneview.math.Position
import io.github.sceneview.math.Rotation
import io.github.sceneview.math.Scale
import kotlinx.coroutines.launch

class ArActivity : AppCompatActivity() {

    // ── Views ──────────────────────────────────────────────────────────────────
    private lateinit var arSceneView: ArSceneView
    private lateinit var loadingLayout: FrameLayout
    private lateinit var tvLoading: TextView
    private lateinit var tvInstruction: TextView
    private lateinit var btnBack: Button
    private lateinit var btnRemove: Button
    private lateinit var btnAddToCart: Button
    private lateinit var controlsLayout: LinearLayout
    private lateinit var scaleBar: SeekBar
    private lateinit var rotationBar: SeekBar

    // ── AR State ───────────────────────────────────────────────────────────────
    private var modelNode: ArModelNode? = null
    private var isModelLoaded = false
    private var isModelPlaced = false

    // ── Data ───────────────────────────────────────────────────────────────────
    private var modelUrl = ""
    private var productName = ""
    private var productPrice = ""
    private var productId = ""

    companion object {
        const val EXTRA_MODEL_URL = "model_url"
        const val EXTRA_PRODUCT_NAME = "product_name"
        const val EXTRA_PRODUCT_PRICE = "product_price"
        const val EXTRA_PRODUCT_ID = "product_id"
        const val RESULT_ADDED_TO_CART = "added_to_cart"

        // Free sample GLB for testing
        const val SAMPLE_MODEL_URL =
            "https://sceneview.github.io/assets/models/DamagedHelmet.glb"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Get data from Flutter
        modelUrl = intent.getStringExtra(EXTRA_MODEL_URL) ?: ""
        productName = intent.getStringExtra(EXTRA_PRODUCT_NAME) ?: "Product"
        productPrice = intent.getStringExtra(EXTRA_PRODUCT_PRICE) ?: "0"
        productId = intent.getStringExtra(EXTRA_PRODUCT_ID) ?: ""

        // Build layout
        val root = buildLayout()
        setContentView(root)

        // Initialize AR
        initAR()
    }

    // ── Build Layout ───────────────────────────────────────────────────────────
    private fun buildLayout(): FrameLayout {
        val dp = resources.displayMetrics.density

        fun Int.dp() = (this * dp).toInt()

        val root = FrameLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // ── AR Scene ──────────────────────────────
        arSceneView = ArSceneView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }
        root.addView(arSceneView)

        // ── Loading Overlay ───────────────────────
        loadingLayout = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(0xCC000000.toInt())
        }

        tvLoading = TextView(this).apply {
            text = "Initializing AR...\nPlease wait"
            textSize = 16f
            gravity = android.view.Gravity.CENTER
            setTextColor(0xFFFFFFFF.toInt())
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply { gravity = android.view.Gravity.CENTER }
        }
        loadingLayout.addView(tvLoading)
        root.addView(loadingLayout)

        // ── Top Bar ───────────────────────────────
        val topBar = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER_VERTICAL
            setPadding(16.dp(), getStatusBarHeight() + 8.dp(), 16.dp(), 8.dp())
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply { gravity = android.view.Gravity.TOP }
        }

        btnBack = Button(this).apply {
            text = "✕"
            textSize = 16f
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0x88000000.toInt())
            layoutParams = LinearLayout.LayoutParams(48.dp(), 48.dp())
            setOnClickListener { finish() }
        }

        val nameBox = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0x88000000.toInt())
            setPadding(16.dp(), 8.dp(), 16.dp(), 8.dp())
            layoutParams = LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f
            ).apply {
                marginStart = 8.dp()
                marginEnd = 8.dp()
            }
        }

        TextView(this).apply {
            text = productName
            textSize = 14f
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
            setTextColor(0xFFFFFFFF.toInt())
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }.also { nameBox.addView(it) }

        TextView(this).apply {
            text = "\$$productPrice"
            textSize = 12f
            setTextColor(0xFFCCCCCC.toInt())
        }.also { nameBox.addView(it) }

        btnRemove = Button(this).apply {
            text = "🗑"
            textSize = 16f
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0xFFEF4444.toInt())
            layoutParams = LinearLayout.LayoutParams(48.dp(), 48.dp())
            visibility = View.GONE
            setOnClickListener { removeModel() }
        }

        topBar.addView(btnBack)
        topBar.addView(nameBox)
        topBar.addView(btnRemove)
        root.addView(topBar)

        // ── Instruction Text ──────────────────────
        tvInstruction = TextView(this).apply {
            text = "🔍 Move your phone to detect surfaces\nthen tap to place furniture"
            textSize = 14f
            gravity = android.view.Gravity.CENTER
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0x88000000.toInt())
            setPadding(24.dp(), 12.dp(), 24.dp(), 12.dp())
            visibility = View.GONE
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply { gravity = android.view.Gravity.CENTER }
        }
        root.addView(tvInstruction)

        // ── Bottom Panel ──────────────────────────
        val bottomPanel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xEE000000.toInt())
            setPadding(24.dp(), 16.dp(), 24.dp(), 40.dp())
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply { gravity = android.view.Gravity.BOTTOM }
        }

        // Controls (hidden until model placed)
        controlsLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        // Scale control
        val scaleRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        TextView(this).apply {
            text = "📐"
            textSize = 20f
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }.also { scaleRow.addView(it) }

        scaleBar = SeekBar(this).apply {
            max = 100
            progress = 30
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            ).apply { marginStart = 12.dp() }
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(
                    sb: SeekBar?, progress: Int, fromUser: Boolean
                ) {
                    if (fromUser) {
                        val s = 0.1f + (progress / 100f) * 2.9f
                        modelNode?.scale = Scale(s, s, s)
                    }
                }
                override fun onStartTrackingTouch(sb: SeekBar?) {}
                override fun onStopTrackingTouch(sb: SeekBar?) {}
            })
        }
        scaleRow.addView(scaleBar)

        // Rotation control
        val rotRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = 8.dp() }
        }

        TextView(this).apply {
            text = "🔄"
            textSize = 20f
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }.also { rotRow.addView(it) }

        rotationBar = SeekBar(this).apply {
            max = 360
            progress = 0
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            ).apply { marginStart = 12.dp() }
            setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(
                    sb: SeekBar?, progress: Int, fromUser: Boolean
                ) {
                    if (fromUser) {
                        modelNode?.rotation = Rotation(0f, progress.toFloat(), 0f)
                    }
                }
                override fun onStartTrackingTouch(sb: SeekBar?) {}
                override fun onStopTrackingTouch(sb: SeekBar?) {}
            })
        }
        rotRow.addView(rotationBar)

        controlsLayout.addView(scaleRow)
        controlsLayout.addView(rotRow)

        // Add to cart button
        btnAddToCart = Button(this).apply {
            text = "🛒   Add to Cart   —   \$$productPrice"
            textSize = 15f
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0xFFE94560.toInt())
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                52.dp()
            ).apply { topMargin = 16.dp() }
            setOnClickListener {
                val data = Intent()
                data.putExtra(RESULT_ADDED_TO_CART, true)
                setResult(Activity.RESULT_OK, data)
                finish()
            }
        }

        bottomPanel.addView(controlsLayout)
        bottomPanel.addView(btnAddToCart)
        root.addView(bottomPanel)

        return root
    }

    // ── Init AR ────────────────────────────────────────────────────────────────
    private fun initAR() {
        arSceneView.apply {

            // AR session ready
            onArSessionCreated = {
                runOnUiThread {
                    loadingLayout.visibility = View.GONE
                    tvInstruction.visibility = View.VISIBLE
                    tvInstruction.text =
                        "🔍 Move your phone to detect surfaces\nthen tap to place"
                }
                loadModel()
            }

            // Plane tapped
            onTapAr = { hitResult, _ ->
                handleTap(hitResult)
            }

            // AR frame update
            onArFrame = { arFrame ->
                // Update instruction based on tracking state
                val camera = arFrame.camera
                runOnUiThread {
                    when (camera.trackingState) {
                        TrackingState.TRACKING -> {
                            if (!isModelPlaced) {
                                tvInstruction.text =
                                    "✅ Surface detected! Tap to place furniture"
                            }
                        }
                        TrackingState.PAUSED -> {
                            if (!isModelPlaced) {
                                tvInstruction.text =
                                    "🔍 Move phone slowly to detect surface..."
                            }
                        }
                        TrackingState.STOPPED -> {
                            tvInstruction.text = "⚠️ Tracking lost. Move slowly."
                        }
                        else -> {}
                    }
                }
            }
        }
    }

    // ── Load 3D Model ──────────────────────────────────────────────────────────
    private fun loadModel() {
        val url = if (modelUrl.isNotEmpty()) modelUrl else SAMPLE_MODEL_URL

        lifecycleScope.launch {
            try {
                modelNode = ArModelNode(
                    engine = arSceneView.engine,
                    placementMode = PlacementMode.INSTANT
                ).apply {
                    loadModelGlbAsync(
                        glbFileLocation = url,
                        scaleToUnits = 1f,
                        centerOrigin = Position(y = -1f)
                    ) {
                        // Model loaded successfully
                        isModelLoaded = true
                        runOnUiThread {
                            tvInstruction.text =
                                "✅ Model ready! Tap on a flat surface to place"
                        }
                    }
                }

                arSceneView.addChild(modelNode!!)

            } catch (e: Exception) {
                runOnUiThread {
                    tvInstruction.text = "⚠️ Failed to load model: ${e.message}"
                }
            }
        }
    }

    // ── Handle Tap ─────────────────────────────────────────────────────────────
    private fun handleTap(hitResult: HitResult) {
        if (!isModelLoaded) {
            runOnUiThread {
                tvInstruction.text = "⏳ Model still loading, please wait..."
            }
            return
        }

        val anchor = hitResult.createAnchor()
        modelNode?.anchor = anchor

        if (!isModelPlaced) {
            isModelPlaced = true
            runOnUiThread {
                tvInstruction.visibility = View.GONE
                controlsLayout.visibility = View.VISIBLE
                btnRemove.visibility = View.VISIBLE
                Toast.makeText(
                    this,
                    "Furniture placed! Use sliders to adjust size and rotation",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    // ── Remove Model ───────────────────────────────────────────────────────────
    private fun removeModel() {
        modelNode?.anchor = null
        isModelPlaced = false

        // Reset sliders
        scaleBar.progress = 30
        rotationBar.progress = 0
        modelNode?.scale = Scale(1f, 1f, 1f)
        modelNode?.rotation = Rotation(0f, 0f, 0f)

        runOnUiThread {
            tvInstruction.text = "🔍 Tap on a surface to place again"
            tvInstruction.visibility = View.VISIBLE
            controlsLayout.visibility = View.GONE
            btnRemove.visibility = View.GONE
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────
    private fun getStatusBarHeight(): Int {
        val id = resources.getIdentifier(
            "status_bar_height", "dimen", "android"
        )
        return if (id > 0) resources.getDimensionPixelSize(id) else 60
    }

    // ── Lifecycle ──────────────────────────────────────────────────────────────
    override fun onResume() {
        super.onResume()
        try {
            arSceneView.onResume(this)
        } catch (e: CameraNotAvailableException) {
            Toast.makeText(this, "Camera not available", Toast.LENGTH_SHORT).show()
            finish()
        } catch (e: Exception) {
            Toast.makeText(this, "AR Error: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onPause() {
        super.onPause()
        try { arSceneView.onPause(this) } catch (e: Exception) { }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            modelNode?.destroy()
            arSceneView.destroy()
        } catch (e: Exception) { }
    }
}