import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Prevod casovej peciatky (milisekundy) na formatovany datum
String getFormattedDateTime(num dt, [String pattern = 'yyyy-MM-dd']) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));

// Kratka sprava v spodnej casti obrazovky
void showMsg(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
