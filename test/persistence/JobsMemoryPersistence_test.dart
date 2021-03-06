import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_jobs/pip_services_jobs.dart';
import './JobsPersistenceFixture.dart';

void main() {
  group('JobsMemoryPersistence', () {
    JobsMemoryPersistence persistence;
    JobsPersistenceFixture fixture;

    setUp(() async {
      persistence = JobsMemoryPersistence();
      persistence.configure(ConfigParams());

      fixture = JobsPersistenceFixture(persistence);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      await fixture.testCrudOperations();
    });

    test('Get with Filters', () async {
      await fixture.testGetWithFilters();
    });
  });
}
