import 'body_builder.dart';
import 'builder.dart';
import 'header_builder.dart';
import 'init_builder.dart';
import 'query_builder.dart';

/// http content 的內容構建類
class RequestContentBuilder implements Builder {
  final init = InitBuilder();
  final body = BodyBuilder();
  final header = HeaderBuilder();
  final query = QueryBuilder();

  /// 設定初始化屬性
  void settingInit({
    String? path,
    String? method,
    String? contentType,
    String? scheme,
    String? host,
    int? port,
  }) {
    init
      ..path = path ?? init.path
      ..method = method ?? init.method
      ..contentType = contentType ?? init.contentType
      ..scheme = scheme ?? init.scheme
      ..host = host ?? init.host
      ..port = port ?? init.port;
  }

  /// 添加 body
  void addBody(BodyContent content) {
    body.add(content);
  }

  /// 添加 header
  void addHeader(HeaderContent content) {
    header.add(content);
  }

  /// 添加 query param
  void addQuery(QueryContent content) {
    query.add(content);
  }

  @override
  String build() {
    final initText = init.build();
    final queryText = query.build();
    final bodyText = body.build();
    final headerText = header.build();
    return '''
    $initText
    $headerText
    $queryText
    $bodyText
    return content;
    ''';
  }
}
