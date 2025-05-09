import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  void scanDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
     // Listen for scan results
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.platformName} found!'); // FIX: Use `platformName` instead of `name`
      }
    });

    // Stop scanning after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      subscription.cancel(); // FIX: Cancel subscription properly
      FlutterBluePlus.stopScan();
    });
  }
}
