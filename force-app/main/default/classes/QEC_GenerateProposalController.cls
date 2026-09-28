public class QEC_GenerateProposalController {
    /*@AuraEnabled public String preferredName {get;set;}
    @AuraEnabled public String contractId {get;set;}
    @AuraEnabled public String account {get;set;}*/
    @AuraEnabled
    public static String getContractInfo(Id recordId, String dealsheetType, Boolean categoryFlag/*, Boolean wordFormat*/){
        List<Contract__c> currentContract = [select id,Account__r.name from Contract__c where id =: recordId];
        List<Case> caseRecord = [select id, casenumber from Case where Related_Contract__c =: currentContract[0].id order by createddate desc limit 1];
        String casename='';
        if(caseRecord.size() > 0){
            casename= caseRecord[0].CaseNumber+' - ';
        }
        String url1 ='';
        String url2='';
        String redirectURL='';
        String contractId=String.valueOf(recordId);
        String fileName = casename+currentContract[0].Account__r.Name+' - '+String.valueOf(System.today());
        if(dealsheetType == 'Domestic'){
            Domestic_Dealsheet__mdt urlArray = [SELECT Id,Domain__c,BTL_URL__c,PDF__c,URL__c,Word__c from Domestic_Dealsheet__mdt Limit 1];
            url1 = urlArray.Domain__c;
            
            //Removed as per JIRA CRM-4173: Word option to be removed
            /**if(wordFormat){
                url2= urlArray.Word__c;
            }else{**/
                url2= urlArray.PDF__c;
            //}
            
            if(categoryFlag){
                url2 = url2+ urlArray.BTL_URL__c;
            }else{
                url2 = url2+ urlArray.URL__c;
            }
        }else if(dealsheetType == 'International'){
            International_Dealsheet__mdt urlArray = [SELECT Id,BTL_URL__c,Domain__c,PDF_URI__c,URL__c,Word_URI__c from International_Dealsheet__mdt Limit 1];
            url1 = urlArray.Domain__c;
            
            //Removed as per JIRA CRM-4173: Word option to be removed
            /*if(wordFormat){
                url2= urlArray.Word_URI__c;
            }else{*/
                url2= urlArray.PDF_URI__c;
            //}
            
            if(categoryFlag){
                url2 = url2+ urlArray.BTL_URL__c;
            }else{
                url2 = url2+ urlArray.URL__c;
            }
        }
        redirectURL = url1+contractId+url2+contractId+'&OFN=QantasDS '+dealsheetType+' - '+fileName+'&SC1=SalesforceFile';
        system.debug('redirect url--------- '+redirectURL);
        
        return redirectURL.trim();
    }
}