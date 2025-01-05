import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:money_management/exchange_screen.dart';

class Addaccount extends StatefulWidget {
  final String userId;
  const Addaccount({super.key, required this.userId});

  @override
  State<Addaccount> createState() => _AddaccountState();
}

class _AddaccountState extends State<Addaccount> {
  final TextEditingController lbpController = TextEditingController();
  final TextEditingController usdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void redirectToExchangeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExchangeScreen(userId: widget.userId),
      ),
    );
  }

  Future<void> saveAccount() async {
    if (_formKey.currentState!.validate()) {
      String lbpAmount = lbpController.text.trim();
      String usdAmount = usdController.text.trim();

      try {
        var response = await http.post(
          Uri.parse('http://adcsci410.atwebpages.com/addaccount.php'),
          body: {
            'user_id': widget.userId,
            'balance_usd': usdAmount,
            'balance_lbp': lbpAmount,
          },
        );

        var result = jsonDecode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200) {
          if (result['status'] == 'success') {
            redirectToExchangeScreen();
          } else if (result['status'] == 'account_exists') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExchangeScreen(userId: widget.userId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result['message'] ?? 'Failed to save account')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save account')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      lbpController.clear();
      usdController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Account'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Account Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              TextFormField(
                controller: lbpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Balance in LBP',
                  hintText: 'Enter amount in LBP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: usdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Balance in USD',
                  hintText: 'Enter amount in USD',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveAccount,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Account',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
