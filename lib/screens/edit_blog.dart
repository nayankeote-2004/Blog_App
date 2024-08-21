import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EditBlogPage extends StatefulWidget {
  final String blogId;
  final Map<String, dynamic> blogData;

  EditBlogPage({required this.blogId, required this.blogData});

  @override
  _EditBlogPageState createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  late quill.QuillController _quillController;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the title controller with the existing title
    _titleController.text = widget.blogData['title'];

    // Initialize the QuillController with the existing content
    final content = widget.blogData['content'] as String;
    final doc = quill.Document()..insert(0, content);
    _quillController = quill.QuillController(
      document: doc,
      selection: TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _saveChanges() async {
    // Update the blog data in both the user's collection and all_blogs collection
    final updatedData = {
      'title': _titleController.text,
      'content': _quillController.document.toPlainText(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('blogs')
        .doc(widget.blogId)
        .update(updatedData);

    await FirebaseFirestore.instance
        .collection('all_blogs')
        .doc(widget.blogId)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blog updated successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blog'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit your blog post',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                child: quill.QuillEditor(
                  controller: _quillController,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                  configurations: const quill.QuillEditorConfigurations(
                    scrollable: true,
                    padding: EdgeInsets.all(8.0),
                    autoFocus: false,
                    expands: true,
                  ),
                ),
              ),
              quill.QuillToolbar.simple(controller: _quillController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
