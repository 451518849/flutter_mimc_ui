import 'dart:convert';

import 'package:flutter_mimc_ui/model/mimc.dart';
import 'package:flutter_mimc_ui/utils/date.dart';

import 'message.dart';

class ImConversations {
  final List<ImConversation> conversations;
  ImConversations({this.conversations});

  factory ImConversations.fromJson(List<dynamic> parsedJson) {
    List<ImConversation> conversations = List<ImConversation>();
    conversations = parsedJson.map((i) => ImConversation.fromJson(i)).toList();
    return ImConversations(conversations: conversations);
  }
}

class ImConversation {
  final String sequence;
  final String userType;

  final String lastMessageAt;
  ImMessage lastMessage;

  String appAccount;
  String peerId;
  String peerName;
  String peerAvatar;

  ImConversation({
    this.sequence,
    this.userType,
    this.lastMessageAt,
    this.appAccount,
    this.lastMessage,
    this.peerId,
    this.peerName,
    this.peerAvatar,
  });

  factory ImConversation.fromJson(Map<dynamic, dynamic> jsonMap) {
    String payload =
        jsonMap['lastMessage']['payload'].toString().replaceAll("\r\n", "");

    return ImConversation(
      sequence: jsonMap['sequence'],
      peerId: '0',
      peerAvatar:
          'http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100',
      peerName: '加载中...',
      lastMessageAt: tranImTime(int.parse(jsonMap['timestamp'])),
      lastMessage: ImMessage(
          fromAccount: jsonMap['lastMessage']['fromAccount'],
          toAccount: jsonMap['lastMessage']['toAccount'],
          extra: ImMessageExtra.fromJson(
              jsonMap['lastMessage']['msgExtra'].toString().length != 0
                  ? json.decode(jsonMap['lastMessage']['msgExtra'])
                  : {}),
          secondaryPayload: ImMessagePayload.fromJson(
              json.decode(utf8.decode(base64.decode(payload))))),
    );
  }
}

class ImConversationExtra {
  int unreadMessagesCount;
  ImConversationExtra({this.unreadMessagesCount});

  factory ImConversationExtra.fromJson(Map<dynamic, dynamic> jsonMap) {
    return ImConversationExtra(
        unreadMessagesCount: jsonMap['unread_messages_count'] ?? 0);
  }
}
