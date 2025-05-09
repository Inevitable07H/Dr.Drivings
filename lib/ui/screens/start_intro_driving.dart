import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'driving_session_screen.dart';

class StartIntroDriving extends StatefulWidget {
  @override
  _StartIntroDrivingState createState() => _StartIntroDrivingState();
}

class _StartIntroDrivingState extends State<StartIntroDriving> {
  final FlutterTts flutterTts = FlutterTts();
  VideoPlayerController? _controller; // Make nullable to avoid early access
  bool showStartDriving = false;
  bool skipVideo = false;
  bool videoReadyToShow = false;

  @override
  void initState() {
    super.initState();
    _startIntro();
  }

  Future<void> _startIntro() async {
    await flutterTts.setSpeechRate(1);
    await flutterTts.setPitch(100);
    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.speak(
      "Hello Vighnesh... Welcome to Dr.Drivings. You are on the right track to learn the driving skills with me as the doctor beside you. "
      "Let me walk you through a little intro to the car parts and the car basics.",
    );

    // Wait 5 seconds before initializing video
    await Future.delayed(Duration(seconds: 3));
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/car_intro_1.mp4');
    await _controller!.initialize();
    _controller!.setLooping(false);

    _controller!.addListener(() {
      if (_controller!.value.position >= _controller!.value.duration && !skipVideo) {
        _onVideoFinished();
      }
    });

    setState(() {
      videoReadyToShow = true;
    });

    _controller!.play();
  }

  Future<void> _speakOutro() async {
    await flutterTts.setSpeechRate(1);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
      "Yeah Vighnesh! Looks like you’ve learned your first lesson quickly. Remember, the basics are the foundation to everything stronger. So now we move forward.",
    );
  }

  void _onVideoFinished() async {
    await _speakOutro();
    if (mounted) setState(() => showStartDriving = true);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('Welcome Vighnesh 👋'),
        backgroundColor: Colors.indigo,
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "🚘 Intro to Driving",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 115, 200, 236),
              ),
            ),
            const SizedBox(height: 25),

            /// Video Card (safe to render only if controller is ready)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: videoReadyToShow && _controller != null && _controller!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      )
                    : Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text("Please wait... Preparing video 🎬"),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            /// Skip Button
            ElevatedButton.icon(
              onPressed: () {
                if (_controller != null) {
                  skipVideo = true;
                  _controller!.pause();
                  _onVideoFinished();
                }
              },
              icon: Icon(Icons.skip_next, size: 20),
              label: Text("Skip Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const Spacer(),

            /// Start Driving Button
            if (showStartDriving)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DrivingSessionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  elevation: 6,
                ),
                child: Text(
                  "🚗 Start Driving",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
