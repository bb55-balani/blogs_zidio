// import 'package:flutter/widgets.dart';
// import 'package:flutter/cupertino.dart';
import 'package:blogs_app/pages/view_post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class homePage extends StatefulWidget {
  String username = "";
  homePage({super.key, required this.username});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  TextEditingController blogTitle = TextEditingController();
  TextEditingController blogContent = TextEditingController();
  File? blogPostImg;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        blogPostImg = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadPost() async {
    if (blogPostImg == null) return;

    try {
      // Get user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');

      // Upload image
      final uploadTask = storageRef.putFile(blogPostImg!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Upload other data
      final docRef = FirebaseFirestore.instance.collection('uploads').doc();
      await docRef.set({
        'userId': userId,
        'title': blogTitle.text,
        'description': blogContent.text,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Upload Successfull!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 12, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add your posts!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 30,
                        child: Text(
                          widget.username.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * .2,
                      child: blogPostImg != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              //absolute gives the img path
                              child: Image.file(
                                blogPostImg!.absolute,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 142, 141, 141),
                                  borderRadius: BorderRadius.circular(8)),
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                    ),
                    Positioned(
                        right: 18,
                        bottom: 18,
                        child: GestureDetector(
                          onTap: () {
                            pickImage();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Choose Image",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Form(
                      child: Column(
                    children: [
                      TextFormField(
                        controller: blogTitle,
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Enter post title",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: blogContent,
                        maxLines: 10,
                        decoration: InputDecoration(
                          // labelText: "Description",
                          hintText: "Enter post content..",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
                ),
                GestureDetector(
                  onTap: () {
                    uploadPost();
                  },
                  child: Container(
                    margin: EdgeInsets.all(12),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "Upload Post",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ViewPost();
                      },
                    ));
                  },
                  child: Container(
                    margin: EdgeInsets.all(12),
                    width: MediaQuery.of(context).size.width * 1,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "View Post",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
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
