import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mimc_ui/model/message.dart';
import 'package:flutter_mimc_ui/view/avatar.dart';

import '../message.dart';

class TextMessage extends StatefulWidget {
  final ImMessage message;
  final int messageAlign;
  final String avatarUrl;
  final Color color;

  TextMessage(
      {Key key, this.message, this.messageAlign, this.avatarUrl, this.color})
      : super(key: key);

  @override
  _TextMessageState createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  @override
  Widget build(BuildContext context) {
    return _buildTextMessage();
  }

  Widget _buildTextMessage() {
    if (widget.messageAlign == MessageLeftAlign) {
      return Container(
        margin: const EdgeInsets.only(left: 10, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ImAvatar(
                avatarUrl: widget.avatarUrl,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Text(widget.message.secondaryPayload.text,
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0)),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 2, right: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  constraints: BoxConstraints(maxWidth: 250),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Text(widget.message.secondaryPayload.text,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16.0)),
                ),
                widget.message.extra?.read == ImMessageReadType.read
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Text(
                          '已读',
                          textAlign: TextAlign.right,
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Text(
                          '未读',
                          textAlign: TextAlign.right,
                          style:
                              TextStyle(fontSize: 10, color: Colors.blue[400]),
                        ),
                      ),
              ],
            ),
            Container(
              child: ImAvatar(avatarUrl: widget.avatarUrl),
            ),
          ],
        ),
      );
    }
  }
}
