import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertest/Converter.dart';

class BouncingImage extends StatefulWidget {
  const BouncingImage({Key? key}) : super(key: key);

  @override
  _BouncingImageState createState() => _BouncingImageState();
}

class _BouncingImageState extends State<BouncingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Define position (translation) animation
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0, // Adjust this value to control the bounce height
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Set up a repeating bounce animation
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0.0, _positionAnimation.value),
          child: child,
        );
      },
      child: const Image(
        image: AssetImage('images/Login.jpg'), // Adjust the path accordingly
        height: 400,
        width: 400,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController useremailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style2 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
      backgroundColor: const Color.fromARGB(255, 137, 0, 155),
      foregroundColor: const Color.fromARGB(255, 238, 236, 238),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Center(
        child: Column(
          children: [
            const BouncingImage(),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: useremailController,
                    decoration: const InputDecoration(
                      labelText: "User Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: style2,
              onPressed: () {
                getUserData(useremailController.text);
              },
              child: const Text("LOGIN"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void getUserData(String useremail) {
    FirebaseFirestore.instance
        .collection('UserRegistration')
        .where('Email', isEqualTo: useremail)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size > 0) {
        // Email found in database, get the unique ID of the user document
        String userId = querySnapshot.docs.first.id;
        // Navigate to Converter page with the user ID
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Converter(userEmail: useremail, userId: userId)),
        );
      } else {
        // Email not found in database, show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Email Incorrect"),
              content: const Text("The provided email is not registered."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: Login(),
  ));
}
