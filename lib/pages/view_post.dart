import 'dart:io';

import 'package:blogs_app/pages/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ViewPost extends StatefulWidget {
  const ViewPost({Key? key}) : super(key: key);

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  List<String> likedPosts = [];
//delete post
  Future<void> deletePost(String postId, String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      await FirebaseFirestore.instance
          .collection('uploads')
          .doc(postId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Post deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<String> getUsername(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['name'] ?? 'Unknown';
  }

//update post
  Future<void> editPost(String postId, Map<String, dynamic> postData) async {
    TextEditingController titleController =
        TextEditingController(text: postData['title']);
    TextEditingController descriptionController =
        TextEditingController(text: postData['description']);
    String? newImageUrl;
    XFile? newImage;

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Post'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      newImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      setState(() {});
                    },
                    child: Text('Change Image'),
                  ),
                  newImage != null
                      ? Image.file(File(newImage!.path))
                      : Image.network(postData['imageUrl']),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (newImage != null) {
                    String fileName = newImage!.name;
                    UploadTask uploadTask = FirebaseStorage.instance
                        .ref('uploads/$fileName')
                        .putFile(File(newImage!.path));
                    TaskSnapshot snapshot = await uploadTask;
                    newImageUrl = await snapshot.ref.getDownloadURL();

                    await FirebaseStorage.instance
                        .refFromURL(postData['imageUrl'])
                        .delete();
                  }
                  await FirebaseFirestore.instance
                      .collection('uploads')
                      .doc(postId)
                      .update({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'imageUrl': newImageUrl ?? postData['imageUrl'],
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Post updated successfully!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ));
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        actions: [
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "Logout Successful!",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ));
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return signIn();
                },
              ));
            },
            child: Container(
                margin: EdgeInsets.only(right: 10), child: Icon(Icons.logout)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uploads') // Filter by current user ID
            // .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print(
              'Current User ID: ${FirebaseAuth.instance.currentUser!.uid}'); // Debugging statement

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No uploads found for the current user.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final postId = docs[index].id;
              final userId = data['userId'];
              bool liked = likedPosts.contains(postId);

              return FutureBuilder<String>(
                future: getUsername(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final username = userSnapshot.data ?? 'Unknown';

                  return Stack(children: [
                    Container(
                      width: 500,
                      height: 360, // Increased height to accommodate username
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 24, 23, 23)
                              .withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ], color: Colors.white),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                                width: 500,
                                height: 200,
                                child: Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.cover,
                                )),
                            Container(
                                width: 500,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                color: Color.fromARGB(255, 237, 240, 242),
                                child: Center(
                                    child: Text(
                                  "Title : " + data['title'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                ))),
                            Container(
                              width: 500,
                              padding: EdgeInsets.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['description'],
                                    style: TextStyle(fontSize: 15),
                                    maxLines: 5,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Uploaded by: $username",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: Text(
                                          "Download",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 5,
                        right: 10,
                        left: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      editPost(postId, data);
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      deletePost(postId, data['imageUrl']);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (liked) {
                                      likedPosts.remove(postId); // Unlike post
                                    } else {
                                      likedPosts.add(postId); // Like post
                                    }
                                  });
                                },
                                icon: liked
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.pink,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                      )),
                          ],
                        ))
                  ]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
