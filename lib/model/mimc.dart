import 'dart:convert';
import 'dart:math';

import 'package:flutter_mimc/flutter_mimc.dart';

import 'message.dart';

class MIMC {
  static String clientId;
  static FlutterMIMC instance;
  static Future<void> login(String clientId) async {
    MIMC.clientId = clientId;
    instance = await FlutterMIMC.init(
        debug: false,
        appId: "xxx",
        appKey: "1",
        appSecret: "1/cxsSIQ==",
        appAccount: clientId);

    await instance.login();
  }

  static void sendText(String from, String to, String text) {
    ImMessage message = ImMessage();
    message.fromAccount = from;
    message.toAccount = to;
    message.bizType = ImMessageType.text;
    message.timestamp = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> payloadMap = {
      "fromAccount": from,
      "toAccount": to,
      "bizType": ImMessageType.text,
      "version": "0",
      "text": text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    message.payload = json.encode(payloadMap);
    instance.sendMessage(message).then((res) {
      print('rres:${base64.decode(res)}');
    });
  }

  static void sendWhisper(String from, String to, num sequence, String type) {
    ImMessage message = ImMessage();
    message.fromAccount = from;
    message.toAccount = to;
    message.bizType = type;
    message.isStore = false;
    message.timestamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> payloadMap;
    if (type == ImMessageType.read) {
      payloadMap = {
        "messageId": sequence,
        "read": ImMessageReadType.read,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
    } else if (type == ImMessageType.recall) {
      payloadMap = {
        "messageId": sequence,
        "recall": ImMessageRecallType.recall,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
    }
    message.payload = json.encode(payloadMap);
    instance.sendMessage(message);
  }

  // 获取最近会话列表
  static Future<dynamic> getContacts() async {
    var res = await instance.getContact(isV2: true, msgExtraFlag: true);
    if (res.code == 200) {
      print("获取最近会话列表成功：${res.toJson()}");
      return res.data["contacts"];
    } else {
      print("获取最近会话列表失败:${res.message}");
      return [];
    }
  }

  // 拉取单聊消息记录(包含多个版本的接口)
  // static Future<dynamic> pullConversationHistoryMessages(String peerId) async {
  //   int thisTimer = DateTime.now().millisecondsSinceEpoch;
  //   String fromAccount = clientId;
  //   String toAccount = peerId;
  //   String utcFromTime = (thisTimer - 85400000).toString();
  //   String utcToTime = thisTimer.toString();
  //   var res = await instance.pullP2PHistory(PullHistoryType.queryOnCount,
  //       toAccount: toAccount,
  //       fromAccount: fromAccount,
  //       utcFromTime: utcFromTime,
  //       utcToTime: utcToTime);
  //   if (res.code == 200) {
  //     print("聊天记录：${res.data}");
  //     return res.data["messages"];
  //   } else {
  //     print("单聊消息记录执行失败:${res.message}");
  //     return [];
  //   }
  // }

  // 拉取单聊消息记录(包含多个版本的接口)
  static Future<dynamic> pullConversationHistoryMessages(
      String peerId, int count) async {
    int thisTimer = DateTime.now().millisecondsSinceEpoch;
    String fromAccount = clientId;
    String toAccount = peerId;
    String utcFromTime = (thisTimer - 85400000).toString();
    String utcToTime = thisTimer.toString();
    var res = await instance.pullP2PHistory(PullHistoryType.queryOnCount,
        toAccount: toAccount,
        fromAccount: fromAccount,
        utcFromTime: utcFromTime,
        count: count,
        utcToTime: utcToTime);
    if (res.code == 200) {
      print("聊天记录：${res.data}");
      return res.data["messages"];
    } else {
      print("单聊消息记录执行失败:${res.message}");
      return [];
    }
  }

  static void receiveMessage(void Function(ImMessage message) callback) {
    // 接收单聊
    instance.addEventListenerHandleMessage().listen((MIMCMessage message) {
      print('收到消息：');
      callback(ImMessage.fromJson(message.toJson(), encode: false));
    }).onError((err) {});
  }

  //所有的更新只能在extra字段上进行
  //更新消息中的extra字段
  static void updateMessage(String from, String to, num sequence,
      String extraKey, String extraValue) {
    Map<String, dynamic> extra = {extraKey: extraValue};
    instance.updatePullP2PExtra(
      toAccount: to,
      fromAccount: from,
      sequence: sequence.toString(),
      extra: json.encode(extra),
    );

    // instance.updatePullP2PExtraV2(
    //     toAccount: to,
    //     fromAccount: from,
    //     sequence: sequence.toString(),
    //     extraKey: 'read',
    //     extraValue: extraValue);
  }

  static void updateMessages(
      String from, String to, String sequence, String key, String value) {
    instance.updatePullP2PExtra(
        toAccount: to,
        fromAccount: from,
        sequence: sequence,
        extra: json.encode({key: value}));
  }

  static void updateConversationUnreadMessagesCount(String account, int count) {
    Map<String, dynamic> extra = {
      "unread_messages_count": count,
    };
    instance.updateContactP2PExtra(account: account, extra: json.encode(extra));
  }

  static void clearConversationUnreadMessages(
      String from, String to, String sequence) {
    updateMessages(from, to, sequence, "read", "1");
  }
}
