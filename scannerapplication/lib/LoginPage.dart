import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scannerapplication/HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mail = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> kayitOl() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: mail.text, password: password.text)
        .then((kullanici) {
      FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc(mail.text)
          .set({"KullaniciEposta": mail.text, "KullaniciSifre": password.text}
        );
      mail.clear();
      password.clear();
      TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your account has been successfully created!'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'ok'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
        child: null,
      );
    });
  }

  girisYap() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: mail.text, password: password.text)
        .then((kullanici) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/purplelogo.png', fit : BoxFit.contain, height: 72,),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Image.asset('assets/images/scanrcpt.png',width: 150,height: 70,)
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(50, 0, 50, 20),
              child: Image.asset('assets/images/scan.png',width: 60,height: 60,)
            ),
            Container(
              padding: EdgeInsets.fromLTRB(50, 10, 50, 20),
              child: TextField(
                controller: mail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "E-Mail",
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: TextField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
                child: 
                RaisedButton(
                    padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                    color: Colors.purple,
                    textColor: Colors.white,
                    child: Text("Log in"),
                    onPressed: girisYap),
            ),
            Container(
              alignment: Alignment.center,
                child: 
                RaisedButton(
                    padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                    color: Colors.purple,
                    textColor: Colors.white,
                    child: Text("Sign up"),
                    onPressed: kayitOl),
            ),
          ],
        ),
      ),
    );
  }
}
