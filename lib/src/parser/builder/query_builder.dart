import 'param_content_builder.dart';

/// Query 的構建類
class QueryBuilder extends ParamContentBuilder<QueryContent> {
  @override
  String build() {
    final start = 'content.addQuerys({';
    final end = '});';

    String text = '';

    for (var e in params) {
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

    return '''
    $start
    $text
    $end
    ''';
  }
}

class QueryContent {
  final String key;
  final String? fieldName;
  final String? value;
  final bool nullable;
  final bool ignoreNull;

  final bool usedValue;
  final bool usedFieldName;

  QueryContent.value({
    required this.key,
    required this.value,
    required this.nullable,
    required this.ignoreNull,
  })  : fieldName = null,
        usedValue = true,
        usedFieldName = false;

  QueryContent.field({
    required this.key,
    required this.fieldName,
    required this.nullable,
    required this.ignoreNull,
  })  : value = null,
        usedValue = false,
        usedFieldName = true;
}
