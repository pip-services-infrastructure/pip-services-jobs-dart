import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import '../build/JobsServiceFactory.dart';

class JobsProcess extends ProcessContainer {
  JobsProcess() : super('jobs', 'Jobs orchestration microservice') {
    factories.add(JobsServiceFactory());
    factories.add(DefaultRpcFactory());
  }
}
