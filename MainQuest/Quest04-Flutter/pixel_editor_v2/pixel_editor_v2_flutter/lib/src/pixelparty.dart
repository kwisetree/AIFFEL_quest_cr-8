import 'package:flutter/material.dart';
import 'package:pixel_editor_v2_client/pixel_editor_v2_client.dart';
import 'package:pixels/pixels.dart';

import '../../main.dart';

// The main widget for the Pixel Party app.
// This widget will be the root of the app and will contain the main UI.
// The PixelParty widget draws the image using the PixelEditor from pixels packagage
// PixelImageController manages the pixel data
// calls the _listenToUpdates method to listen to updates from the server
class PixelParty extends StatefulWidget {
  const PixelParty({super.key});

  @override
  State<PixelParty> createState() => _PixelPartyState();
}

class _PixelPartyState extends State<PixelParty> {
  // The pixel image controller contains the image data and handles updates.
  // If it is null, the image is not yet loaded from the server.
  PixelImageController? _imageController;

  @override
  void initState() {
    super.initState();
    // Connect to the server and listen to updates.
    _listenToUpdates();
  } 

  Future<void> _listenToUpdates() async {
    // Indefinitely try to connect and listen to updates from the server.
    while (true) {
      try {
        // Get the stream of updates from the server.
        final imageUpdates = client.pixelParty.imageUpdates();

        // Listen for updates from the stream. The await for construct will
        // wait for a message to arrive from the server, then run through the
        // body of the loop.
        await for (final update in imageUpdates) {
          // Check which type of update we have received.
          if (update is ImageData) {
            // This is a complete image update, containing all pixels in the
            // image. Create a new PixelImageController with the pixel data.
            setState(() {
              _imageController = PixelImageController(
                pixels: update.pixels,
                palette: PixelPalette.rPlace(),
                width: update.width,
                height: update.height,
              );
            });
          } else if (update is ImageUpdate) {
            // Got an incremental update of the image. 
            // Just set the single pixel.
            _imageController?.setPixelIndex(
              pixelIndex: update.pixelIndex,
              colorIndex: update.color,
            );
          }
        }
      } on MethodStreamException catch (_) {
        // MethodStreamException is a superclass of a set of detailed exceptions.
        // We lost the connection to the server, or failed to connect.
        setState(() {
          _imageController = null;
        });
      }

      // Wait 5 seconds until we try to connect again.
      await Future.delayed(Duration(seconds: 5));
    }
  }

  // User interface for the Pixel Party app.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _imageController == null
          ? const CircularProgressIndicator()
          : PixelEditor(
              controller: _imageController!,
              onSetPixel: (details) {
                // When a user clicks a pixel we will get a callback from the
                // PixelImageController, with information about the changed
                // pixel. When that happens we call the setPixels method on
                // the server.
                client.pixelParty.setPixel(
                  pixelIndex: details.tapDetails.index,
                  colorIndex: details.colorIndex,
                );
              },
            ),
    );
  }
} // _PixelPartyState