import 'package:alchemy/components/small_card.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/error.dart';
import 'package:alchemy/routing.dart';
import 'package:alchemy/services/photos.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadButton extends StatelessWidget {
  final void Function(String url)? onUploadComplete;
  final void Function(Future<String> urlFuture)? onUploadStart;
  final ImagePicker _imagePicker;

  PhotoUploadButton({super.key, this.onUploadComplete, this.onUploadStart})
    : _imagePicker = ImagePicker(),
    assert(onUploadComplete != null || onUploadStart != null);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _pickImage(context),
    child: const SmallCard(child: Icon(Icons.add, color: Colors.black38)),
  );

  void _pickImage(BuildContext context) async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 2048, maxHeight: 2048, requestFullMetadata: false);
      if (file == null) return;

      final urlFuture = PhotosService.instance.uploadPhoto(file, RequestsService.instance);
      if (onUploadStart != null) onUploadStart!(urlFuture);

      if (onUploadComplete != null) {
        final url = await urlFuture;
        onUploadComplete!(url);
      }
    } on PlatformException catch (e) {
      Logger.warn(runtimeType, 'Could not pick image: $e');
    } on RequestsServiceException catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
    }
  }
}
