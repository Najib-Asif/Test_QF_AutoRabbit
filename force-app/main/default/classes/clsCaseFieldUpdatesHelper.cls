/***********************************************************************************************************************************

History:
======================================================================================================================
Name                          Description                                           Tag
======================================================================================================================
Yuvaraj MV           Ticketing Authority Number generation                          T01

Created Date    : 09/05/18 (DD/MM/YYYY)

TestClass       :TestclsCaseFieldUpdatesHelper
**********************************************************************************************************************************/

public class clsCaseFieldUpdatesHelper{
   
  /*  public static void generateAuthorityNumber(List<Case> caseList){
        try{
            QIC_AutoNumber__c qicInfo = QIC_AutoNumber__c.getValues('Fee Waiver Request'); 
            Decimal authNum = qicInfo.LastNumber__c;   
            String blanketWaiverType = qicInfo.CaseType__c ;
            String QICRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(qicInfo.Record_Type__c).getRecordTypeId();
            String blanketWaiverRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(qicInfo.Blanket_Waiver__c).getRecordTypeId();
            
            for(Case c: caseList){
                if(c.Authority_Number__c == null){
                if(c.RecordTypeId == blanketWaiverRecordTypeId  && c.Status == qicInfo.ClosedStatus__c ){
                    c.Authority_Number__c = authNum.format().replace(',','') ;
                    authNum = authNum + 1; 
                    if(authNum == qicInfo.EndNumber__c){
                        authNum = qicInfo.StartNumber__c;
                    }
                }
                if(c.RecordTypeId == QICRecordTypeId  && c.Status == qicInfo.ClosedStatus__c && c.Type != blanketWaiverType){
                    c.Authority_Number__c = authNum.format().replace(',','') ;
                    authNum = authNum + 1; 
                    if(authNum == qicInfo.EndNumber__c){
                        authNum = qicInfo.StartNumber__c;
                    }
                }
                }
            }
            if(qicInfo.LastNumber__c != authNum){
                qicInfo.LastNumber__c = authNum;
                update qicInfo ;
            } 
        }catch(Exception e){
            system.debug('EXCEPTION_Authority_Number:'+e.getStackTraceString());
        }
        } */
    
    /* QAC Release 2 Authority Number Generation logic removed from Status field */
    
    public static void generateAuthorityNumberNew(List<Case> caseList)
    {
        try
        {
            QIC_AutoNumber__c qicInfo = QIC_AutoNumber__c.getValues('Fee Waiver Request'); 
            
            Decimal authNum = qicInfo.LastNumber__c;   
            String blanketWaiverType = qicInfo.CaseType__c ;
            String QICRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(qicInfo.Record_Type__c).getRecordTypeId();
            String blanketWaiverRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(qicInfo.Blanket_Waiver__c).getRecordTypeId();
            
            for(Case c: caseList)
            {
                if(c.Authority_Number__c == null)
                {
                    if(c.RecordTypeId == blanketWaiverRecordTypeId  && (c.Authority_Status__c == 'Auto Approved' || c.Authority_Status__c == 'Approved'))
                    {
                        c.Authority_Number__c = authNum.format().replace(',','') ;
                        authNum = authNum + 1; 
                        if(authNum == qicInfo.EndNumber__c)
                        {
                            authNum = qicInfo.StartNumber__c;
                        }
                    }
                    if(c.RecordTypeId == QICRecordTypeId  && (c.Authority_Status__c == 'Auto Approved' || c.Authority_Status__c == 'Approved') && c.Type != blanketWaiverType)
                    {
                        c.Authority_Number__c = authNum.format().replace(',','') ;
                        authNum = authNum + 1; 
                        if(authNum == qicInfo.EndNumber__c)
                        {
                            authNum = qicInfo.StartNumber__c;
                        }
                    }
                }
            }
            if(qicInfo.LastNumber__c != authNum)
            {
                qicInfo.LastNumber__c = authNum;
                update qicInfo ;
            } 
        }
        catch(Exception e)
        {
            system.debug('EXCEPTION_Authority_Number:'+e.getStackTraceString());
        }
    }
    
     /*--------------------------------------------------------------------------------------      
    Method Name:        updateAccountRequestPending
    Description:        Updating QAC_Request_Pending__c to False when Case is getting Closed
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static void updateAccountRequestPending(List<Case> lstCase, Map<Id, Case> mapOldMap){ 
      
        try{
            
            set<Id> setAccountIds = new set<Id>();
            string caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
            list<Account> toUpdateAccounts = new list<Account>();
            for(Case eachCase : lstCase){
                if(eachCase.Status == 'Closed' 
                    && mapOldMap.get(eachCase.Id).Status != 'Closed'
                    && eachCase.RecordTypeId == caseRecordTypeId){
                    setAccountIds.add(eachCase.AccountId);
                }                
            }
            
            if(setAccountIds.size() > 0){
                for(Id eachId : setAccountIds){
                    toUpdateAccounts.add(new Account(Id = eachId, QAC_Request_Pending__c = false));    
                }
            }
            
            if(toUpdateAccounts.size() > 0){
                update toUpdateAccounts;
            }
            
        }
        
        catch(Exception ex) {
            system.debug('ex###############'+ex);
        }
        
    }
}