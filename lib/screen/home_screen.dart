import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import provider package

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ThemeNotifier to manage theme state
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

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
  bool isVisible = false;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _curvedAnimation;

  predictGender(String name) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('https://api.genderize.io/?name=$name');
    var response = await http.get(url);
    var body = json.decode(response.body);

    setState(() {
      result = body['gender'] != null
          ? 'Gender: ${body['gender']}'
          : 'Gender could not be predicted';
      imageResult = body['gender'] ?? 'both'; // Use 'both' to show both images
      isVisible = true;
      isLoading = false;
      _controller.forward(from: 0);
    });
  }

  LinearGradient getGradient(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (themeNotifier.isDarkMode) {
      // Different gradient for dark mode
      return LinearGradient(
        colors: [Colors.grey.shade800, Colors.black87],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (imageResult == 'male') {
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

    // Applying a different curve to your animation
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: getGradient(context),
              ),
            ),
            elevation: 10,
            shadowColor: Colors.teal.shade200,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Gender Genie',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: getGradient(context),
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
                                fontFamily: 'Roboto',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Input Field Container
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: themeNotifier.isDarkMode
                                    ? Colors.grey.shade800.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 12,
                                    offset: Offset(
                                        0, 6), // Controls shadow positioning
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      maxLength: 15,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        hintText: 'Enter a name',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500),
                                        prefixIcon: const Icon(Icons.person,
                                            color: Colors.teal),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear,
                                        color: Colors.teal.shade700),
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
                              onPressed: () =>
                                  predictGender(_nameController.text),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.teal.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20), // More rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 16),
                                elevation: 8, // Enhanced shadow effect
                              ),
                              child: const Text(
                                'Predict',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Show loading indicator if fetching data
                            if (isLoading)
                              const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            else
                              AnimatedOpacity(
                                opacity: _nameController.text.isEmpty ? 0 : 1,
                                duration: const Duration(milliseconds: 600),
                                child: _nameController.text.isEmpty
                                    ? const Text(
                                        'Please enter a name.',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.red),
                                      )
                                    : SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: const Offset(0, 0),
                                        ).animate(_curvedAnimation),
                                        child: ScaleTransition(
                                          scale: _curvedAnimation,
                                          child: FadeTransition(
                                            opacity: _curvedAnimation,
                                            child: Column(
                                              children: [
                                                Text(
                                                  result,
                                                  style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                if (imageResult == 'both')
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors
                                                                .teal.shade700,
                                                            width: 4,
                                                          ),
                                                        ),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            'assets/images/male.png',
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors
                                                                .pinkAccent
                                                                .shade200,
                                                            width: 4,
                                                          ),
                                                        ),
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            'assets/images/female.png',
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (imageResult == 'male')
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors
                                                            .teal.shade700,
                                                        width: 4,
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/male.png',
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                else if (imageResult ==
                                                    'female')
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.pinkAccent
                                                            .shade200,
                                                        width: 4,
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/female.png',
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            const Spacer(),
                            // Footer Text or any additional information
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
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
