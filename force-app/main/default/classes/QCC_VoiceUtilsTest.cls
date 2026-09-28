@isTest
public class QCC_VoiceUtilsTest {
    @isTest
    static void getEnvSettingTest(){
        Id orgId = UserInfo.getOrganizationId();
        String orgIdto15 = orgId.to15();
        test.startTest();
        Environment_Setting__mdt evntMdt = QCC_VoiceUtils.getEnvSetting();
        test.stopTest();
        //System.AssertEquals(evntMdt.Org_Id__c, orgIdto15);
    }
    @isTest
    static void checkIfValidPhoneTest()
    {
        String phone1='+61 0534756569-M';
        String phone2='61 0534756569-M';
        String phone3='0534756569-M';
        String phone4='+61534756569-M';
        String phone5='61534756569-M';
        
        test.starttest();
        String getOutPutPhone=QCC_VoiceUtils.checkIfValidPhone(phone1); 
        getOutPutPhone=QCC_VoiceUtils.checkIfValidPhone(phone2);
        getOutPutPhone=QCC_VoiceUtils.checkIfValidPhone(phone3);
        getOutPutPhone=QCC_VoiceUtils.checkIfValidPhone(phone4);
        getOutPutPhone=QCC_VoiceUtils.checkIfValidPhone(phone5);
        test.stoptest();
    }
    @isTest
    static void checkIfValidEmailTest()
    {
        String email1='abc@test.com/';
        String email2='abc@qantas.com.au';
        
        
        test.starttest();
        Boolean getOutPutEmail=QCC_VoiceUtils.checkIfValidEmail(email1); 
        getOutPutEmail=QCC_VoiceUtils.checkIfValidEmail(email2);
        
        test.stoptest();
    }
     @isTest
    static void insertLogRecTest()
    {
       
        try
        {
            test.starttest();
            QCC_VoiceUtils.insertLogRec('Integration Logs','QCC','QCC_VoiceUtils','insertLogRec','YesInbound','NoOutbound',true,'63736686738','Exception error');
        
            test.stoptest();
        }
        catch(Exception e)
        {
            system.debug('Exception ocurred'+e.getmessage());
        }
        
    }
}