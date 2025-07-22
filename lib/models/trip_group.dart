// lib/models/trip_group.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TripGroup {
  final String id;
  final String groupName;
  final String location; // <-- FIELD ADDED
  final String adminUid;
  final List<String> members;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final String tripType;
  final String inviteCode;

  TripGroup({
    required this.id,
    required this.groupName,
    required this.location, // <-- FIELD ADDED
    required this.adminUid,
    required this.members,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    required this.tripType,
    required this.inviteCode,
  });

  factory TripGroup.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripGroup(
      id: doc.id,
      groupName: data['groupName'] ?? '',
      location: data['location'] ?? '', // <-- FIELD ADDED
      adminUid: data['adminUid'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      startDate: (data['startDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      endDate: (data['endDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      totalBudget: (data['totalBudget'] ?? 0.0).toDouble(),
      tripType: data['tripType'] ?? 'Leisure',
      inviteCode: data['inviteCode'] ?? '',
    );
  }
}