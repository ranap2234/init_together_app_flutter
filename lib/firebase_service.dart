import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseService();

  Future<String> LoginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        return "success";
      } else {
        return "failure";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "user not found";
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user';
      } else {
        return "failure";
      }
    }}

  Future<String> CreateUser({required String name,
    required String email,
    required String userType,
    required String password}) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      String userId = userCredential.user!.uid;
      await _db.collection('users').doc(userId).set({
        "fullName": name,
        "email": email,
        "userType": userType,
      });
      if (userType == "student") {
        await _db.collection('students').doc(userId).set({
          "name": name,
        });} else if (userType == 'parent') {
          await _db.collection('parents').doc(userId).set({
            "name": name,
          });}
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
      return e.code;
    }
  }}}