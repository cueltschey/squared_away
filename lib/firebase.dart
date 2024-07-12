import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FireBaseAuth extends StatefulWidget {
  @override
  _FireBaseAuthState createState() => _FireBaseAuthState();
}

class _FireBaseAuthState extends State<FireBaseAuth> {
  bool signedIn = false;
  _googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() {
      signedIn = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _googleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return signedIn? Scaffold(
      appBar: AppBar(
        title: Text('Google Drive File Sync'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
        ],
      ),
    ) : Scaffold(appBar: AppBar(title: Text("Google Drive File Sync")), body: Center(child: CircularProgressIndicator()),);
  }
}