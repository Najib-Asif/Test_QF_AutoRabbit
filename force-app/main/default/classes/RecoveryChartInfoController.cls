/********************************************************************************************************************************

Description: Recovery Portfolio functionality
History:
======================================================================================================================
Name                    Jira                Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  QDCUSCON-5396    Recovery Portfolio functionality                                T01
                                    
Created Date    : 01/02/19 (DD/MM/YYYY)

**********************************************************************************************************************************/

global  without sharing  class RecoveryChartInfoController {

      /*    public String PDFData {get; set;} 
    
    public RecoveryChartInfoController(){
        PDFData = '';
    }
    
    public PageReference downloadPDF(){         
        System.PageReference pageRef = new System.PageReference('/apex/PDFGenerator');
    
        //ensure pdf downloads and is assigned with defined name
        pageRef.getHeaders().put('content-disposition', 'attachment; filename=DataPDF.pdf');
     
        return pageRef;
    }*/
    @AuraEnabled
    public static List<User> getMembers(){
        
        List<User> usrList= [select ID,Firstname,Name,Email from User where ManagerId =:Userinfo.getUserId()];
        
        return usrList;
    } 
    
    @AuraEnabled
    public static List<Recovery__c> getMembersRecoveryTypeData(String usrId){
        //List<User> usrList = [select id from usergetMembersRecoveryData where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //Case_Assigned_To__c CaseAssignedTo__c
        System.debug('usrId$$$'+usrId);
       // System.debug('usrId$$$'+rcvryType);
        List<Recovery__c> rcvryList;
        if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
         //   if(rcvryType == null){
             rcvryList= [select ID,Status__c,Type__c,Amount__c,Approver_Comment__c,Monetary_Value__c, Value__c,Refund_Account__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c    , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList];   
           // }else{
          //   rcvryList= [select ID,Status__c,Type__c,Amount__c,Approver_Comment__c,Monetary_Value__c, Value__c,Refund_Account__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c    , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList and Type__c =:rcvryType];    
           // }
             
        }else{
            //if(rcvryType == null){
                 rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,
                                      Monetary_Value__c, Value__c,Description__c, Name,
                                      Case_Number__c, Investigated_By__c,
                                      ApprovedBy__c , FulfilledBy__c, Fulfilled_Date__c,Refund_Account__c from Recovery__c where createdbyId =:usrId];

           // }else{
             // rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,
               //                       Monetary_Value__c, Value__c,Description__c, Name,
                 //                     Case_Number__c, Investigated_By__c,
                   //                   ApprovedBy__c , FulfilledBy__c, Fulfilled_Date__c,Refund_Account__c from Recovery__c where createdbyId =:usrId and Type__c =:rcvryType];
            //}
        }
               
        return rcvryList;
    }
    
    @AuraEnabled
    public static List<String> getMembersRecoveryTypeList(){
        //List<User> usrList = [select id from usergetMembersRecoveryData where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //Case_Assigned_To__c CaseAssignedTo__c
        
        List<String> rcvryTypeList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Recovery__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('ple'+ple);
        for(Schema.PicklistEntry p : ple){
            if(p.isActive()){
                rcvryTypeList.add(p.getValue());
            }
        }
               
        return rcvryTypeList;
    }
    @AuraEnabled
    public static List<Recovery__c> getMembersRecoveryData(String usrId, String rcvryType ){
        //List<User> usrList = [select id from usergetMembersRecoveryData where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //Case_Assigned_To__c CaseAssignedTo__c
        System.debug('usrId$$$'+usrId);
        List<Recovery__c> rcvryList;
        if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            if(rcvryType == null){
                 rcvryList= [select ID,Status__c,Type__c,Amount__c,Approver_Comment__c,Monetary_Value__c, Value__c,Refund_Account__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c    , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList];    
            }else{
                 rcvryList= [select ID,Status__c,Type__c,Amount__c,Approver_Comment__c,Monetary_Value__c, Value__c,Refund_Account__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c    , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList and Type__c = :rcvryType];
            }
            
        }else{
             if(rcvryType == null){
              rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,
                                      Monetary_Value__c, Value__c,Description__c, Name,
                                      Case_Number__c, Investigated_By__c,
                                      ApprovedBy__c , FulfilledBy__c, Fulfilled_Date__c,Refund_Account__c from Recovery__c where createdbyId =:usrId];

        
             }else{
                 rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,
                                      Monetary_Value__c, Value__c,Description__c, Name,
                                      Case_Number__c, Investigated_By__c,
                                      ApprovedBy__c , FulfilledBy__c, Fulfilled_Date__c,Refund_Account__c from Recovery__c where createdbyId =:usrId and Type__c = :rcvryType];


             }
        }
               
        return rcvryList;
    }
    
    @AuraEnabled
    public static List<Recovery__c> searchMembersRecoveryData(String usrId, String fDate, String tDate){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //Case_Assigned_To__c CaseAssignedTo__c
        System.debug('fDate$$$'+fDate);
        System.debug('tDate$$$'+tDate);
        String TimedStart = '11:01:00 AM';
        String TimedEnd = '1:59:00 PM';
        DateTime fromDate = DateTime.valueOf(fDate + ' ' + TimedStart);
        DateTime toDate = DateTime.valueOf(tDate + ' ' + TimedEnd);
        //DateTime fromDate;// = (DateTime) fDate;
        //DateTime toDate;// = (DateTime)tDate;
        System.debug('fDate$$$'+fDate);
        System.debug('tDate$$$'+tDate);
        System.debug('fromDate$$$'+fromDate);
        System.debug('toDate$$$'+toDate);
        List<Recovery__c> rcvryList;
        if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
             rcvryList= [select ID,Status__c,Type__c,Amount__c,Refund_Account__c, Approver_Comment__c,Monetary_Value__c, Value__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c   , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList and createdDate >=:fromDate and createdDate <=:toDate];
        }else{
              rcvryList= [select ID,Status__c,Type__c,Amount__c,Refund_Account__c, Approver_Comment__c,Monetary_Value__c, Value__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c  , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrId and createdDate >=:fromDate and createdDate <=:toDate];
        }
               
        return rcvryList;
    }
    
    
    @AuraEnabled
    public static Integer getAverageRecoveryAmount(String usrId, String rcvryType){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
             if(rcvryType == null && rcvryType == ''){
                groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrList];
             }else{
                groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrList and Type__c =:rcvryType]; 
             }
         }else{
             if(rcvryType == null && rcvryType == ''){
                groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrId];
             }else{
                groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrId and Type__c=:rcvryType]; 
             }
         }
        Object avgAmount = groupedResults[0].get('aver');  
        return Integer.valueOf(avgAmount);
       //Integer avgAmountInt = Integer.valueOf(avgAmount);
       // return avgAmountInt;
    }
    
     @AuraEnabled
    public static Integer getAverageRecoveryMonetaryValue(String usrId, String rcvryType){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
       // List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
       // 
       AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
              if(rcvryType == null && rcvryType == ''){
                 groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrList];
              }else{
                   groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrList and Type__c =:rcvryType];
              }
         }else{
             if(rcvryType == null && rcvryType == ''){
                 groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrId];
             }else{
               groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrId and Type__c =:rcvryType]; 
             }
         }                
        Object avgAmount = groupedResults[0].get('aver');                
        Integer avgAmountInt = Integer.valueOf(avgAmount);
        return avgAmountInt;
    }
    
     @AuraEnabled
    public static Integer getAverageRecoveryValue(String usrId, String rcvryType){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //AggregateResult[] groupedResults = [SELECT AVG(Value__c   )aver FROM Recovery__c where createdbyId =:usrId];// where Case_Number__c =:caseList];
        System.debug('userIdgggg'+usrId);
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
              if(rcvryType == null && rcvryType ==''){
                groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrList];
              }else{
                  groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrList and Type__c =:rcvryType];
              }
             System.debug('groupedResults'+groupedResults);
         }else{
             System.debug('groupedResults'+groupedResults);
              if(rcvryType == null && rcvryType==''){
                groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrId];
              }else{
                groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrId and Type__c =:rcvryType];   
              }
         }      
        
        Object avgAmount = groupedResults[0].get('aver'); 
        Integer avgAmountInt = Integer.valueOf(avgAmount);
        return avgAmountInt;
    }
    
    
     @AuraEnabled
    public static Integer getAverageRecoveryGoodwillMonetaryValue(String usrId){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //AggregateResult[] groupedResults = [SELECT AVG(Value__c   )aver FROM Recovery__c where createdbyId =:usrId];// where Case_Number__c =:caseList];
        System.debug('userIdgggg'+usrId);
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            groupedResults = [SELECT AVG(Goodwill_Monetory_Value__c)aver FROM Recovery__c where createdbyId =:usrList];
             System.debug('groupedResults'+groupedResults);
         }else{
             System.debug('groupedResults'+groupedResults);
             groupedResults = [SELECT AVG(Goodwill_Monetory_Value__c)aver FROM Recovery__c where createdbyId =:usrId];
         }      
        
        Object avgAmount = groupedResults[0].get('aver'); 
        Integer avgAmountInt = Integer.valueOf(avgAmount);
        return avgAmountInt;
    }
    
    
    @AuraEnabled
    public static Integer getAverageRecoveryAmountDate(String usrId, String fDate, String tDate){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        String TimedStart = '11:01:00 AM';
        String TimedEnd = '1:59:00 PM';
        DateTime fromDate = DateTime.valueOf(fDate + ' ' + TimedStart);
        DateTime toDate = DateTime.valueOf(tDate + ' ' + TimedEnd);
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrList and createdDate >=:fromDate and createdDate <=:toDate];
         }else{
             groupedResults = [SELECT AVG(Amount__c)aver FROM Recovery__c where createdbyId =:usrId and createdDate >=:fromDate and createdDate <=:toDate];
         }
        Object avgAmount = groupedResults[0].get('aver'); 
        return Integer.valueOf(avgAmount);
//Integer avgAmountInt = Integer.valueOf(avgAmount);
        //return avgAmountInt;
    }
    
     @AuraEnabled
    public static Integer getAverageRecoveryMonetaryValueDate(String usrId, String fDate, String tDate){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
       // List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
       String TimedStart = '11:01:00 AM';
        String TimedEnd = '1:59:00 PM';
        DateTime fromDate = DateTime.valueOf(fDate + ' ' + TimedStart);
        DateTime toDate = DateTime.valueOf(tDate + ' ' + TimedEnd);
       AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrList and createdDate >=:fromDate and createdDate <=:toDate];
         }else{
             groupedResults = [SELECT AVG(Monetary_Value__c)aver FROM Recovery__c where createdbyId =:usrId and createdDate >=:fromDate and createdDate <=:toDate];
         }                
        Object avgAmount = groupedResults[0].get('aver');                
        return Integer.valueOf(avgAmount);
       // Integer avgAmountInt = Integer.valueOf(avgAmount);
       // return avgAmountInt;
    }
    
     @AuraEnabled
    public static Integer getAverageRecoveryValueDate(String usrId, String fDate, String tDate){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //AggregateResult[] groupedResults = [SELECT AVG(Value__c   )aver FROM Recovery__c where createdbyId =:usrId];// where Case_Number__c =:caseList];
        String TimedStart = '11:01:00 AM';
        String TimedEnd = '1:59:00 PM';
        DateTime fromDate = DateTime.valueOf(fDate + ' ' + TimedStart);
        DateTime toDate = DateTime.valueOf(tDate + ' ' + TimedEnd);
        System.debug('userIdgggg'+usrId);
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrList and createdDate >=:fromDate and createdDate <=:toDate];
             System.debug('groupedResults'+groupedResults);
         }else{
             System.debug('groupedResults'+groupedResults);
             groupedResults = [SELECT AVG(Value__c)aver FROM Recovery__c where createdbyId =:usrId and createdDate >=:fromDate and createdDate <=:toDate];
         }      
        
        Object avgAmount = groupedResults[0].get('aver'); 
        return Integer.valueOf(avgAmount);
        //Integer avgAmountInt = Integer.valueOf(avgAmount);
        //return avgAmountInt;
    }

 @AuraEnabled
    public static Integer getAverageRecoveryGoodwillMonetaryValueDate(String usrId, String fDate, String tDate){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //AggregateResult[] groupedResults = [SELECT AVG(Value__c   )aver FROM Recovery__c where createdbyId =:usrId];// where Case_Number__c =:caseList];
            String TimedStart = '11:01:00 AM';
        String TimedEnd = '1:59:00 PM';
        DateTime fromDate = DateTime.valueOf(fDate + ' ' + TimedStart);
        DateTime toDate = DateTime.valueOf(tDate + ' ' + TimedEnd);
        System.debug('userIdgggg'+usrId);
        AggregateResult[] groupedResults;
         if(usrId == null || usrId ==''){
            usrId = UserInfo.getUserId();
            List<User> usrList = [select id from user where ManagerId =: usrId];
            groupedResults = [SELECT AVG(Goodwill_Monetory_Value__c)aver FROM Recovery__c where createdbyId =:usrList and createdDate >=:fromDate and createdDate <=:toDate];
             System.debug('groupedResults'+groupedResults);
         }else{
             System.debug('groupedResults'+groupedResults);
             groupedResults = [SELECT AVG(Goodwill_Monetory_Value__c)aver FROM Recovery__c where createdbyId =:usrId and createdDate >=:fromDate and createdDate <=:toDate];
         }      
        
        Object avgAmount = groupedResults[0].get('aver'); 
        return Integer.valueOf(avgAmount);
        //Integer avgAmountInt = Integer.valueOf(avgAmount);
        //return avgAmountInt;
    }
        
        @AuraEnabled
    public static List<Recovery__c> getMembersRecoveryDataFiltered(String usrId, String status){
        //List<User> usrList = [select id from user where ManagerId =: usrId];
        //List<Case> caseList = [select id, OwnerId from case where OwnerId =:usrList];
        //Case_Assigned_To__c CaseAssignedTo__c
        System.debug('usrId$$$'+usrId);
        List<Recovery__c> rcvryList;
        if(status == 'All'){                    
            if(usrId == null || usrId ==''){
                usrId = UserInfo.getUserId();
                List<User> usrList = [select id from user where ManagerId =: usrId];
                 rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,Refund_Account__c,Monetary_Value__c, Value__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c   , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList];
            }else{
                  rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,
                                          Monetary_Value__c, Value__c,Description__c, Name,
                                          Case_Number__c, Investigated_By__c,
                                          ApprovedBy__c , FulfilledBy__c, Fulfilled_Date__c,Refund_Account__c from Recovery__c where createdbyId =:usrId];    
            }
        }else{
            if(usrId == null || usrId ==''){
                usrId = UserInfo.getUserId();
                List<User> usrList = [select id from user where ManagerId =: usrId];
                 rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,Refund_Account__c,Monetary_Value__c, Value__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c   , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrList and Status__c=:status];
            }else{
                  rcvryList= [select ID,Status__c,Type__c,Amount__c, Approver_Comment__c,Refund_Account__c,Monetary_Value__c, Value__c,Description__c, Name,Case_Number__c, Investigated_By__c,ApprovedBy__c  , FulfilledBy__c, Fulfilled_Date__c from Recovery__c where createdbyId =:usrId and Status__c=:status];    
            }
        }
               
        return rcvryList;
    }   
}