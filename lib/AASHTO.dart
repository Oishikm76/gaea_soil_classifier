import 'package:flutter/material.dart';

class AASHTOPage extends StatefulWidget {
  const AASHTOPage({super.key});

  @override
  _AASHTOPageState createState() => _AASHTOPageState();
}

class _AASHTOPageState extends State<AASHTOPage> {
  final TextEditingController _llController = TextEditingController();
  final TextEditingController _piController = TextEditingController();
  final TextEditingController _pass10Controller = TextEditingController();
  final TextEditingController _pass40Controller = TextEditingController();
  final TextEditingController _pass200Controller = TextEditingController();

  String _classificationResult = '';
  String _giResult = '';
  String _warningMessage = '';

  // AASHTO classification logic
  String aashtoClassify(double ll, double pi, double pass10, double pass40, double pass200) {
    if (pass200 <= 35) {
      if (pass200 <= 15 && pass10 <= 50 && pass40 <= 30 && pi <= 6) {
        return "A-1-a";
      } else if (pass200 <= 25 && pass40 <= 50 && pi <= 6) {
        return "A-1-b";
      } else if (pass200 <= 10 && pass40 >= 51) {
        return "A-3";
      } else if (pass200 <= 35) {
        if (ll <= 40 && pi <= 10) {
          return "A-2-4";
        } else if (ll >= 41 && pi <= 10) {
          return "A-2-5";
        } else if (ll <= 40 && pi > 10) {
          return "A-2-6";
        } else if (ll >= 41 && pi > 10) {
          return "A-2-7";
        }
      }
    } else {
      if (ll <= 40 && pi <= 10) {
        return "A-4";
      } else if (ll >= 41 && pi <= 10) {
        return "A-5";
      } else if (ll <= 40 && pi > 10) {
        return "A-6";
      } else if (ll >= 41 && pi > 10) {
        if (pi <= ll - 30) {
          return "A-7-5";
        } else {
          return "A-7-6";
        }
      }
    }
    return "Unclassified";
  }

  // Calculate the GI based on classification
  double calculateGI(String classification, double pass200, double ll, double pi) {
    double gi = 0;
    if (classification == "A-1-a" || classification == "A-1-b" || classification == "A-2-4" || classification == "A-2-5" || classification == "A-3" || classification == "Unclassified") {
      gi = 0;
    } else if (classification == "A-2-6" || classification == "A-2-7") {
      gi = (0.01 * (pass200 - 15) * (pi - 10)).roundToDouble();
    } else {
      gi = (pass200 - 35) * (0.2 + 0.005 * (ll - 40)) + 0.01 * (pass200 - 15) * (pi - 10);
      gi = gi.roundToDouble();
    }
    return gi < 0 ? 0 : gi;
  }

  // Function to handle classification on button press
  void classifySoil() {
    double? ll = double.tryParse(_llController.text);
    double? pi = double.tryParse(_piController.text);
    double? pass10 = double.tryParse(_pass10Controller.text);
    double? pass40 = double.tryParse(_pass40Controller.text);
    double? pass200 = double.tryParse(_pass200Controller.text);

    if (ll == null || pi == null || pass10 == null || pass40 == null || pass200 == null) {
      setState(() {
        _classificationResult = '';
        _giResult = '';
        _warningMessage = '❌ Error: Please provide all the required inputs.';
      });
      return;
    }

    String classification = aashtoClassify(ll, pi, pass10, pass40, pass200);
    double gi = calculateGI(classification, pass200, ll, pi);

    setState(() {
      _classificationResult = "✅ The AASHTO soil classification is: $classification";
      _giResult = "GI: $gi";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AASHTO Soil Classification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, 
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF87705c), // Brown app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Input fields and buttons below the heading
              _buildInputField('Enter Liquid Limit (LL):', _llController),
              _buildInputField('Enter Plasticity Index (PI):', _piController),
              _buildInputField('Enter % passing No. 10 sieve:', _pass10Controller),
              _buildInputField('Enter % passing No. 40 sieve:', _pass40Controller),
              _buildInputField('Enter % passing No. 200 sieve:', _pass200Controller),

              // Button to trigger soil classification
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: classifySoil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF87705c), // Dark brown button color
                    foregroundColor: Colors.white, // White text color on button
                  ),
                  child: const Text('Classify Soil'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _warningMessage,
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 16),
              Text(
                _classificationResult,
                style: const TextStyle(fontSize: 16),
              ),
              if (_giResult.isNotEmpty)
                Text(
                  _giResult,
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white, // White colored input field
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
