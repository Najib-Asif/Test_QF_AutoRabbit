/**********************************************************************************************************************************

Created Date    : 27/07/17 (DD/MM/YYYY)
Added By        : Karpagam Swaminathan
Description     : To validate only one account  classification added  to account
JIRA            : CRM-2653
Version         : V1.0 - 27/07/17 - Initial version



**********************************************************************************************************************************/




public class Account_ClassificationValidationHelper
{
    public static void accClassPCValidation(List<Account_Classifications__c> accList){
        String ExpRecId;
        
        try{
            List<String> accclasType = new List<String>();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setAccountIds1 = new Set<Id>();
            system.debug('accList*************'+accList);
            for(Account_Classifications__c objAcc : accList ) {
                setAccountIds1 . add(objAcc.Account__c);
                system.debug('objAcc $$$$$$$$$$$$$'+objAcc);
                Account_Classification_Type__c act = Account_Classification_Type__c.getValues(objAcc.Classification__c);
                String accType= String.valueof(act.Classification_Type__c);
                accclasType.add(accType);
                System.debug('accType%%%%%%%%%%%%'+accType);
                if(objAcc.Classification__c == accType)
                {
                    setAccountIds.add(objAcc.Account__c); 
                    system.debug('inside if');
                }
            }
            
            //Populate a map of the query results
            Map<Id, Account_Classifications__c  > mapAccclassification = new Map<Id, Account_Classifications__c >();
            for(Account_Classifications__c objAcc : [SELECT Id, Name,Classification__c,Account__c
                                                     FROM Account_Classifications__c 
                                                     WHERE Account__c IN :setAccountIds1 and Classification__c IN:accclasType
                                                    ]) {
                                                        mapAccclassification.put(objAcc.Account__c, objAcc);
                                                        System.debug('mapAccclassification%%%%%%%%%%%%'+mapAccclassification);
                                                    }
            
            //Iterate through your list of Account classifications records and generate an error for any 
            //that have a matching Classification in the map
            for(Account_Classifications__c objAcc : accList) {
                if(mapAccclassification.containsKey(objAcc.Account__c)) {
                    Account_Classifications__c objExistingAcc = mapAccclassification.get(objAcc.Account__c);
                    System.debug('Found another copy ' + objExistingAcc.Id + '  name is ' + objExistingAcc.Name);
                    ExpRecId=objExistingAcc.Id;
                    objAcc.addError(Label.Account_Classification_Validation_Error);
                }
            }
        }
        
        Catch(Exception e){
        //insert Log record to capture the exception occured
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Account_ClassificationValidation', 'Account_ClassificationValidationHelper', 
                                    'Account_ClassificationValidationHelper',String.valueOf(''), String.valueOf(''),false, ExpRecId, e);
        }
    }
    
}