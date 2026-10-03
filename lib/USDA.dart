import 'package:flutter/material.dart';

class USDAPage extends StatefulWidget {
  const USDAPage({super.key});

  @override
  _USDAPageState createState() => _USDAPageState();
}

class _USDAPageState extends State<USDAPage> {
  final TextEditingController _sandController = TextEditingController();
  final TextEditingController _clayController = TextEditingController();
  final TextEditingController _gravelController = TextEditingController();

  String _classificationResult = '';
  String _warningMessage = '';

  // USDA soil classification function
  String classifySoilUSDA(double sand, double silt, double clay, double gravel) {
    if (sand + silt + clay + gravel != 100) {
      return "Invalid percentages: they should add up to 100";
    }

    // Sands
    if (sand > 85 && (silt + 1.5 * clay) < 15) {
      return "Sand";
    }

    // Loamy sands
    if (70 <= sand && sand <= 91 && (silt + 1.5 * clay) >= 15 && (silt + 2 * clay) < 30) {
      return "Loamy sand";
    }

    // Sandy loams
    if ((7 <= clay && clay <= 20 && sand > 52 && (silt + 2 * clay) >= 30) || (clay < 7 && silt < 50 && sand > 43)) {
      return "Sandy loam";
    }

    // Loam
    if (7 <= clay && clay <= 27 && 28 <= silt && silt <= 50 && sand <= 52) {
      return "Loam";
    }

    // Silt loam
    if ((silt >= 50 && 12 <= clay && clay <= 27) || (50 <= silt && silt <= 80 && clay < 12)) {
      return "Silt loam";
    }

    // Silt
    if (silt >= 80 && clay < 12) {
      return "Silt";
    }

    // Sandy clay loam
    if (20 <= clay && clay <= 35 && silt < 28 && sand > 45) {
      return "Sandy clay loam";
    }

    // Clay loam
    if (27 <= clay && clay <= 40 && 20 < sand && sand <= 46) {
      return "Clay loam";
    }

    // Silty clay loam
    if (27 <= clay && clay <= 40 && sand <= 20) {
      return "Silty clay loam";
    }

    // Sandy clay
    if (clay >= 35 && sand >= 45) {
      return "Sandy clay";
    }

    // Silty clay
    if (clay >= 40 && silt >= 40) {
      return "Silty clay";
    }

    // Clay
    if (clay >= 40 && sand <= 45 && silt < 40) {
      return "Clay";
    }

    return "Not classified";
  }

  // Convert and classify the soil based on input values
  void classifySoil() {
    double? sand = double.tryParse(_sandController.text);
    double? clay = double.tryParse(_clayController.text);
    double? gravel = double.tryParse(_gravelController.text);

    if (sand == null || clay == null || gravel == null) {
      setState(() {
        _classificationResult = '';
        _warningMessage = '❌ Error: Please provide all the required inputs.';
      });
      return;
    }

    // Adjust the sand, clay, and silt percentages based on gravel
    double adjustedSand = (sand * 100) / (100 - gravel);
    double adjustedClay = (clay * 100) / (100 - gravel);
    double silt = 100 - adjustedSand - adjustedClay - gravel;

    String soilType = classifySoilUSDA(adjustedSand, silt, adjustedClay, gravel);

    setState(() {
      if (gravel == 0) {
        _classificationResult = "✅ The soil type is: $soilType";
      } else {
        _classificationResult = "✅ The soil type is: Gravelly $soilType";
      }
      _warningMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'USDA Soil Classification',
          style: TextStyle(
            fontWeight: FontWeight.bold,  // Bold title
            color: Colors.white,          // White title text for contrast
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF87705c),  // Brown app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Sand Input
              _buildInputField('Enter percentage of Sand:', _sandController),
              // Clay Input
              _buildInputField('Enter percentage of Clay:', _clayController),
              // Gravel Input
              _buildInputField('Enter percentage of Gravel:', _gravelController),
              
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
