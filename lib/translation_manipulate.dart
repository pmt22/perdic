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
            Visibility(
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDeleteConfirmation(context);
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
                  autofocus: true,
                  initialValue: isCreation ? null : translation.vi,
                  decoration: const InputDecoration(labelText: 'Tiếng Việt'),
                  validator: (val) {
                    freshTranslation!.vi = val!;
                    return textValidation(val, true);
                  },
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  initialValue: isCreation ? null : translation.en,
                  decoration: const InputDecoration(labelText: 'Tiếng Anh'),
                  validator: (val) {
                    freshTranslation!.en = val!;
                    return textValidation(val, false);
                  },
                  onFieldSubmitted: (value) {
                    submit(context);
                  },
                ),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        submit(context);
                      },
                      child: const Text('Lưu')),
                )
              ],
            ),
          ),
        ));
  }

  void submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      var validation = validateTranslation();
      if (validation != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(validation),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating));
      } else {
        if (isCreation) {
          addTranslationToFirestore(freshTranslation!);
        } else {
          updateTranslation(freshTranslation!);
        }
        widget.callback.call();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lưu xong rồi đó'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AlertDialog(
                  title: Text('Xác nhận'),
                  content: Center(child: Text('Bạn có chắc chắn muốn xóa?')),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy')),
                    TextButton(
                        onPressed: () =>
                            deleteTranslation(translation.id).then((value) {
                              widget.callback.call();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }),
                        child: Text('OK')),
                  ],
                )
              ],
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

    return null;
  }

  String? validateTranslation() {
    if (widget.existingTranslations.contains(freshTranslation) &&
        freshTranslation != translation) {
      return 'Cặp từ này có rồi, nhập khác đi nha';
    }
    return null;
  }
}
