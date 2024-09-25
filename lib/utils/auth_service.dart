import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milan_hackathon/models/chat.dart';
import 'package:milan_hackathon/models/message.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        log('Google sign-in aborted by user');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await _auth.signInWithCredential(credentials);
      final user = userCredential.user;

      String branch = '';
      String year = '';

      if (user != null &&
          user.email != null &&
          user.email!.endsWith('@iith.ac.in')) {
        branch = user.email!.substring(0, 2);
        year = user.email!.substring(2, 4);
      }

      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          final newUser = user_model.User(
            name: user.displayName ?? '',
            email: user.email ?? '',
            profilePhoto: user.photoURL ?? '',
            branch: branch,
            year: year,
          );
          await userDoc.set(newUser.toMap());
        }
      }

      return userCredential;
    } catch (e) {
      log('Error during Google sign-in: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      log("Something went wrong: $e");
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserProfiles() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();
    
    return _firestore
        .collection('users')
        .where('email', isNotEqualTo: currentUser.email)
        .snapshots();
  }

  Future<bool> checkChatExists(String email1, String email2) async {
    final participants = [email1, email2]..sort();
    final chatDoc = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .get();
    return chatDoc.docs.isNotEmpty;
  }

  Future<Chat> fetchChats(String email1, String email2) async {
    final participants = [email1, email2]..sort();
    final chatDoc = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .get();
    if (chatDoc.docs.isNotEmpty) {
      final chat = chatDoc.docs.first;
      return Chat.fromJson(chat.data());
    } else {
      log('No chat found for participants: $participants');
      await _firestore.collection('chats').add({
        'participants': participants,
        'messages': [],
      });
      return Chat(participants: participants, messages: []);
    }
  }

  Future<user_model.User?> getUserData(String email) async {
    log('Fetching user data for email: $email'); // Debugging log
    final userDoc = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('Firestore query completed. Number of documents found: ${userDoc.docs.length}'); // Debugging log
    if (userDoc.docs.isNotEmpty) {
      final user = userDoc.docs.first;
      log('User data found: ${user.data()}'); // Debugging log
      return user_model.User.fromMap(user.data());
    } else {
      log('No user data found for email: $email'); // Debugging log

      // Fetch all users and log their emails for debugging
      final allUsers = await _firestore.collection('users').get();
      for (var doc in allUsers.docs) {
        log('Stored user email: ${doc.data()['email']}'); // Debugging log
      }

      return null;
    }
  }

  Future<void> sendMessage(Message message) async {
    final chatDoc = await _firestore.collection('chats').where('participants', isEqualTo: [message.receiverEmail, message.senderEmail]..sort()).get();
    if (chatDoc.docs.isNotEmpty) {
      final chat = chatDoc.docs.first;
      final chatId = chat.id;
      await _firestore.collection('chats').doc(chatId).update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
      });
    } else {
      log('No chat found for participants: ${[message.receiverEmail, message.senderEmail]}');
    }
  }

  Stream<Chat?> getChatData(String senderEmail, String receiverEmail) {
    final participants = [senderEmail, receiverEmail]..sort();

    return _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            log('Chat data found for participants: $participants');
            final doc = snapshot.docs.first;
            final data = doc.data() as Map<String, dynamic>; // Convert to Map<String, dynamic>
            return Chat.fromJson(data); // Convert the map to a Chat model
          } else {
            log('No chat data found for participants: $participants');
            _firestore.collection('chats').add({
              'participants': participants,
              'messages': [],
            });
            return null;
          }
        });
  }
}