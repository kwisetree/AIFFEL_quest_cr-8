import 'package:pixel_editor_v2_client/pixel_editor_v2_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'src/pixelparty.dart';

// Sets up a singleton client object that can be used to talk to the server from
// anywhere in our app. The client is generated from your server code.
// The client is set up to connect to a Serverpod running on a local server on
// the default port. You will need to modify this to connect to staging or
// production servers.
var client = Client('http://$localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

void main() {
  // start the app
  runApp(const PixelPartyApp());
}

class PixelPartyApp extends StatelessWidget {
  const PixelPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Party',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), 
      home: Scaffold(
        body: const PixelParty(),
      ),
    );
  }
}