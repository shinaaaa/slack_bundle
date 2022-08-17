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
  List<Message> messages = [];
  String _channel = "";
  List<DropdownMenuItem<String>> dropdownItems = [];
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
    if (isPublic) {
      List<Channels> channels =
          await ConversationService().callConversationsList("public_channel");
      channels.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        dropdownItems = channels.map((channel) {
          return DropdownMenuItem(value: channel.id, child: Text(channel.name));
        }).toList();
        _channel = channels.first.id;
      });
    } else {
      List<Channels> channels =
          await ConversationService().callConversationsList("private_channel");
      channels.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        dropdownItems = channels.map((channel) {
          return DropdownMenuItem(value: channel.id, child: Text(channel.name));
        }).toList();
        _channel = channels.first.id;
      });
    }
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
          margin: const EdgeInsets.fromLTRB(0, 70, 0, 30),
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
                  SendMessageService()
                      .callScheduledMessagesList(_channel)
                      .then((value) {
                    setState(() {
                      if (value == null) return;
                      messages = value.scheduledMessages;
                    });
                  });
                });
              },
              items: dropdownItems,
            )
          ])),
      messages.isEmpty
          ? const Expanded(
              child: Center(
                  child: Text(
              "예약 메시지가 없습니다.",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            )))
          : Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(70, 0, 70, 0),
                  child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (_, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              showDeletePopup(context, index);
                            },
                            title: Text(
                              messages[index].text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                                '예약 시간 : ${convertTime(messages[index].postAt)}'),
                          ),
                        );
                      })))
    ]));
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
                          messages[index].channelId, messages[index].id)
                      .then((value) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(value ? "삭제성공" : "삭제실패"),
                        backgroundColor:
                            value ? Colors.blueAccent : Colors.redAccent));
                    if (!value) return;
                    setState(() {
                      messages.removeAt(index);
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
