import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slack_bundle/util/Preferences.dart';

import '../model/Conversations.dart';
import '../service/ConversationService.dart';
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
  List<DropdownMenuItem<String>> _dropdownItems = [];
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _createDropdownItems(_isPublic);
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
      return;
    }
    channels.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _dropdownItems = channels.map((channel) {
        return DropdownMenuItem(
            value: channel.id,
            child: Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
            ));
      }).toList();
      _channel = channels.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                margin: const EdgeInsets.fromLTRB(70, 60, 70, 30),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _selectTime(context),
                        Row(children: [
                          _channelTypeSelect(),
                          const SizedBox(width: 15),
                          _channelDropdown()
                        ])
                      ]),
                  const SizedBox(height: 10),
                  _messageForm(),
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 200,
                                height: 50,
                                child: ElevatedButton.icon(
                                    icon:
                                        const Icon(Icons.send_sharp, size: 18),
                                    onPressed: () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      Util.showProgressDialog(context);
                                      SendMessageService()
                                          .callScheduleMessage(
                                              _channel, _reservationTime, _msg)
                                          .then((value) {
                                        if (value) _controller.text = "";
                                        showSendMessageResultSnackBar(
                                            context, value);
                                      });
                                    },
                                    label: const Text('SEND MESSAGE')))
                          ]))
                ]))));
  }

  Row _selectTime(BuildContext context) {
    return Row(children: [
      Text('${_date.year}.${_date.month}.${_date.day}'),
      IconButton(
          iconSize: 18,
          color: const Color.fromRGBO(120, 120, 120, 1),
          onPressed: () {
            Util().getDatePicker(context).then((date) {
              setState(() {
                if (date == null) return;
                _date = date;
              });
            });
          },
          icon: const Icon(Icons.date_range)),
      const SizedBox(width: 10),
      Text(_time.format(context)),
      IconButton(
          iconSize: 18,
          color: const Color.fromRGBO(120, 120, 120, 1),
          onPressed: () {
            Util().getTimePicker(context).then((time) {
              setState(() {
                if (time == null) return;
                _time = time;
              });
            });
          },
          icon: const Icon(Icons.access_time_sharp))
    ]);
  }

  Container _channelDropdown() {
    return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        width: 120,
        height: 30,
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(200, 200, 200, 1)),
            borderRadius: BorderRadius.circular(5)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          isExpanded: true,
          value: _channel,
          icon: const Icon(Icons.expand_more),
          style: const TextStyle(color: Color(0xff281E26)),
          onChanged: (String? newValue) {
            setState(() {
              _channel = newValue!;
            });
          },
          items: _dropdownItems,
        )));
  }

  Form _messageForm() {
    return Form(
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
            }));
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
              decoration: _isSelectedButtonBoxDecoration(_isPublic),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isPublic = true;
                      _createDropdownItems(_isPublic);
                    });
                  },
                  child: Text("공개채널",
                      style: TextStyle(
                          color: _isSelectedButtonTextColor(_isPublic)))))),
      Positioned(
          right: 0,
          child: Container(
              width: 100,
              decoration: _isSelectedButtonBoxDecoration(!_isPublic),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isPublic = false;
                      _createDropdownItems(_isPublic);
                    });
                  },
                  child: Text("비공개채널",
                      style: TextStyle(
                          color: _isSelectedButtonTextColor(!_isPublic))))))
    ]);
  }

  BoxDecoration? _isSelectedButtonBoxDecoration(bool selected) {
    if (!selected) return null;
    return BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.transparent, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(25)));
  }

  Color _isSelectedButtonTextColor(bool selected) {
    if (selected) return Colors.white;
    return const Color.fromRGBO(150, 150, 150, 1);
  }

  void showSendMessageResultSnackBar(BuildContext context, value) {
    Util.dismissProgressDialog(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? "저장 성공" : "저장실패"),
        backgroundColor: value ? Colors.blueAccent : Colors.redAccent));
  }
}
