import 'package:pip_services3_commons/pip_services3_commons.dart';

class JobV1Schema extends ObjectSchema {
  JobV1Schema() : super() {
    withRequiredProperty('id', TypeCode.String);
    withRequiredProperty('type', TypeCode.String);
    withRequiredProperty('ref_id', TypeCode.String);
    withOptionalProperty('params', null);

    withRequiredProperty('created', null);
    withOptionalProperty('started', null);
    withOptionalProperty('locked_until', null);
    withOptionalProperty('execute_until', null);
    withOptionalProperty('completed', null);
    withRequiredProperty('retries', TypeCode.Integer);
  }
}
