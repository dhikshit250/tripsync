// lib/screens/expenses_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsync/models/trip_group.dart';
import 'package:tripsync/models/expense.dart';

class ExpensesScreen extends StatefulWidget {
  final TripGroup group;

  const ExpensesScreen({super.key, required this.group});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Expense", style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount (₹)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addExpense(descriptionController.text, amountController.text);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addExpense(String description, String amount) {
    if (description.trim().isEmpty || amount.trim().isEmpty || currentUser == null) {
      return;
    }

    final double? amountValue = double.tryParse(amount);
    if (amountValue == null) return;

    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.id)
        .collection('expenses')
        .add({
      'description': description,
      'amount': amountValue,
      'paidBy': currentUser!.displayName ?? 'Anonymous',
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expenses", style: GoogleFonts.poppins()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.group.id)
            .collection('expenses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No expenses till now.",
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }

          final expenses = snapshot.data!.docs.map((doc) => Expense.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Paid by ${expense.paidBy}"),
                  trailing: Text(
                    "₹${expense.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}