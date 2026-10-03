import 'package:flutter/material.dart';
import 'USCS.dart';  // Import USCS classification page
import 'AASHTO.dart';  // Import AASHTO classification page
import 'USDA.dart';  // Import USDA classification page

void main() {
  runApp(const GaeaApp());
}

class GaeaApp extends StatelessWidget {
  const GaeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaea: Soil Classification',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF87705c, // Brown shade (#87705c)
          <int, Color>{
            50: Color(0xFF87705c),
            100: Color(0xFF87705c),
            200: Color(0xFF87705c),
            300: Color(0xFF87705c),
            400: Color(0xFF87705c),
            500: Color(0xFF87705c),
            600: Color(0xFF87705c),
            700: Color(0xFF87705c),
            800: Color(0xFF87705c),
            900: Color(0xFF87705c),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFFD3D3D3), // Light ash background
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildClassificationCard(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gaea: The Soil Classification App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White title text for contrast
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF87705c), // Brown app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Instructions: Choose one of the classification systems below to classify your soil sample according to USDA, AASHTO, or USCS standards.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal, // Normal weight for the text
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildClassificationCard(
              context,
              title: "USCS Classification",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => USCSPage()),
                );
              },
            ),
            _buildClassificationCard(
              context,
              title: "AASHTO Classification",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AASHTOPage()),
                );
              },
            ),
            _buildClassificationCard(
              context,
              title: "USDA Classification",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => USDAPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
