@isTest
public class Test_RiskReportExport{

    public static testMethod void myTest(){
        List<Account> accList = new List<Account>();
        
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        
        //Accounts        
        accList = TestUtilityDataClassQantas.getAccounts();
        
        //Risk Record
        Risk__c risk = new Risk__c();
        risk.Account__c = accList[1].Id;
        risk.At_Risk_Since__c = Date.Today();
        
        // Account Relationship
        Account_Relation__c accRelation = new Account_Relation__c();
        accRelation.Related_Account__c = accList[1].Id;
        
        try{
            Database.Insert(accRelation);
            Database.Insert(risk);
        }Catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        
        // Initializing class
        RiskReportExport riskReport = new RiskReportExport();
        // Calling Wrapper class
        RiskReportExport.RiskReportWrapper riskWrapper = new RiskReportExport.RiskReportWrapper(risk, accRelation);
        riskReport.getRiskWrapperList();
        riskReport.exportExcel();
    }
    
}