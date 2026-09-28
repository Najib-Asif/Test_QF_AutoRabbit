global class schduleSystemAdminCaseCreation implements Schedulable {

   global void execute(SchedulableContext ctx) {
      new Flow.Interview.Service_Request_System_admin_case_creation(new Map<String,Object>()).start();
   }   
}