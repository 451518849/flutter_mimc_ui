import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mimc_ui/model/message.dart';
import 'package:flutter_mimc_ui/view/avatar.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_mimc_ui/view/gallery/video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../message.dart';

class VideoMessage extends StatefulWidget {
  final String avatarUrl;
  final Color color;
  final ImMessage message;
  final int messageAlign;

  VideoMessage(
      {Key key,
      this.avatarUrl,
      this.color = const Color(0xfffdd82c),
      this.message,
      this.messageAlign = MessageLeftAlign})
      : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  @override
  Widget build(BuildContext context) {
    _buildVideo(widget.message);
    return _buildVideoMessage(context);
  }

  Widget _buildVideoMessage(BuildContext context) {
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
              onTap: () => _pushToVideoPlayer(widget.message.secondaryPayload.meta.url, context),
              child: Container(
                height: 200,
                width: 100,
                margin: const EdgeInsets.only(bottom: 10, left: 4),
                child: widget.message.secondaryPayload.meta.thumbnailUrl == null
                    ? SizedBox()
                    : Image(
                        image: FileImage(File(widget.message.secondaryPayload.meta.thumbnailUrl)),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _pushToVideoPlayer(widget.message.secondaryPayload.meta.url, context),
        child: Container(
          margin: const EdgeInsets.only(right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 200,
                width: 100,
                margin: const EdgeInsets.only(bottom: 10, right: 4),
                child: widget.message.secondaryPayload.meta.thumbnailUrl == null
                    ? SizedBox()
                    : Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned(
                            child: Image(
                              image: FileImage(
                                  File(widget.message.secondaryPayload.meta.thumbnailUrl)),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 4,
                            bottom: 2,
                            child: Text(
                              '00:${widget.message.secondaryPayload.meta.duration}',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                          )
                        ],
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

  void _buildVideo(ImMessage message) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: message.secondaryPayload.meta.url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 100,
      quality: 25,
    );

    if (message.secondaryPayload.meta.thumbnailUrl == null && thumbnailPath != null) {
      message.secondaryPayload.meta.thumbnailUrl = thumbnailPath;
      setState(() {});
    }
  }

  void _pushToVideoPlayer(String url, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageVideoGalleryView(url: url)));
  }
}
