import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blog_app/screens/blog_detail.dart';

class BlogListPage extends StatefulWidget {
  @override
  _BlogListPageState createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> with TickerProviderStateMixin {
  final CollectionReference _blogsCollection =
      FirebaseFirestore.instance.collection('all_blogs');
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> _blogs = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fetchBlogs();
  }

  Future<String?> _getImageUrl(String blogId) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('blogs_images/$blogId.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL for blog $blogId: $e');
      return null;
    }
  }

  Future<bool> _getLikeStatus(String blogId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likes')
        .doc(blogId)
        .get();
    return doc.exists;
  }

  Future<void> _toggleLike(String blogId, bool liked, int index) async {
    final likeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('likes')
        .doc(blogId);

    if (liked) {
      await likeRef.delete();
      await _blogsCollection.doc(blogId).update({
        'likes': FieldValue.increment(-1),
      });
      setState(() {
        _blogs[index]['liked'] = false;
        _blogs[index]['likes']--;
      });
    } else {
      await likeRef.set({});
      await _blogsCollection.doc(blogId).update({
        'likes': FieldValue.increment(1),
      });
      setState(() {
        _blogs[index]['liked'] = true;
        _blogs[index]['likes']++;
      });
    }
  }

  Future<void> _fetchBlogs() async {
    final snapshot = await _blogsCollection.get();
    final blogs = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final blogId = doc.id;
      final imageUrl = await _getImageUrl(blogId);
      final liked = await _getLikeStatus(blogId);
      return {
        'id': blogId,
        'title': data['title'] ?? '',
        'summary': data['content'] ?? '',
        'date': data['time'] ?? '',
        'image': imageUrl,
        'likes': data['likes'] ?? 0,
        'comments': data['comments'] ?? 0,
        'liked': liked,
      };
    }).toList());

    setState(() {
      _blogs = blogs;
    });

    // Animate the appearance of each blog item
    for (int i = 0; i < _blogs.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _listKey.currentState?.insertItem(i, duration: Duration(milliseconds: 300));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog App', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _blogs.length,
        itemBuilder: (context, index, animation) {
          final blog = _blogs[index];
          return _buildBlogItem(blog, animation, index);
        },
      ),
    );
  }

  Widget _buildBlogItem(Map<String, dynamic> blog, Animation<double> animation, int index) {
    final blogId = blog['id'];
    final blogTitle = blog['title'];
    final blogSummary = blog['summary'];
    final blogDate = blog['date'];
    final blogImage = blog['image'];
    final blogLikes = blog['likes'];
    final liked = blog['liked'];

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -1),
        end: Offset.zero,
      ).animate(animation),
      child: GestureDetector(
        onTap: () => _navigateToBlogDetail(context, blog),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 12,
            shadowColor: Colors.black.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: blogImage ?? '',
                  child: blogImage != null
                      ? Image.network(
                          blogImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blogTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        blogSummary,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Text(
                        blogDate,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  liked
                                      ? Icons.thumb_up_alt_rounded
                                      : Icons.thumb_up_alt_outlined,
                                  color: liked
                                      ? Colors.blueAccent
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  _toggleLike(blogId, liked, index);
                                },
                              ),
                              Text(
                                '$blogLikes',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBlogDetail(BuildContext context, Map<String, dynamic> blog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailPage(
          title: blog['title'],
          content: blog['summary'],
          imageUrl: blog['image'] ?? '',
        ),
      ),
    );
  }
}
