import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final String authProvider;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.authProvider = 'email',
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      authProvider: data['authProvider'] ?? 'email',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'fullName': fullName,
    'photoUrl': photoUrl,
    'phoneNumber': phoneNumber,
    'isEmailVerified': isEmailVerified,
    'authProvider': authProvider,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}