import 'package:alchemy/components/bigbutton.dart';
import 'package:alchemy/components/bottomcard.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

const maxPlacemarkInfoLen = 128;

class UnavailablePage extends StatelessWidget {
  const UnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const BottomCard(
        title: 'Unavailable',
        children: [
          Text('Alchemy is not yet available in your area.'),
        ],
      );
    }

    return BottomCard(
      title: 'Unavailable',
      children: [
        const Text('Alchemy is not yet available in your area. If you\'d like, you can join the waiting list and we\'ll notify you once the app is available.'),
        const SizedBox(height: 16),
        BigButton(text: 'Join the Waiting List', onPressed: () => _joinWaitingList(context)),
      ],
    );
  }

  void _joinWaitingList(BuildContext context) async {
    try {
      final locationService = LocationService.instance;
      final location = await locationService.getLocation();
      final placemark = await locationService.getPlacemark(location);
      if (placemark == null || placemark.country == null || placemark.administrativeArea == null || placemark.locality == null) {
        throw _PlacemarkDataException(placemark);
      }

      var administrativeArea = placemark.administrativeArea!;
      if (administrativeArea.length > maxPlacemarkInfoLen) administrativeArea = administrativeArea.substring(0, maxPlacemarkInfoLen);

      var locality = placemark.locality!;
      if (locality.length > maxPlacemarkInfoLen) locality = locality.substring(0, maxPlacemarkInfoLen);

      await RequestsService.instance.post('/waitinglist', {
        'isoCountry': placemark.isoCountryCode,
        'administrativeArea': administrativeArea,
        'locality': locality,
      }, (v) => v);

      textSnackbar(context, 'You\'re on the waiting list!');
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Error joining wait list');
    }
  }
}

class _PlacemarkDataException implements Exception {
  final Placemark? placemark;

  _PlacemarkDataException(this.placemark);

  @override
  String toString() {
    if (placemark == null) return 'Placemark is null';
    return 'Placemark contains null values: $placemark';
  }
}
