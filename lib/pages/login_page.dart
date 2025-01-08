import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../services/auth.dart';
import '../services/google_signin.dart';
import 'custom_text_field.dart';
import 'forgat_password.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: HexColor("FFFFFF"),
      appBar: AppBar(
        elevation: 5,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Login",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w500,
              color: HexColor("#00bf63"),
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [ ClipOval(
                child: Image.asset(
                  "assets/images/logo.jpeg",
                  // Add other properties for the image if needed...
                  width: 225,
                  height: 225,
                  fit: BoxFit.cover,
                ),
              ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: SizedBox(
                    height: screenHeight * 0.08,
                    width: screenWidth * 0.8,
                    child: CustomTextField(
                      labelText: "E-mail",
                      controller: _emailController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: SizedBox(
                    height: screenHeight * 0.08,
                    width: screenWidth * 0.8,
                    child: CustomTextField(
                      labelText: "Password",
                      controller: _passwordController,
                      obscureText: true,
                      maxLines: 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ForgatPassword()));
                  },
                  child: Row(
                    children: [
                      Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 15,
                          color: HexColor("#00bf63").withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox(
                    width: screenWidth, // 80% of screen width
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("#00bf63"),
                      ),
                      onPressed: () {
                        Auth()
                            .signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                        )
                            .then((value) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login successful'),
                            ),
                          );
                          // Delay navigation to HomePage
                          Future.delayed(const Duration(milliseconds: 30), () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const HomePage()));
                          });
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Login failed: $error'),
                          ));
                        });
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 0),
                  child: SizedBox(
                    width: screenWidth * 0.8, // 80% of screen width
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        GoogleSignInService().signInWithGoogle().then((value) {
                          route(context);
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Giriş başarısız: $error'),
                          ));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
            
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterPage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Yatayda ortalar
                    crossAxisAlignment: CrossAxisAlignment.center, // Dikeyde ortalar
                    children: [
                      Text(
                        "Not a member? ",
                        style: TextStyle(
                          fontSize: 15,
                          color: HexColor("#00bf63"),
                        ),
                      ),
                      Text(
                        "Sign up Now",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 15,
                          color: HexColor("#00bf63"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
void route(BuildContext context) {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Navigate to HomePage if document exists
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    // Handle case where the document does not exist
    print('Document does not exist on the database');
  }
}  

