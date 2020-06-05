import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_mongodb/pip_services3_mongodb.dart';

import '../data/version1/JobV1.dart';
import './IJobsPersistence.dart';

class JobsMongoDbPersistence
    extends IdentifiableMongoDbPersistence<JobV1, String>
    implements IJobsPersistence {
  JobsMongoDbPersistence() : super('jobs') {
    maxPageSize = 1000;
  }

  dynamic composeFilter(FilterParams filter) {
    filter = filter ?? FilterParams();

    var criteria = [];

    var id = filter.getAsNullableString('id');
    if (id != null) {
      criteria.add({'_id': id});
    }

    var type = filter.getAsNullableString('type');
    if (type != null) {
      criteria.add({'type': type});
    }

    var ref_id = filter.getAsNullableString('ref_id');
    if (ref_id != null) {
      criteria.add({'ref_id': ref_id});
    }

    var created = filter.getAsNullableDateTime('created');
    if (created != null) {
      criteria.add({'created': created.toIso8601String()});
    }
    var created_from = filter.getAsNullableDateTime('created_from');
    if (created_from != null) {
      criteria.add({
        'created': {r'$gte': created_from.toIso8601String()}
      });
    }
    var created_to = filter.getAsNullableDateTime('created_to');
    if (created_to != null) {
      criteria.add({
        'created': {r'$lte': created_to.toIso8601String()}
      });
    }

    var started = filter.getAsNullableDateTime('started');
    if (started != null) {
      criteria.add({'started': started.toIso8601String()});
    }
    var started_from = filter.getAsNullableDateTime('started_from');
    if (started_from != null) {
      criteria.add({
        'started': {r'$gte': started_from.toIso8601String()}
      });
    }
    var started_to = filter.getAsNullableDateTime('started_to');
    if (started_to != null) {
      criteria.add({
        'started': {r'$lte': started_to.toIso8601String()}
      });
    }

    var locked_until = filter.getAsNullableDateTime('locked_until');
    if (locked_until != null) {
      criteria.add({'locked_until': locked_until.toIso8601String()});
    }
    var locked_from = filter.getAsNullableDateTime('locked_from');
    if (locked_from != null) {
      criteria.add({
        'locked_until': {r'$gte': locked_from.toIso8601String()}
      });
    }
    var locked_to = filter.getAsNullableDateTime('locked_to');
    if (locked_to != null) {
      criteria.add({
        'locked_until': {r'$lte': locked_to.toIso8601String()}
      });
    }

    var execute_until = filter.getAsNullableDateTime('execute_until');
    if (execute_until != null) {
      criteria.add({'execute_until': execute_until.toIso8601String()});
    }
    var execute_from = filter.getAsNullableDateTime('execute_from');
    if (execute_from != null) {
      criteria.add({
        'execute_until': {r'$gte': execute_from.toIso8601String()}
      });
    }
    var execute_to = filter.getAsNullableDateTime('execute_to');
    if (execute_to != null) {
      criteria.add({
        'execute_until': {r'$lte': execute_to.toIso8601String()}
      });
    }

    var completed = filter.getAsNullableDateTime('completed');
    if (completed != null) {
      criteria.add({'completed': completed.toIso8601String()});
    }
    var completed_from = filter.getAsNullableDateTime('completed_from');
    if (completed_from != null) {
      criteria.add({
        'completed': {r'$gte': completed_from.toIso8601String()}
      });
    }
    var completed_to = filter.getAsNullableDateTime('completed_to');
    if (completed_to != null) {
      criteria.add({
        'completed': {r'$lte': completed_to.toIso8601String()}
      });
    }

    var retries = filter.getAsNullableInteger('retries');
    if (retries != null) {
      criteria.add({'retries': retries});
    }
    var min_retries = filter.getAsNullableInteger('min_retries');
    if (min_retries != null) {
      criteria.add({
        'retries': {r'$gt': min_retries}
      });
    }

    return criteria.isNotEmpty ? {r'$and': criteria} : null;
  }

  @override
  Future<JobV1> startJobById(
      String correlationId, String id, num timeout) async {
    var now = DateTime.now();
    var filter = {
      r'$and': [
        {'_id': id},
        {
          r'$or': [
            {
              'completed': {r'$eq': null}
            },
            {
              'completed': {r'$exists': false}
            }
          ]
        },
        {
          r'$or': [
            {
              'locked_until': {r'$eq': null}
            },
            {
              'locked_until': {r'$exists': false}
            },
            {
              'locked_until': {r'$lte': now.toIso8601String()}
            }
          ]
        }
      ]
    };

    var update = {
      r'$set': {
        'timeout': timeout,
        'started': now.toIso8601String(),
        'locked_until': DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + timeout).toIso8601String(),
      },
      r'$inc': {'retries': 1}
    };

    var item = await collection.findAndModify(
        query: filter, update: update, returnNew: true, upsert: false);

    if (item == null) {
      logger.trace(correlationId, 'Nothing found from %s with id = %s',
          [collectionName, id]);
      return null;
    }
    logger.trace(
        correlationId, 'Retrieved from %s with id = %s', [collectionName, id]);
    return convertToPublic(item);
  }

  @override
  Future<JobV1> startJobByType(
      String correlationId, String type, num timeout, num maxRetries) async {
    var now = DateTime.now();
    var filter = {
      r'$and': [
        {'type': type},
        {
          r'$or': [
            {
              'completed': {r'$eq': null}
            },
            {
              'completed': {r'$exists': false}
            }
          ]
        },
        {
          r'$or': [
            {
              'locked_until': {r'$eq': null}
            },
            {
              'locked_until': {r'$exists': false}
            },
            {
              'locked_until': {r'$lte': now.toIso8601String()}
            }
          ]
        },
        {
          'retries': {r'$lt': maxRetries}
        }
      ]
    };

    var update = {
      r'$set': {
        'timeout': timeout,
        'started': now.toUtc(),
        'locked_until': DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + timeout).toIso8601String(),
      },
      r'$inc': {'retries': 1}
    };

    var item = await collection.findAndModify(
        query: filter, update: update, returnNew: true, upsert: false);

    if (item == null) {
      logger.trace(correlationId, 'Nothing found from %s with type = %s',
          [collectionName, type]);
      return null;
    }
    logger.trace(correlationId, 'Retrieved from %s with type = %s',
        [collectionName, type]);
    return convertToPublic(item);
  }

  @override
  Future<DataPage<JobV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging) async {
    return super
        .getPageByFilterEx(correlationId, composeFilter(filter), paging, null);
  }

  @override
  Future deleteByFilter(String correlationId, FilterParams filter) {
    return super.deleteByFilterEx(correlationId, composeFilter(filter));
  }
}
