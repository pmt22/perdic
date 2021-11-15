import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perdic/constant.dart';
import 'package:perdic/translation.dart';
import 'dart:async';

class TranslationManipulate extends StatefulWidget {
  final Translation inputTranslation;
  final Set<Translation> existingTranslations;
  final FutureOr<void> Function() callback;

  const TranslationManipulate(
      this.inputTranslation, this.existingTranslations, this.callback,
      {Key? key})
      : super(key: key);

  @override
  _TranslationManipulateState createState() => _TranslationManipulateState();
}

class _TranslationManipulateState extends State<TranslationManipulate> {
  final _formKey = GlobalKey<FormState>();
  Translation? freshTranslation;

  @override
  Widget build(BuildContext context) {
    freshTranslation = translation.copy();
    return Scaffold(
        appBar: AppBar(
          title: Text(isCreation ? 'Thêm mới' : 'Chỉnh sửa'),
          actions: [
            Visibility(child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteTranslation(translation.id).then((value) {
                  widget.callback.call();
                  Navigator.pop(context);
                });
              },
            ),
              visible: !isCreation,
            )

          ],
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: isCreation ? null : translation.vi,
                  decoration: const InputDecoration(labelText: 'Tiếng Việt'),
                  validator: (val) => textValidation(val, true),
                  onChanged: (val) => {freshTranslation!.vi = val},
                ),
                TextFormField(
                  initialValue: isCreation ? null : translation.en,
                  decoration: const InputDecoration(labelText: 'Tiếng Anh'),
                  validator: (val) => textValidation(val, false),
                  onChanged: (val) => {freshTranslation!.en = val},
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isCreation) {
                          addTranslationToFirestore(freshTranslation!);
                        } else {
                          updateTranslation(freshTranslation!);
                        }
                        widget.callback.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lưu xong rồi đó')));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Lưu'))
              ],
            ),
          ),
        ));
  }

  Future<DocumentReference> addTranslationToFirestore(
      Translation addingTranslation) {
    return FirebaseFirestore.instance
        .collection(Constant.firestoreDictionary())
        .add(<String, dynamic>{
      'vi': addingTranslation.vi,
      'en': addingTranslation.en,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  void updateTranslation(Translation updatingTranslation) {
    FirebaseFirestore.instance
        .collection(Constant.firestoreDictionary())
        .doc(updatingTranslation.id)
        .update(<String, dynamic>{
      'vi': updatingTranslation.vi,
      'en': updatingTranslation.en,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<void> deleteTranslation(String? documentId) {
    return FirebaseFirestore.instance
        .collection(Constant.firestoreDictionary())
        .doc(documentId)
        .delete();
  }

  Translation get translation => widget.inputTranslation;

  bool get isCreation => translation.isEmpty();

  String? textValidation(value, bool isVi) {
    if (value == null || value.isEmpty) {
      return 'Nhập gì đó dùm cái bạn ei!!!';
    }

    if (widget.existingTranslations.contains(freshTranslation)) {
      return isCreation
          ? 'Cặp từ này có rồi, nhập khác đi nha'
          : 'Sửa mà không khác gì thì lưu chi nè';
    }
    return null;
  }
}
