import 'dart:convert';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'user.dart';

/*
//需要显示的消息格式
{
    "fromAccount":from_account
    "toAccount": to,
    "topicId":"",
    "bizType":"",
    "timestamp": DateTime.now().millisecondsSinceEpoch,
    "payload":{
      "messaegeId":messaegeId
      "fromAccount": from,
      "toAccount": to,
      "bizType": ImMessageType.text,
      "version": "0",
      "text": text,
      "meta":{duration,size,url}
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    }
    "extra":{"read":1}
  }

//不需要显示的消息格式，已读，撤销
{
    "fromAccount":from_account
    "toAccount": to,
    "bizType":read,recall
    "payload":{
      "messaegeId":messaegeId //sequence
      "read":1
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    }
  }
*/
class ImMessageType {
  static const String read = "read";
  static const String recall = "recall";

  static const String text = "text";
  static const String image = "image";
  static const String audio = "audio";
  static const String video = "video";
  static const String location = "location";
  static const String file = "file";
}

class ImMessageReadType {
  static const String unread = "0";
  static const String read = "1";
}

class ImMessageRecallType {
  static const String unrecall = "0";
  static const String recall = "1";
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
  ImMessageExtra extra;
  final ImMessagePayload secondaryPayload;
  ImMessage(
      {String toAccount,
      String fromAccount,
      String bizType,
      num timestamp,
      num sequence,
      int topicId,
      String payload,
      this.fromUser,
      this.toUser,
      this.secondaryPayload,
      this.extra})
      : super(
            sequence: sequence,
            toAccount: toAccount,
            bizType: bizType,
            timestamp: timestamp,
            fromAccount: fromAccount,
            topicId: topicId,
            payload: payload);

  factory ImMessage.fromJson(Map<dynamic, dynamic> jsonMap,
      {bool encode = true}) {
    print('ImMessage.fromJson:$jsonMap');

    String payload;
    if (encode) {
      payload = utf8.decode(base64.decode(jsonMap['payload']));
    } else {
      payload = jsonMap['payload'];
    }
    print('ImMessage.fromJson payload:$payload');

    bool hasExtra =
        (jsonMap['extra'] != null) && jsonMap['extra'].toString().length != 0;

    return ImMessage(
        sequence: num.parse(jsonMap['sequence'].toString()),
        toAccount: jsonMap['toAccount'],
        fromAccount: jsonMap['fromAccount'],
        bizType: jsonMap['bizType'],
        topicId: jsonMap['topicId'],
        payload: payload,
        extra: hasExtra
            ? ImMessageExtra.fromJson(json.decode(jsonMap['extra']))
            : null,
        secondaryPayload: ImMessagePayload.fromJson(json.decode(payload)),
        timestamp: jsonMap['timestamp'] ?? 0);
  }
}

class ImMessagePayload {
  final num messageId;
  final String toAccount;
  final String fromAccount;
  String bizType;
  final String version;
  final String text;
  final ImMessagePayloadMeta meta;
  final String read;
  ImMessagePayload(
      {this.messageId,
      this.bizType,
      this.toAccount,
      this.fromAccount,
      this.text,
      this.meta,
      this.read,
      this.version});

  factory ImMessagePayload.fromJson(Map<dynamic, dynamic> jsonMap) {
    return ImMessagePayload(
        messageId: jsonMap['messageId'] != null
            ? num.parse(jsonMap['messageId'].toString())
            : 0,
        read: jsonMap['read'],
        toAccount: jsonMap['toAccount'],
        fromAccount: jsonMap['fromAccount'],
        text: jsonMap['text'] ?? '',
        bizType: jsonMap['bizType'],
        meta: ImMessagePayloadMeta.fromJson(jsonMap['meta'] ?? {}),
        version: jsonMap['version'].toString());
  }
}

class ImMessageExtra {
  String read;
  String type;
  ImMessageExtra({this.read, this.type});

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
