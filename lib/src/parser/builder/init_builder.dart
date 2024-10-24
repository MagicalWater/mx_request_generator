import 'builder.dart';

/// Http 初始化構建類
class InitBuilder implements Builder {
  String? path;
  String? method;
  String? contentType;
  String? scheme;
  String? host;
  int? port;

  @override
  String build() {
    final schemeText = scheme == null ? '' : 'scheme: \'$scheme\',';
    final hostText = host == null ? '' : 'host: \'$host\',';
    final pathText = path == null ? '' : 'path: \'$path\',';
    final portText = port == null ? '' : 'port: $port,';
    final methodText = method == null ? '' : 'method: \'$method\',';
    final contentTypeText = contentType == null ? '' : 'contentType: \'$contentType\',';

    return '''
    final content = base.copyWith(
      $schemeText
      $hostText
      $pathText
      $portText
      $methodText
      $contentTypeText
    );
    ''';
  }
}
