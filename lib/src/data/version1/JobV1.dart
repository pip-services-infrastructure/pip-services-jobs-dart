import 'package:pip_services3_commons/pip_services3_commons.dart';

import './NewJobV1.dart';

class JobV1 implements IStringIdentifiable {
  @override
  // Job description
  String id;
  String type;
  String ref_id;
  dynamic params;

  // Job control
  DateTime created;
  DateTime started;
  DateTime locked_until;
  DateTime execute_until;
  DateTime completed;
  num retries;

  JobV1(
      {String id,
      String type,
      String ref_id,
      dynamic params,
      DateTime created,
      DateTime started,
      DateTime locked_until,
      DateTime execute_until,
      DateTime completed,
      num retries})
      : id = id,
        type = type,
        ref_id = ref_id,
        params = params,
        created = created,
        started = started,
        locked_until = locked_until,
        execute_until = execute_until,
        completed = completed,
        retries = retries;

  JobV1.fromNewJobV1(NewJobV1 newJob) {
    created = DateTime.now().toUtc();
    retries = 0;

    if (newJob != null) {
      type = newJob.type;
      ref_id = newJob.ref_id;
      params = newJob.params;
      if (newJob.ttl != null && newJob.ttl > 0) {
        execute_until = DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().toUtc().millisecondsSinceEpoch + newJob.ttl)
            .toUtc();
      }
    }
  }

  void fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    ref_id = json['ref_id'];
    params = json['params'];
    var created_json = json['created'];
    var started_json = json['started'];
    var locked_until_json = json['locked_until'];
    var execute_until_json = json['execute_until'];
    var completed_json = json['completed'];
    created = created_json != null ? DateTime.tryParse(created_json) : null;
    started = started_json != null ? DateTime.tryParse(started_json) : null;
    locked_until =
        locked_until_json != null ? DateTime.tryParse(locked_until_json) : null;
    execute_until = execute_until_json != null
        ? DateTime.tryParse(execute_until_json)
        : null;
    completed =
        completed_json != null ? DateTime.tryParse(completed_json) : null;
    retries = json['retries'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'ref_id': ref_id,
      'params': params,
      'created': created != null ? created.toIso8601String() : created,
      'started': started != null ? started.toIso8601String() : started,
      'locked_until':
          locked_until != null ? locked_until.toIso8601String() : locked_until,
      'execute_until': execute_until != null
          ? execute_until.toIso8601String()
          : execute_until,
      'completed': completed != null ? completed.toIso8601String() : completed,
      'retries': retries
    };
  }
}
