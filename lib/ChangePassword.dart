import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePassword extends StatefulWidget {
  final String userId;

  const ChangePassword({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePassword> createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  Color defaultFieldColor = Colors.black54;
  Color errorColor = Colors.red;
  Color labelColor = Colors.black54; // Define separate color for label text

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> validateCurrentPassword() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection("UserRegistration")
        .doc(widget.userId)
        .get();

    Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
    return data['Password'] == currentPasswordController.text;
  }

  bool validatePassword(String password) {
    if (password.length < 6) {
      newPasswordError = "Password must be at least 6 characters long";
      return false;
    }

    bool hasAlphabet = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumeric = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasAlphabet) {
      newPasswordError = "Password must contain at least 1 alphabet";
      return false;
    }
    if (!hasNumeric) {
      newPasswordError = "Password must contain at least 1 numeric character";
      return false;
    }
    if (!hasSpecialChar) {
      newPasswordError = "Password must contain at least 1 special character";
      return false;
    }

    return true;
  }

  void validateForm() async {
    bool isCurrentPasswordValid = await validateCurrentPassword();
    bool isNewPasswordValid = validatePassword(newPasswordController.text);
    bool isConfirmPasswordValid =
        newPasswordController.text == confirmPasswordController.text;

    setState(() {
      currentPasswordError =
          isCurrentPasswordValid ? null : "Invalid current password";
      newPasswordError = isNewPasswordValid ? null : newPasswordError;
      confirmPasswordError = isConfirmPasswordValid
          ? null
          : "New password and confirm password do not match";
    });

    if (isCurrentPasswordValid &&
        isNewPasswordValid &&
        isConfirmPasswordValid) {
      // Perform password change operation
      changePassword();
    }
  }

  Future<void> showConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Password Changed"),
          content: const Text("Password changed successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Pop dialog and change password page
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword() async {
    String newPassword = newPasswordController.text;

    try {
      // Update password in Firestore
      await FirebaseFirestore.instance
          .collection("UserRegistration")
          .doc(widget.userId)
          .update({'Password': newPassword});

      // Show success message or toast indicating password change success
      showConfirmationDialog();
    } catch (error) {
      // Show error message or toast indicating password change failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Change Password'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: !_showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: labelColor), // Apply label color
                  errorText: currentPasswordError,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: defaultFieldColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: currentPasswordError != null
                            ? errorColor
                            : defaultFieldColor),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                    icon: Icon(_showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    currentPasswordError = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: labelColor), // Apply label color
                  errorText: newPasswordError,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: defaultFieldColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: newPasswordError != null
                            ? errorColor
                            : defaultFieldColor),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                    icon: Icon(_showNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    newPasswordError = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: labelColor), // Apply label color
                  errorText: confirmPasswordError,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: defaultFieldColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: confirmPasswordError != null
                            ? errorColor
                            : defaultFieldColor),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    confirmPasswordError = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validateForm,
                child: const Text('Change Password'),
              ),
            ],
          ),
        ));
  }
}
