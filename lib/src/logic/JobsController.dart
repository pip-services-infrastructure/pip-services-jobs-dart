import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

import '../../src/data/version1/JobV1.dart';
import '../../src/data/version1/NewJobV1.dart';
import '../../src/persistence/IJobsPersistence.dart';
import './IJobsController.dart';
import './JobsCommandSet.dart';

class JobsController
    implements
        IJobsController,
        IConfigurable,
        IReferenceable,
        ICommandable,
        IOpenable {
  IJobsPersistence persistence;
  JobsCommandSet commandSet;
  bool _opened = false;
  FixedRateTimer _timer = FixedRateTimer(() {}, 300000);
  num _cleanInterval = 1000 * 60 * 5;
  num _maxRetries = 10;
  final CompositeLogger _logger = CompositeLogger();

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    _logger.configure(config);
    _cleanInterval =
        config.getAsLongWithDefault('options.clean_interval', 1000 * 60);
    _maxRetries = config.getAsLongWithDefault('options.max_retries', 10);
  }

  @override
  bool isOpen() {
    return _opened;
  }

  /// Opens the session.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			    Future that receives error or null no errors occured.
  @override
  Future open(String correlationId) async {
    return Future.delayed(Duration(), () {
      if (_cleanInterval > 0) {
        _timer = FixedRateTimer(() {
          cleanJobs(correlationId);
        }, _cleanInterval, 0);
        _timer.start();
      }
      _opened = true;
      _logger.trace(correlationId, 'Jobs controller is opened');
    });
  }

  @override
  Future close(String correlationId) async {
    return Future.delayed(Duration(), () {
      if (_timer.isStarted()) {
        _timer.stop();
      }
      _opened = false;
      _logger.trace(correlationId, 'Jobs controller is closed');
    });
  }

  /// Set references to component.
  ///
  /// - [references]    references parameters to be set.
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    persistence = references.getOneRequired<IJobsPersistence>(
        Descriptor('pip-services-jobs', 'persistence', '*', '*', '1.0'));
  }

  /// Gets a command set.
  ///
  /// Return Command set
  @override
  CommandSet getCommandSet() {
    commandSet ??= JobsCommandSet(this);
    return commandSet;
  }

  /// Add new job from newJob.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [newJob]                a new job to be added to exist job.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> addJob(String correlationId, NewJobV1 newJob) {
    var job = JobV1.fromNewJobV1(newJob);
    return persistence.create(correlationId, job);
  }

  /// Add new job if not exist with same type and ref_jobId
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [newJob]                a new job to be added to exist job.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> addUniqJob(String correlationId, NewJobV1 newJob) async {
    var filter =
        FilterParams.fromTuples(['type', newJob.type, 'ref_id', newJob.ref_id]);

    var paging = PagingParams();
    var page = await persistence.getPageByFilter(correlationId, filter, paging);
    if (page.data.isNotEmpty) {
      return page.data[0];
    } else {
      var job = JobV1.fromNewJobV1(newJob);
      return persistence.create(correlationId, job);
    }
  }

  /// Gets a page of jobs retrieved by a given filter.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [filter]            (optional) a filter function to filter items
  /// - [paging]            (optional) paging parameters
  /// Return         Future that receives a data page
  /// Throws error.
  @override
  Future<DataPage<JobV1>> getJobs(
      String correlationId, FilterParams filter, PagingParams paging) {
    return persistence.getPageByFilter(correlationId, filter, paging);
  }

  /// Gets a job by its unique jobId.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> getJobById(String correlationId, String id) {
    return persistence.getOneById(correlationId, id);
  }

  /// Starts a job by its unique jobId.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> startJobById(String correlationId, String jobId, num timeout) {
    return persistence.startJobById(correlationId, jobId, timeout);
  }

  /// Start fist free job by type
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobType]                a jobType of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// - [maxRetries]                a maxRetries for get item with retries less than them.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> startJobByType(
      String correlationId, String jobType, num timeout, num maxRetries) {
    return persistence.startJobByType(
        correlationId, jobType, timeout, maxRetries);
  }

  /// Extends job execution limit on timeout value
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> extendJob(String correlationId, String jobId, num timeout) {
    var now = DateTime.now().toUtc();
    var update = AnyValueMap.fromValue({
      'timeout': timeout,
      'locked_util': DateTime.fromMillisecondsSinceEpoch(
              now.millisecondsSinceEpoch + timeout)
          .toUtc()
    });

    return persistence.updatePartially(correlationId, jobId, update);
  }

  /// Aborts job
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> abortJob(String correlationId, String jobId) {
    var update = AnyValueMap.fromValue({
      'started': null,
      'locked_util': null,
    });

    return persistence.updatePartially(correlationId, jobId, update);
  }

  /// Completes job
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  @override
  Future<JobV1> completeJob(String correlationId, String jobId) {
    var update = AnyValueMap.fromValue({
      'started': null,
      'locked_util': null,
      'completed': DateTime.now().toUtc()
    });

    return persistence.updatePartially(correlationId, jobId, update);
  }

  /// Deletes a job by it's unique jobId.
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of the job to be deleted
  /// Return                Future that receives deleted job
  /// Throws error.
  @override
  Future<JobV1> deleteJobById(String correlationId, String jobId) {
    return persistence.deleteById(correlationId, jobId);
  }

  /// Removes all jobs
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  @override
  Future deleteJobs(String correlationId) {
    return persistence.deleteByFilter(correlationId, FilterParams());
  }

  /// Clean completed and expiration jobs
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  @override
  Future cleanJobs(String correlationId) async {
    var now = DateTime.now().toUtc();

    _logger.trace(correlationId, 'Starting jobs cleaning...');

    try {
      await persistence.deleteByFilter(
          correlationId, FilterParams.fromValue({'min_retries': _maxRetries}));

      await persistence.deleteByFilter(correlationId,
          FilterParams.fromValue({'execute_to': now.toIso8601String()}));

      await persistence.deleteByFilter(correlationId,
          FilterParams.fromValue({'completed_to': now.toIso8601String()}));

      _logger.trace(correlationId, 'Jobs cleaning ended.');
    } on ApplicationException catch (ex) {
      _logger.error(correlationId, ex, 'Failed to clean up jobs.');
    }
  }
}
