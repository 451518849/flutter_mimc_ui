import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart';
import 'package:flutter_mimc_ui/model/conversation.dart';
import 'package:flutter_mimc_ui/model/mimc.dart';
import 'package:flutter_mimc_ui/model/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'conversation.dart';

const String CONVERSATION_CHANNEL = "flutter_lc_im/conversations";

/*
 * 聊天了列表界面，目前是只加载最新的20条，有下拉刷新。 
 */
class ImConversationListPage extends StatefulWidget {
  final String title;
  final String currentUserId;

  ImConversationListPage({this.title = '最近联系人列表', this.currentUserId});
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ImConversationListPage> {
  List<ImConversation> _conversations = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //只有下拉刷新，上拉加载leancloud有些问题
  void _onRefresh() async {
    MIMC.getContacts().then((res) {
      List<ImConversation> conversations =
          ImConversations.fromJson(res).conversations;
      _loadData(conversations);
    });
  }

  Widget imRefreshHeader() {
    return ClassicHeader(
      refreshingText: "加载中...",
      idleText: "加载最新会话",
      completeText: '加载完成',
      releaseText: '松开刷新数据',
      failedIcon: null,
      failedText: '刷新失败，请重试。',
    );
  }

  @override
  void initState() {
    super.initState();

    MIMC.getContacts().then((res) {
      List<ImConversation> conversations =
          ImConversations.fromJson(res).conversations;

      for (int i = 0; i < conversations.length; i++) {
        conversations[i].appAccount = widget.currentUserId;

        if (conversations[i].appAccount ==
            conversations[i].lastMessage.fromAccount) {
          conversations[i].peerId = conversations[i].lastMessage.toAccount;
        } else {
          conversations[i].peerId = conversations[i].lastMessage.fromAccount;
        }
      }

      _loadData(conversations);
    });
  }

  void _loadData(List<ImConversation> conversations) {
    setState(() {
      if (conversations.length == 1) {
        //是否是更新未读消息的数据
        bool isUpdateUnreadMessage = false;

        if (!isUpdateUnreadMessage) {
          _conversations = conversations;
        }
      } else {
        _conversations = conversations;
      }
      _refreshController.refreshCompleted();
    });

    //根据用户id到自己的服务器上获取头像，然后更新UI
    List peerIds = List();
    for (var item in _conversations) {
      // peerIds.add(item.peerId);
      // http request
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _conversations.length == 0
          ? SizedBox()
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: imRefreshHeader(),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _conversations.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          print(_conversations[index].appAccount);
                          print(_conversations[index].peerId);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImConversationPage(
                                        currentUser: ImUser(
                                          uid: widget.currentUserId,
                                        ),
                                        toUser: ImUser(
                                          uid: _conversations[index].peerId,
                                          username:
                                              _conversations[index].peerName,
                                        ),
                                      )));
                        },
                        child: _buildListItem(_conversations[index]));
                  }),
            ),
    );
  }

  Widget _buildListItem(ImConversation conversation) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              conversation.lastMessage.fromAccount == widget.currentUserId ||
                      conversation.lastMessage.extra.read == "0"
                  ? Container(
                      margin: EdgeInsets.only(left: 20, top: 7),
                      padding: EdgeInsets.all(10),
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6.0),
                        // image url 去要到自己的服务器上去请求回来再赋值，这里使用一张默认值即可
                        image: DecorationImage(
                            image: NetworkImage(conversation.peerAvatar)),
                      ),
                    )
                  : Badge(
                      badgeContent: Text(
                        '1',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 20, top: 7),
                        padding: EdgeInsets.all(10),
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.0),
                          // image url 去要到自己的服务器上去请求回来再赋值，这里使用一张默认值即可
                          image: DecorationImage(
                              image: NetworkImage(conversation.peerAvatar)),
                        ),
                      ),
                    ),
              Container(
                margin: EdgeInsets.only(left: 6, top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        conversation.peerName,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: 280),
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                          '${conversation.lastMessage.secondaryPayload.text}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: 14, bottom: 18),
            child: Text(conversation.lastMessageAt,
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          )
        ],
      ),
    );
  }
}
