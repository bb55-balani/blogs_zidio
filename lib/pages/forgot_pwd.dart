import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({super.key});

  @override
  State<forgotPassword> createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {
  TextEditingController email = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String msg = "";
  Future<void> forgotPwd(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        msg = "Email sent for reset password!!";
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                msg,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Enter email to send the password reset link!"),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 350,
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Enter email"),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  forgotPwd(email.text);
                },
                child: Text(
                  "Send Email",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
