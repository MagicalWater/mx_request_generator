import 'param_content_builder.dart';

/// Body 的構建類
class BodyBuilder extends ParamContentBuilder<BodyContent> {

  @override
  String build() {

    // 取出所有的row body
    final allRowBody = params.where((element) => element.key == null);

    // 取出所有的key-value body
    final allKeyValueBody = params.where((element) => element.key != null);

    // row body 區塊
    final rawBodyText = _rowBodysText(allRowBody);

    final keyValueBodyText = _keyValueBodysText(allKeyValueBody);

    if (rawBodyText.isNotEmpty && keyValueBodyText.isNotEmpty) {
      // 有raw body和key-value body
      // raw優先, 若raw列表為空則使用key-value
      return '''
      $rawBodyText
      else { $keyValueBodyText }
      ''';
    } else if (rawBodyText.isNotEmpty) {
      // 只有raw body
      return rawBodyText;
    } else if (keyValueBodyText.isNotEmpty) {
      // 只有key-value body
      return keyValueBodyText;
    } else {
      return '';
    }
  }

  String _rowBodysText(Iterable<BodyContent> rowBodys) {
    // 只取最後一個有效的(有效代表有值或者不忽略null)
    var effectiveText = '';

    for (var element in rowBodys) {
      if (element.usedFieldName) {
        // 變數需要判空
        if (element.ignoreNull) {
          effectiveText += 'if (${element.fieldName} != null) ${element.fieldName},';
        } else {
          effectiveText += '${element.fieldName},';
        }
      } else if (element.usedValue) {
        // 常數可以直接知道是否為空
        if (element.value != null) {
          effectiveText += '${element.value},';
        } else if (!element.ignoreNull) {
          effectiveText += 'null,';
        }
      }
    }

    if (effectiveText.isEmpty) {
      return '';
    }

    final defText = 'final rowBodys = <String?>[$effectiveText];';
    final determineText = 'if (rowBodys.isNotEmpty) { content.setBodyInRow(rowBodys.last); }';
    return '''
    $defText
    
    $determineText
    ''';
  }

  String _keyValueBodysText(Iterable<BodyContent> keyValueBodys) {
    // 只取最後一個有效的(有效代表有值或者不忽略null)
    String text = '';

    for (var e in keyValueBodys) {
      if (e.usedFieldName) {
        // 使用變數
        if (e.nullable && e.ignoreNull) {
          // 若為可空, 且當null時不加入key
          // 則需要進行判斷
          text += 'if (${e.fieldName} != null) \'${e.key}\': ${e.fieldName},';
        } else {
          text += '\'${e.key}\': ${e.fieldName},';
        }
      } else if (e.usedValue) {
        // 使用常數
        if (!e.ignoreNull || e.value != null) {
          text += '\'${e.key}\': ${e.value == null ? null : '\'${e.value}\''},';
        }
      }
    }

    if (text.isEmpty) {
      return '';
    }

    final defText = 'content.addBodyInKeyValues({$text});';
    return '''
    $defText
    ''';
  }
}

class BodyContent {
  final String? key;
  final String? fieldName;
  final String? value;
  final bool nullable;
  final bool ignoreNull;

  final bool usedValue;
  final bool usedFieldName;

  BodyContent.value({
    required this.key,
    required this.value,
    required this.nullable,
    required this.ignoreNull,
  })  : fieldName = null,
        usedValue = true,
        usedFieldName = false;

  BodyContent.field({
    required this.key,
    required this.fieldName,
    required this.nullable,
    required this.ignoreNull,
  })  : value = null,
        usedValue = false,
        usedFieldName = true;
}
