/*-----------------------------------------------------------------------------------------------------------------------------
Author:TCS       
Description:To check whether Manager contact is duplicate or not based few scenarios   
Test Class for  QAC_ManagerContactsDuplicateCheck  
*********************************************************************************************************************************
*********************************************************************************************************************************/
@IsTest
public class QAC_ManagerContDupCheck_Test {
    
    @testsetup
    public static void setupdata()
    {
           
        // Create PermissionSet with Custom Permission and assign to test user
    PermissionSet ps = new PermissionSet();
    ps.Name = 'Test';
    ps.Label = 'Test';
    insert ps;
    SetupEntityAccess sea = new SetupEntityAccess();
    sea.ParentId = ps.Id;
    sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'QCC_Bypass_Account_Contact_Case_Triggers'][0].Id;
    insert sea;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = UserInfo.getUserId();
    psa.PermissionSetId = ps.Id;
    insert psa;
    }
    @IsTest
    public static void dedupe(){
        TestUtilityDataClassQantas.enableTriggers();
     	TestUtilityDataClassQantas.createContactTriggerSetting();
        
        String conRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(); 
     	List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact(FirstName='Fname1', LastName='testxby',Email='testxby@gmail.com',MobilePhone='9999256123',verification_number__c='1234567098',QAC_Contact__c='Yes',RecordTypeId=conRTId);
        conList.add(con1);
        Contact con2 = new Contact(FirstName='Fname2', LastName='testxby',Email='testxby@gmail.com',MobilePhone='9999256123',QAC_Contact__c='Yes',RecordTypeId=conRTId);
        conList.add(con2);
        try{
        insert conList;
        
        Contact con = new Contact();
        con.id=conList[0].id;
        con.Verification_Number__c='1234586709';
        update con;
        }Catch(Exception e){System.debug('Exception Caught');}
        
        
    }

}