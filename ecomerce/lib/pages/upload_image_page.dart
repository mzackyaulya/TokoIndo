import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(File imageFile) async {
  final cloudName = 'dz94rjzyz'; // ganti sesuai akun kamu
  final uploadPreset = 'flutter_unsigned_preset'; // ganti sesuai preset kamu

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  var request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final jsonResp = jsonDecode(respStr);
    return jsonResp['secure_url']; // URL gambar hasil upload
  } else {
    print('Upload failed with status: ${response.statusCode}');
    return null;
  }
}
