import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';

class ReportProfile extends StatefulWidget {
  final Profile profile;

  const ReportProfile(this.profile, {super.key});

  @override
  State<StatefulWidget> createState() => _ReportProfileState();
}

class _ReportProfileState extends State<ReportProfile> {
  String _reportReason = '';
  String? _reportError;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.flag),
      title: const Text('Report Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.profile.name} will not be notified.'),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Reason',
              helperText: 'Please provide a reason for your report.',
              errorText: _reportError,
              errorMaxLines: 3,
              helperMaxLines: 3,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            maxLines: 5,
            onChanged: (v) => setState(() {
              _reportReason = v;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitReport,
          child: const Text('Submit Report'),
        ),
      ],
    );
  }

  void _submitReport() async {
    if (_reportReason.trim().isEmpty) {
      setState(() {
        _reportError = 'Report reason cannot be empty.';
      });

      return;
    }

    try {
      await RequestsService.instance.post('/profile/report', {
        'contact': widget.profile.uid,
        'reason': _reportReason,
      }, (v) => v);

      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      setState(() {
        _reportError = 'Failed to submit report.';
      });
    }
  }
}
