import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mimc_ui/model/message.dart';
import 'package:flutter_mimc_ui/view/avatar.dart';
import 'package:bubble/bubble.dart';

import '../message.dart';

class AudioMessage extends StatefulWidget {
  final ImMessage message;
  final int messageAlign;
  final String avatarUrl;
  final Color color;
  AudioMessage(
      {Key key, this.message, this.messageAlign, this.avatarUrl, this.color})
      : super(key: key);

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  bool _isVoice = false;
  String _speakVoiceMessageId;

  @override
  Widget build(BuildContext context) {
    return _buildVoiceMessage(context);
  }

  Widget _buildVoiceMessage(BuildContext context) {
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
            GestureDetector(
              onTap: () =>
                  _speakVoice(widget.message.messageId, widget.message.secondaryPayload.meta.url),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10, left: 4),
                child: Bubble(
                  stick: true,
                  nip: BubbleNip.leftTop,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/speak_left.png',
                        width: 20,
                        height: 20,
                      ),
                      Container(
                          child: Text(''' ${widget.message.secondaryPayload.meta.duration}'' ''')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _speakVoice(widget.message.messageId, widget.message.secondaryPayload.meta.url),
        child: Container(
          margin: const EdgeInsets.only(right: 10, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 80.0 + widget.message.secondaryPayload.meta.duration,
                margin: const EdgeInsets.only(bottom: 10, right: 4),
                child: Bubble(
                  stick: true,
                  nip: BubbleNip.rightTop,
                  color: widget.color,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          child: Text(''' ${widget.message.secondaryPayload.meta.duration}'' ''')),
                      Image.asset(
                        'assets/images/speak_right.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: ImAvatar(avatarUrl: widget.avatarUrl),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _speakVoice(String messageId, String path) {
    if (_speakVoiceMessageId == messageId && _isVoice == true) {
      audioPlayer.stop();
      _isVoice = false;
    } else {
      if (!_isVoice) {
        _playVoice(path);
        _isVoice = true;
      } else {
        audioPlayer.stop();
        _playVoice(path);
        _isVoice = true;
      }
    }
    _speakVoiceMessageId = messageId;
  }

  void _playVoice(String path) async {
    if (path.contains("http")) {
      await audioPlayer.play(path).then((_) {
        _isVoice = false;
      });
    } else {
      await audioPlayer.play(path, isLocal: true).then((_) {
        _isVoice = false;
      });
    }
  }
}
