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
  List<DropdownMenuItem<String>> dropdownItems = [];
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _createDropdownItems(_isPublic);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  });
                },
                items: dropdownItems,
              ),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.fromLTRB(70, 30, 70, 60),
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.blue))),
              width: 200,
              child: Text(_fileName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () async {
              FilePickerResult? filePickerResult =
                  await _filePicker.pickFiles();
              setState(() {
                if (filePickerResult == null) return;
                _fileName = filePickerResult.files.single.name;
                _filePath = filePickerResult.files.single.path!;
              });
            },
            icon: const Icon(Icons.file_upload),
            label: const Text("첨부 파일"),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_sharp),
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
            label: const Text('SEND MESSAGE'),
          ),
        ])
      ]),
    ));
  }

  void showSendMessageResultSnackBar(BuildContext context, value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? "전송 성공" : "전송 실패"),
        backgroundColor: value ? Colors.blueAccent : Colors.redAccent));
  }
}
