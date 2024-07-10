import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UploadToGoogleDriveWidget extends StatefulWidget {
  @override
  _UploadToGoogleDriveWidgetState createState() => _UploadToGoogleDriveWidgetState();
}

class _UploadToGoogleDriveWidgetState extends State<UploadToGoogleDriveWidget> {
  bool _isUploading = false;
  String _uploadStatus = '';

  // Google OAuth credentials
  final String _clientId = 'YOUR_CLIENT_ID';
  final String _clientSecret = 'YOUR_CLIENT_SECRET';
  final List<String> _scopes = [drive.DriveApi.driveScope];

  Future<auth.AuthClient> _authenticate() async {
    final clientId = auth.ClientId(_clientId, _clientSecret);
    final authClient = await auth.clientViaUserConsent(clientId, _scopes, _prompt).catchError((e) {
      print(e);
      return null;
    });

    return authClient;
  }

  Future<void> _prompt(String url) async {
    print('Navigate to the following URL and grant permissions:');
    print(url);
    print('Enter the authorization code:');
    final code = stdin.readLineSync();
    final credentials = await auth.obtainAccessCredentialsViaUserConsent(auth.ClientId(_clientId, _clientSecret), _scopes, (url) async {
      print('Please navigate to the following URL to authorize:');
      print(url);
    });

    final client = auth.autoRefreshingClient(auth.ClientId(_clientId, _clientSecret), credentials);
    return client;
  }

  Future<void> _uploadFiles() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      final client = await _authenticate();
      final driveApi = drive.DriveApi(client);
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();

      // Ensure the 'squared_away' directory exists in Google Drive
      final folder = await driveApi.files.create(drive.File(name: 'squared_away', mimeType: 'application/vnd.google-apps.folder'));

      for (var file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);
          final media = drive.Media(file.openRead(), file.lengthSync());
          final driveFile = drive.File(name: fileName, parents: [folder.id?? ""]);

          await driveApi.files.create(driveFile, uploadMedia: media);
        }
      }

      setState(() {
        _uploadStatus = 'Upload complete!';
      });
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error uploading files: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to Google Drive'),
      ),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploadFiles,
              child: Text('Upload Files'),
            ),
            SizedBox(height: 20),
            Text(_uploadStatus),
          ],
        ),
      ),
    );
  }
}