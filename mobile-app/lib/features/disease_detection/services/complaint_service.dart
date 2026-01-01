import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit a complaint
  Future<String?> submitComplaint({
    required String idNumber,
    required String name,
    required String complaint,
    File? attachment,
  }) async {
    try {
      print('Starting complaint submission...');

      String? attachmentUrl;

      // Upload attachment if provided
      if (attachment != null && await attachment.exists()) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = 'complaints/complaint_${timestamp}_$idNumber.jpg';

        print('Uploading attachment: $fileName');

        TaskSnapshot snapshot = await _storage.ref(fileName).putFile(attachment);
        attachmentUrl = await snapshot.ref.getDownloadURL();
        print('Attachment URL obtained: $attachmentUrl');
      }

      // Save complaint data to Firestore
      DocumentReference docRef = await _firestore.collection('complaints').add({
        'idNumber': idNumber,
        'name': name,
        'complaint': complaint,
        'attachmentUrl': attachmentUrl,
        'status': 'Pending', // Pending, In Progress, Resolved
        'submittedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'replies': [], // Array for storing replies
      });

      print('Complaint saved to Firestore with ID: ${docRef.id}');
      return docRef.id;

    } catch (e) {
      print('Error submitting complaint: $e');
      return null;
    }
  }

  // Get all complaints (for admin view)
  Stream<QuerySnapshot> getComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get complaints by ID number
  Stream<QuerySnapshot> getComplaintsById(String idNumber) {
    return _firestore
        .collection('complaints')
        .where('idNumber', isEqualTo: idNumber)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Update complaint status
  Future<bool> updateComplaintStatus(String complaintId, String status) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error updating complaint status: $e');
      return false;
    }
  }

  // Add reply to complaint
  Future<bool> addReply(String complaintId, String reply, String repliedBy) async {
    try {
      final replyData = {
        'message': reply,
        'repliedBy': repliedBy,
        'repliedAt': Timestamp.now(),
      };

      await _firestore.collection('complaints').doc(complaintId).update({
        'replies': FieldValue.arrayUnion([replyData]),
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Error adding reply: $e');
      return false;
    }
  }

  // Delete complaint
  Future<bool> deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).delete();
      return true;
    } catch (e) {
      print('Error deleting complaint: $e');
      return false;
    }
  }

  // Delete attachment from storage (optional cleanup)
  Future<void> deleteAttachment(String fileUrl) async {
    try {
      if (fileUrl.isNotEmpty) {
        final ref = _storage.refFromURL(fileUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting attachment: $e');
    }
  }
}