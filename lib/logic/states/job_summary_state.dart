import 'job_priority.dart';

class JobSummaryState{
  String? name;
  String? orderNumber;
  int? companyId;
  int? jobId;
  String? description;
  JobPriority? priority;
  JobSummaryState(int companyId, int jobId);
  bool isReady(){
    if(name == null) return false;
    if(orderNumber == null) return false;
    if(companyId == null) return false;
    if(jobId == null) return false;
    if(description == null) return false;
    if(priority == null) return false;
    return true;
  }
}