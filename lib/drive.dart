import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:squared_away/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';


const _clientId = "700175434084-1lleqpt1d1p7f385on5o0qchko5uo3ao.apps.googleusercontent.com";
const _clientSecret = "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";
const _scopes = ['https://www.googleapis.com/auth/drive.file'];


class GoogleDriveFileSync extends StatefulWidget {
  final Function() getDataCallback;
  GoogleDriveFileSync({super.key, required this.getDataCallback});
  _GoogleDriveState createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDriveFileSync> {
  final GoogleDrive driveApi = GoogleDrive();
  bool isLoading = false;

  Future<void> _loadingWrapper(Function() functionToRun) async {
    setState(() {
      isLoading = true;
    });
    void result = await functionToRun();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Google Drive file sync")),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Column(children: [Icon(Icons.upload), Text("Push files to drive")],),
              onPressed: () =>
              {
                _loadingWrapper(driveApi.syncFilesToGoogleDrive),
              }
            )
          ),
          Center(
              child: ElevatedButton(
                child: Column(children: [Icon(Icons.download), Text("Pull files from drive")],),
                onPressed: () => {
                  _loadingWrapper(() => driveApi.pullFilesFromGoogleDrive(widget.getDataCallback)),
                }
              )
          ),
          isLoading? Center(child: CircularProgressIndicator()) : SizedBox()
        ],
      )
    );
  }
}


class GoogleDrive {
  final storage = SecureStorage();

  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    //Get Credentials
    var credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) {
          launchUrl(Uri.parse(url));
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken!);
      return authClient;
    } else {
      print(credentials["expiry"]);
      //Already authenticated
      return authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.tryParse(credentials["expiry"])!),
              credentials["refreshToken"],
              _scopes));
    }
  }

// check if the directory forlder is already available in drive , if available return its id
// if not available create a folder in drive and return id
//   if not able to create id then it means user authetication has failed
  Future<String?> _getFolderId(ga.DriveApi driveApi) async {
    final mimeType = "application/vnd.google-apps.folder";
    String folderName = "SquaredAway";

    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );
      final files = found.files;
      if (files == null) {
        print("Sign-in first Error");
        return null;
      }

      // The folder already exists
      if (files.isNotEmpty) {
        return files.first.id;
      }

      // Create a folder
      ga.File folder = ga.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      print("Folder ID: ${folderCreation.id}");

      return folderCreation.id;
    } catch (e) {
      print(e);
      /*
      var credentials = await storage.getCredentials();
      if(credentials == null){
        print("Failed to get credentials!!");
        return null;
      }
      var newCredentials = await refreshCredentials(
          ClientId(_clientId, _clientSecret),
          AccessCredentials(
            AccessToken(credentials["type"], credentials["data"],
              DateTime.tryParse(credentials["expiry"])!),
            credentials["refreshToken"],
            _scopes),
          http.Client());
      var newDrive = ga.DriveApi(authenticatedClient(http.Client(), newCredentials));
      _getFolderId(newDrive);
      */
      await storage.clear();
      return null;
    }
  }

  Future<void> deleteAndRecreateFolder() async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    String? folderId = await _getFolderId(drive);

    if (folderId == null) {
      print("Invalid Folder");
      return;
    }

    try {
      // Retrieve all files in the folder
      final files = await drive.files.list(q: "'$folderId' in parents", $fields: "files(id)");

      // Delete each file
      for (var file in files.files!) {
        await drive.files.delete(file.id!);
        print("Deleted file ${file.id}");
      }

      // Delete the folder itself
      await drive.files.delete(folderId);
      print("Deleted folder $folderId");
    } catch (e) {
      print("Error deleting and recreating folder: $e");
    }
  }

  uploadFileToGoogleDrive(File file) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    String? folderId = await _getFolderId(drive);
    if (folderId == null) {
      print("Sign-in first Error");
    } else {
      ga.File fileToUpload = ga.File();
      fileToUpload.parents = [folderId];
      fileToUpload.name = p.basename(file.absolute.path);
      var response = await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
      print("Drive response: ");
      print(response);
    }
  }

  Future<void> downloadFile(ga.DriveApi driveApi, String fileId, String savePath) async {
    final fileStream = await driveApi.files.get(fileId, downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media;
    final saveFile = File(savePath);
    final raf = saveFile.openWrite();

    await fileStream.stream.pipe(raf);
    await raf.close();
  }

  Future<void> pullFilesFromGoogleDrive(Function getDataCallback) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    String? folderId = await _getFolderId(drive);

    if (folderId == null) {
      print("SquaredAway folder not found in Google Drive.");
      return;
    }

    final files = await drive.files.list(
      q: "'$folderId' in parents",
      $fields: "files(id, name)",
    );

    final documentsDirectory = await getApplicationDocumentsDirectory();

    for (var file in files.files!) {
      String savePath = p.join(documentsDirectory.path, file.name!);
      await downloadFile(drive, file.id!, savePath);
      print("Downloaded ${file.name} to $savePath");
    }

    await getDataCallback();
  }

  Future<void> syncFilesToGoogleDrive() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = documentsDirectory.listSync();
    deleteAndRecreateFolder();

    for (FileSystemEntity file in files) {
      if (file is File) {
        print("Uploading file " + file.path);
        await uploadFileToGoogleDrive(file);
      }
    }
  }
}