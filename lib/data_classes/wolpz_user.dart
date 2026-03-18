import 'package:cloud_firestore/cloud_firestore.dart';

class WolpzUser {
  final String userID;
  final String firstName;
  final String lastName;
  final String email;
  final int? freeUsesRemaining;
  bool isSubscribed;
  final String? registeredDeviceId;

  WolpzUser({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.freeUsesRemaining,
    required this.isSubscribed,
    this.registeredDeviceId,
  });

  Map<String, Object?> toJson() {
    return {
      'userID': userID,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isSubscribed': isSubscribed,
      'registeredDeviceId': registeredDeviceId,
    };
  }

  factory WolpzUser.fromJson(Map<String, dynamic> doc) {
    WolpzUser user = WolpzUser(
      userID: doc['userID'] as String? ?? '',
      firstName: doc['firstName'] as String? ?? '',
      lastName: doc['lastName'] as String? ?? '',
      email: doc['email'] as String? ?? '',
      freeUsesRemaining: (doc['freeUsesRemaining'] as num?)?.toInt() ?? 0,
      isSubscribed: doc['isSubscribed'] as bool? ?? false,


    );
    return user;
  }

  factory WolpzUser.fromDocument(DocumentSnapshot doc) {
    return WolpzUser.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'VoicedUser(name: $firstName, email: $email)';
  }
}
