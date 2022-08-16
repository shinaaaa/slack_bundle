import 'package:flutter/material.dart';
import 'package:slack_bundle/model/AuthTest.dart';
import 'package:slack_bundle/service/AuthTestService.dart';

import '../util/Preferences.dart';

class SettingStatefulWidget extends StatefulWidget {
  const SettingStatefulWidget({Key? key}) : super(key: key);

  @override
  State<SettingStatefulWidget> createState() => _SettingStatefulWidgetState();
}

class _SettingStatefulWidgetState extends State<SettingStatefulWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tokenController;
  AuthTest _auth = AuthTest(ok: false, team: "", url: "");
  String _token = "";
  bool _onClick = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
    Preferences.getToken().then((value) {
      _token = value;
      _tokenController.text = value;
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
        body: Column(children: [
      const SizedBox(
        height: 100,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("Token : "),
        SizedBox(
            width: 300,
            child: Form(
                key: _formKey,
                child: TextFormField(
                    decoration: const InputDecoration(prefixText: "Bearer "),
                    controller: _tokenController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {
                        _token = text;
                        _onClick = false;
                      });
                    }))),
        const SizedBox(width: 10),
        ElevatedButton.icon(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              AuthTestService().authTest(_token).then((value) {
                setState(() {
                  _onClick = true;
                  _auth = value;
                });
              });
            },
            icon: const Icon(Icons.check),
            label: const Text("검사"))
      ]),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        width: 470,
        child: _checkTestResult(),
      ),
      const SizedBox(
        height: 100,
      ),
      ElevatedButton.icon(
          style: const ButtonStyle(visualDensity: VisualDensity(horizontal: 4)),
          onPressed: () {
            if (!_auth.ok) {
              showSaveSnackBar(context, _auth.ok);
              return;
            }
            Preferences.setToken(_token).then((value) {
              showSaveSnackBar(context, value);
            });
          },
          icon: const Icon(Icons.save),
          label: const Text("저장"))
    ]));
  }

  void showSaveSnackBar(BuildContext context, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? "저장 성공" : "저장실패"),
        backgroundColor: value ? Colors.blueAccent : Colors.redAccent));
  }

  Card _checkTestResult() {
    if (!_onClick) {
      return const Card(
        child: ListTile(
          title: Text('토큰 검증'),
        ),
      );
    }
    if (_auth.ok) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: const Text('검증 성공'),
          subtitle: Text("Workspace : ${_auth.team}\nURL : ${_auth.url}"),
        ),
      );
    }

    return const Card(
      child: ListTile(
        leading: Icon(Icons.cancel_outlined, color: Colors.red),
        title: Text('검증 실패'),
      ),
    );
  }
}
