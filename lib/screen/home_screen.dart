import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  String result = 'none';
  String imageResult = 'none';
  bool isVisible = false; // Used for controlling opacity in animations

  // Initialize the AnimationController and Animation
  late AnimationController _controller;

  predictGender(String name) async {
    var url = Uri.parse('https://api.genderize.io/?name=$name');
    var response = await http.get(url);
    var body = json.decode(response.body);

    setState(() {
      result = 'Gender: ${body['gender']}';
      imageResult = '${body['gender']}';
      isVisible = true; // Set visibility to true to trigger the animation
      _controller.forward(from: 0); // Restart the animation
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Duration of the animation
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Light background color
        appBar: AppBar(
          title: const Text('GenderGenie'),
          backgroundColor: Colors.teal.shade600, // AppBar color
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heading
              const Text(
                'Enter a Name to Predict Gender',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Name input field with better styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade100,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  maxLength: 15,
                  style: const TextStyle(
                      color: Colors.black), // Change input text color to black
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                    hintText: 'Enter a name',
                    hintStyle: TextStyle(color: Colors.teal.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Predict button with better color and animation
              ElevatedButton(
                onPressed: () => predictGender(_nameController.text),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  shadowColor: Colors.teal.shade200,
                ),
                child: const Text(
                  'Predict',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),

              // Error message or result display with animation
              AnimatedOpacity(
                opacity: _nameController.text.isEmpty ? 0 : 1,
                duration: const Duration(milliseconds: 600),
                child: _nameController.text.isEmpty
                    ? const Text(
                        'Please enter a name.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      )
                    : FadeTransition(
                        opacity: _controller,
                        child: Column(
                          children: [
                            Text(
                              result,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Display gender image with fade effect
                            imageResult == 'none'
                                ? Container()
                                : imageResult == 'male'
                                    ? SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Image.asset(
                                          'assets/images/male.png',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Image.asset(
                                          'assets/images/female.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
