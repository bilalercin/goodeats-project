import 'package:flutter/material.dart';
import 'package:goodeats/pages/custom_text_field.dart';
import 'package:goodeats/pages/login_page.dart';
import 'package:hexcolor/hexcolor.dart';

import '../services/register_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegisterService _registerService = RegisterService();

  void _register() async {
    var contextMessage = ScaffoldMessenger.of(context);
    try {
      await _registerService.registerUser(
        name: _nameController.text,
        surname: _surnameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      contextMessage.showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );
      Future.delayed(Duration(microseconds: 30), () {
              // 2 saniye bekledikten sonra başka bir sayfaya geçiş yapıyoruz
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // NextPage() yeni sayfa
              );
            });
    } catch (e) {
      contextMessage.showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: HexColor("FFFFFF"),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sign up",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w500,
              color: HexColor("#00bf63"),
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: SizedBox(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                      labelText: "Name",
                      maxLines: 1,
                      controller: _nameController),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: SizedBox(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                      maxLines: 1,
                      labelText: "Surname",
                      controller: _surnameController),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: SizedBox(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                      maxLines: 1,
                      labelText: "Email",
                      controller: _emailController),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: SizedBox(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.8,
                  child: CustomTextField(
                      maxLines: 1,
                      labelText: "Password",
                      controller: _passwordController,
                      obscureText: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor("#00bf63"),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _register,
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),const SizedBox(
                      height: 70,
                    ), 
              GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
              },
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    "Already a member? ",
                    style: TextStyle(
                      fontSize: 15,
                      color: HexColor("#00bf63"),
                    ),
                  ),
                  Text("Login",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      color: HexColor("#00bf63"),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

