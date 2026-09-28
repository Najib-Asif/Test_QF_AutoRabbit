@isTest
public class Test_MemberTriggerHandler{
    
  /*public static testMethod void testProductRegistrationInsert(){
        List<Account> accList = new List<Account>();
        List<Associated_Person__c> memberList = new List<Associated_Person__c>();
        List<Case> caseList = new List<Case>();
        
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.getCaseSubtypeCSetting();
        TestUtilityDataClassQantas.getCaseTypeCSetting();
        
        accList = TestUtilityDataClassQantas.getAccounts();
        
        memberList = TestUtilityDataClassQantas.getMembers(accList);     
        
        caseList = TestUtilityDataClassQantas.getCases(accList);
        
        for(Associated_Person__c asp : memberList){
            asp.Active_Profile_Record__c = true;
            asp.Active_QBD_Record__c = true;
        }
        
        try{
            Database.Update(memberList);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
       
  } */
}