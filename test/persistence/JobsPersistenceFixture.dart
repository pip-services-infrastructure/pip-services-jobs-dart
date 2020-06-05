import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services_jobs/pip_services_jobs.dart';

var now = DateTime.now();

final JOB1 = JobV1(
    id: 'Job_t1_0fsd',
    type: 't1',
    ref_id: 'obj_0fsd',
    params: null,
    created: DateTime.parse('2019-11-07T17:30:00').toUtc(),
    started: DateTime.parse('2019-11-07T17:30:20').toUtc(),
    locked_until: DateTime.parse('2019-11-07T18:00:20').toUtc(),
    execute_until: DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + 1000 * 60 * 5)
        .toUtc(),
    completed: null,
    retries: 5);
final JOB2 = JobV1(
    id: 'Job_t1_1fsd',
    type: 't1',
    ref_id: 'obj_1fsd',
    params: null,
    created: DateTime.parse('2019-11-07T17:35:00').toUtc(),
    started: DateTime.parse('2019-11-07T17:35:20').toUtc(),
    locked_until: DateTime.parse('2019-11-07T17:50:20').toUtc(),
    execute_until: DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + 1000 * 60 * 10)
        .toUtc(),
    completed: null,
    retries: 3);
final JOB3 = JobV1(
    id: 'Job_t2_3fsd',
    type: 't2',
    ref_id: 'obj_3fsd',
    params: null,
    created: DateTime.parse('2019-11-07T17:40:00').toUtc(),
    started: DateTime.parse('2019-11-07T17:40:20').toUtc(),
    locked_until: DateTime.parse('2019-11-07T17:50:20').toUtc(),
    execute_until: DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + 1000 * 60 * 15)
        .toUtc(),
    completed: null,
    retries: 2);

class JobsPersistenceFixture {
  IJobsPersistence _persistence;

  JobsPersistenceFixture(IJobsPersistence persistence) {
    expect(persistence, isNotNull);
    _persistence = persistence;
  }

  void _testCreateJobs() async {
    // Create the first job
    var job = await _persistence.create(null, JOB1);

    expect(job, isNotNull);
    expect(JOB1.id, job.id);
    expect(JOB1.type, job.type);
    expect(JOB1.ref_id, job.ref_id);
    expect(JOB1.created.millisecondsSinceEpoch,
        job.created.millisecondsSinceEpoch);
    expect(JOB1.started.millisecondsSinceEpoch,
        job.started.millisecondsSinceEpoch);
    expect(JOB1.locked_until.millisecondsSinceEpoch,
        job.locked_until.millisecondsSinceEpoch);
    expect(JOB1.retries, job.retries);

    // Create the second job
    job = await _persistence.create(null, JOB2);
    expect(job, isNotNull);
    expect(JOB2.id, job.id);
    expect(JOB2.type, job.type);
    expect(JOB2.ref_id, job.ref_id);
    expect(JOB2.created.millisecondsSinceEpoch,
        job.created.millisecondsSinceEpoch);
    expect(JOB2.started.millisecondsSinceEpoch,
        job.started.millisecondsSinceEpoch);
    expect(JOB2.locked_until.millisecondsSinceEpoch,
        job.locked_until.millisecondsSinceEpoch);
    expect(JOB2.retries, job.retries);

    // Create the third job
    job = await _persistence.create(null, JOB3);
    expect(job, isNotNull);
    expect(JOB3.id, job.id);
    expect(JOB3.type, job.type);
    expect(JOB3.ref_id, job.ref_id);
    expect(JOB3.created.millisecondsSinceEpoch,
        job.created.millisecondsSinceEpoch);
    expect(JOB3.started.millisecondsSinceEpoch,
        job.started.millisecondsSinceEpoch);
    expect(JOB3.locked_until.millisecondsSinceEpoch,
        job.locked_until.millisecondsSinceEpoch);
    expect(JOB3.retries, job.retries);
  }

  void testCrudOperations() async {
    JobV1 job1;

    // Create items
    await _testCreateJobs();

    // Get all jobs
    var page = await _persistence.getPageByFilter(
        null, FilterParams(), PagingParams());
    expect(page, isNotNull);
    expect(page.data.length, 3);

    job1 = page.data[0];

    // Update the job
    job1.retries = 4;

    var job = await _persistence.update(null, job1);
    expect(job, isNotNull);
    expect(job1.id, job.id);
    expect(4, job.retries);

    // Get job by id
    job = await _persistence.getOneById(null, job1.id);
    expect(job, isNotNull);
    expect(job1.id, job.id);
    expect(job1.type, job.type);
    expect(job1.ref_id, job.ref_id);
    expect(job1.created.millisecondsSinceEpoch,
        job.created.millisecondsSinceEpoch);
    expect(job1.started.millisecondsSinceEpoch,
        job.started.millisecondsSinceEpoch);
    expect(job1.locked_until.millisecondsSinceEpoch,
        job.locked_until.millisecondsSinceEpoch);
    expect(job1.retries, job.retries);

    // Delete the job
    job = await _persistence.deleteById(null, job1.id);
    expect(job, isNotNull);
    expect(job1.id, job.id);

    // Try to get deleted job
    job = await _persistence.getOneById(null, job1.id);
    expect(job, isNull);

    // Delete all jobs
    await _persistence.deleteByFilter(null, FilterParams());

    // Try to get jobs after delete
    page = await _persistence.getPageByFilter(
        null, FilterParams(), PagingParams());
    expect(page, isNotNull);
    expect(page.data.length, 0);
  }

  void testGetWithFilters() async {
    // Create items
    await _testCreateJobs();

    // Filter by id
    var page = await _persistence.getPageByFilter(
        null, FilterParams.fromValue({'id': 'Job_t1_0fsd'}), PagingParams());
    expect(page.data.length, 1);

    // Filter by type
    page = await _persistence.getPageByFilter(
        null, FilterParams.fromValue({'type': 't1'}), PagingParams());
    expect(page.data.length, 2);

    // Filter by retries
    page = await _persistence.getPageByFilter(
        null, FilterParams.fromValue({'retries': '2'}), PagingParams());
    expect(page.data.length, 1);

    // Filter by retries_max
    page = await _persistence.getPageByFilter(
        null, FilterParams.fromValue({'min_retries': '0'}), PagingParams());
    expect(page.data.length, 3);

    // Filter by created
    page = await _persistence.getPageByFilter(
        null,
        FilterParams.fromValue(
            {'created': DateTime.parse('2019-11-07T17:40:00').toUtc()}),
        PagingParams());
    expect(page.data.length, 1);

    // Filter by locked_to
    page = await _persistence.getPageByFilter(
        null,
        FilterParams.fromValue(
            {'locked_to': DateTime.parse('2019-11-07T18:10:00').toUtc()}),
        PagingParams());
    expect(page.data.length, 3);

    // Filter by execute_from
    page = await _persistence.getPageByFilter(
        null,
        FilterParams.fromValue({
          'execute_from': DateTime.fromMillisecondsSinceEpoch(
                  now.millisecondsSinceEpoch + 1000 * 60 * 8)
              .toUtc()
        }),
        PagingParams());
    expect(page.data.length, 2);

    // Test updateJobForStart
    // var job = await _persistence.startJobByType(null, 't2', 1000, 6);
    var job = await _persistence.startJobById(null, JOB3.id, 1000);
    expect(job, isNotNull);
    expect(JOB3.retries + 1, job.retries);
    expect(JOB3.started.millisecondsSinceEpoch, isNotNull);
    expect(JOB3.locked_until, isNotNull);
  }
}
