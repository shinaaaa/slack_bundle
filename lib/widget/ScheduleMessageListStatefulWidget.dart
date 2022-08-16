import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slack_bundle/model/ScheduledMessage.dart';

import '../service/SlackService.dart';
import '../util/Preferences.dart';

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

  @override
  void initState() {
    super.initState();
    Preferences.getChannel().then((channel) {
      _channel = channel;
      SlackService().callScheduledMessagesList(_channel).then((value) {
        setState(() {
          if (value == null) return;
          messages = value.scheduledMessages;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('예약 목록')),
        body: Container(
            margin: const EdgeInsets.fromLTRB(70, 30, 70, 0),
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                    "예약 메시지가 없습니다.",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ))
                : ListView.builder(
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
                    })));
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
                  SlackService()
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
