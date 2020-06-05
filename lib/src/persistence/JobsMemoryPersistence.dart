import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_data/pip_services3_data.dart';
import '../data/version1/JobV1.dart';
import './IJobsPersistence.dart';

class JobsMemoryPersistence extends IdentifiableMemoryPersistence<JobV1, String>
    implements IJobsPersistence {
  JobsMemoryPersistence() : super() {
    maxPageSize = 1000;
  }

  Function composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var id = filter.getAsNullableString('id');
    var type = filter.getAsNullableString('type');
    var ref_id = filter.getAsNullableString('ref_id ');

    var created = filter.getAsNullableDateTime('created');
    var created_from = filter.getAsNullableDateTime('created_from');
    var created_to = filter.getAsNullableDateTime('created_to');

    var started = filter.getAsNullableDateTime('started');
    var started_from = filter.getAsNullableDateTime('started_from');
    var started_to = filter.getAsNullableDateTime('started_to');

    var locked_until = filter.getAsNullableDateTime('locked_until');
    var locked_from = filter.getAsNullableDateTime('locked_from');
    var locked_to = filter.getAsNullableDateTime('locked_to');

    var execute_until = filter.getAsNullableDateTime('execute_until');
    var execute_from = filter.getAsNullableDateTime('execute_from');
    var execute_to = filter.getAsNullableDateTime('execute_to');

    var completed = filter.getAsNullableDateTime('completed');
    var completed_from = filter.getAsNullableDateTime('completed_from');
    var completed_to = filter.getAsNullableDateTime('completed_to');

    var retries = filter.getAsNullableInteger('retries');
    var min_retries = filter.getAsNullableInteger('min_retries');

    return (item) {
      if (id != null && item.id != id) {
        return false;
      }
      if (type != null && item.type != type) {
        return false;
      }
      if (ref_id != null && item.ref_id != ref_id) {
        return false;
      }

      if (created != null &&
          item.created.millisecondsSinceEpoch !=
              created.millisecondsSinceEpoch) {
        return false;
      }
      if (created_from != null &&
          item.created.millisecondsSinceEpoch <
              created_from.millisecondsSinceEpoch) {
        return false;
      }
      if (created_to != null &&
          item.created.millisecondsSinceEpoch >
              created_to.millisecondsSinceEpoch) {
        return false;
      }

      if (started != null &&
          (item.started == null ||
              item.started.millisecondsSinceEpoch !=
                  started.millisecondsSinceEpoch)) {
        return false;
      }
      if (started_from != null &&
          (item.started == null ||
              item.started.millisecondsSinceEpoch <
                  started_from.millisecondsSinceEpoch)) {
        return false;
      }
      if (started_to != null &&
          (item.started == null ||
              item.started.millisecondsSinceEpoch >
                  started_to.millisecondsSinceEpoch)) {
        return false;
      }

      if (locked_until != null &&
          (item.locked_until == null ||
              item.locked_until.millisecondsSinceEpoch !=
                  locked_until.millisecondsSinceEpoch)) {
        return false;
      }
      if (locked_from != null &&
          (item.locked_until == null ||
              item.locked_until.millisecondsSinceEpoch <
                  locked_from.millisecondsSinceEpoch)) {
        return false;
      }
      if (locked_to != null &&
          (item.locked_until == null ||
              item.locked_until.millisecondsSinceEpoch >
                  locked_to.millisecondsSinceEpoch)) {
        return false;
      }

      if (execute_until != null &&
          (item.execute_until == null ||
              item.execute_until.millisecondsSinceEpoch !=
                  execute_until.millisecondsSinceEpoch)) {
        return false;
      }
      if (execute_from != null &&
          (item.execute_until == null ||
              item.execute_until.millisecondsSinceEpoch <
                  execute_from.millisecondsSinceEpoch)) {
        return false;
      }
      if (execute_to != null &&
          (item.execute_until == null ||
              item.execute_until.millisecondsSinceEpoch >
                  execute_to.millisecondsSinceEpoch)) {
        return false;
      }

      if (completed != null &&
          (item.completed == null ||
              item.completed.millisecondsSinceEpoch !=
                  completed.millisecondsSinceEpoch)) {
        return false;
      }
      if (completed_from != null &&
          (item.completed == null ||
              item.completed.millisecondsSinceEpoch <
                  completed_from.millisecondsSinceEpoch)) {
        return false;
      }
      if (completed_to != null &&
          (item.completed == null ||
              item.completed.millisecondsSinceEpoch >
                  completed_to.millisecondsSinceEpoch)) {
        return false;
      }

      if (retries != null && item.retries != retries) {
        return false;
      }
      if (min_retries != null && item.retries <= min_retries) {
        return false;
      }

      return true;
    };
  }

  @override
  Future<JobV1> startJobById(
      String correlationId, String id, num timeout) async {
    var item = items.isNotEmpty ? items.where((item) => item.id == id) : null;

    if (item == null || item.isEmpty || item.first == null) {
      logger.trace(correlationId, 'Item %s was not found', [id]);
      return null;
    } else {
      var job = item.first;
      var now = DateTime.now().toUtc();
      if (job.completed == null &&
          (job.locked_until == null ||
              job.locked_until.millisecondsSinceEpoch <=
                  now.millisecondsSinceEpoch)) {
        job.started = now;
        job.locked_until = DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + timeout);
        job.retries++;

        logger.trace(correlationId, 'Updated item %s', [job.id]);

        await save(correlationId);
        return job;
      } else {
        logger.trace(correlationId, 'Item %s was completed or locked', [id]);
        return null;
      }
    }
  }

  @override
  Future<JobV1> startJobByType(
      String correlationId, String type, num timeout, num maxRetries) async {
    var now = DateTime.now().toUtc();
    var item = items.isNotEmpty
        ? items.where((item) =>
            item.type == type &&
            item.completed == null &&
            item.retries < maxRetries &&
            (item.locked_until == null ||
                item.locked_until.millisecondsSinceEpoch <=
                    now.millisecondsSinceEpoch))
        : null;

    if (item == null || item.isEmpty || item.first == null) {
      logger.trace(correlationId, 'Item with type %s was not found', [type]);
      return null;
    } else {
      var job = item.first;
      job.started = now;
      job.locked_until = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + timeout);
      job.retries++;

      logger.trace(correlationId, 'Updated item %s', [job.id]);

      await save(correlationId);
      return job;
    }
  }

  @override
  Future<DataPage<JobV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) {
    return super
        .getPageByFilterEx(correlationId, composeFilter(filter), paging, null);
  }

  @override
  Future deleteByFilter(String correlationId, FilterParams filter) {
    return super.deleteByFilterEx(correlationId, composeFilter(filter));
  }
}
