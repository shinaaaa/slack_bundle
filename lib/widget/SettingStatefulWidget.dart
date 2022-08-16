import 'package:flutter/material.dart';

import '../util/Preferences.dart';

class SettingStatefulWidget extends StatefulWidget {
  const SettingStatefulWidget({Key? key}) : super(key: key);

  @override
  State<SettingStatefulWidget> createState() => _SettingStatefulWidgetState();
}

class _SettingStatefulWidgetState extends State<SettingStatefulWidget> {
  late TextEditingController _tokenController;
  late TextEditingController _channelController;
  String _token = "";
  String _channel = "";

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    _channelController = TextEditingController();
    Preferences.getToken().then((value) {
      _token = value;
      _tokenController.text = value;
    });
    Preferences.getChannel().then((value) {
      _channel = value;
      _channelController.text = value;
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Channel : "),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _channelController,
              onChanged: (text) {
                setState(() {
                  _channel = text;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  Preferences.setChannel(_channel).then((value) {
                    showSaveSnackBar(context, value);
                  });
                });
              },
              icon: const Icon(Icons.save),
              label: const Text("저장"))
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Token : "),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(prefixText: "Bearer "),
              controller: _tokenController,
              obscureText: false,
              onChanged: (text) {
                setState(() {
                  _token = text;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  Preferences.setToken(_token).then((value) {
                    showSaveSnackBar(context, value);
                  });
                });
              },
              icon: const Icon(Icons.save),
              label: const Text("저장"))
        ],
      )
    ]));
  }

  void showSaveSnackBar(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? "저장 성공" : "저장실패"),
        backgroundColor: value ? Colors.blueAccent : Colors.redAccent));
  }
}
