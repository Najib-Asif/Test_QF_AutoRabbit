/***********************************************************************************************************************************

Description: Test class for the Apex controller RecoveryChartInfoController
History:
======================================================================================================================
Name                    Jira                Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  QDCUSCON-5396    Recovery Portfolio functionality                                T01
                                    
Created Date    : 01/02/19 (DD/MM/YYYY)

**********************************************************************************************************************************/

@isTest
public class RecoveryChartInfoControllerTest {

    @isTest
     static void getMembersTest(){
         
     User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         
        List<User> usrList = RecoveryChartInfoController.getMembers();
    } 
    
    @isTest
     static void getMembersRecoveryDataTest(){
         
          User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
            List<Recovery__c> rList = RecoveryChartInfoController.getMembersRecoveryData(UserInfo.getUserId(),'Qantas Points');  
         }
         List<Recovery__c> rList = RecoveryChartInfoController.getMembersRecoveryData('','Qantas Points'); 
       
    }        
    
    @isTest
    private static void searchMembersRecoveryDataTest(){
        
        //DateTime d = Date.Today() +1;
        String dateStr =  '2019-01-01' ;
        String dateStrEnd =  '2019-02-01' ;
                  User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
        List<Recovery__c> rList = RecoveryChartInfoController.searchMembersRecoveryData(UserInfo.getUserId(),dateStr,dateStrEnd);
         }
        List<Recovery__c> rList = RecoveryChartInfoController.searchMembersRecoveryData('',dateStr,dateStrEnd);
    }
    
       @isTest
    private static void getAverageRecoveryAmountDateTest(){
         String dateStr =  '2019-01-01' ;
        String dateStrEnd =  '2019-02-01' ;
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
        Integer i =  RecoveryChartInfoController.getAverageRecoveryAmountDate(UserInfo.getUserId(),dateStr,dateStrEnd);
         }
        Integer i =  RecoveryChartInfoController.getAverageRecoveryAmountDate('',dateStr,dateStrEnd);
    }
    
        @isTest
    private static void getAverageRecoveryMonetaryValueDateTest(){
         String dateStr =  '2019-01-01' ;
        String dateStrEnd =  '2019-02-01' ;
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
       Integer i =  RecoveryChartInfoController.getAverageRecoveryMonetaryValueDate(UserInfo.getUserId(),dateStr,dateStrEnd);
         }
        Integer i =  RecoveryChartInfoController.getAverageRecoveryMonetaryValueDate('',dateStr,dateStrEnd);
    }
    
        @isTest
    private static void getAverageRecoveryValueDateTest(){
          String dateStr =  '2019-01-01' ;
        String dateStrEnd =  '2019-02-01' ;
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
            Integer i =  RecoveryChartInfoController.getAverageRecoveryValueDate(UserInfo.getUserId(),dateStr,dateStrEnd);
            Integer j= RecoveryChartInfoController.getAverageRecoveryGoodwillMonetaryValueDate(UserInfo.getUserId(),dateStr,dateStrEnd);
            Integer k= RecoveryChartInfoController.getAverageRecoveryGoodwillMonetaryValue(UserInfo.getUserId());
            Integer l= RecoveryChartInfoController.getAverageRecoveryAmount(UserInfo.getUserId(),'Qantas Points');
            List<string> m =RecoveryChartInfoController.getMembersRecoveryTypeList();
            List<Recovery__c> n =RecoveryChartInfoController.getMembersRecoveryTypeData(UserInfo.getUserId());

         }
        Integer i =  RecoveryChartInfoController.getAverageRecoveryValueDate('',dateStr,dateStrEnd);
    }
            
      @isTest
    private static void getAverageRecoveryMonetaryValueTest(){
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
       Integer i =  RecoveryChartInfoController.getAverageRecoveryMonetaryValue(UserInfo.getUserId(),'Qantas Points');
         }
         Integer i =  RecoveryChartInfoController.getAverageRecoveryMonetaryValue('','Qantas Points');
    }
    
       @isTest
    private static void getAverageRecoveryValueTest(){
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
       RecoveryChartInfoController.getAverageRecoveryValue(UserInfo.getUserId(),'');
         }
        //Integer i =  RecoveryChartInfoController.getAverageRecoveryValue('');
        
    }
    
    @isTest
    private static void getMembersRecoveryDataFilteredTest(){
                         User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US'
    // UserRoleId = r.Id
);
         insert u;
         System.runAs(u){
        List<Recovery__c> rList = RecoveryChartInfoController.getMembersRecoveryDataFiltered(UserInfo.getUserId(),'All');
         }
        List<Recovery__c> rList = RecoveryChartInfoController.getMembersRecoveryDataFiltered('','All');
    }
}