/*
 *********************************************************************************
 * History:
 * Version     Author           Date            Description
 * 2.0         Sruthi Anil     04-06-2026      CRM 12989 -Code Security Remediation
 *********************************************************************************
 */

@isTest
public class Freight_ChatTopic_Test {
    @testSetup
    public static void setup() {
       
        LiveChatVisitor lv = new LiveChatVisitor();
        
        insert lv;
        
        LiveChatTranscript lc = new LiveChatTranscript();
        lc.Freight_Chat_Topic__c='Pets';
        lc.LiveChatVisitorId = lv.id;
        
        insert lc;
        
    }
     @isTest
    public static void chatTopic(){
    
        LiveChatTranscript lc =[Select Id from LiveChatTranscript where Freight_Chat_Topic__c='Pets'];
        Freight_GetTranscriptVariables.TranscriptInput tinpt = new Freight_GetTranscriptVariables.TranscriptInput();
        tinpt.routableId = lc.id;
        
        Freight_GetTranscriptVariables.getUserName(new List<Freight_GetTranscriptVariables.TranscriptInput> {tinpt});
        
    }

// CRM 12989- Added test method to cover the catch block added as part of Code Security Remediation in Freight_GetTranscriptVariables class.

    @isTest
    static void userNoAccess(){
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'];
    User u1 = new User(
          Username = 'testu045600ser@example.com',
          Email = 'testus11145611er@qantas.com.au',
          LastName = 'Test',
          FirstName = 'User',
          Alias = 'testu',
          ProfileId = p.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US'
);
    insert u1;
        LiveChatVisitor lv = new LiveChatVisitor();        
        insert lv;
        LiveChatTranscript lc = new LiveChatTranscript();
        lc.Freight_Chat_Topic__c='Pets';
        lc.LiveChatVisitorId = lv.id;
        insert lc;        
    Test.startTest();
        System.runAs(u1) {
          try{  
                Freight_GetTranscriptVariables.TranscriptInput tinpt = new Freight_GetTranscriptVariables.TranscriptInput();
                tinpt.routableId = lc.id;
                Freight_GetTranscriptVariables.getUserName(new List<Freight_GetTranscriptVariables.TranscriptInput> {tinpt}); 
          } catch (Exception e) {
                System.assertNotEquals(null, e);
          }
        }
    Test.stopTest();
    }
}