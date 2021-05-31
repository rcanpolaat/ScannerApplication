import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scannerapplication/LoginPage.dart';
import 'package:scannerapplication/camera.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var gelenYaziBasligi = "";
  bool isrefresh = false;
  DocumentSnapshot veri;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        leading: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        title: Text("Home",),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
                icon: Icon (Icons.refresh), 
                onPressed: (){
                  FirebaseFirestore.instance
                  .collection("Doküman").doc()
                  .get().then((gelenveri) {
                    setState((){
                      isrefresh = true;
                      veri = gelenveri;
                    });
                  });
                  
              }),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((deger) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false);
                });
              }),
        ],
      ),

      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => OcrApp()),
                (Route<dynamic> route) => false);
          }),

          body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Doküman').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: 
          ,)
          return ListView(
            children: snapshot.data.docs.map((document) {
              return Container(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: RaisedButton(
                  onPressed:(){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Editingfile(
                    text: document['doküman'],
                  ),
                ),
              );
                } , child: Text(document['baslik']))),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

