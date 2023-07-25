import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> downloadGIF({required String url, required String id}) async {
  try {
    final response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$id/${url.split('/').last}')
        ..writeAsBytes(response.bodyBytes);
      return file.path;
    }
  } catch (e) {
    print("Download Failed.\n\n" + e.toString());
  }
  return null;
}
