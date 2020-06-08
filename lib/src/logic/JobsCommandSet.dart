import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../src/logic/IJobsController.dart';
import '../../src/data/version1/NewJobV1Schema.dart';
import '../../src/data/version1/NewJobV1.dart';

class JobsCommandSet extends CommandSet {
  IJobsController _controller;

  JobsCommandSet(IJobsController controller) : super() {
    _controller = controller;

    addCommand(_makeAddJob());
    addCommand(_makeAddUniqJob());
    addCommand(_makeGetJobs());
    addCommand(_makeGetJobById());
    addCommand(_makeStartJobById());
    addCommand(_makeStartJobByType());
    addCommand(_makeExtendJob());
    addCommand(_makeAbortJob());
    addCommand(_makeCompleteJob());
    addCommand(_makeDeleteJobById());
    addCommand(_makeDeleteJobs());
    addCommand(_makeCleanJobs());
  }

  ICommand _makeAddJob() {
    return Command('add_job',
        ObjectSchema(true).withRequiredProperty('new_job', NewJobV1Schema()),
        (String correlationId, Parameters args) {
      var new_job = NewJobV1();
      new_job.fromJson(args.get('new_job'));
      return _controller.addJob(correlationId, new_job);
    });
  }

  ICommand _makeAddUniqJob() {
    return Command('add_uniq_job',
        ObjectSchema(true).withRequiredProperty('new_job', NewJobV1Schema()),
        (String correlationId, Parameters args) {
      var new_job = NewJobV1();
      new_job.fromJson(args.get('new_job'));
      return _controller.addUniqJob(correlationId, new_job);
    });
  }

  ICommand _makeGetJobs() {
    return Command(
        'get_jobs',
        ObjectSchema(true)
            .withOptionalProperty('filter', FilterParamsSchema())
            .withOptionalProperty('paging', PagingParamsSchema()),
        (String correlationId, Parameters args) {
      var filter = FilterParams.fromValue(args.get('filter'));
      var paging = PagingParams.fromValue(args.get('paging'));
      return _controller.getJobs(correlationId, filter, paging);
    });
  }

  ICommand _makeGetJobById() {
    return Command('get_job_by_id',
        ObjectSchema(true).withRequiredProperty('job_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      return _controller.getJobById(correlationId, jobId);
    });
  }

  ICommand _makeStartJobById() {
    return Command(
        'start_job_by_id',
        ObjectSchema(true)
            .withRequiredProperty('job_id', TypeCode.String)
            .withRequiredProperty('timeout', TypeCode.Integer),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      var timeout = args.getAsIntegerWithDefault('timeout', 1000 * 60);
      return _controller.startJobById(correlationId, jobId, timeout);
    });
  }

  ICommand _makeStartJobByType() {
    return Command(
        'start_job_by_type',
        ObjectSchema(true)
            .withRequiredProperty('type', TypeCode.String)
            .withRequiredProperty('timeout', TypeCode.Integer)
            .withOptionalProperty('max_retries', TypeCode.Integer),
        (String correlationId, Parameters args) {
      var type = args.getAsString('type');
      var timeout = args.getAsIntegerWithDefault('timeout', 1000 * 60);
      var maxRetries = args.getAsIntegerWithDefault('max_retries', 10);
      return _controller.startJobByType(
          correlationId, type, timeout, maxRetries);
    });
  }

  ICommand _makeExtendJob() {
    return Command(
        'extend_job',
        ObjectSchema(true)
            .withRequiredProperty('job_id', TypeCode.String)
            .withRequiredProperty('timeout', TypeCode.Integer),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      var timeout = args.getAsIntegerWithDefault('timeout', 1000 * 60);
      return _controller.extendJob(correlationId, jobId, timeout);
    });
  }

  ICommand _makeAbortJob() {
    return Command('abort_job',
        ObjectSchema(true).withRequiredProperty('job_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      return _controller.abortJob(correlationId, jobId);
    });
  }

  ICommand _makeCompleteJob() {
    return Command('complete_job',
        ObjectSchema(true).withRequiredProperty('job_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      return _controller.completeJob(correlationId, jobId);
    });
  }

  ICommand _makeDeleteJobById() {
    return Command('delete_job_by_id',
        ObjectSchema(true).withRequiredProperty('job_id', TypeCode.String),
        (String correlationId, Parameters args) {
      var jobId = args.getAsString('job_id');
      return _controller.deleteJobById(correlationId, jobId);
    });
  }

  ICommand _makeDeleteJobs() {
    return Command('delete_jobs', ObjectSchema(true),
        (String correlationId, Parameters args) {
      return _controller.deleteJobs(correlationId);
    });
  }

  ICommand _makeCleanJobs() {
    return Command('clean_jobs', ObjectSchema(true),
        (String correlationId, Parameters args) {
      return _controller.cleanJobs(correlationId);
    });
  }
}
