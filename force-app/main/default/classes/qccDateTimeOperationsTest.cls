/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class qccDateTimeOperationsTest {

    @isTest
    static void myUnitTest1() {

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        insert lstConfigData;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        Datetime currentDateTime=DateTime.now();
        DateTime GMTDateNow = Datetime.newInstanceGmt(currentDateTime.year(),currentDateTime.month(),currentDateTime.day(),currentDateTime.hour(),currentDateTime.minute(),currentDateTime.second());
        Datetime selectedDateTime=currentDateTime.addhours(3);    

        Id contactRTID= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact createCont=new Contact(firstname='Duplicate',lastname='Cont1',Frequent_Flyer_Number__c='12345',Source__c='',SSU__c=false,recordtypeid=contactRTID,Schedule_Sensitive_Message__c=GMTDateNow.addminutes(-10),QCC_TECH_RecordType__c='Individual Contact');
        insert createCont;
        
        Contact createCont2=new Contact(firstname='Duplicate',lastname='Cont2',Frequent_Flyer_Number__c='123456',Source__c='',SSU__c=false,recordtypeid=contactRTID,Schedule_Sensitive_Message__c=GMTDateNow.addhours(5),QCC_TECH_RecordType__c='Individual Contact');
        insert createCont2;


        test.startTest();
        qccDateTimeOperations.getCurrentDateTime();
        qccDateTimeOperations.compareDateTime(createCont.id);
		qccDateTimeOperations.compareDateTime(createCont2.id);
        qccDateTimeOperations.convertInGMT(selectedDateTime);
        qccDateTimeOperations.compareSelectedDateTime(selectedDateTime);

        try{
            qccDateTimeOperations.compareSelectedDateTime(null);
            qccDateTimeOperations.convertInGMT(null);
          }catch(AuraHandledException e){
            Assert.areEqual('Script-thrown exception', e.getMessage());
             }
          
       

        test.stopTest();
    }
}