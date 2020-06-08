import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

class JobsHttpServiceV1 extends CommandableHttpService {
  JobsHttpServiceV1() : super('v1/jobs') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-jobs', 'controller', '*', '*', '1.0'));
  }
}
