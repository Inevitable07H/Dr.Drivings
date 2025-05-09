import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCeFD74q-ATS6-bPH5YgCWNERbh22GRlMc',
      appId: '1:260831743378:android:60da1154966ce7e51c854b',
      messagingSenderId: '260831743378',
      projectId: 'drdrivingsapp',
      databaseURL: 'https://drdrivingsapp-default-rtdb.firebaseio.com/',
    ),
  );
  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dr. Drivings App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),  
    );
  }
}
