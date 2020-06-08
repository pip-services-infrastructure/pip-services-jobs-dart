import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../persistence/JobsMemoryPersistence.dart';
import '../persistence/JobsFilePersistence.dart';
import '../persistence/JobsMongoDbPersistence.dart';
import '../logic/JobsController.dart';
import '../services/version1/JobsHttpServiceV1.dart';

class JobsServiceFactory extends Factory {
  static final MemoryPersistenceDescriptor =
      Descriptor('pip-services-jobs', 'persistence', 'memory', '*', '1.0');
  static final FilePersistenceDescriptor =
      Descriptor('pip-services-jobs', 'persistence', 'file', '*', '1.0');
  static final MongoDbPersistenceDescriptor =
      Descriptor('pip-services-jobs', 'persistence', 'mongodb', '*', '1.0');
  static final ControllerDescriptor =
      Descriptor('pip-services-jobs', 'controller', 'default', '*', '1.0');
  static final HttpServiceDescriptor =
      Descriptor('pip-services-jobs', 'service', 'http', '*', '1.0');

  JobsServiceFactory() : super() {
    registerAsType(
        JobsServiceFactory.MemoryPersistenceDescriptor, JobsMemoryPersistence);
    registerAsType(
        JobsServiceFactory.FilePersistenceDescriptor, JobsFilePersistence);
    registerAsType(JobsServiceFactory.MongoDbPersistenceDescriptor,
        JobsMongoDbPersistence);
    registerAsType(JobsServiceFactory.ControllerDescriptor, JobsController);
    registerAsType(JobsServiceFactory.HttpServiceDescriptor, JobsHttpServiceV1);
  }
}
