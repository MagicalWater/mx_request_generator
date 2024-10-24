import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart' as code_builder;

import '../element_parser.dart';
import 'builder/body_builder.dart';
import 'builder/header_builder.dart';
import 'builder/query_builder.dart';
import 'builder/request_content_builder.dart';
import 'parser.dart';

/// 產出 api 類
class ApiClassParser extends RequestParser {
  @override
  String getClassSuffixName() => 'Api';

  /// 產出實作的 api methods
  @override
  List<code_builder.Method> generateMethods(ClassElement element) {
    // 取得 ClassElement 底下的所有 method, 開始進行分析以及建立 Method
    return element.methods.map((e) => _generateMethod(e)).toList();
  }

  @override
  code_builder.Class generateClass({
    required String interfaceName,
    required String className,
    required List<code_builder.Method> methods,
  }) {
    return code_builder.Class((c) {
      c
        ..abstract = true
        ..name = className
        ..methods.addAll(methods)
        ..constructors.add(code_builder.Constructor((b) {
          // ExRequestApi(super.base);
          b.requiredParameters.add(code_builder.Parameter((p) {
            p
              ..toSuper = true
              ..name = 'base';
          }));
        }))
        ..extend = code_builder.refer('RequestBase')
        ..implements = ListBuilder([code_builder.refer(interfaceName)]);
    });
  }

  code_builder.Method _generateMethod(MethodElement element) {
    // method 內容的構建器
    final contentBuilder = RequestContentBuilder();

    // 取得 method 的名稱
    final methodName = element.name;

    // 首先取得 meta data
    final methodAnnotation = getMethodReader(element);

    // 取得 method 裡面必選的參數(擁有名稱的必選參數不在此處)
    final requiredParam =
        element.parameters.where((e) => e.isRequiredPositional).toList();

    // 取得 method 裡面可選或者擁有名稱的參數
    final optionalParam = element.parameters
        .where((e) => e.isOptional || e.isRequiredNamed)
        .toList();

    // 取得以及設置初始化參數
    // 取得 meta data 使用的類型
    var path = methodAnnotation.peek('path')?.stringValue;
    final scheme = methodAnnotation.peek('scheme')?.stringValue;
    final host = methodAnnotation.peek('host')?.stringValue;
    final port = methodAnnotation.peek('port')?.intValue;
    final method = methodAnnotation.peek('method')?.stringValue;
    final contentType = methodAnnotation.peek('contentType')?.stringValue;
    final headers =
        methodAnnotation.peek('headers')?.mapValue.mapStringNullable();
    final queryParameters =
        methodAnnotation.peek('queryParameters')?.mapValue.mapStringNullable();
    final body = methodAnnotation.peek('body');

    contentBuilder.settingInit(
      path: path,
      method: method,
      contentType: contentType,
      scheme: scheme,
      host: host,
      port: port,
    );

    // 解析常數參數 (header/body/query)
    headers?.forEach((k, v) {
      final content = HeaderContent.value(
        key: k,
        value: v,
        nullable: v == null,
        ignoreNull: false,
      );
      contentBuilder.addHeader(content);
    });

    queryParameters?.forEach((k, v) {
      final content = QueryContent.value(
        key: k,
        value: v,
        nullable: v == null,
        ignoreNull: false,
      );
      contentBuilder.addQuery(content);
    });

    if (body?.isString == true) {
      print('body is string');
      final content = BodyContent.value(
        key: null,
        value: body!.stringValue,
        nullable: false,
        ignoreNull: false,
      );
      contentBuilder.addBody(content);
    } else if (body?.isMap == true) {
      print('body is map');
      body!.mapValue.mapStringNullable().forEach((k, v) {
        final content = BodyContent.value(
          key: k,
          value: v,
          nullable: v == null,
          ignoreNull: false,
        );
        contentBuilder.addBody(content);
      });
    }

    // 添加必選/可選參數到 content Builder
    path = _addParamToContentBuilder(
      builder: contentBuilder,
      urlPath: path,
      params: requiredParam,
      isRequiredRange: true,
    );

    path = _addParamToContentBuilder(
      builder: contentBuilder,
      urlPath: path,
      params: optionalParam,
      isRequiredRange: false,
    );

    return code_builder.Method((b) {
      b
        ..annotations = ListBuilder([
          const code_builder.CodeExpression(code_builder.Code('override')),
        ])
        ..name = methodName
        ..requiredParameters
            .addAll(_convertToCodeBuilderParam(requiredParam, false))
        ..optionalParameters
            .addAll(_convertToCodeBuilderParam(optionalParam, true))
        ..body = code_builder.Code(contentBuilder.build())
        ..returns = code_builder.refer('RequestContent');
    });
  }

  /// 將參數轉換為 codeBuilder 添加方法參數的型態
  List<code_builder.Parameter> _convertToCodeBuilderParam(
    List<ParameterElement> element,
    bool isOptional,
  ) {
    return element.map((e) {
      return code_builder.Parameter((p) {
        List<String> paramAnnotation = [];
        // if (e.metadata.any((m) => m.isRequired)) {
        //   // 如果此參數是必選, 則需要加入 required 的 annotation
        //   paramAnnotation.add('required');
        // }

        // 將 annotation 轉換為 codeExpression
        List<code_builder.CodeExpression> paramAnnotationCode = paramAnnotation
            .map((f) => code_builder.CodeExpression(code_builder.Code(f)))
            .toList();

        // print('取得類型名稱: ${e.type.getDisplayString(withNullability: true)}');
        p
          ..annotations.addAll(paramAnnotationCode)
          ..type = code_builder.refer(e.type.getDisplayString())
          ..name = e.name
          ..named = e.isNamed
          ..required = isOptional ? e.isRequired : false
          ..defaultTo = e.defaultValueCode == null
              ? null
              : code_builder.Code(e.defaultValueCode!);
      });
    }).toList();
  }

  /// 添加方法的參數設定到 [RequestContentBuilder]
  /// [isRequiredRange] - 是否為必填區塊的參數
  /// 回傳新的urlPath (無論是否有變更都回傳)
  String? _addParamToContentBuilder({
    required RequestContentBuilder builder,
    required String? urlPath,
    required List<ParameterElement> params,
    required bool isRequiredRange,
  }) {
    String? currentPath = urlPath;

    // 遍歷所有的參數, 依據參數的類型, 加入到對應的 Builder
    for (final e in params) {
      // 取得參數的 meta data
      final paramReader = getParamReader(e);

      // 就可以從 meta data 取得參數的類型
      final paramType = getParamType(paramReader);

      // 變數名稱
      final fieldName = e.name;

      // 變數類型
      final fieldNullable = isFieldNullable(e);

      // key name
      final key = paramReader.peek('name')?.stringValue;
      final ignoreNull = paramReader.peek('ignoreNull')?.boolValue;

      switch (paramType) {
        case ParamType.query:
          final content = QueryContent.field(
            key: key!,
            fieldName: fieldName,
            nullable: fieldNullable,
            ignoreNull: ignoreNull!,
          );
          builder.addQuery(content);
          break;
        case ParamType.header:
          final content = HeaderContent.field(
            key: key!,
            fieldName: fieldName,
            nullable: fieldNullable,
            ignoreNull: ignoreNull!,
          );
          builder.addHeader(content);
          break;
        case ParamType.path:
          // 將路徑裡面的 {variable} 做替換
          currentPath = currentPath?.replaceAll('{$key}', '\$$fieldName');
          builder.settingInit(path: currentPath);
          break;
        case ParamType.body:
          // 添加到body
          final content = BodyContent.field(
            key: key,
            fieldName: fieldName,
            nullable: fieldNullable,
            ignoreNull: ignoreNull!,
          );
          builder.addBody(content);
          break;
      }
    }

    return currentPath;
  }
}

extension DartStringMap on Map<DartObject?, DartObject?> {
  /// 從 [DartObject] 轉換為 <String?, String?>
  Map<String?, String?> mapString() => map((k, v) {
        final keyString = k?.toStringValue();
        final valueString = v?.toStringValue();
        return MapEntry(keyString, valueString);
      });

  /// 從 [DartObject] 轉換為 <String?, String?>, 並且過濾掉 key為null
  Map<String, String?> mapStringNullable() => mapString().whereType();
}

extension NonNullMap on Map<dynamic, dynamic> {
  Map<T, S> whereType<T, S>() {
    final newMap = Map.from(this);
    newMap.removeWhere((key, value) => key is! T || value is! S);
    return newMap.map((key, value) => MapEntry(key as T, value as S));
  }
}
