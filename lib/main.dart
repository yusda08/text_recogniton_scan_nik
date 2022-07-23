import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_recognition/camera_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;
  OverlayFormat format = OverlayFormat.cardID1;
  XFile? imageFile;
  String scannedText = "";

  void setImgFile(XFile file) {
    imageFile = file;
  }

  @override
  Widget build(BuildContext context) {
    CardOverlay overlay = CardOverlay.byFormat(format);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition example"),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final imgResult = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => CameraPage()));
                    setImgFile(imgResult);
                    getRecognisedText(imgResult);
                  },
                  label: Text('Open Camera'),
                  icon: Icon(Icons.camera),
                ),
                if (textScanning) const CircularProgressIndicator(),
                if (!textScanning && imageFile == null)
                  AspectRatio(
                    aspectRatio: overlay.ratio!,
                    child: Container(
                      color: Colors.grey[300]!,
                    ),
                  ),
                if (imageFile != null)
                  AspectRatio(
                    aspectRatio: overlay.ratio!,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          alignment: FractionalOffset.center,
                          image: FileImage(
                            File(imageFile!.path),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Text(
                    scannedText,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            )),
      )),
    );
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    scannedText = "";
    List dataText = [];
    TextLine line;
    for (TextBlock block in recognizedText.blocks) {
      for (line in block.lines) {
        dataText.add(line.text);
      }
    }
    String nik = dataText[2].toString();
    String newString = nik.replaceAll(':', '');
    scannedText = newString;
    textScanning = false;
    textRecognizer.close();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }
}
