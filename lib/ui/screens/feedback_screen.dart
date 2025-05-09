import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FlutterTts tts = FlutterTts();

  bool _isSpeakingDone = false;
  bool _isLoading = true;

  // ✅ Manually entered data
  Map<String, int> feedbackData = {
    'Clutch': 2,
    'Gear': 1,
    'Accelerator': 1,
    'Brake': 1,
    'Tips Missed': 1,
  };

  String groqSummary = "";

  final Map<String, Color> _colors = {
    'Clutch': Colors.blue,
    'Gear': Colors.green,
    'Accelerator': Colors.orange,
    'Brake': Colors.red,
    'Tips Missed': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _analyzeFeedback();
  }

  Future<void> _analyzeFeedback() async {
    await _getGroqSummary(feedbackData);
    setState(() => _isLoading = false);
  }

  Future<void> _getGroqSummary(Map<String, int> feedbackData) async {
    final String prompt = """
Analyze the driving feedback from a driving session:
- Clutch: ${feedbackData['Clutch']}
- Gear: ${feedbackData['Gear']}
- Accelerator: ${feedbackData['Accelerator']}
- Brake: ${feedbackData['Brake']}
- Tips Missed: ${feedbackData['Tips Missed']}

Give a 4-line summary with compliments and suggestions. End with: "See you tomorrow!"
""";

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer " // 🛡️ Replace with your GROQ API one!
      },
      body: jsonEncode({
        "model": "llama3-70b-8192",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final String reply = json["choices"][0]["message"]["content"];
      setState(() => groqSummary = reply);

      await tts.speak(reply);
      setState(() => _isSpeakingDone = true);
    } else {
      groqSummary = "Failed to fetch feedback from AI.";
    }
  }

  List<PieChartSectionData> _buildPieSections() {
    return feedbackData.entries.map((entry) {
      final double percent = entry.value * 20.0;
      return PieChartSectionData(
        color: _colors[entry.key],
        value: percent,
        title: '${entry.key}\n${percent.toInt()}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Feedback Summary'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "🧠 AI Driving Feedback",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (groqSummary.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      groqSummary,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_isSpeakingDone)
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text("Go to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
