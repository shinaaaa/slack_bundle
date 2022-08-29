import 'package:flutter/material.dart';

class Util {
  Future<DateTime?> getDatePicker(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
  }

  Future<TimeOfDay?> getTimePicker(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Loading...')
                      ])));
        });
  }

  static void dismissProgressDialog(BuildContext context) {
    Navigator.pop(context);
  }
}
