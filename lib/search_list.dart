import 'package:flutter/material.dart';
import 'package:perdic/constant.dart';
import 'package:perdic/translation.dart';
import 'package:perdic/translation_manipulate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SearchList extends StatefulWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final filteredSet = <Translation>{};
  final translationSet = <Translation>{};
  var searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  onAddButtonClicked();
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: buildBody(),
    );
  }

  void onAddButtonClicked() {
    navigateToTranslationManipulate(null);
  }

  void navigateToTranslationManipulate(Translation? translation) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return TranslationManipulate(
          translation ?? Translation.empty, translationSet, () {
        setState(() {
          translationSet.clear();
        });
      });
    }));
  }

  Widget buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(
              hintText: 'Tìm kiếm bằng tiếng Việt và Anh',
              hintStyle: TextStyle(fontWeight: FontWeight.w100)),
          autofocus: true,
          onChanged: (str) {
            setState(() {
              searchText = str;
              filteredSet.clear();
              if (str.isNotEmpty) {
                filteredSet.addAll(translationSet);
                filteredSet.retainWhere((trans) => trans.contains(str));
              }
            });
          },
        ),
        FutureBuilder(
          future: getCollectionDictionary(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                "Hình như có lỗi gì rồi, thử lại sau nhé",
                style: TextStyle(color: Colors.red),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Text("Danh sách chưa có gì hết");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              for (var document in snapshot.data!.docs) {
                Translation translation =
                    Translation(document['vi'], document['en']);
                translation.id = document.id;
                translationSet.add(translation);
              }

              return Expanded(child: buildTranslationList());
            }

            return const Center(child: CircularProgressIndicator());
          },
        )
      ],
    );
  }

  Widget buildTranslationList() {
    final tiles = getListToBuild().map((trans) {
      return ListTile(
        title: Text(trans.toString()),
        onTap: () {
          navigateToTranslationManipulate(trans);
        },
      );
    });

    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(tiles: tiles, context: context).toList()
        : <Widget>[];
    return ListView(children: divided);
  }

  Iterable getListToBuild() {
    return searchText.isNotEmpty ? filteredSet : translationSet;
  }

  getCollectionDictionary() {
    return FirebaseFirestore.instance
        .collection(Constant.firestoreDictionary())
        .orderBy('vi')
        .get();
  }
}
