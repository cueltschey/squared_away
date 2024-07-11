import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';


class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();
  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<Response> head( url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers?..addAll(_headers));
}

class DriveSyncPage extends StatefulWidget {
  @override
  _DriveSyncState createState() => _DriveSyncState();
}

class _DriveSyncState extends State<DriveSyncPage> {
  bool signedIn = false;
  final googleSignIn = GoogleSignIn(
    scopes: <String>[DriveApi.driveFileScope],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Drive File Sync'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
        ],
      ),
    );
  }
}