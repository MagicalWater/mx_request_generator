// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// ApiGenerator
// **************************************************************************

part of 'request.dart';

abstract class ExRequestApi extends RequestBase implements ExRequestInterface {
  ExRequestApi(super.base);

  @override
  RequestContent exApi(
    String titlePath,
    String? aId,
    String bToken,
    String cBody,
    String rawBody, {
    required String check,
    required String? opId,
    String? opToken,
    String? opBody,
    MultipartFile? opBodyFile,
    String? optRawBody,
    required List<String> opId2,
  }) {
    final content = base.copyWith();

    content.addHeaders({
      'titleHKey': 'titleHValue',
      'token': bToken,
      if (opToken != null) 'tokenOp': opToken,
    });

    content.addQuerys({
      'titleQPKey': 'titleQPValue',
      if (aId != null) 'id': aId,
      if (opId != null) 'opId': opId,
      'opId2': opId2,
    });

    final rowBodys = <String?>[if (rawBody != null) rawBody, optRawBody];

    if (rowBodys.isNotEmpty) {
      content.setBodyInRow(rowBodys.last);
    } else {
      content.addBodyInKeyValues({
        'body': cBody,
        'bodyOp': opBody,
        if (opBodyFile != null) 'bodyFOp': opBodyFile,
      });
    }

    return content;
  }
}
