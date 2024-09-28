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
  bool isLoading = false;

  late AnimationController _controller;

  predictGender(String name) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('https://api.genderize.io/?name=$name');
    var response = await http.get(url);
    var body = json.decode(response.body);

    setState(() {
      result = body['gender'] != null ? 'Gender: ${body['gender']}' : 'Gender could not be predicted';
      imageResult = body['gender'] ?? 'both'; // Use 'both' to show both images
      isVisible = true;
      isLoading = false;
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
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: getGradient(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Enter a Name to Predict Gender',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Input Field Container
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      maxLength: 15,
                                      style: const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        hintText: 'Enter a name',
                                        hintStyle: TextStyle(color: Colors.teal),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, color: Colors.teal.shade700),
                                    onPressed: () {
                                      _nameController.clear();
                                      setState(() {
                                        result = 'none';
                                        imageResult = 'none';
                                      });
                                    },
                                  ),
                                ],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                shadowColor: Colors.teal.shade200,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Show loading indicator if fetching data
                            if (isLoading)
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            else
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
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Show both images if gender is null
                                            if (imageResult == 'both')
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 150,
                                                    width: 150,
                                                    child: Image.asset(
                                                      'assets/images/male.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  SizedBox(
                                                    height: 150,
                                                    width: 150,
                                                    child: Image.asset(
                                                      'assets/images/female.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else if (imageResult == 'male')
                                              SizedBox(
                                                height: 150,
                                                width: 150,
                                                child: Image.asset(
                                                  'assets/images/male.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            else if (imageResult == 'female')
                                              SizedBox(
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
                            const Spacer(),
                            // Footer Text or any additional information
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Powered by Genderize API',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
