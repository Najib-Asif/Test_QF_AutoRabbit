/*----------------------------------------------------------------------------------------------------------------------
Author:    Mehul Manchanda
Jira:      CRM-3920
Description:  To fetch the user details for radar dashboard component.
Test Class: QL_currentUserInfoCtrlTest   
************************************************************************************************************************
History
*************************************************************************************************************************/
public with sharing class QL_currentUserInfoCtrl {
   @AuraEnabled 
    public static user fetchUser(){
     // query current user information  
      User oUser = [select id,FirstName,LastName,Qantas_Staff_ID__c 
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
}