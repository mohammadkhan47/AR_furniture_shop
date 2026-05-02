package com.example.arshopapp

import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        const val AR_CHANNEL = "com.example.arshopapp/ar"
        const val AR_REQUEST_CODE = 1001
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AR_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ── Check if AR is supported ──────────────
                "checkARSupport" -> {
                    val supported = checkARSupport()
                    result.success(supported)
                }

                // ── Open AR Screen ────────────────────────
                "openAR" -> {
                    val modelUrl = call.argument<String>("modelUrl") ?: ""
                    val productName = call.argument<String>("productName") ?: ""
                    val productPrice = call.argument<String>("productPrice") ?: ""
                    val productId = call.argument<String>("productId") ?: ""

                    if (!checkARSupport()) {
                        result.error(
                            "AR_NOT_SUPPORTED",
                            "ARCore is not supported on this device",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    pendingResult = result

                    val intent = Intent(this, ArActivity::class.java).apply {
                        putExtra(ArActivity.EXTRA_MODEL_URL, modelUrl)
                        putExtra(ArActivity.EXTRA_PRODUCT_NAME, productName)
                        putExtra(ArActivity.EXTRA_PRODUCT_PRICE, productPrice)
                        putExtra(ArActivity.EXTRA_PRODUCT_ID, productId)
                    }

                    startActivityForResult(intent, AR_REQUEST_CODE)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == AR_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val addedToCart = data.getBooleanExtra(
                    ArActivity.RESULT_ADDED_TO_CART, false
                )
                pendingResult?.success(
                    mapOf("addedToCart" to addedToCart)
                )
            } else {
                pendingResult?.success(
                    mapOf("addedToCart" to false)
                )
            }
            pendingResult = null
        }
    }

    private fun checkARSupport(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT < 24) return false

            val availability = com.google.ar.core.ArCoreApk
                .getInstance()
                .checkAvailability(this)

            availability == com.google.ar.core.ArCoreApk.Availability.SUPPORTED_INSTALLED ||
                    availability == com.google.ar.core.ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD ||
                    availability == com.google.ar.core.ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED
        } catch (e: Exception) {
            false
        }
    }
}