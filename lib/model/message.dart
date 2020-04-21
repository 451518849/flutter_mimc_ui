import 'dart:convert';

import 'package:flutter_mimc/flutter_mimc.dart';

import 'user.dart';

class ImMessageType {
  static const String text = "text";
  static const String image = "image";
  static const String audio = "audio";
  static const String video = "video";
  static const String location = "location";
  static const String file = "file";
}

class ImMessages {
  final List<ImMessage> messages;
  ImMessages({this.messages});

  factory ImMessages.fromJson(List<dynamic> parsedJson) {
    List<ImMessage> messages = List<ImMessage>();
    messages = parsedJson.map((i) => ImMessage.fromJson(i)).toList();
    return ImMessages(messages: messages);
  }
}

class ImMessage extends MIMCMessage {
  final ImUser fromUser;
  final ImUser toUser;
  final ImMessageExtra extra;
  final String sequence;

  final ImMessagePayload secondaryPayload;

  ImMessage(
      {String toAccount,
      String fromAccount,
      String bizType,
      num timestamp,
      int topicId,
      String payload,
      this.sequence,
      this.fromUser,
      this.toUser,
      this.secondaryPayload,
      this.extra})
      : super(
            toAccount: toAccount,
            bizType: bizType,
            timestamp: timestamp,
            fromAccount: fromAccount,
            topicId: topicId,
            payload: payload);

  factory ImMessage.fromJson(Map<dynamic, dynamic> jsonMap) {
    String payload = utf8.decode(base64.decode(jsonMap['payload']));
    if (jsonMap['sequence'] == '158738207235697001') {
      return ImMessage(
          toAccount: "6",
          fromAccount: "1050",
          bizType: "text",
          extra: ImMessageExtra.fromJson({}),
          secondaryPayload: ImMessagePayload(text: '1232'),
          timestamp: jsonMap['timestamp'] ?? 0);
    }

    return ImMessage(
        toAccount: jsonMap['toAccount'],
        fromAccount: jsonMap['fromAccount'],
        bizType: jsonMap['bizType'],
        topicId: jsonMap['topic_id'],
        payload: payload,
        sequence: jsonMap['sequence'],
        extra: ImMessageExtra.fromJson(jsonMap['extra'].toString().length != 0
            ? json.decode(jsonMap['extra'])
            : {}),
        secondaryPayload: ImMessagePayload.fromJson(json.decode(payload)),
        timestamp: jsonMap['timestamp'] ?? 0);
  }
}

class ImMessagePayload {
  final String toAccount;
  final String fromAccount;
  String bizType;
  final String version;
  final String text;
  final ImMessagePayloadMeta meta;
  ImMessagePayload(
      {this.bizType,
      this.toAccount,
      this.fromAccount,
      this.text,
      this.meta,
      this.version});

  factory ImMessagePayload.fromJson(Map<dynamic, dynamic> jsonMap) {
    return ImMessagePayload(
        toAccount: jsonMap['to_account'],
        fromAccount: jsonMap['from_account'],
        text: jsonMap['text'] ?? '',
        bizType: jsonMap['biz_type'],
        meta: ImMessagePayloadMeta.fromJson(jsonMap['meta'] ?? {}),
        version: jsonMap['version']);
  }
}

class ImMessageExtra {
  String read;
  ImMessageExtra({this.read});

  factory ImMessageExtra.fromJson(Map<dynamic, dynamic> jsonMap) {
    print('ImMessagePayloadExtra :$jsonMap');
    return ImMessageExtra(read: jsonMap['read'] ?? "0");
  }
}

class ImMessagePayloadMeta {
  final int duration;
  final String size;
  final String url;
  String thumbnailUrl;

  ImMessagePayloadMeta({
    this.duration,
    this.size,
    this.url,
    this.thumbnailUrl,
  });

  factory ImMessagePayloadMeta.fromJson(Map<dynamic, dynamic> jsonMap) {
    return ImMessagePayloadMeta(
      duration: jsonMap['duration'],
      size: jsonMap['size'],
      url: jsonMap['url'],
    );
  }
}
