import 'package:alchemy/logger.dart';
import 'package:alchemy/services/requests.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

const maxPhotoSizeBytes = 1500000;

class PhotosService {
  static final PhotosService instance = PhotosService();
  static const int maxPhotoCount = 10;

  Future<String> uploadPhoto(XFile file, RequestsService requests) async {
    final data = await file.readAsBytes();
    var image = decodeImage(data);
    if (image == null) throw PhotosServiceFormatException();

    final aspect = image.width / image.height;
    if (image.width > image.height) {
      final h = (1024 / aspect).floor();
      image = copyResize(image, width: 1024, height: h);
    } else {
      final w = (1024 * aspect).floor();
      image = copyResize(image, width: w, height: 1024);
    }

    var quality = 100;
    var photo = encodeJpg(image, quality: quality);
    while (photo.lengthInBytes > maxPhotoSizeBytes && quality > 0) {
      quality -= 1;
      photo = encodeJpg(image, quality: quality);
    }

    if (photo.lengthInBytes > maxPhotoSizeBytes) {
      throw PhotosServiceResizeException();
    }

    final String url = await requests.postBinary(
        '/photos', photo, 'image/jpeg', (v) => v['url']);
    return url;
  }

  Future<void> removePhoto(String url, RequestsService requests) async {
    try {
      final uri = Uri.parse(url);
      final key = uri.queryParameters['key'];
      await requests.delete('/photos', (v) => v, urlParams: {'key': key});
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
    }
  }
}

abstract class PhotosServiceException implements Exception {
  final String _message;
  PhotosServiceException(String message) : _message = message;

  @override
  String toString() {
    return 'Photos Service Exception: $_message';
  }
}

class PhotosServiceFormatException extends PhotosServiceException {
  PhotosServiceFormatException() : super('unknown image format');
}

class PhotosServiceResizeException extends PhotosServiceException {
  PhotosServiceResizeException() : super('failed to resize image');
}
