import 'dart:html' as html; 
import 'package:flutter/material.dart';
import 'start_intro_driving.dart';

class LicenseVerificationScreen extends StatefulWidget {
  const LicenseVerificationScreen({super.key});

  @override
  _LicenseVerificationScreenState createState() =>
      _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState
    extends State<LicenseVerificationScreen> {
  bool _scanned = false;
  String _extractedText = "Scan your license to extract details.";

  final String simulatedText = '''
Name: Vighnesh Subhash Chejara
License No: MH14XX6789
DOB: 24/04/2004
Issue Date: 07/07/2022
Class: LMV, MCWG
State: Maharashtra
''';

  void simulateScan() {
    setState(() {
      _scanned = true;
      _extractedText = simulatedText;
    });
  }

  void _proceedToIntro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StartIntroDriving()),
    );
  }

  void _launchLearnerLicenseSite() {
    html.window.open(
      'https://parivahan.gov.in/parivahan//en/content/learners-license',
      '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("License Verification"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF6FF), Color.fromRGBO(208, 232, 255, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "License Scanner (Simulated)",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap the button below to simulate license scanning.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/photos/license_sample.jpg",
                      height: 250,
                      width: 450,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _launchLearnerLicenseSite,
                    child: const Text(
                      "👶 Newbie? Get your learner’s license",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: simulateScan,
                    icon: const Icon(Icons.camera),
                    label: const Text("Simulate License Scan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _scanned ? 1 : 0,
                    child: Column(
                      children: [
                        Card(
                          elevation: 6,
                          shadowColor: Colors.blueAccent.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _extractedText,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _proceedToIntro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Proceed Further"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
