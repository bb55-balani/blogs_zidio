import 'package:blogs_app/pages/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class signUp extends StatefulWidget {
  const signUp({super.key});

  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _errorMessage = '';

  void _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      await user!.updateDisplayName(_nameController.text);
      await user.sendEmailVerification();

      // Store user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text,
        'email': _emailController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _errorMessage = 'Sign up successful! Please verify your email!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Sign-Up Successfull!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Please verify your email!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return signIn();
          },
        ));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   _errorMessage,
                //   style: TextStyle(color: Colors.green),
                // ),
                // SizedBox(
                //   height: 5,
                // ),
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Fill details and post something exciting!!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: "Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                      hintText: "Password",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    _signUp();
                  },
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return signIn();
                            },
                          ));
                        },
                        child: Text(
                          "Sign In.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
