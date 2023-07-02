import 'package:alchemy/data/message.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/data/match.dart';

class MatchService {
  static final MatchService instance = MatchService();

  Future<List<Match>> getMatches(RequestsService requests) async {
    final res = (await requests.get('/matches', (v) => v['matches'] as List<dynamic>))!;
    final matches = res.map((e) => Match.fromJson(e)).toList();
    return matches;
  }

  Future<List<Message>> getMessages(String target, int limit, RequestsService requests, {
    int? olderThan,
  }) async {
    final args = {
      'target': target,
      'limit': limit.toString(),
    };

    if (olderThan != null) args['olderThan'] = olderThan.toString();
    final res = (await requests.get('/messages', (v) => v, urlParams: args))!;
    final messages = (res['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList();
    return messages;
  }

  Future<Message> sendMessage(String to, String content, RequestsService requests) async {
    final message = (await requests.post('/messages', {
      'to': to,
      'message': content,
    }, Message.fromJson))!;

    return message;
  }

  Future<List<Match>> unmatch(String target, RequestsService requests) async {
    final res = (await requests.delete('/likes', (v) => v, urlParams: {
      'target': target,
    }))!;

    final matches = (res['matches'] as List<dynamic>).map((e) => Match.fromJson(e)).toList();
    return matches;
  }
}
