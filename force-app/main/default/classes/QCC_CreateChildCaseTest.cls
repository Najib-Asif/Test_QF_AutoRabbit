/*==============================================================================================================================
Author:         Gandla Mallikarjuna
Company:        TCS
Purpose:        Jira:CRM-8706 Test class for QCC_CreateChildCase
==============================================================================================================================*/
@isTest
public class QCC_CreateChildCaseTest {
    
    static testMethod void testSegregateEmailMsgBodyAndFooter() {
        List<String> emailMsgs = new List<String>();
        
        emailMsgs.add('<h1>________________________________ From: xyx@gmail.com</h1>');
        
        List<String> testResp = new List<String>();
        Test.startTest();
           testResp = QCC_CreateChildCase.segregateEmailMsgBodyAndFooter(emailMsgs);
        Test.stopTest();
        
        System.assert(testResp.size() > 0);
        
    }

}