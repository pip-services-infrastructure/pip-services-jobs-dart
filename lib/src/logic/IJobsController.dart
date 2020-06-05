import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../../src/data/version1/JobV1.dart';
import '../../src/data/version1/NewJobV1.dart';

abstract class IJobsController {
  // Add new job
  Future<JobV1> addJob(String correlationId, NewJobV1 newJob);

  // Add new job if not exist with same type and ref_jobId
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

  /// Gets an job by its unique jobId.
  ///
  /// - [correlationId]     (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                an jobId of job to be retrieved.
  /// Return         Future that receives job or error.
  Future<JobV1> getJobById(String correlationId, String jobId);

  Future<JobV1> startJobById(String correlationId, String jobId, num timeout);

  // Start fist free job by type
  Future<JobV1> startJobByType(
      String correlationId, String jobType, num timeout, num maxRetries);

  // Extend job execution limit on timeout value
  Future<JobV1> extendJob(String correlationId, String jobId, num timeout);

  // Abort job
  Future<JobV1> abortJob(String correlationId, String jobId);

  // Compleate job
  Future<JobV1> completeJob(String correlationId, String jobId);

  /// Deleted an job by it's unique jobId.
  ///
  /// - [correlation_jobId]    (optional) transaction jobId to trace execution through call chain.
  /// - [jobId]                an jobId of the job to be deleted
  /// Return                Future that receives deleted job
  /// Throws error.
  Future<JobV1> deleteJobById(String correlationId, String jobId);

  // Remove all jobs
  Future deleteJobs(String correlationId);

  // Clean completed and expiration jobs
  Future cleanJobs(String correlationId);
}
