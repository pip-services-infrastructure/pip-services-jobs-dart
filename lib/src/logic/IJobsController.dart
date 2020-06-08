import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../src/data/version1/JobV1.dart';
import '../../src/data/version1/NewJobV1.dart';

abstract class IJobsController {
  /// Add new job from newJob.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [newJob]                a new job to be added to exist job.
  /// Return         Future that receives job or error.
  Future<JobV1> addJob(String correlationId, NewJobV1 newJob);

  /// Add new job if not exist with same type and ref_jobId
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [newJob]                a new job to be added to exist job.
  /// Return         Future that receives job or error.
  Future<JobV1> addUniqJob(String correlationId, NewJobV1 newJob);

  /// Gets a page of jobs retrieved by a given filter.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [filter]            (optional) a filter function to filter items
  /// - [paging]            (optional) paging parameters
  /// Return         Future that receives a data page
  /// Throws error.
  Future<DataPage<JobV1>> getJobs(
      String correlationId, FilterParams filter, PagingParams paging);

  /// Gets a job by its unique jobId.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  Future<JobV1> getJobById(String correlationId, String jobId);

  /// Starts a job by its unique jobId.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// Return         Future that receives job or error.
  Future<JobV1> startJobById(String correlationId, String jobId, num timeout);

  /// Start fist free job by type
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobType]                a jobType of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// - [maxRetries]                a maxRetries for get item with retries less than them.
  /// Return         Future that receives job or error.
  Future<JobV1> startJobByType(
      String correlationId, String jobType, num timeout, num maxRetries);

  /// Extends job execution limit on timeout value
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// - [timeout]                a timeout for set locked_until time for job.
  /// Return         Future that receives job or error.
  Future<JobV1> extendJob(String correlationId, String jobId, num timeout);

  /// Aborts job
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  Future<JobV1> abortJob(String correlationId, String jobId);

  /// Completes job
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  Future<JobV1> completeJob(String correlationId, String jobId);

  /// Deletes a job by it's unique jobId.
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                a jobId of the job to be deleted
  /// Return                Future that receives deleted job
  /// Throws error.
  Future<JobV1> deleteJobById(String correlationId, String jobId);

  /// Removes all jobs
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  Future deleteJobs(String correlationId);

  /// Clean completed and expiration jobs
  ///
  /// - [correlationId]    (optional) transaction jobId to trace execution through call chain.
  /// Return                Future that receives null for success
  /// Throws error.
  Future cleanJobs(String correlationId);
}
