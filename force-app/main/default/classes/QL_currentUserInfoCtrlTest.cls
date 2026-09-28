@isTest
public class QL_currentUserInfoCtrlTest {
@isTest
    static void userTest()
    {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = new User(Alias = 'testuser', Email='standarduser@qantas.com.au', 
                          FirstName='test',LastName='user',Qantas_Staff_ID__c='1234', ProfileId = testProfile.Id,Username='standarduser@qantas.com.au', 
                                 CommunityNickname='abcd', TimeZoneSidKey='Australia/Sydney', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US' );

        System.runAs(testUser) {
            user testUser1 = QL_currentUserInfoCtrl.fetchUser();
            // The following code runs as user 'u' 
            System.debug('Current User First Name: ' + testUser1.FirstName);
            System.debug('Current User Last Name: ' + testUser1.LastName); 
        }
    }
}