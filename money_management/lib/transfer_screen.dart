import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isUSD = false; // Default currency is LBP

  void performTransfer() {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String id = idController.text.trim();
    String amount = amountController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || id.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    String currency = isUSD ? "USD" : "LBP";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Transfer Successful: $amount $currency to $firstName $lastName (ID: $id)."),
      ),
    );

    // Clear all fields after successful transfer
    firstNameController.clear();
    lastNameController.clear();
    idController.clear();
    amountController.clear();

    setState(() {
      isUSD = false; // Reset currency to default
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    idController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: isUSD,
                  onChanged: (value) {
                    setState(() {
                      isUSD = value!;
                    });
                  },
                ),
                Text("Transfer in USD (default is LBP)"),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: performTransfer,
              child: Text("Transfer"),
            ),
          ],
        ),
      ),
    );
  }
}