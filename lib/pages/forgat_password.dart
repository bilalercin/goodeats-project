import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'custom_text_field.dart';
import '../services/auth.dart';

class ForgatPassword extends StatefulWidget {
  const ForgatPassword({super.key});

  @override
  State<ForgatPassword> createState() => _ForgatPasswordState();
}

class _ForgatPasswordState extends State<ForgatPassword> {
  final Auth _auth = Auth();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Şifremi Unuttum"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding:  EdgeInsets.only(left: screenHeight * 0.02, top: screenHeight * 0.05, bottom: screenHeight * 0.01, right: screenHeight * 0.04),
            child: const Text(
              "E-mail",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: screenHeight * 0.02, top: screenHeight * 0.01, bottom: screenHeight * 0.04, right: screenHeight * 0.04),
            child: SizedBox(
                height: screenHeight * 0.08,
                width: screenHeight * 0.8,
                child: CustomTextField(
                  labelText: "E-mail",
                  controller: _emailController,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: SizedBox(
              width: 312,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("8552A1"),
                ),
                onPressed: () async {
                  var navigatorMessage = Navigator.of(context);
                  await _auth.sendPasswordReset(_emailController.text);
                  navigatorMessage.push(
                    MaterialPageRoute(
                      builder: (context) => const ResetConfirmationScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Mail Gönder",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetConfirmationScreen extends StatelessWidget {
  const ResetConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Forgot password"),
      ),
      body: Scaffold()
    );
  }
}
