import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slack_bundle/model/ScheduledMessage.dart';

import '../model/Conversations.dart';
import '../service/ConversationService.dart';
import '../service/SendMessageService.dart';

class ScheduleMessageListStatefulWidget extends StatefulWidget {
  const ScheduleMessageListStatefulWidget({Key? key}) : super(key: key);

  @override
  State<ScheduleMessageListStatefulWidget> createState() =>
      _ScheduleMessageListStatefulWidgetState();
}

class _ScheduleMessageListStatefulWidgetState
    extends State<ScheduleMessageListStatefulWidget> {
  List<Message> _messages = [];
  String _channel = "";
  List<DropdownMenuItem<String>> _dropdownItems = [];
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _createDropdownItems(_isPublic);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createDropdownItems(bool isPublic) async {
    String type = "public_channel";
    if (!isPublic) type = "private_channel";
    List<Channels> channels =
        await ConversationService().callConversationsList(type);
    if (channels.isEmpty) {
      setState(() {
        _dropdownItems = [
          const DropdownMenuItem(value: "0", child: Text('채널 없음'))
        ];
        _channel = "0";
      });
      _messages = [];
      return;
    }
    channels.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _dropdownItems = channels.map((channel) {
        return DropdownMenuItem(value: channel.id, child: Text(channel.name));
      }).toList();
      _channel = channels.first.id;
    });
    _callScheduledMessagesList();
  }

  String _channelType(bool isPublic) {
    if (isPublic) return "공개채널";
    return "비공개채널";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Container(
          margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 155,
              child: SwitchListTile(
                  title: Text(
                    _channelType(_isPublic),
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                      _createDropdownItems(_isPublic);
                    });
                  }),
            ),
            DropdownButton<String>(
              value: _channel,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _channel = newValue!;
                  _callScheduledMessagesList();
                });
              },
              items: _dropdownItems,
            )
          ])),
      _messages.isEmpty
          ? const Expanded(
              child: Center(
                  child: Text(
              "예약 메시지가 없습니다.",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            )))
          : Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(70, 30, 70, 0),
                  child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (_, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              showDeletePopup(context, index);
                            },
                            title: Text(
                              _messages[index].text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                '예약 시간 : ${convertTime(_messages[index].postAt)}'),
                          ),
                        );
                      })))
    ]));
  }

  void _callScheduledMessagesList() {
    SendMessageService().callScheduledMessagesList(_channel).then((value) {
      setState(() {
        if (value == null) return;
        _messages = value.scheduledMessages;
      });
    });
  }

  void showDeletePopup(BuildContext ctx, int index) {
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("알림"),
            content: const Text("예약문자를 삭제하시겠습니까?"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "Cancel");
                },
                child: const Text("취소"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "Ok");
                  SendMessageService()
                      .callDeleteScheduledMessagesList(
                          _messages[index].channelId, _messages[index].id)
                      .then((value) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(value ? "삭제성공" : "삭제실패"),
                        backgroundColor:
                            value ? Colors.blueAccent : Colors.redAccent));
                    if (!value) return;
                    setState(() {
                      _messages.removeAt(index);
                    });
                  });
                },
                child: const Text("삭제"),
              ),
            ],
          );
        });
  }

  String convertTime(int msTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(msTime * 1000);
    return DateFormat.yMd('ko_KR').add_Hm().format(dateTime);
  }
}

enum ResultType { success, fail, normal }
