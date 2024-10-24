import 'package:dio/dio.dart';
import 'package:mx_request/mx_request.dart';

import 'request.dart';

void main() async {
  // 初始化http請求工具
  final dio = Dio();

  // 初始化api接口實體
  final request = ExRequest();

  print('發出請求');

  // 發出http api請求, 並取得響應
  await dio
      .mxRequest(request.exApi(
    'apiPath',
    'hi',
    'bToken',
    'cBody',
    'rawBody',
    opBodyFile: MultipartFile.fromString('value'),
    check: 'check',
    opId: 'opId',
    opId2: ['opId2'],
  ))
      .then((value) {
    print('響應: $value');
  }).catchError((e, s) {
    print('錯誤: $e');
  });
}
