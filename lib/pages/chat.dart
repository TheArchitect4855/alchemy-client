import 'dart:async';
import 'package:alchemy/components/confirmationdialog.dart';
import 'package:alchemy/components/report_profile.dart';
import 'package:alchemy/data/message.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/profile.dart';
import 'package:alchemy/services/match.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
import 'package:flutter/material.dart';

const messageChunkSize = 10;

class ChatPage extends StatefulWidget {
  final Profile profile;
  final void Function(Message message) onMessage;
  final void Function() onUnmatch;

  const ChatPage(this.profile, {required this.onMessage, required this.onUnmatch, super.key});

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _textController;
  late final Timer _pollTimer;
  final MatchService _matchService = MatchService.instance;
  final RequestsService _requestsService = RequestsService.instance;
  int _profileCurrentPhoto = 0;
  bool _loadedAll = false;
  List<Message>? _messages;
  int? _oldest;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _pollTimer = Timer.periodic(const Duration(minutes: 1), (_) => _loadMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          InkWell(
            onTap: _openProfile,
            splashFactory: NoSplash.splashFactory,
            child: CircleAvatar(backgroundImage: NetworkImage(widget.profile.photoUrls[0])),
          ),
          const SizedBox(width: 16),
          Text(widget.profile.name),
        ]),
        actions: [
          IconButton(
            onPressed: () => showDialog(context: context, builder: (_) => ReportProfile(widget.profile)),
            icon: const Icon(Icons.flag, color: Colors.black38),
          ),
          IconButton(
            onPressed: _unmatch,
            icon: const Icon(Icons.block, color: Colors.black38),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _messages?.isEmpty == true ? const Center(child: Text('No messages yet! Say something nice \u{2728}')) : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                itemBuilder: _buildMessage,
              )),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  suffixIcon: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.black38),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _pollTimer.cancel();
    super.dispose();
  }

  Widget? _buildMessage(BuildContext context, int index) {
    if (_messages != null && index >= _messages!.length && _loadedAll) {
      return null;
    } else if ((_messages == null && index == 0) || index == _messages?.length) {
      return const Center(child: CircularProgressIndicator());
    } else if (_messages == null || index > _messages!.length) {
      _loadMessages();
      return null;
    }

    final theme = Theme.of(context);
    final message = _messages![index];
    final Alignment alignment;
    final Color color;
    final EdgeInsets margin;
    if (message.isLocal) {
      alignment = Alignment.centerRight;
      color = HSVColor.fromColor(theme.colorScheme.primary).withSaturation(0.2).withValue(0.9).toColor();
      margin = const EdgeInsets.fromLTRB(32, 4, 4, 4);
    } else {
      alignment = Alignment.centerLeft;
      color = HSVColor.fromColor(theme.colorScheme.secondary).withSaturation(0.2).withValue(0.9).toColor();
      margin = const EdgeInsets.fromLTRB(4, 4, 32, 4);
    }

    return Align(
      alignment: alignment,
      widthFactor: 1,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SelectableText(message.content),
      ),
    );
  }

  void _loadMessages() async {
    try {
      final messages = await _matchService.getMessages(
        widget.profile.uid,
        messageChunkSize,
        _requestsService,
        olderThan: _oldest,
      );

      setState(() {
        _messages ??= [];
        if (messages.isEmpty) {
          _loadedAll = true;
          return;
        }

        if (messages.length < messageChunkSize) {
          _loadedAll = true;
        }

        _messages!.addAll(messages);
        final oldest = messages.last.id;
        if (_oldest == null || oldest < _oldest!) {
          _oldest = oldest;
        } else if (oldest >= _oldest!) {
          _loadedAll = true;
        }
      });
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Failed to load messages');
    }
  }

  void _openProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(
      widget.profile,
      currentPhoto: _profileCurrentPhoto,
      isLiked: true,
      onLike: null,
      onPhotoChanged: (photo) => setState(() {
        _profileCurrentPhoto = photo;
      }),
    )));
  }

  void _sendMessage() async {
    String content = _textController.text;
    if (content.trim().isEmpty) return;
    _textController.text = '';

    try {
      final message = await _matchService.sendMessage(widget.profile.uid, content, _requestsService);
      setState(() {
        if (_messages == null) {
          _messages = [ message ];
        } else {
          _messages!.insert(0, message);
        }
      });

      widget.onMessage(message);
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Failed to send message');
    }
  }

  void _unmatch() async {
    final confirm = await ConfirmationDialog(
      action: 'Unmatch',
      detail: 'Are you sure you want to unmatch with ${widget.profile.name}? You will not longer be able to message with them. This cannot be undone.',
    ).show(context);

    if (confirm) {
      widget.onUnmatch();
      if (mounted) Navigator.pop(context);
    }
  }
}
