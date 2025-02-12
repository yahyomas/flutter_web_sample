import 'dart:html';
import 'dart:js';
import 'dart:js_util';
import 'dart:ui_web';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

/// [Widget] displaying the home page consisting of an image and buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? _imageUrl;
  bool _isMenuOpen = false;
  String _viewId = '';

  ///checks screen state and toggles
  void _toggleFullscreen() {
    context.callMethod('eval', [
      "if (!document.fullscreenElement) { document.documentElement.requestFullscreen(); } else { document.exitFullscreen(); }"
    ]);
  }

  ///toggles menu
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  ///checks screen state and returns the result
  bool _isFullscreen() {
    return getProperty(document, 'fullscreenElement') != null;
  }

  /// [build] method that returns a container if [_imageUrl] is null
  /// Web view when content is available
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              children: [
                Expanded(
                  child: _imageUrl == null
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                      : HtmlElementView(viewType: _viewId),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration:
                        const InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _loadImage,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black54,
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      bottom: 80, // Place above
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isFullscreen()
                              ? ElevatedButton(
                            onPressed: () {
                              _toggleFullscreen();
                              _toggleMenu();
                            },
                            child: const Text('Exit Fullscreen'),
                          )
                              : ElevatedButton(
                            onPressed: () {
                              _toggleFullscreen();
                              _toggleMenu();
                            },
                            child: const Text('Enter Fullscreen'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  ///loading an image, putting in div and updating ui
  void _loadImage() {
    setState(() {
      _imageUrl = _urlController.text;

      // Register a new view factory with the updated image URL
      final uniqueId = 'image-view-${DateTime.now().millisecondsSinceEpoch}';

      // ignore: undefined_prefixed_name
      platformViewRegistry.registerViewFactory(uniqueId, (int viewId) {
        final div = DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'center'
          ..style.backgroundColor = 'black';

        final img = ImageElement(src: _imageUrl!)
          ..style.maxWidth = '100%'
          ..style.maxHeight = '100%'
          ..onDoubleClick.listen((event) {
            context.callMethod('eval', [
              "if (!document.fullscreenElement) { document.documentElement.requestFullscreen(); } else { document.exitFullscreen(); }"
            ]);
          });

        div.children.add(img);
        return div;
      });

      _viewId = uniqueId; // Update view ID
    });
  }
}
