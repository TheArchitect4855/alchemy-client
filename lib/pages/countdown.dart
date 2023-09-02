import 'dart:async';
import 'dart:math';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/init.dart';
import 'package:alchemy/services/explore.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

const previewSize = 4;
const previewCount = previewSize * previewSize;

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<StatefulWidget> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  late final Future<List<ImageProvider>> _imageSlicesFuture;
  late final Timer _timer;
  late String _countdown;
  final List<ImageProvider> _previewImages = [];
  DateTime _lastExploreUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _imageSlicesFuture = _createImageSlices();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    _countdown = _getCountdown();
    _loadPreviewProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(body: SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/icon.png', height: 130),
          Text(_countdown, style: theme.textTheme.displayLarge, textAlign: TextAlign.center),
          const Text("You'll be able to start matching once the timer runs out. Check back regularly to see who's in your area!", textAlign: TextAlign.center),
          Expanded(child: FutureBuilder(
            future: _imageSlicesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return LayoutBuilder(
                  builder: (context, constraints) => Wrap(
                    children: _buildPreviewProfiles(constraints, snapshot.data!),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          )),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Widget> _buildPreviewProfiles(BoxConstraints constraints, List<ImageProvider> imageSlices) {
    const margin = 8.0;
    final res = <Widget>[];
    final width = constraints.maxWidth / previewSize - margin * 2;
    final height = constraints.maxHeight / previewSize - margin * 2;
    for (var i = 0; i < previewCount; i += 1) {
      final image = i < _previewImages.length ? _previewImages[i] : imageSlices[i];
      res.add(Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(margin),
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(image: image, fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [ BoxShadow(color: Colors.black54, offset: Offset(4, 4), blurRadius: 4) ]
          ),
          position: DecorationPosition.foreground,
        ),
      ));
    }

    return res;
  }

  Future<List<ImageProvider>> _createImageSlices() async {
    const sliceSize = 256;
    final data = await rootBundle.load('assets/blobs.png');
    final source = image.decodePng(Uint8List.view(data.buffer))!;
    final rng = Random();
    List<ImageProvider> slices = [];
    for (int i = 0; i < previewCount; i += 1) {
      final x = rng.nextInt(source.width - sliceSize);
      final y = rng.nextInt(source.height - sliceSize);
      final slice = image.copyCrop(source, x: x, y: y, width: sliceSize, height: sliceSize);
      final data = image.encodePng(slice);
      slices.add(MemoryImage(data));
    }

    return slices;
  }

  String _getCountdown() {
    var remaining = liveDate.difference(DateTime.now()).inSeconds;
    final days = (remaining / 86400).floor();
    remaining %= 86400;
    final hours = (remaining / 3600).floor().toString().padLeft(2, '0');
    remaining %= 3600;
    final minutes = (remaining / 60).floor().toString().padLeft(2, '0');
    remaining %= 60;
    final seconds = remaining.toString().padLeft(2, '0');
    return '$days:$hours:$minutes:$seconds';
  }

  void _loadPreviewProfiles() async {
    final profiles = await ExploreService.instance.getPotentialMatches(LocationService.instance, RequestsService.instance);
    _previewImages.clear();
    _previewImages.addAll(profiles.map((e) => NetworkImage(e.photoUrls[0])));
  }

  void _tick(Timer timer) {
    final now = DateTime.now();
    final d = now.difference(_lastExploreUpdate);
    if (d.inMinutes >= 5) {
      Logger.info(runtimeType, 'Refreshing preview profiles...');
      _loadPreviewProfiles();
      _lastExploreUpdate = now;
    }

    setState(() {
      _countdown = _getCountdown();
    });
  }
}
