import 'package:flutter/material.dart';
import 'package:fluttertest/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimatedSignupImage extends StatefulWidget {
  const AnimatedSignupImage({Key? key}) : super(key: key);

  @override
  _AnimatedSignupImageState createState() => _AnimatedSignupImageState();
}

class _AnimatedSignupImageState extends State<AnimatedSignupImage>
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
          child: Container(
            child: const Image(
              image: AssetImage('images/SignUp.jpg'),
              height: 400,
              width: 400,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => SignupState();
}

class SignupState extends State<Signup> {
  int _userCount = 0; // Variable to hold the current user count

  @override
  void initState() {
    super.initState();
    _getUserCount(); // Fetch initial user count from database
  }

  // Method to fetch the current user count from the database
  Future<void> _getUserCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("UserRegistration").get();
    setState(() {
      _userCount = querySnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController countryController = TextEditingController();

    final ButtonStyle style2 = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
      backgroundColor: const Color.fromARGB(255, 137, 0, 155),
      foregroundColor: const Color.fromARGB(255, 238, 236, 238),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup Page"),
      ),
      body: Center(
        child: Column(
          children: [
            const AnimatedSignupImage(), // Include the AnimatedSignupImage widget
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  TextField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      labelText: "Country",
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: style2,
              onPressed: () async {
                CollectionReference tab =
                    FirebaseFirestore.instance.collection("UserRegistration");
                String email = emailController.text;

                // Check if the email already exists
                QuerySnapshot emailSnapshot =
                    await tab.where('Email', isEqualTo: email).get();

                if (emailSnapshot.docs.isNotEmpty) {
                  // Email already exists
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Email Exists'),
                        content: const Text(
                            'The provided email is already registered. Please use a different email.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Email doesn't exist, proceed with registration
                  _userCount++; // Increment user count
                  await tab.doc('$_userCount').set({
                    // Use user count as ID
                    'FirstName': firstNameController.text,
                    'LastName': lastNameController.text,
                    'Email': emailController.text,
                    'Password': passwordController.text,
                    'Country': countryController.text,
                  });
                  // Registration successful, redirect to login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                }
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
