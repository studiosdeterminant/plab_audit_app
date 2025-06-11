import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';

class ImageAnnotationScreen extends StatefulWidget {
  final File imageFile;
  const ImageAnnotationScreen({required this.imageFile, Key? key}) : super(key: key);

  @override
  State<ImageAnnotationScreen> createState() => _ImageAnnotationScreenState();
}

class _ImageAnnotationScreenState extends State<ImageAnnotationScreen> {
  late ImagePainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Image"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final image = await _controller.exportImage();
              if (image != null) {
                Navigator.pop(context, image);
              }
            },
          )
        ],
      ),
      body: ImagePainter.file(
        widget.imageFile,
        controller: _controller,
        scalable: false,
      ),
    );
  }
}