import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:perdic/search_list.dart';
import 'package:perdic/translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PerdicApp());
}

class PerdicApp extends StatelessWidget {
  const PerdicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Từ điển của Thảo',
      home: SearchList(),
    );
  }
}