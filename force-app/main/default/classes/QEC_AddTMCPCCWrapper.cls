/***********************************************************************************************************************************

Description: Wrapper class to hold UI elements to render in UI. Same wrapper will be used to retrieve data from UI to perform DML

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Ram Kolli             EXPRCON-97     Manage TMC/PCC on Proposal and Contract  objects            T01		        	
Created Date    : 20/08/19 (DD/MM/YYYY)

**********************************************************************************************************************************/
public class QEC_AddTMCPCCWrapper {
    @AuraEnabled public String pcc {get;set;}
    @AuraEnabled public String gds {get;set;}
    @AuraEnabled public Date sdate {get;set;}
    @AuraEnabled public Date edate {get;set;}
    @AuraEnabled public Id tmcId {get;set;}
    @AuraEnabled public Boolean active {get;set;}
    @AuraEnabled public Boolean chkbox {get;set;}
    @AuraEnabled public String iata {get;set;}
    @AuraEnabled public Boolean history {get;set;}
    @AuraEnabled public Id contractTMCId {get;set;}
    @AuraEnabled public String accountName {get;set;}
        
   public QEC_AddTMCPCCWrapper(){
      //default values goes here
      chkbox = false;
   }
}