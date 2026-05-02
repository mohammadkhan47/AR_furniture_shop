// import 'package:arshopapp/view/login.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// void main(){
//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: LoginAPi()
//     );
//   }
// }
//
// class MyShop extends StatefulWidget {
//   const MyShop({super.key});
//
//   @override
//   State<MyShop> createState() => _MyShopState();
// }
//
// class _MyShopState extends State<MyShop> {
//   List<Map<String, String>> categories = [
//     {"title": "Shoes", "image": "assets/images/landb.png"},
//     {"title": "Watch", "image": "assets/images/landb.png"},
//     {"title": "Bag", "image": "assets/images/landb.png"},
//     {"title": "Phone", "image": "assets/images/landb.png"},
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//        body: SingleChildScrollView(
//          scrollDirection: Axis.vertical,
//          child: Padding(
//            padding: const EdgeInsets.all(16.0),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    CircleAvatar(
//                      child: Icon(Icons.menu),
//                    ),
//                    CircleAvatar(
//                      child: Icon(Icons.shopping_bag),
//                    )
//                  ],
//                ),
//                SizedBox(height: 30),
//                Text('Hemendra',style: TextStyle(
//                  fontSize: 35,
//                  fontWeight: FontWeight.bold,
//                ),),
//                SizedBox(height: 5),
//                Text('welcome to Laza',style: TextStyle(
//                  fontSize: 20,
//                  color: Colors.grey
//                ),),
//                SizedBox(height: 20),
//                Row(
//                  children: [
//                    Container(
//                      width: 320,
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.circular(12),
//                        gradient: LinearGradient(
//                          colors: [
//                            Colors.white,
//                            Colors.grey.shade200,
//                          ],
//                          begin: Alignment.topLeft,
//                          end: Alignment.bottomRight,
//                        ),
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.black.withOpacity(0.1),
//                            blurRadius: 10,
//                            offset: Offset(0, 4),
//                          ),
//                        ],
//                      ),
//                      child: TextField(
//                        keyboardAppearance: Brightness.dark,
//                        keyboardType: TextInputType.text,
//                        decoration: InputDecoration(
//                          hintText: "Search...",
//                          prefixIcon: Icon(Icons.search),
//                          border: InputBorder.none,
//                          contentPadding: EdgeInsets.symmetric(vertical: 15),
//                        ),
//                      ),
//                    ),
//                    SizedBox(width: 10),
//                    Container(
//                      width: 45,
//                      height: 45,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.purpleAccent
//                     ),
//                      child: Icon(Icons.keyboard_voice_sharp,color: Colors.white,size: 30,),
//                    )
//                  ],
//                ),
//                SizedBox(height: 40),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//
//                    Text('Categories',style: TextStyle(
//                      fontSize: 20,
//                      fontWeight: FontWeight.bold,
//                    ),),
//                    SizedBox(width: 10),
//                    Text('See all',style: TextStyle(
//                      fontSize: 15,
//                      color: Colors.grey
//                    ),)
//                  ],
//                ),
//                SizedBox(
//                  height: 30,
//                  child: ListView(
//                    scrollDirection: Axis.horizontal,
//                    children: [
//                    ],
//                  ),
//                ),
//                SingleChildScrollView(
//                  scrollDirection: Axis.horizontal,
//                  child: Row(
//                    children: [
//                      brandItem('adidas', 'assets/images/landb.png'),
//                      brandItem('adidas', 'assets/images/landb.png'),
//                      brandItem('adidas', 'assets/images/landb.png'),
//                      brandItem('adidas', 'assets/images/landb.png'),
//                      brandItem('adidas', 'assets/images/landb.png'),
//                      brandItem('adidas', 'assets/images/landb.png'),
//                    ],
//                  ),
//                ),
//                SizedBox(height: 20),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Text(
//                      "Choose Brand",
//                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                    ),
//                    Text(
//                      "View All",
//                      style: TextStyle(color: Colors.grey),
//                    ),
//                  ],
//                ),
//                SizedBox(height: 15),
//                GridView.count(
//                    crossAxisCount: 2,
//                    mainAxisSpacing: 10,
//                    crossAxisSpacing: 10,
//                    shrinkWrap: true,
//                    physics: NeverScrollableScrollPhysics(),
//                    children:
//                      categories.map((item) {
//                        return Container(
//                          decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.circular(15),
//                            boxShadow: [
//                              BoxShadow(
//                                color: Colors.grey.shade300,
//                                blurRadius: 5,
//                                offset: const Offset(2, 2),
//                              ),
//                            ],
//                          ),
//                          child: Column(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: [
//                              Image.asset(
//                                item["image"]!,
//                                height: 60,
//                              ),
//                              const SizedBox(height: 10),
//                              Text(
//                                item["title"]!,
//                                style: const TextStyle(
//                                  fontSize: 16,
//                                  fontWeight: FontWeight.bold,
//                                ),
//                              ),
//                            ],
//                          ),
//                        );
//                      }).toList(),
//
//            ),
//          ]
//            ),),
//        ),
//      )
//     );
//   }
//   Widget brandItem(String name , String image){
//     return Container(
//       width: 150,
//       margin: EdgeInsets.only(right: 12),
//       padding: EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           )
//         ]
//       ),
//       child: Row(
//         children: [
//           Image.asset(image,width: 50,height: 50,),
//           SizedBox(width: 10),
//           Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
//         ],
//       ),
//     );
//   }
// }
//
