import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Create a new post
  Future<String?> createPost({
    required String description,
    required File image,
    required String userId,
    required String username,
  }) async {
    try {
      // Validate inputs
      if (description.isEmpty || userId.isEmpty) {
        throw Exception('Invalid post data');
      }

      // Upload image to Firebase Storage
      String imageName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await _storage.ref(imageName).putFile(image);
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Save post data to Firestore
      DocumentReference docRef = await _firestore.collection('posts').add({
        'description': description,
        'imageUrl': imageUrl,
        'userId': userId,
        'username': username,
        'createdAt': Timestamp.now(),
        'likes': 0,
        'comments': [],
      });

      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get all posts
  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update a post
  Future<bool> updatePost({
    required String postId,
    required String description,
    File? image,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'description': description,
        'updatedAt': Timestamp.now(),
      };

      // If new image is provided, upload it
      if (image != null) {
        String imageName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
        TaskSnapshot snapshot = await _storage.ref(imageName).putFile(image);
        String imageUrl = await snapshot.ref.getDownloadURL();
        updateData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('posts').doc(postId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }
}