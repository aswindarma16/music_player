import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/music.dart';

Future<List<Music>> getMusicList(String keyword) async {
  String getMusicListAPI = "https://itunes.apple.com/search?term=$keyword&country=id&media=music";

  var getMusicListAPIResponse = await http.get(
    Uri.parse(getMusicListAPI),
  );

  if(getMusicListAPIResponse.statusCode == 200) {
    List<Music> musicList = [];

    var checkVersionResponseJson = jsonDecode(getMusicListAPIResponse.body);
    var results = checkVersionResponseJson["results"];

    if(results != null) {
      if(results.length > 0) {
        results.forEach((music) {
          musicList.add(
            Music(
              artistName: music["artistName"] ?? "-",
              previewUrl: music["previewUrl"] ?? "-",
              trackName: music["trackName"] ?? "-",
              imagePreview: music["artworkUrl100"] ?? "-",
              albumName: music["collectionName"] ?? "-",
              trackId: music["trackId"].toString()
            )
          );
        });
      }
    }

    return musicList;
  }
  else {
    return [];
  }
}