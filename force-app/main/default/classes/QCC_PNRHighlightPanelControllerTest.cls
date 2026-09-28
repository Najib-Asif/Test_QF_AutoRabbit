/******************************************************
    * Created By : Flo De Los Reyes | ACN | Developer 
    * Purpose : test class for QCC_PNRHighlightPanelController
    * Created Date    : 13/03/23 (DD/MM/YYYY)
    * Modified Date   : 13/03/23 (DD/MM/YYYY)
    * Modified By     : Flo De Los Reyes
    * JIRA            : ADT-23
    * Version         : 1.1 -Initial Development | Flo
******************************************************/
@isTest
public class QCC_PNRHighlightPanelControllerTest {
    
	static testmethod void getURLAddressTest(){
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        
        System.runAs(u){
            
            List<Environment_Setting__mdt> lstArdMetaData =  QCC_PNRHighlightPanelController.getURLAddress();
            system.assertEquals(!lstArdMetaData.isEmpty(), true, 'No record in custom meta data');
        }
    }
}