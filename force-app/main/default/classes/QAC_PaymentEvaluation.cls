/*
  Modified Date   : 18/10/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4833
  Version         : V2.0 - Changes : Close the Cases which is not Closed rather than 
                    Closing the cases which is already Closed to avoid the Milestone error
*/

global class QAC_PaymentEvaluation implements Database.Batchable<Service_Payment__c> {
    
    global Service_Payment__c[] start(Database.BatchableContext BC) {
        //Changes added by Vinoth for TS-4833
        //return [SELECT Id, Name, Work_Order__c, Payment_Type__c, Case__c, Payment_Status__c, Payment_Due_Date__c FROM Service_Payment__c WHERE Payment_Status__c = 'Pending'];
        return [SELECT Id, Name, Work_Order__c, Payment_Type__c, Case__c, Payment_Status__c, Payment_Due_Date__c, Case__r.IsClosed, Work_Order__r.Status, Work_Order__r.EndDate FROM Service_Payment__c WHERE Payment_Status__c = 'Pending' AND Payment_Due_Date__c != NULL AND DAY_ONLY(Payment_Due_Date__c) < Today];
        //Changes Ends for for TS-4833
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Payment__c> servicePaymentList) {
      list<Case> toUpdateCase = new list<Case>();
        list<WorkOrder> toUpdateWorkOrder = new list<WorkOrder>();
        
        //Changes added by Vinoth for TS-4833
        /*for(Service_Payment__c eachPayment : servicePaymentList){
            if(eachPayment.Payment_Due_Date__c != NULL)
            {
                if(eachPayment.Payment_Due_Date__c < Date.today()){
                    if(eachPayment.Case__c != NULL )
                    {
                        //Changes added JIRA:TS-3240
                        toUpdateCase.add(new Case(Id = eachPayment.Case__c, Status = 'Auto Closed', Approve__c='No', Condition_Met__c='No'));    
                        //Changes ends JIRA:TS-3240
                    }
                    if(eachPayment.Work_Order__c != NULL )
                    {
                        toUpdateWorkOrder.add(new WorkOrder(Id= eachPayment.Work_Order__c, Status = 'Canceled', EndDate = Date.today()));
                    }
                    eachPayment.Payment_Status__c = 'Cancelled';
                }    
            }
                        
        }*/
        
        for(Service_Payment__c eachPayment : servicePaymentList){
            if(eachPayment.Case__c != NULL && eachPayment.Case__r.IsClosed == FALSE){
                //Changes added JIRA:TS-3240
                toUpdateCase.add(new Case(Id = eachPayment.Case__c, Status = 'Auto Closed', Approve__c='No', Condition_Met__c='No'));
                //Changes ends JIRA:TS-3240
            }
            if(eachPayment.Work_Order__c != NULL && (eachPayment.Work_Order__r.Status != 'Canceled' || eachPayment.Work_Order__r.EndDate == NULL)){
                toUpdateWorkOrder.add(new WorkOrder(Id= eachPayment.Work_Order__c, Status = 'Canceled', EndDate = Date.today()));
            }
            eachPayment.Payment_Status__c = 'Cancelled';
        }    
        //Changes Ends for for TS-4833

        list<Database.SaveResult> spResults = Database.update(servicePaymentList, false);
        list<Database.SaveResult>  caseResults = Database.update(toUpdateCase, false);
        list<Database.SaveResult>  woResults = Database.update(toUpdateWorkOrder, false);
  
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}