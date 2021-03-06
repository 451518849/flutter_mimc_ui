import 'package:flutter/material.dart';
import 'package:flutter_mimc/flutter_mimc.dart';
import 'package:flutter_mimc_ui/model/mimc.dart';

import 'model/user.dart';
import 'page/conversation.dart';
import 'page/conversation_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _clientId = "900";

  _login() async {
     MIMC.login(_clientId);
   /// init push api
  //  MIMCPush mImcPush = MIMCPush(mImcAppId: "", mImcAppKey: "", mImcAppSecret: "5MDFQRY==");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _login();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xiao Mi Im Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildChatViewBtn(),
            _buildConversationListView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatViewBtn() {
    return RaisedButton(
      child: Text('跳转去聊天界面'),
      onPressed: () {
        ImUser currentUser = ImUser(
            uid: _clientId,
            username: '张三',
            avatarUrl:
                'http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100');
        ImUser toUser = ImUser(
            uid: '1',
            username: '莉丝',
            avatarUrl:
                'http://thirdqq.qlogo.cn/g?b=oidb&k=h22EA0NsicnjEqG4OEcqKyg&s=100');

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ImConversationPage(
                    currentUser: currentUser,
                    toUser: toUser,
                  )),
        );
      },
    );
  }

  Widget _buildConversationListView(BuildContext context) {
    return RaisedButton(
      child: Text('跳转去最近联系人列表'),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImConversationListPage(currentUserId: _clientId,)),
        );
      },
    );
  }
}