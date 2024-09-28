import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  String result = 'none';
  String imageResult = 'none';
  bool isVisible = false;

  late AnimationController _controller;

  predictGender(String name) async {
    var url = Uri.parse('https://api.genderize.io/?name=$name');
    var response = await http.get(url);
    var body = json.decode(response.body);

    setState(() {
      result = 'Gender: ${body['gender']}';
      imageResult = '${body['gender']}';
      isVisible = true;
      _controller.forward(from: 0);
    });
  }

  LinearGradient getGradient() {
    if (imageResult == 'male') {
      return LinearGradient(
        colors: [Colors.lightBlueAccent, Colors.blueAccent.shade200],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (imageResult == 'female') {
      return LinearGradient(
        colors: [Colors.pinkAccent.shade100, Colors.pinkAccent.shade200],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [Colors.teal.shade600, Colors.cyan.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: getGradient(),
              ),
            ),
            elevation: 10,
            shadowColor: Colors.teal.shade200,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.person_search_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Gender Predictor',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder( // Use LayoutBuilder for responsive design
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox( // Ensure all widgets fit within constraints
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight( // Adjust height of inner column
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.shade100,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _nameController,
                            maxLength: 15,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear, color: Colors.teal.shade700),
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() {
                                    result = 'none';
                                    imageResult = 'none';
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => predictGender(_nameController.text),
                          child: const Text(
                            'Predict',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal.shade700,
                            onPrimary: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            shadowColor: Colors.teal.shade200,
                          ),
                        ),
                        const SizedBox(height: 30),
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
                        const Spacer(), // Use Spacer to occupy any remaining space
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
