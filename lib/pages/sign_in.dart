import 'package:blogs_app/pages/forgot_pwd.dart';
import 'package:blogs_app/pages/home_page.dart';
import 'package:blogs_app/pages/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class signIn extends StatefulWidget {
  const signIn({super.key});

  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController t_email = TextEditingController();
  final TextEditingController t_password = TextEditingController();
  String message = "";

  void login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: t_email.text.trim(),
        password: t_password.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        await user.reload(); // Refresh the user's authentication state
        user = _auth.currentUser; // Get the refreshed user

        if (user != null && user.emailVerified) {
          // Fetch user details from Firestore
          DocumentSnapshot userData =
              await _firestore.collection('users').doc(user.uid).get();
          String userName = userData['name'];

          // Navigate to home page or show user data
          // print("User logged in: $userName");
          setState(() {
            message = "User logged in: $userName";
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Welcome " + userName + "!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ));
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return homePage(
                  username: userName,
                );
              },
            ));
          });
        } else {
          setState(() {
            message = 'Please verify your email to log in.';
          });
        }
      } else {
        setState(() {
          message = 'User not found.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? "An error occurred";
      });
    } catch (e) {
      setState(() {
        message = 'An unknown error occurred: $e';
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
                //   message,
                //   style: TextStyle(color: Colors.green),
                // ),
                // SizedBox(
                //   height: 25,
                // ),
                Text(
                  "Sign In",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  "One step away from posting things!!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: t_email,
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
                    controller: t_password,
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
                  height: 4,
                ),
                Container(
                  width: 360,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(""),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return forgotPassword();
                            },
                          ));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text(
                    "SIGN IN",
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
                      "Not have an account?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return signUp();
                            },
                          ));
                        },
                        child: Text(
                          "Sign Up.",
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
