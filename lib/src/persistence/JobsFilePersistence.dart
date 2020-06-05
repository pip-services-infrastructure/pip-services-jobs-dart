import 'package:pip_services3_data/pip_services3_data.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/JobV1.dart';
import './JobsMemoryPersistence.dart';

class JobsFilePersistence extends JobsMemoryPersistence {
  JsonFilePersister<JobV1> persister;

  JobsFilePersistence([String path]) : super() {
    persister = JsonFilePersister<JobV1>(path);
    loader = persister;
    saver = persister;
  }
  @override
  void configure(ConfigParams config) {
    super.configure(config);
    persister.configure(config);
  }
}
