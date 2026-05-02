// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class LoginAPi extends StatefulWidget {
//   const LoginAPi({super.key});
//
//   @override
//   State<LoginAPi> createState() => _LoginAPiState();
// }
//
// class _LoginAPiState extends State<LoginAPi> {
//   bool isloading = false;
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController(text: "kminchelle");
//   final _passwordController = TextEditingController(text: "0lelplR");
//   void handleLogin()async{
//     setState(() {
//       isloading = true;
//     });
//     try{
//       final data = await UserLogin(_emailController.text.trim(), _passwordController.text.trim());
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('login success')));
//     }catch(e){
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('login failed')));
//     }
//   }
// Future<Map<String, dynamic>> UserLogin(String username, String password) async{
//   final response = await http.post(Uri.parse('https://dummyjson.com/auth/login'),
//     headers: {
//       'Content-Type': 'application/json'
//     },
//     body: jsonEncode({
//       "username" : username,
//       "password" : password,
//     })
//   );
//
//   print("Status Code: ${response.statusCode}");
//   print("Response Body: ${response.body}");
//   if(response.statusCode == 200){
//     return jsonDecode(response.body);
//   }
//   else{
//     throw Exception('login failed: ${response.statusCode}');
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Login"),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Form(
//         key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//              TextFormField(
//                controller: _emailController,
//                decoration: InputDecoration(
//                  hintText: 'email',
//                  prefixIcon: Icon(Icons.email),
//                ),
//              ),
//               SizedBox(height: 30),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   hintText: 'password',
//                   prefixIcon: Icon(Icons.password),
//                   suffixIcon: Icon(Icons.visibility),
//                 ),
//               ),
//               SizedBox(height: 40),
//              isloading ? CircularProgressIndicator() : ElevatedButton(
//                  onPressed: (){
//                    handleLogin();
//                  },
//                  style: ElevatedButton.styleFrom(
//                    backgroundColor: Colors.blueAccent),
//                  child: Text('Login')
//              )],
//           ),
//       ),
//     );
//   }
// }
