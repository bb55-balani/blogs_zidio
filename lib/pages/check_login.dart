import 'package:blogs_app/pages/home_page.dart';
import 'package:blogs_app/pages/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class checkLogin extends StatefulWidget {
  const checkLogin({super.key});

  @override
  State<checkLogin> createState() => _checkLoginState();
}

class _checkLoginState extends State<checkLogin> {
  Future<String> getUsername(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data()?['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String>(
            future: getUsername(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasData) {
                return homePage(
                  username: userSnapshot.data!,
                );
              } else {
                return signIn();
              }
            },
          );
        } else {
          return signIn();
        }
      },
    );
  }
}
