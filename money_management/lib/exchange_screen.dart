import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeScreen extends StatefulWidget {
  final String userId;

  const ExchangeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  late Future<List<Map<String, dynamic>>> users;
  late Future<Map<String, dynamic>> accountInfo;
  late Future<List<Map<String, dynamic>>> receivedTransfers;
  String selectedUserId = '';
  final TextEditingController dateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://adcsci410.atwebpages.com/fetch_users.php'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data is List ? List<Map<String, dynamic>>.from(data) : [];
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<Map<String, dynamic>> fetchAccountInfo() async {
    final response = await http.get(Uri.parse(
        'http://adcsci410.atwebpages.com/fetchaccountinfo.php?id=${widget.userId}'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data.first;
      }
      return {'message': 'No account info found'};
    } else {
      throw Exception('Failed to load account info');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReceivedTransfers() async {
    final response = await http.get(Uri.parse(
        'http://adcsci410.atwebpages.com/fetch_receive.php?user_id=${widget.userId}'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data is List ? List<Map<String, dynamic>>.from(data) : [];
    } else {
      throw Exception('Failed to load received transfers');
    }
  }

  Future<void> transfer() async {
    final date = dateController.text.trim();
    final amount = amountController.text.trim();
    final currency = currencyController.text.trim();

    if (date.isEmpty ||
        amount.isEmpty ||
        currency.isEmpty ||
        selectedUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://adcsci410.atwebpages.com/add_transfer.php'),
        body: {
          'sender_id': widget.userId,
          'receiver_id': selectedUserId,
          'date': date,
          'amount': amount,
          'currency': currency,
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          responseData['message'] == "Transfer successful") {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transfer successful')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(responseData['message'] ?? 'Transfer failed')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
    accountInfo = fetchAccountInfo();
    receivedTransfers = fetchReceivedTransfers();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exchange Dashboard'),
          backgroundColor: Colors.blueAccent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Transfer', icon: Icon(Icons.send)),
              Tab(text: 'Received', icon: Icon(Icons.download)),
              Tab(text: 'Account Info', icon: Icon(Icons.info)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(  
              future: users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final userList = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          value: selectedUserId.isEmpty ? null : selectedUserId,
                          hint: const Text('Select recipient'),
                          onChanged: (value) {
                            setState(() {
                              selectedUserId = value!;
                            });
                          },
                          items: userList.map((user) {
                            return DropdownMenuItem<String>(
                              value: user['id'].toString(),
                              child: Text(user['name']),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            hintText: 'Enter transfer date',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            hintText: 'Enter currency (USD/LBP)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: transfer,
                          child: const Text('Transfer'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No users available'));
              },
            ),
            FutureBuilder<List<Map<String, dynamic>>>(  
              future: receivedTransfers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final transfers = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: transfers.length,
                    itemBuilder: (context, index) {
                      final transfer = transfers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${transfer['date']}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Amount: ${transfer['amount']} ${transfer['currency']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                    child: Text('No received transfers available'));
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: accountInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final account = snapshot.data!;
                  if (account.containsKey('message')) {
                    return Center(
                        child: Text(account['message'] ?? 'No data available'));
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Name: ${account['name']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Account Balance (USD): ${account['balance_usd']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Account Balance (LBP): ${account['balance_lbp']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No account info available'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
