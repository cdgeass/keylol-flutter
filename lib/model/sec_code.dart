import 'dart:math';

import 'package:html/dom.dart';

// 验证码相关参数
class SecCode {
  late final String auth;
  late String formHash;
  late final String update;
  late final String loginHash;
  late String currentIdHash;

  SecCode(this.auth, this.formHash, this.update, this.loginHash,
      this.currentIdHash);

  SecCode.fromDocument(Document document) {
    final refreshButtons = document.getElementsByClassName('sec_button');
    if (refreshButtons.isEmpty) {
      return;
    }
    final refreshButton = refreshButtons[0];
    final onClickExp = refreshButton.attributes['onclick'] ?? '';
    final splits = onClickExp.split(' ');
    final updateSecCodeExp = splits[splits.length - 1];

    loginHash = updateSecCodeExp.substring(23, 28);
    update = updateSecCodeExp.substring(31, 36);

    final inputs = document.getElementsByTagName('input');
    for (var input in inputs) {
      if (input.attributes['name'] == 'formhash') {
        formHash = input.attributes['value']!;
        break;
      }
    }
  }

  String getIdHash() {
    final random = Random();
    final randomSeed = (random.nextDouble() * 1000).floor();
    currentIdHash = 'S$randomSeed';
    return currentIdHash;
  }
}
