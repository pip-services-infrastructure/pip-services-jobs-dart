import 'package:pip_services3_commons/pip_services3_commons.dart';

class NewJobV1Schema extends ObjectSchema {
  NewJobV1Schema() : super() {
    withRequiredProperty('type', TypeCode.String);
    withRequiredProperty('ref_id', TypeCode.String);
    withRequiredProperty('ttl', TypeCode.Integer);
    withOptionalProperty('params', null);
  }
}
