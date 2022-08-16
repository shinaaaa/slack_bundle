import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slack_bundle/util/Preferences.dart';

import '../service/SendMessageService.dart';
import '../util/Util.dart';

class ScheduleMessageStatefulWidget extends StatefulWidget {
  const ScheduleMessageStatefulWidget({Key? key}) : super(key: key);

  @override
  State<ScheduleMessageStatefulWidget> createState() =>
      _ScheduleMessageStatefulWidgetState();
}

class _ScheduleMessageStatefulWidgetState
    extends State<ScheduleMessageStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  late DateTime _date;
  late TimeOfDay _time;
  var _msg = "";
  String _channel = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _date = DateTime.now();
    _time = TimeOfDay.now();

    Preferences.getChannel().then((value) {
      _channel = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _reservationTime {
    DateTime time = DateFormat().dateTimeConstructor(_date.year, _date.month,
        _date.day, _time.hour, _time.minute, 0, 0, false);
    return "${time.millisecondsSinceEpoch ~/ 1000}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        Container(
            margin: const EdgeInsets.fromLTRB(0, 50, 0, 30),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(width: 50),
              ElevatedButton.icon(
                  onPressed: () {
                    Future<DateTime?> future = Util().getDatePicker(context);
                    future.then((date) {
                      setState(() {
                        if (date == null) return;
                        _date = date;
                      });
                    });
                  },
                  icon: const Icon(Icons.date_range),
                  label: const Text('Date')),
              const SizedBox(width: 10),
              Text(
                '${_date.year}.${_date.month}.${_date.day}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 50),
              ElevatedButton.icon(
                  onPressed: () {
                    Future<TimeOfDay?> future = Util().getTimePicker(context);
                    future.then((time) {
                      setState(() {
                        if (time == null) return;
                        _time = time;
                      });
                    });
                  },
                  icon: const Icon(Icons.access_time_sharp),
                  label: const Text('Time')),
              const SizedBox(width: 10),
              Text('${_time.hour}:${_time.minute}',
                  style: const TextStyle(fontSize: 20)),
            ])),
        Container(
            margin: const EdgeInsets.fromLTRB(70, 0, 70, 30),
            child: Form(
                key: _formKey,
                child: TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Message',
                        alignLabelWithHint: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    maxLength: 10000,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 10,
                    controller: _controller,
                    onChanged: (text) {
                      _msg = text;
                    }))),
        // textSection,
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.send_sharp),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  showSendPopup(context);
                },
                label: const Text('SEND MESSAGE'),
              )
            ])),
      ]),
    ));
  }

  Future<dynamic> showSendPopup(BuildContext ctx) {
    return showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("알림"),
              content: const Text("예약문자를 전송하시겠습니까?"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, "Cancel");
                  },
                  child: const Text("취소"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, "OK");
                    SendMessageService()
                        .callScheduleMessage(_channel, _reservationTime, _msg)
                        .then((value) {
                      if (value) _controller.text = "";
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(value ? "저장 성공" : "저장실패"),
                          backgroundColor:
                              value ? Colors.blueAccent : Colors.redAccent));
                    });
                  },
                  child: const Text("전송"),
                )
              ]);
        });
  }
}
