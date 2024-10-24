import 'package:dio/dio.dart';
import 'package:mx_request/mx_request.dart';

part 'request.api.dart';

/// 運行以下命令生成api實體
/// dart pub run build_runner build
@RequestIF()
abstract class ExRequestInterface {
  @StaticRequest(
    // body: {
    //   'titleBodyKey': 'titleBodyValue',
    // },
    // port: 8881,
    headers: {
      'titleHKey': 'titleHValue',
    },
    queryParameters: {
      'titleQPKey': 'titleQPValue',
    },
  )
  RequestContent exApi(
      @Path('titlePath') String titlePath,
      @Query('id') String? aId,
      @Header('token') String bToken,
      @Body('body') String cBody,
      @Body(null) String rawBody, {
        @Path('check') required String check,
        @Query('opId') required String? opId,
        @Header('tokenOp') String? opToken,
        @Body('bodyOp', ignoreNull: false) String? opBody,
        @Body('bodyFOp') MultipartFile? opBodyFile,
        @Body(null, ignoreNull: false) String? optRawBody,
        @Query('opId2') required List<String> opId2,
      });
}

class ExRequest extends ExRequestApi {
  ExRequest()
      : super(RequestContent(
    scheme: 'https',
    host: 'www.google.com',
  ));
}
