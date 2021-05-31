import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:scannerapplication/HomePage.dart';
import 'dart:async';
import 'ocr_engine.dart';
import 'package:image/image.dart' as imglib;
import 'process.dart';

class OcrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        title: Text("Scanning"),
        backgroundColor: Colors.purple,
      ),
      body: CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraPage> {
  List<CameraDescription> cameras;
  CameraController controller;
  bool _isScanBusy = false;
  bool _cameraInitialized = false;
  bool _isButtonPressed = false;
  Timer _timer;
  String _textDetected = " ";

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize().then((_) async {
      _cameraInitialized = true;
      await controller
          .startImageStream((CameraImage image) async {
            if(_isButtonPressed){
            controller.stopImageStream();
            }
        if (_isScanBusy) {
          print("1.5 -------- isScanBusy, skipping...");
          return;
        }

        print("1 -------- isScanBusy = true");
        _isScanBusy = true;
        print(_isButtonPressed);
        if (_isButtonPressed){

            const shift = (0xFF << 24);

          final int width = image.width;
          final int height = image.height;
          final int uvRowStride = image.planes[1].bytesPerRow;
          final int uvPixelStride = image.planes[1].bytesPerPixel;

          var img = imglib.Image(width, height); // Create Image buffer

          // Fill image buffer with plane[0] from YUV420_888
          for(int x=0; x < width; x++) {
            for(int y=0; y < height; y++) {
              final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
              final int index = y * width + x;

              final yp = image.planes[0].bytes[index];
              final up = image.planes[1].bytes[uvIndex];
              final vp = image.planes[2].bytes[uvIndex];
              int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
              int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
              int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
              // color: 0x FF  FF  FF  FF 
              //           A   B   G   R
              img.data[index] = shift | (b << 16) | (g << 8) | r;
            }
          }

            imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
            List<int> png = pngEncoder.encodeImage(img);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(imagePath: png, image:image ),
                ),
              );
          }
        
          _isScanBusy = false;
        }).catchError((error) {
          _isScanBusy = false;
        });
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraInitialized) {
      return Container();
    }
    return Column(children: [
      Expanded(child: _cameraPreviewWidget()),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Text(
          _textDetected,
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 34),
        )
      ]),
      Container(
        height: 100,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                  child: Text("Take Picture"),
                  textColor: Colors.white,
                  color: Colors.purple,
                  onPressed: (){setState(() {
                    _isButtonPressed=true;
                  });} ),
            ]),
      ),
    ]);
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final CameraImage image;
  final List<int> imagePath;
  const DisplayPictureScreen({Key key, this.image, this.imagePath}) : super(key: key);
 
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        title: Text('Display the Picture')
        ),
      body: Column(
              children: [
                Expanded(child:RotatedBox(child: Image.memory(widget.imagePath), quarterTurns: 1,)),
                ElevatedButton(onPressed: () async {
                await OcrManager.scanText(widget.image).then((textVision) {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Scanned(
                    text: textVision,
                  ),
                ),
              );
              });}, child: Text("Scanning"),
              ),
             ],
      ));
  }
}
class Scanned extends StatefulWidget {
  final String text;
  const Scanned({Key key, this.text}) : super(key: key);

  @override
  _ScannedState createState() => _ScannedState();
}

class _ScannedState extends State<Scanned> {
  TextEditingController date = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController company = TextEditingController();
  @override
  void initState() {
    super.initState();
    Processor TP = Processor();
    
    date.text = TP.date_finder(widget.text);
    company.text = TP.company_finder(widget.text);
    price.text = TP.price_finder(widget.text);
  }

  savefile(){
    FirebaseFirestore.instance.collection(company.text).doc(date.text).set({
      'toplam': price.text,
      'doküman': widget.text,
      'baslik': date.text,
    }).whenComplete(() => print("Yazı eklendi"));
    Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (Route<dynamic> route) => false);
  }
  editfile(){
    Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Editingfile(text: widget.text)),
          (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        title: Text('Display the Result Text')
        ),
      body: ListView(
        children: [
          //Text(widget.text),
          ListTile(
            leading: Icon(Icons.receipt_long_rounded,color: Colors.purple,),
            title: Text(widget.text),
          ),
          ListTile(
            leading: Icon(Icons.business_outlined,color: Colors.purple,),
            title: TextField(controller: company),
          ),
          ListTile(
            leading: Icon(Icons.date_range_outlined,color: Colors.purple,),
            title: TextField(controller: date),
          ),
          ListTile(
            leading: Icon(Icons.attach_money_outlined,color: Colors.purple,),
            title: TextField(controller: price),
          ),
          RaisedButton(
            padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
            color: Colors.purple,
            textColor: Colors.white,
            child: Text("Save"),
            onPressed: savefile ),
            RaisedButton(
            padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
            color: Colors.purple,
            textColor: Colors.white,
            child: Text("Edit"),
            onPressed: editfile ),
        ],
      ) 
    );
  }
}
class Editingfile extends StatefulWidget {
  String text;
  Editingfile({Key key, this.text}) : super(key: key);
  @override
  _EditingfileState createState() => _EditingfileState(text: text);
}

class _EditingfileState extends State<Editingfile> {
  String text;
  TextEditingController textcontroll;
  TextEditingController t1 = TextEditingController();
  _EditingfileState({this.text});
  savefile(){
    FirebaseFirestore.instance.collection("Doküman").doc(t1.text).set({
      'doküman': textcontroll.text,
      'baslik': t1.text,
    }).whenComplete(() => print("Yazı eklendi"));
    Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (Route<dynamic> route) => false);
  }
  @override
  void initState() {
    super.initState();
    textcontroll = TextEditingController(text: text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        title: Text('Display the Result Text')
        ),
      body: Column(
        children: [
          Container(child: TextField(controller: textcontroll,maxLines: 20,), height: 500.0,),
          Container(child: TextField(controller: t1,),),
          RaisedButton(
            padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
            color: Colors.purple,
            textColor: Colors.white,
            child: Text("Save"),
            onPressed: savefile ),
        ])
    );
  }
}
