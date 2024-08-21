import 'package:blog_app/screens/edit_blog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserBlogsPage extends StatefulWidget {
  @override
  _UserBlogsPageState createState() => _UserBlogsPageState();
}

class _UserBlogsPageState extends State<UserBlogsPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId =
        FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _editBlog(String blogId, Map<String, dynamic> blogData) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlogPage(
          blogId: blogId,
          blogData: blogData,
        ),
      ),
    );
  }

  Future<void> _deleteBlog(String blogId) async {
    // Delete blog 
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('blogs')
        .doc(blogId)
        .delete();

    // Delete blog from the all_blogs collection
    await FirebaseFirestore.instance
        .collection('all_blogs')
        .doc(blogId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blog deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Blogs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('blogs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No blogs found.'));
          }

          final userBlogs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userBlogs.length,
            itemBuilder: (context, index) {
              final blogData = userBlogs[index].data() as Map<String, dynamic>;
              final blogId = userBlogs[index].id;

              // Debugging: Print the fetched blog data to check
              print('Blog Data: $blogData');

              // Handle content field type
              final content = blogData['content'];
              String displayContent = 'No Content';

              if (content is String) {
                displayContent = content;
              } else {
                // Default to 'No Content' if the content is not a string
                displayContent = 'No Content';
              }

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              8.0)), // Optional: Add rounded corners to the top of the image
                      child: Image.network(
                        blogData['image'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit
                            .cover, // Ensures the image covers the entire area without distortion
                        width: double.infinity,
                        height:
                            200, // Adjust the height as needed to fit the design
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200, // Same height to maintain consistency
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            blogData['title'] ?? 'No Title',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            displayContent,
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _editBlog(blogId, blogData),
                                child: Text('Edit'),
                              ),
                              SizedBox(width: 5),
                              TextButton(
                                onPressed: () => _deleteBlog(blogId),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
