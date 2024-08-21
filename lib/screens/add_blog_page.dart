import 'dart:io';
import 'package:blog_app/widgets/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

class AddBlogPage extends StatefulWidget {
  @override
  _AddBlogPageState createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _quillController = quill.QuillController.basic();
  XFile? _image;
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false; // To track loading state

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  void _uploadBlog() async {
    if (_titleController.text.isEmpty ||
        _quillController.document.isEmpty() ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are required!', style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch the user's name from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userName = userDoc.get('name') ?? 'Unknown';

      // Generate a unique ID for the blog
      String blogId = Uuid().v4();

      // Get the content from the Quill editor
      String content = _quillController.document.toPlainText();

      final file = File(_image!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('blogs_images')
          .child('$blogId.jpg');

      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      // Create a map to store the blog data
      Map<String, dynamic> blogData = {
        'title': _titleController.text,
        'content': content,
        'image': downloadURL,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'blogId': blogId,
        'authorName': userName, // Include the user's name
      };

      // Store the blog in the user's unique collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('blogs')
          .doc(blogId)
          .set(blogData);

      // Store the blog in the global all_blogs collection
      await _firestore.collection('all_blogs').doc(blogId).set(blogData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Blog uploaded successfully!', style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.greenAccent,
        ),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => Navbar()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload blog: ${e.toString()}', style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Add New Blog',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Content:',
                style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        color: Colors.grey[200],
                      ),
                      child: quill.QuillEditor(
                        controller: _quillController,
                        scrollController: ScrollController(),
                        focusNode: _focusNode,
                        configurations: quill.QuillEditorConfigurations(
                          padding: EdgeInsets.all(8.0),
                          expands: true,
                          placeholder: 'Write your blog content here...',
                        ),
                      ),
                    ),
                    quill.QuillToolbar.simple(controller: _quillController),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _image != null
                  ? AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Image.file(
                        File(_image!.path),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      'No image selected.',
                      style: GoogleFonts.openSans(color: Colors.grey),
                    ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo_library),
                    label: Text('Choose from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _uploadBlog,
                          child: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
