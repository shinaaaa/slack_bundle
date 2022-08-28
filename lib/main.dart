import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'widget/ScheduleMessageListStatefulWidget.dart';
import 'widget/ScheduleMessageStatefulWidget.dart';
import 'widget/SendMessageStatefulWidget.dart';
import 'widget/SettingStatefulWidget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Nanum_Gothic",
          textTheme: const TextTheme(
              bodyText1: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              bodyText2: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              button: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''),
      ],
      home: const MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    SendMessageStatefulWidget(),
    ScheduleMessageStatefulWidget(),
    ScheduleMessageListStatefulWidget(),
    SettingStatefulWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _menuTitle = <String>[
    "메시지 발송",
    "예약 메시지",
    "예약 목록",
    "설정",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_menuTitle.elementAt(_selectedIndex))),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              elevation: 30,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.message),
                  label: _menuTitle.elementAt(0),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.event),
                  label: _menuTitle.elementAt(1),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.list),
                  label: _menuTitle.elementAt(2),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: _menuTitle.elementAt(3),
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              onTap: _onItemTapped,
            )));
  }
}
