import 'package:pip_services_jobs/pip_services_jobs.dart';

void main(List<String> argument) {
  try {
    var proc = JobsProcess();
    proc.configPath = './config/config.yml';
    proc.run(argument);
  } catch (ex) {
    print(ex);
  }
}
