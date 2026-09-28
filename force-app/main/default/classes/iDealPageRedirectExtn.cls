/***********************************************************************************************************************************

Description: Apex class for implementing iDealcheck button functionality for Lightening

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Bharathkumar Narayanan  CRM-2828    Apex class for implementing iDealcheck button functionality                 T01
                                    
Created Date    : 11/06/17 (DD/MM/YYYY)

**********************************************************************************************************************************/
global with sharing class iDealPageRedirectExtn {

    public static Integer count{get; set;}
    public static Integer count2{get; set;}
    public static Integer count3{get; set;}
    public static Integer count4{get; set;}
    public iDealPageRedirectExtn(ApexPages.StandardController controller){
       
            String accountId = ApexPages.CurrentPage().getParameters().get('id');
        if(accountId!=null){
            System.debug(count+' '+count2+' '+count3+' '+count4);
            count   =    0;
            count2  =    0;
            count3  =    0;
            count4  =    0;
             count =[select count() from Agency_Info__c where Account__c= :accountId and Recordtype.Name='Distribution' limit 1];             
             count2 =[select count() from Agency_Info__c where Account__c=:accountId and PCC__c!='' and Recordtype.Name='GDS' limit 1];             
             count3 =[select count() from Agency_Info__c where Account__c in (select Primary_Account__c from Account_Relation__c where Related_Account__c=:accountId and Active__c=TRUE) and PCC__c!='' limit 1];             
             count4 =[select count() from Contract__c where Account__c=:accountId];           
            System.debug(count+' '+count2+' '+count3+' '+count4);
            }
        
    }    
}