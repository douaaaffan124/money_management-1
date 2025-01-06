import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiveScreen extends StatefulWidget {
  final String userId; // The current user's ID

  const ReceiveScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late Future<List<Map<String, dynamic>>> receivedTransactions;

  Future<List<Map<String, dynamic>>> fetchReceivedTransactions() async {
    try {
      final response = await http.get(Uri.parse(
          'http://adcsci410.atwebpages.com/fetch_receive.php?user_id=${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return [];
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    receivedTransactions = fetchReceivedTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Received Transactions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: receivedTransactions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        "From: ${transaction['sender_name']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "Amount: ${transaction['amount']} ${transaction['currency']}"),
                      leading: CircleAvatar(
                        child: Text(transaction['sender_name'][0]),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text(
                "No received transactions.",
                style: TextStyle(fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }
}
