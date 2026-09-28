@isTest
public class Test_associatedPersonSearchController{

    //Added By Praveen For test class failure fix
    @testsetup
    static void createData(){
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
    }

    public static testMethod void myTest(){
        List<Account> accList = new List<Account>();
        
        // Custom setting creation
        TestUtilityDataClassQantas.enableTriggers();
        
        //Accounts
        accList = TestUtilityDataClassQantas.getAccounts();
        
        //Custom Setting
        Associated_Person_Fields__c apf = new Associated_Person_Fields__c(Name = 'AssociatedPersonField-Ids', Email__c = 'con15',
                                                                          FirstName__c = 'name_firstcon2', FrequentFlyerNumber__c = '00N9000000DHmC1',
                                                                          JobTitle__c = 'con5', LastName__c = 'name_lastcon2', Phone__c = 'con10'
                                                                          );
        try{
            Database.Insert(apf);
        }catch(Exception e){
            System.debug('Exception Occured: '+e.getMessage());
        }
        
        //Associated Person
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(accList[0]);
        associatedPersonSearchController aps = new associatedPersonSearchController(stdController);
        aps.searchContacts();
        aps.createNewContact();
        aps.contiueToEdit();
        aps.goBack();        
                
        Test.stopTest();
    }
}