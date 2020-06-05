import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_jobs/pip_services_jobs.dart';

final JOB1 = NewJobV1(
    type: 't1', ref_id: 'obj_0fsd', ttl: 1000 * 60 * 60 * 3, params: null);
final JOB2 =
    NewJobV1(type: 't1', ref_id: 'obj_1fsd', ttl: 1000 * 60 * 60, params: null);
final JOB3 =
    NewJobV1(type: 't2', ref_id: 'obj_3fsd', ttl: 1000 * 60 * 30, params: null);

void main() {
  group('JobsController', () {
    JobsMemoryPersistence persistence;
    JobsController controller;

    setUp(() async {
      persistence = JobsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = JobsController();
      controller.configure(ConfigParams());

      var references = References.fromTuples([
        Descriptor(
            'pip-services-jobs', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-services-jobs', 'controller', 'default', 'default', '1.0'),
        controller
      ]);

      controller.setReferences(references);

      await persistence.open(null);
    });

    tearDown(() async {
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      JobV1 job1;

      // Create the first job
      var job = await controller.addJob(null, JOB1);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      job1 = job;

      // Create the second job
      job = await controller.addJob(null, JOB2);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB2.type, job.type);
      expect(JOB2.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB2.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Create the third job
      job = await controller.addJob(null, JOB3);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB3.type, job.type);
      expect(JOB3.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB3.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Get one job
      job = await controller.getJobById(null, job1.id);
      expect(job, isNotNull);
      expect(job.id, job1.id);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);
      expect(job1.retries, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Get all jobs
      var page = await controller.getJobs(null, FilterParams(), PagingParams());
      expect(page, isNotNull);
      expect(page.data.length, 3);

      job1 = page.data[0];

      // Delete the job
      job = await controller.deleteJobById(null, job1.id);
      expect(job, isNotNull);
      expect(job1.id, job.id);

      // Try to get deleted job
      job = await controller.getJobById(null, job1.id);
      expect(job, isNull);

      // Delete all jobs
      await controller.deleteJobs(null);

      // Try to get jobs after delete
      page = await controller.getJobs(null, FilterParams(), PagingParams());
      expect(page, isNotNull);
      expect(page.data.length, 0);
    });

    test('Control operations', () async {
      JobV1 job1, job2;

      // Create the first job
      var job = await controller.addJob(null, JOB1);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      job1 = job;

      // Create the second job
      job = await controller.addJob(null, JOB2);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB2.type, job.type);
      expect(JOB2.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB2.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      job2 = job;

      // Test start job by type
      job =
          await controller.startJobByType(null, job1.type, 1000 * 60 * 10, 10);
      expect(job, isNotNull);
      expect(job.started, isNotNull);
      expect(job.locked_until, isNotNull);

      // Test extend job
      var timeout = 1000 * 60 * 5;
      //var newExeUntil = DateTime.fromMillisecondsSinceEpoch(job1.execute_until.millisecondsSinceEpoch + timeout);

      job = await controller.extendJob(null, job1.id, timeout);
      expect(job, isNotNull);
      expect(job.started, isNotNull);
      //expect(newExeUntil.toUtc().millisecondsSinceEpoch, job.execute_until.toUtc().millisecondsSinceEpoch);

      // Test complete job
      job = await controller.completeJob(null, job1.id);
      expect(job, isNotNull);
      expect(job.completed, isNotNull);

      // Test start job
      timeout = 1000 * 60;
      job = await controller.startJobById(null, job2.id, timeout);
      expect(job, isNotNull);
      expect(job.started, isNotNull);
      expect(job.locked_until, isNotNull);

      // Test abort job
      job = await controller.abortJob(null, job2.id);
      expect(job, isNotNull);
      expect(job.started, isNull);
      expect(job.locked_until, isNotNull);
    });

    test('Test clean expired jobs', () async {
      JobV1 job1;

      // Create the first job
      var job = await controller.addJob(null, JOB1);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      job1 = job;

      // Create the second job
      job = await controller.addJob(null, JOB2);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB2.type, job.type);
      expect(JOB2.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB2.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Create the third job
      job = await controller.addJob(null, JOB3);
      expect(job, isNotNull);
      expect(job.id, isNotNull);
      expect(JOB3.type, job.type);
      expect(JOB3.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB3.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Get all jobs
      var page = await controller.getJobs(null, FilterParams(), PagingParams());
      expect(page, isNotNull);
      expect(page.data.length, 3);

      // Test start job by type
      job =
          await controller.startJobByType(null, job1.type, 1000 * 60 * 10, 10);
      expect(job, isNotNull);
      expect(job.started, isNotNull);
      expect(job.locked_until, isNotNull);

      // Test complete job
      job = await controller.completeJob(null, job1.id);
      expect(job, isNotNull);
      expect(job.completed, isNotNull);

      // Test clean jobs
      await controller.cleanJobs(null);

      // Get all jobs after clean
      page = await controller.getJobs(null, FilterParams(), PagingParams());
      expect(page, isNotNull);
      expect(page.data.length, 2);
    });
  });
}
