import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perdic/constant.dart';
import 'package:perdic/translation.dart';
import 'package:perdic/translation_manipulate.dart';

class SearchList extends StatefulWidget {
  const SearchList({Key? key}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  final _formKey = GlobalKey<FormState>();

  final filteredSet = <Translation>{};
  final translationSet = <Translation>{};
  final passcodeSet = <String>{};
  var searchText = '';
  bool authorized = true;
  StreamController<String> dictionarySize = StreamController();

  @override
  Widget build(BuildContext context) {
    return authorized ? authorizedMain() : unauthorizedMain();
  }

  Scaffold unauthorizedMain() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passcode'),
      ),
      body: FutureBuilder(
          future: getCollectionAuthorization(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                "Hình như có lỗi gì rồi, thử lại sau nhé",
                style: TextStyle(color: Colors.red),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              for (var document in snapshot.data!.docs) {
                passcodeSet.add(document.data()['passcode']);
              }

              return Center(
                  child: Form(
                      key: _formKey,
                      child: Container(
                        width: 300,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Passcode',
                              hintStyle: TextStyle(fontWeight: FontWeight.w100)),
                          obscureText: true,
                          autofocus: true,
                          validator: (value) {
                            if (!passcodeSet.contains(value)) {
                              return 'Passcode sai bét rồi';
                            }
                          },
                          onFieldSubmitted: (val) {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                authorized = true;
                              });
                            }
                          },
                        ),
                      )));
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Scaffold authorizedMain() {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(stream: dictionarySize.stream, builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return Text(snapshot.data!);
          }
          return const Text('Danh sách');
        },),
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
              resetFilteredSet();
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
                    Translation(document.data()['vi'], document.data()['en']);
                translation.note = document.data()['note'];
                translation.id = document.id;
                translationSet.add(translation);
              }

              resetFilteredSet();

              dictionarySize.add('Danh sách (' + currentSetSize().toString() + ')');

              return Expanded(child: buildTranslationList());
            }

            return const Center(child: CircularProgressIndicator());
          },
        )
      ],
    );
  }

  currentSetSize() => (searchText.isEmpty ? translationSet.length : filteredSet.length);

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
        .orderBy('en')
        .get();
  }

  getCollectionAuthorization() {
    return FirebaseFirestore.instance
        .collection(Constant.firestoreAuthorization())
        .get();
  }

  void resetFilteredSet() {
    if (searchText.isNotEmpty) {
      filteredSet.clear();
      filteredSet.addAll(translationSet);
      filteredSet.retainWhere((trans) => trans.contains(searchText));
    }
  }
}
