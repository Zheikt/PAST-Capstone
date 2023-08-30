import 'dart:convert';
import 'dart:developer';

import 'package:past_client/classes/auth_token.dart';
import 'package:past_client/classes/request.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:stream_channel/stream_channel.dart';

class WSConnector {
  late final WebSocketChannel channel;

  WSConnector(String uri, AuthToken token) {
    try {
      channel = WebSocketChannel.connect(Uri.parse(uri));

      channel.ready.then((value) =>
          sendMessage(Request(operation: 'verify-auth', service: 'wss', data: {
            'userId': token.owner,
            'authToken': {'token': token.token, 'validUntil': token.validUntil}
          })));
    } catch (ex, stackTrace){
      log(ex.toString(), stackTrace: stackTrace);
    }
  }

  void sendMessage(Request request) {
    channel.sink.add(jsonEncode(request));
  }

  void pipeStream(StreamChannel<dynamic> stream){
    channel.pipe(stream);
  }

  void closeConnection(){
    channel.sink.close();
  }
}
