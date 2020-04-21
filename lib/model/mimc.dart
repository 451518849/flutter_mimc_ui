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
        appKey: "xxx",
        appSecret: "xxx/cxsSIQ==",
        appAccount: clientId);

    await instance.login();
  }

  static void sendText(String from, String to, String text) {
    MIMCMessage message = MIMCMessage();
    message.bizType = ImMessageType.text;
    message.fromAccount = from;
    message.toAccount = to;
    message.timestamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> payloadMap = {
      "from_account": from,
      "to_account": to,
      "biz_type": ImMessageType.text,
      "version": "0",
      "text": text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    };

    message.payload = json.encode(payloadMap);
    instance.sendMessage(message);
  }

  // 获取最近会话列表
  static Future<dynamic> getContacts() async {
    var res = await instance.getContact(isV2: true);
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

  static void receiveMessage(
      void Function(Map<String, dynamic> content) callback) {
    // 接收单聊
    instance.addEventListenerHandleMessage().listen((MIMCMessage message) {
      //第一步清除未读消息数
      // clearConversationUnreadMessagesCount(message.toAccount);
      callback(message.toJson());
    }).onError((err) {});
  }

  //所有的更新只能在extra字段上进行
  //更新消息中的extra字段
  static void updateMessage(String from, String to, String sequence,
      String extraKey, String extraValue) {
    instance.updatePullP2PExtraV2(
        toAccount: to,
        fromAccount: from,
        sequence: sequence,
        extraKey: extraKey,
        extraValue: extraValue);
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
