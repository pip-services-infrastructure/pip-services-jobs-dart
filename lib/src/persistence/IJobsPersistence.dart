import 'dart:async';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import '../data/version1/JobV1.dart';

abstract class IJobsPersistence {
  Future<DataPage<JobV1>> getPageByFilter(
      String correlationId, FilterParams filter, PagingParams paging);

  Future<JobV1> getOneById(String correlationId, String id);

  Future<JobV1> create(String correlationId, JobV1 item);

  Future<JobV1> update(String correlationId, JobV1 item);

  Future<JobV1> updatePartially(
      String correlationId, String id, AnyValueMap values);

  Future<JobV1> startJobById(String correlationId, String id, num timeout);

  Future<JobV1> startJobByType(
      String correlationId, String type, num timeout, num maxRetries);

  Future<JobV1> deleteById(String correlationId, String id);

  Future deleteByFilter(String correlationId, FilterParams filter);
}
