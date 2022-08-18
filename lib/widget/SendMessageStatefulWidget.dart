import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:slack_bundle/service/ConversationService.dart';

import '../model/Conversations.dart';
import '../service/SendMessageService.dart';

class SendMessageStatefulWidget extends StatefulWidget {
  const SendMessageStatefulWidget({Key? key}) : super(key: key);

  @override
  State<SendMessageStatefulWidget> createState() =>
      _SendMessageStatefulWidgetState();
}

class _SendMessageStatefulWidgetState extends State<SendMessageStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  final FilePicker _filePicker = FilePicker.platform;
  late TextEditingController _controller;
  var _msg = "";
  String _fileName = "";
  String _filePath = "";
  String _channel = "";
  List<DropdownMenuItem<String>> _dropdownItems = [];
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _createDropdownItems(_isPublic);
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
        return DropdownMenuItem(value: channel.id, child: Text(channel.name));
      }).toList();
      _channel = channels.first.id;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                margin: const EdgeInsets.fromLTRB(70, 60, 70, 30),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    _channelTypeSelect(),
                    const SizedBox(width: 15),
                    _channelDropdown()
                  ]),
                  const SizedBox(height: 10),
                  _messageForm(),
                  // textSection,
                  Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color:
                                          Color.fromRGBO(150, 150, 150, 1)))),
                          width: 200,
                          child: Text(_fileName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color.fromRGBO(150, 150, 150, 1))),
                          onPressed: () async {
                            FilePickerResult? filePickerResult =
                                await _filePicker.pickFiles();
                            setState(() {
                              if (filePickerResult == null) return;
                              _fileName = filePickerResult.files.single.name;
                              _filePath = filePickerResult.files.single.path!;
                            });
                          },
                          child: const Text("첨부 파일"))
                    ]),
                    const SizedBox(height: 50),
                    SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(
                            icon: const Icon(Icons.send_sharp, size: 18),
                            onPressed: () {
                              if (_filePath.isEmpty) {
                                if (!_formKey.currentState!.validate()) return;
                                SendMessageService()
                                    .callPostMessage(_channel, _msg)
                                    .then((value) {
                                  if (value) _controller.text = "";
                                  showSendMessageResultSnackBar(context, value);
                                });
                                return;
                              }
                              SendMessageService()
                                  .callFileUpload(_channel, _msg, _filePath)
                                  .then((value) {
                                showSendMessageResultSnackBar(context, value);
                              });
                            },
                            label: const Text('SEND MESSAGE')))
                  ])
                ]))));
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

  void showSendMessageResultSnackBar(BuildContext context, value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? "전송 성공" : "전송 실패"),
        backgroundColor: value ? Colors.blueAccent : Colors.redAccent));
  }
}
