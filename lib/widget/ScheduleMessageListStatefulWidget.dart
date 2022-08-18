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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.fromLTRB(70, 65, 70, 30),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _channelTypeSelect(),
                const SizedBox(width: 20),
                _channelDropdown()
              ]),
              _messages.isEmpty
                  ? const Expanded(
                      child: Center(
                          child: Text(
                      "예약 메시지가 없습니다.",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                    )))
                  : const SizedBox(height: 10),
              Expanded(
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
                      }))
            ])));
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

  Container _channelDropdown() {
    return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        height: 30,
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(200, 200, 200, 1)),
            borderRadius: BorderRadius.circular(5)),
        child: DropdownButton<String>(
          value: _channel,
          icon: const Icon(Icons.expand_more),
          style: const TextStyle(color: Color(0xff281E26)),
          underline: DropdownButtonHideUnderline(child: Container()),
          onChanged: (String? newValue) {
            setState(() {
              _channel = newValue!;
            });
          },
          items: _dropdownItems,
        ));
  }

  Stack _channelTypeSelect() {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
          width: 185,
          height: 30,
          decoration: BoxDecoration(
              color: const Color.fromRGBO(235, 235, 235, 1),
              border: Border.all(color: Colors.transparent),
              borderRadius: const BorderRadius.all(Radius.circular(25)))),
      Positioned(
          left: 0,
          child: Container(
              width: 96,
              decoration: !_isPublic
                  ? null
                  : BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.transparent, width: 1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25))),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isPublic = true;
                      _createDropdownItems(_isPublic);
                    });
                  },
                  child: Text("공개채널",
                      style: _isPublic
                          ? const TextStyle(color: Colors.white)
                          : const TextStyle(
                              color: Color.fromRGBO(150, 150, 150, 1)))))),
      Positioned(
          right: 0,
          child: Container(
              width: 100,
              decoration: _isPublic
                  ? null
                  : BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.transparent, width: 1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(25))),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isPublic = false;
                      _createDropdownItems(_isPublic);
                    });
                  },
                  child: Text("비공개채널",
                      style: !_isPublic
                          ? const TextStyle(color: Colors.white)
                          : const TextStyle(
                              color: Color.fromRGBO(150, 150, 150, 1))))))
    ]);
  }

  String convertTime(int msTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(msTime * 1000);
    return DateFormat.yMd('ko_KR').add_Hm().format(dateTime);
  }
}

enum ResultType { success, fail, normal }
