import 'builder.dart';

/// 參數添加抽象類
abstract class ParamContentBuilder<T> implements Builder {
  /// 參數列表
  final params = <T>[];

  /// 添加一個必填的變數類型 body
  void add(T param) {
    params.add(param);
  }
}
