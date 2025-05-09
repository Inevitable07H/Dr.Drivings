import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'feedback_screen.dart'; // Make sure this exists

Timer? _tipTimer;
final List<String> _drivingTips = [
  "Always keep your hands on the wheel at the 9 and 3 positions.",
  "Use your mirrors frequently to stay aware of your surroundings.",
  "Maintain a safe distance from the car ahead of you.",
  "Do not rest your foot on the clutch pedal while driving.",
  "Always use indicators before making turns.",
  "Avoid sudden braking unless it's an emergency.",
  "Keep your eyes moving to observe road signs and hazards.",
  "Remember to cancel your indicator after turning.",
];
int _tipIndex = 0;

class DrivingSessionScreen extends StatefulWidget {
  const DrivingSessionScreen({super.key});

  @override
  State<DrivingSessionScreen> createState() => _DrivingSessionScreenState();
}

class _DrivingSessionScreenState extends State<DrivingSessionScreen> {
  final FlutterTts tts = FlutterTts();
  late DatabaseReference _firebaseRef;

  bool _isLoading = true;
  bool _seatBeltConfirmed = false;
  bool _clutchPressed = false;
  bool _clutchReleased = false;
  bool _acceleratorPressed = false;
  bool _brakePressed = false;
  bool _showFirstGearInstruction = false;
  bool _showFeedbackButton = false;

  int _distance = -1;
  Timer? _sessionTimer;
  int _secondsLeft = 60; // 10 minutes

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    await Firebase.initializeApp();

    _firebaseRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://drdrivingsapp-default-rtdb.firebaseio.com",
    ).ref().child("DrDrivingBrakeControl");

    setState(() => _isLoading = false);

    await tts.speak("Location detected. Please fasten your seatbelt.");
    _startLocationTracking();
  }

  void _startTimer() {
  _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsLeft <= 0) {
      timer.cancel();
      _tipTimer?.cancel(); // Stop tips when session ends
      setState(() => _showFeedbackButton = true);
      tts.speak("Time's up! You’ve completed your session. Tap to view feedback.");
    } else {
      setState(() => _secondsLeft--);
    }
  });

  // Tip every 2 minutes
  _tipTimer = Timer.periodic(const Duration(minutes: 2), (timer) async {
    if (_tipIndex < _drivingTips.length) {
      await tts.speak(_drivingTips[_tipIndex]);
      _tipIndex++;
    } else {
      _tipIndex = 0; // Restart tip cycle if needed
    }
  });
}


  void _startLocationTracking() {
    if (kIsWeb) {
      js.context.callMethod('eval', ["""
        navigator.geolocation.watchPosition(function(position) {
          console.log("Latitude: " + position.coords.latitude);
          console.log("Longitude: " + position.coords.longitude);
        });
      """]);
    }
  }

  void _listenForClutch() {
    _firebaseRef.child("sensor3").onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == "touched" && !_clutchPressed) {
        setState(() => _clutchPressed = true);
        _startDrivingSession();
      }
      if (value == "not touched" && !_clutchReleased && _clutchPressed) {
        setState(() => _clutchReleased = true);
        tts.speak("Good! Now press the accelerator, the bigger pedal to your right.");
        _listenForAccelerator();
      }
    });
  }

  void _listenForAccelerator() {
    _firebaseRef.child("sensor1").onValue.listen((event) async {
      final value = event.snapshot.value;
      if (value == "touched" && !_acceleratorPressed) {
        setState(() => _acceleratorPressed = true);
        await tts.speak("Great! Now continue driving carefully.");
      } else if (value == "not touched" && !_acceleratorPressed) {
        await tts.speak("Please press the accelerator now.");
      }
    });
  }

  void _listenForBrake() {
    _firebaseRef.child("sensor2").onValue.listen((event) async {
      final value = event.snapshot.value;
      if (_distance != -1 && _distance <= 30) {
        if (value == "touched") {
          setState(() => _brakePressed = true);
          await tts.speak("Brake applied. Good job.");
        } else {
          await tts.speak("Brake! Brake! Brake! Please press the brake pedal in the middle.");
        }
      }
    });
  }

  void _listenForDistance() {
    _firebaseRef.child("distance").onValue.listen((event) async {
      final value = event.snapshot.value;
      final parsed = int.tryParse(value.toString());
      if (parsed != null) {
        setState(() => _distance = parsed);
        if (parsed <= 30) {
          await tts.speak("Warning! Obstacle ahead.");
          _listenForBrake();
        } else if (parsed == 50) {
          await tts.speak("In 50 meters, turn right.");
        } else if (parsed == 100) {
          await tts.speak("In 100 meters, turn left.");
        }
      }
    });
  }

  Future<void> _startDrivingSession() async {
    _startTimer();
    setState(() => _showFirstGearInstruction = true);
    await tts.speak("Clutch engaged. Great job!");
    await tts.speak("Now we are going to put the car into first gear.");
    await tts.speak("Look at the image to understand the gear shift.");
    await tts.speak("Gently release the clutch until the car starts moving.");
    await tts.speak("Today we are going to move the car in first gear only.");
    _listenForDistance();
  }

  Widget _buildTimer() {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Text("⏱️ $_secondsLeft sec left | $minutes:$seconds",
        style: const TextStyle(fontSize: 16));
  }

  Widget _buildMapPlaceholder() {
    if (kIsWeb) {
      const viewID = 'html-map-iframe';

      ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'assets/index.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });

      return Container(
        height: 400,
        margin: const EdgeInsets.all(12),
        child: const HtmlElementView(viewType: viewID),
      );
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text("🗺️ Google Maps (Mobile Only)")),
    );
  }

  Widget _buildSeatBeltPrompt() {
    return Column(
      children: [
        const Text("Please fasten your seatbelt to continue.",
            style: TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            setState(() => _seatBeltConfirmed = true);
            await tts.speak("Seatbelt secured. Now press the clutch the peddle to your left side.");
            _listenForClutch();
          },
          child: const Text("✅ Seatbelt Fastened"),
        ),
      ],
    );
  }

  Widget _buildFirstGearImage() {
    if (_showFirstGearInstruction) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("assets/photos/first_gear.png", height: 200),
            const SizedBox(height: 8),
            const Text("First Gear: Push left, then forward",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatusText() {
    if (!_seatBeltConfirmed) return _buildSeatBeltPrompt();
    if (!_clutchPressed) {
      return const Text("⌛ Waiting for clutch press...",
          style: TextStyle(fontSize: 18));
    }
    return const Text("✅ All Set! Ready to Drive!",
        style: TextStyle(fontSize: 18));
  }

  Widget _buildDrivingTip() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "🚘 Tip: Always check mirrors and surroundings before moving!",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFeedbackButton() {
    if (_showFeedbackButton) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackScreen()),
          );
        },
        child: const Text("📊 Go to Feedback Analysis"),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Driving Session"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMapPlaceholder(),
            const SizedBox(height: 16),
            _buildStatusText(),
            _buildTimer(),
            _buildFirstGearImage(),
            if (_seatBeltConfirmed) _buildDrivingTip(),
            const SizedBox(height: 16),
            _buildFeedbackButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

 @override
void dispose() {
  _sessionTimer?.cancel(); 
  _tipTimer?.cancel();
  tts.stop();
  super.dispose();
}

}
