import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perdic/constant.dart';
import 'package:perdic/translation.dart';
import 'dart:async';

import 'package:perdic/word_category.dart';

class WordCategoryManipulate extends StatefulWidget {
  const WordCategoryManipulate({Key? key}) : super(key: key);

  @override
  State<WordCategoryManipulate> createState() => _WordCategoryManipulateState();
}

class _WordCategoryManipulateState extends State<WordCategoryManipulate> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Danh sách Từ loại'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        addNewRow();
                      });
                    },
                    icon: const Icon(Icons.add)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        submit();
                      });
                    },
                    icon: const Icon(Icons.check)),
              ],
            ),
            body: Form(
              key: _formKey,
              child: buildCategoryList()
            )
        )
    );
  }

  void addNewRow() {

  }

  Widget buildCategoryList() {
    final tiles = getListToBuild().map((wc) {
      return ListTile(

        title: TextFormField(
          initialValue: wc.toString(),
        )
        //   title: Row(
        //   children: [
        //     IconButton(
        //         onPressed: () {
        //           setState(() {
        //             removeRow();
        //           });
        //         },
        //         icon: const Icon(Icons.remove)),
        //     TextFormField(
        //       initialValue: wc.toString(),
        //     )
        //   ],
        // ),
      );
    });

    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(tiles: tiles, context: context).toList()
        : <Widget>[];
    return ListView(children: divided);
  }

  Iterable getListToBuild() {
    return [
      WordCategory('text1'), WordCategory('text2'), WordCategory('text3'),
      WordCategory('text1'), WordCategory('text2'), WordCategory('text3'),
      WordCategory('text1'), WordCategory('text2'), WordCategory('text3'),
      WordCategory('text1'), WordCategory('text2'), WordCategory('text3'),
      WordCategory('text1'), WordCategory('text2'), WordCategory('text3'),
    ];
  }

  getWordCategoryCollection() {
    return FirebaseFirestore.instance
        .collection(Constant.firestoreWordCategory())
        .get();
  }

  void submit() {

  }

  void removeRow() {

  }

}