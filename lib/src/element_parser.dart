import 'package:analyzer/dart/element/element.dart';
import 'package:mx_request/mx_request.dart';
import 'package:source_gen/source_gen.dart';

/// 定義為request的method
final methodList = [StaticRequest];

/// api 的參數類型列表
final paramList = [Query, Header, Path, Body];

/// Api 的參數類型
enum ParamType { query, header, path, body }

/// 傳入 Param 的 ConstantReader (annotation)
/// 從 meta 取得 Api 的參數類型分類
ParamType getParamType(ConstantReader annotation) {
  if (annotation.instanceOf(const TypeChecker.typeNamed(Query))) {
    return ParamType.query;
  } else if (annotation.instanceOf(const TypeChecker.typeNamed(Header))) {
    return ParamType.header;
  } else if (annotation.instanceOf(const TypeChecker.typeNamed(Path))) {
    return ParamType.path;
  } else if (annotation.instanceOf(const TypeChecker.typeNamed(Body))) {
    return ParamType.body;
  }
  throw '未知的 param: $annotation';
}

/// 傳入 [ParamElement]
/// 傳回此參數是否為可空
bool isFieldNullable(FormalParameterElement element) {
  final name = element.type.getDisplayString();
  // print('獲取: $name, ${element.type.nullabilitySuffix}');
//  print("打印類型名稱 ${element.type.runtimeType}, ${element.type}, $name");
  return name[name.length - 1] == '?';
}

/// 從method中取得對應的meta data
ConstantReader getMethodReader(MethodElement element) {
  return findConstantReader(element, methodList);
}

/// 從method的參數中取得對應的meta data
ConstantReader getParamReader(FormalParameterElement element) {
  return findConstantReader(element, paramList);
}

/// 傳入 element 以及 尋找的類型列表
/// 返回 對應的 meta data
ConstantReader findConstantReader(Element element, List<Type> findList) {
  for (final type in findList) {
    // 初始化 TypeChecker, 將要搜索的 annotation 類型包進去
    final checker = TypeChecker.typeNamed(type);

    // 使用 TypeChecker 在 MethodElement 裡面搜索對應 type 的物件
    final annotation = checker.firstAnnotationOf(
      element,
      throwOnUnresolved: false,
    );

    // 假如有搜索到的話, 直接返回, 並且包成 ConstantReader方便讀取
    if (annotation != null) return ConstantReader(annotation);
  }
  throw '找不到對應的 meta data';
}
