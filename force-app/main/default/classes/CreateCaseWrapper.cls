/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen/Benazir
Company:       Capgemini
Description:   Class to create Case on Mutiple QBR to Notify Admin to action upon the Duplicate QBR Created
Inputs:
Test Class:    Functional testing will cover this class. 
************************************************************************************************
History
************************************************************************************************
21-Apr-2017    Praveen Sampath          Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
public class CreateCaseWrapper {
     /*--------------------------------------------------------------------------------------      
    Method Name:        createCaseMultipleACtiveQBR
    Description:        Method to Create Delete tracker Logs
    --------------------------------------------------------------------------------------*/    
    public static List<Case>  createCaseMultipleACtiveQBR(List<CaseWrapper> lstcaseWrapper){
        List<Case> lstCaseLog = new List<Case>();
        for(caseWrapper caseWrap: lstcaseWrapper){
            Case  objCase = new Case();
            objCase.RecordTypeId = GenericUtils.getObjectRecordTypeId('Case', caseWrap.recType);
            objCase.Status  = caseWrap.caseStatus;
            objCase.Subject = caseWrap.caseSubject;
            objCase.Description = caseWrap.caseDesc;
            objCase.Origin = caseWrap.caseOrg;
            objCase.Reason = caseWrap.caseReason;
            objCase.Priority = caseWrap.casePriority;
            objCase.AccountId = caseWrap.accId;
            objCase.Type = caseWrap.caseType;
            objCase.Sub_Type_1__c = caseWrap.caseSubType;
            objCase.Sub_Type_2__c = caseWrap.caseSubType2;
            lstCaseLog.add(objCase);
        }
        return lstCaseLog;
    } 
       /*--------------------------------------------------------------------------------------      
    Wrapper Name:       CaseLogWrapper
    Description:        Wrapper to Create Case to Notify System AdminQueue
    --------------------------------------------------------------------------------------*/    
    public class CaseWrapper{
        public String caseDesc;
        public String caseSubject;
        public String caseStatus;
        public String caseOrg;
        public String caseReason;
        public String casePriority;
        public String recType;
        public String accId;
        public String caseType;
        public String caseSubType;
        public String caseSubType2;
    }


}