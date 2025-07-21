// lib/models/expense.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy; // User's name
  final Timestamp createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}