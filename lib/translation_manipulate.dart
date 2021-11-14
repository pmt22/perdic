import 'package:flutter/material.dart';
import 'package:perdic/translation.dart';
import 'dart:async';

class TranslationManipulate extends StatefulWidget {
  final Translation inputTranslation;
  final TranslationService translationService;
  final FutureOr<void> Function(Translation) callback;

  const TranslationManipulate(this.inputTranslation, this.translationService,
      this.callback,
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
                  onChanged: (val) => {
                    freshTranslation!.vi = val
                  },
                ),
                TextFormField(
                  initialValue: isCreation ? null : translation.en,
                  decoration: const InputDecoration(labelText: 'Tiếng Anh'),
                  validator: (val) => textValidation(val, false),
                  onChanged: (val) => {
                    freshTranslation!.en = val
                  },
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          if (isCreation) {
                            translation.update(freshTranslation!);
                            widget.translationService.translations.add(translation);
                          } else {
                            translation.update(freshTranslation!);
                          }
                        });
                        Navigator.pop(context);
                        await widget.callback.call(translation);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Lưu xong rồi đó')));
                      }
                    },
                    child: const Text('Lưu'))
              ],
            ),
          ),
        ));
  }

  Translation get translation => widget.inputTranslation;

  bool get isCreation => translation.isEmpty();

  String? textValidation(value, bool isVi) {
    if (value == null || value.isEmpty) {
      return 'Nhập gì đó dùm cái bạn ei!!!';
    }

    if (widget.translationService.translations.contains(freshTranslation)) {
      return isCreation ? 'Cặp từ này có rồi, nhập khác đi nha' : 'Sửa mà không khác gì thì lưu chi nè';
    }
    return null;
  }
}
