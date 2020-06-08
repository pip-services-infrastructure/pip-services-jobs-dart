import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_jobs/pip_services_jobs.dart';

final JOB1 = NewJobV1(
    type: 't1', ref_id: 'obj_0fsd', ttl: 1000 * 60 * 60 * 3, params: null);
final JOB2 =
    NewJobV1(type: 't1', ref_id: 'obj_1fsd', ttl: 1000 * 60 * 60, params: null);
final JOB3 =
    NewJobV1(type: 't2', ref_id: 'obj_3fsd', ttl: 1000 * 60 * 30, params: null);

var httpConfig = ConfigParams.fromTuples([
  'connection.protocol',
  'http',
  'connection.host',
  'localhost',
  'connection.port',
  3000
]);

void main() {
  group('JobsHttpServiceV1', () {
    JobsMemoryPersistence persistence;
    JobsController controller;
    JobsHttpServiceV1 service;
    http.Client rest;
    String url;

    setUp(() async {
      url = 'http://localhost:3000';
      rest = http.Client();

      persistence = JobsMemoryPersistence();
      persistence.configure(ConfigParams());

      controller = JobsController();
      controller.configure(ConfigParams());

      service = JobsHttpServiceV1();
      service.configure(httpConfig);

      var references = References.fromTuples([
        Descriptor(
            'pip-services-jobs', 'persistence', 'memory', 'default', '1.0'),
        persistence,
        Descriptor(
            'pip-services-jobs', 'controller', 'default', 'default', '1.0'),
        controller,
        Descriptor('pip-services-jobs', 'service', 'http', 'default', '1.0'),
        service
      ]);

      controller.setReferences(references);
      service.setReferences(references);

      await persistence.open(null);
      await service.open(null);
    });

    tearDown(() async {
      await service.close(null);
      await persistence.close(null);
    });

    test('CRUD Operations', () async {
      JobV1 job1;

      // Create the first job
      var resp = await rest.post(url + '/v1/jobs/add_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB1}));
      var job = JobV1();
      job.fromJson(json.decode(resp.body));
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
      resp = await rest.post(url + '/v1/jobs/add_uniq_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB2}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
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

      // Create the third job
      resp = await rest.post(url + '/v1/jobs/add_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB3}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
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
      resp = await rest.post(url + '/v1/jobs/get_job_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job1.id, job.id);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Get all jobs
      resp = await rest.post(url + '/v1/jobs/get_jobs',
          headers: {'Content-Type': 'application/json'},
          body: json
              .encode({'filter': FilterParams(), 'paging': PagingParams()}));
      var page = DataPage<JobV1>.fromJson(json.decode(resp.body), (item) {
        var job = JobV1();
        job.fromJson(item);
        return job;
      });
      expect(page, isNotNull);
      expect(page.data.length, 2);

      // Delete the job
      resp = await rest.post(url + '/v1/jobs/delete_job_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job1.id, job.id);

      // Try to get deleted job
      resp = await rest.post(url + '/v1/jobs/get_job_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id}));
      expect(resp.body, isEmpty);

      // Delete all jobs
      resp = await rest.post(url + '/v1/jobs/delete_jobs',
          headers: {'Content-Type': 'application/json'}, body: json.encode({}));

      // Try to get jobs after delete
      resp = await rest.post(url + '/v1/jobs/get_jobs',
          headers: {'Content-Type': 'application/json'},
          body: json
              .encode({'filter': FilterParams(), 'paging': PagingParams()}));
      page = DataPage<JobV1>.fromJson(json.decode(resp.body), (item) {
        var job = JobV1();
        job.fromJson(item);
        return job;
      });
      expect(page, isNotNull);
      expect(page.data.length, 0);
    });

    test('Control operations', () async {
      JobV1 job1, job2;

      // Create the first job
      var resp = await rest.post(url + '/v1/jobs/add_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB1}));
      var job = JobV1();
      job.fromJson(json.decode(resp.body));
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
      resp = await rest.post(url + '/v1/jobs/add_uniq_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB2}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
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

      // Create the third job
      resp = await rest.post(url + '/v1/jobs/add_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'new_job': JOB3}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
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
      resp = await rest.post(url + '/v1/jobs/get_job_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job1.id, job.id);
      expect(JOB1.type, job.type);
      expect(JOB1.ref_id, job.ref_id);

      expect(0, job.retries);
      expect(JOB1.params, job.params);
      expect(job.created, isNotNull);
      expect(job.execute_until, isNotNull);
      expect(job.started, isNull);
      expect(job.completed, isNull);
      expect(job.locked_until, isNull);

      // Get all jobs
      resp = await rest.post(url + '/v1/jobs/get_jobs',
          headers: {'Content-Type': 'application/json'},
          body: json
              .encode({'filter': FilterParams(), 'paging': PagingParams()}));
      var page = DataPage<JobV1>.fromJson(json.decode(resp.body), (item) {
        var job = JobV1();
        job.fromJson(item);
        return job;
      });
      expect(page, isNotNull);
      expect(page.data.length, 2);

      job1 = page.data[0];
      job2 = page.data[1];

      // Test start job by type
      resp = await rest.post(url + '/v1/jobs/start_job_by_type',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'type': job1.type, 'timeout': 1000 * 60 * 10}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job.locked_until, isNotNull);
      expect(job.started, isNotNull);
      job1 = job;

      // Test extend job
      resp = await rest.post(url + '/v1/jobs/extend_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id, 'timeout': 1000 * 60 * 10}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job.locked_until, isNotNull);
      job1 = job;

      // Test complete job
      resp = await rest.post(url + '/v1/jobs/complete_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job1.id}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job.completed, isNotNull);
      job1 = job;

      // Test start
      resp = await rest.post(url + '/v1/jobs/start_job_by_id',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job2.id, 'timeout': 1000 * 60}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job.locked_until, isNotNull);
      expect(job.started, isNotNull);
      job2 = job;

      // Test abort job
      resp = await rest.post(url + '/v1/jobs/abort_job',
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'job_id': job2.id}));
      job = JobV1();
      job.fromJson(json.decode(resp.body));
      expect(job, isNotNull);
      expect(job.locked_until, isNotNull);
      expect(job.started, isNull);
    });
  });
}
