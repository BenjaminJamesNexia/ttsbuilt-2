import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Persistence{

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/joblisting.txt');
  }

  void writeJobListing(Map<String,dynamic> data) async {
    final file = await _localFile;
    String jsonString = jsonEncode(data);
    // Write the file
    file.writeAsString(jsonString);
  }

  ///Returns a Map<String, dynamic> with values for jobs and last-job-listing-date, or and empty map {}
  Future<Map<String, dynamic>> getJobListingFromFile() async{
    final file = await _localFile;
    bool fileExists = await file.exists();
    if(fileExists) {
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonValue = jsonDecode(jsonString);
      return jsonValue;
    }
    return {};
  }

}