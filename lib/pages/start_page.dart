import 'dart:async';

import 'package:blogs_app/pages/check_login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class startPage extends StatefulWidget {
  const startPage({super.key});

  @override
  State<startPage> createState() => _startPageState();
}

class _startPageState extends State<startPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return checkLogin();
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("images/BlogiFy.json"),
            ],
          ),
        ),
      ),
    );
  }
}
