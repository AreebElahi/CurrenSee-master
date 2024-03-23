import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertest/ChangePassword.dart';

class AccountSettings extends StatefulWidget {
  final String userId;

  const AccountSettings({Key? key, required this.userId}) : super(key: key);

  @override
  State<AccountSettings> createState() => AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data
    getUserData();
  }

  Future<void> getUserData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection("UserRegistration")
        .doc(widget.userId)
        .get();

    Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
    setState(() {
      firstNameController.text = data['FirstName'];
      lastNameController.text = data['LastName'];
      emailController.text = data['Email'];
      passwordController.text = data['Password'];
      countryController.text = data['Country'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: "Country"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("UserRegistration")
                      .doc(widget.userId)
                      .update({
                    'FirstName': firstNameController.text,
                    'LastName': lastNameController.text,
                    'Email': emailController.text,
                    'Password': passwordController.text,
                    'Country': countryController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data updated successfully')),
                  );
                },
                child: const Text('Update'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangePassword(userId: widget.userId),
                    ),
                  );
                },
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
