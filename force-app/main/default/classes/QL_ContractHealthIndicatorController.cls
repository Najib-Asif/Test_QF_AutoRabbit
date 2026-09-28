/***********************************************************************************************************************************

Description: Apex controller for Contract Health Indicator Lightning component

History:
======================================================================================================================
Name                    Jira        Description                                                          Tag
======================================================================================================================
Karpagam Swaminathan              Apex controller for Contract Health Indicator Lightning component                     T01

Created Date    :                 24/102018 (DD/MM/YYYY)

**********************************************************************************************************************************/
public class QL_ContractHealthIndicatorController {
    @AuraEnabled
    public static String contractComputePercentage(String recordId,String sObjectName) {
        String contractlHealth = '';
        String fincontractlHealth='';
        String dealCaseStr ='';
        String conTypeStr = '';
        Integer dealCase=0;
        Integer conType = 0;
        Integer attachment = 0;
        string contractType='';
        string contractStatus='';     
        
        string strqClubDisc='';
        Boolean boolActive=false;
        Integer qClubDisc=0;
        Integer assetExist=0;
        Integer active=0;
        Decimal NumofGreen =0.0;
        Decimal NumofRed = 0.0;

        Id DealRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Support_request').getRecordTypeId();
        Id corpSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate_Scheme').getRecordTypeId();
        Id publicSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Public_Scheme').getRecordTypeId();
        
        Contract__c contRecr = [ SELECT Active__c,Type__c,Status__c,Id,Qantas_Club_Discount__c, (SELECT Id, Type, Status FROM Cases__r WHERE RecordTypeId=:DealRecordTypeId),(SELECT Id FROM Assets__r WHERE RecordTypeId=:corpSchemeRecTypeId OR RecordTypeId=:publicSchemeRecTypeId) FROM Contract__c WHERE Id=:recordId ];
        
        
        //Param 1 if Deal Load Case Exists
        if (contRecr.Cases__r != null) {
            for (Case caseRecord : contRecr.Cases__r) {
                if (!('Not yet assigned - with Account Manager').equals(caseRecord.Status)) {
                    NumofGreen = NumofGreen + 1 ;
                    dealCase = 1;
                    break;
                }
            }
        }
        if (dealCase == 0) {
            NumofRed = NumofRed + 1;
        }
        //Param 2 if Signed by Customer 
        contractStatus = contRecr . Status__c;
        contractType = contRecr . Type__c;
        If (contractStatus == 'Signed by Customer'){
            conType=1; 
            NumofGreen = NumofGreen + 1 ;
        }
        else{
            conType=0;
            NumofRed = NumofRed + 1;
        }
        
        //Param 3  Asset Exists
        strqClubDisc =  contRecr . Qantas_Club_Discount__c;
        if(contRecr . Assets__r.size() > 0)
        {
            if(strqClubDisc == 'Yes')
            {
                NumofGreen = NumofGreen + 1 ;
                assetExist = 1;
            } 
        }
        if(contRecr . Assets__r.size() == 0 && strqClubDisc == 'Yes'){
            NumofRed = NumofRed + 1;
            assetExist = 0;
        }
        if(strqClubDisc == 'No')
            assetExist = 2;
        
        //Param 4 Signed Contract Attached    
        List<ContentDocumentLink> conList =  [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId  =: recordId LIMIT 1];
        if(conList.size()>0){
            NumofGreen = NumofGreen + 1 ;
            attachment = 1;
        }
        else{
            NumofRed = NumofRed + 1;
            attachment = 0;
        }
        If(contractType=='Qantas Business Savings')
        {
            double tempValue1=((NumofGreen)/(NumofGreen+NumofRed))*100;
            contractlHealth=String.valueOf(tempValue1);
            fincontractlHealth = contractlHealth+'*'+String.valueOf(dealCase)+'*'+String.valueOf(conType)+'*'+String.valueOf(assetExist)+'*'+String.valueOf(attachment)+'*'+contractType;
        }
        Else If (contractType=='Corporate Airfares')
        {
            double tempValue1=((NumofGreen)/(NumofGreen+NumofRed))*100;
            contractlHealth=String.valueOf(tempValue1);
            fincontractlHealth = contractlHealth+'*'+String.valueOf(dealCase)+'*'+String.valueOf(conType)+'*'+String.valueOf(assetExist)+'*'+String.valueOf(attachment)+'*'+contractType;
        }
        return fincontractlHealth;
    }
}