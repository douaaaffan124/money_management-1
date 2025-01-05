import 'package:flutter/material.dart';

class ReceiveScreen extends StatelessWidget {
  final List<Map<String, String>> receivedTransactions = [
    {"name": "John", "amount": "200 USD"},
    {"name": "Jane", "amount": "150 EUR"},
    {"name": "Alex", "amount": "300 LBP"},
    {"name": "Emma", "amount": "500 CAD"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Received Transactions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: receivedTransactions.isNotEmpty
            ? ListView.builder(
          itemCount: receivedTransactions.length,
          itemBuilder: (context, index) {
            final transaction = receivedTransactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                title: Text(
                  "From: ${transaction['name']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Amount: ${transaction['amount']}"),
                leading: CircleAvatar(
                  child: Text(transaction['name']![0]),
                ),
              ),
            );
          },
        )
            : Center(
          child: Text(
            "No received transactions.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}