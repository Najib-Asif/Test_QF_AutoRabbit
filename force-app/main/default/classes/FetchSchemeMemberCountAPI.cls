/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir
Company:       Capgemini
Description:   Https callout to fetch the Scheme Active Member Count received from LSL
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
25-AUG-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
global class FetchSchemeMemberCountAPI {
    @future(callout=true)
    public static void getActiveMemberCount() {
        Boolean isException = false;
        HttpRequest request;
        HttpResponse response;
        Map<String, List<String>> mapError = new Map<String, List<String>>();
        try{
            String headerName   = CustomSettingsUtilities.getConfigDataMap('AssetHeaderName');
            String statusCode   = CustomSettingsUtilities.getConfigDataMap('AssetStatusCode');
            Integer istatusCode = integer.valueof(statusCode);
            Id corpSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate_Scheme').getRecordTypeId();
            Id publicSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Public_Scheme').getRecordTypeId();            
            Http http = new Http();
            request = new HttpRequest();
            request.setHeader('authorization', headerName);
            request.setTimeout(60000);
            //request.setEndpoint('callout:ActiveMemberCountURL/schemes');
            //Jira-CRM-5314 upgrade schemes endpoint to corporate/scheme
            request.setEndpoint('callout:ActiveMemberCountURL/corporate/scheme?size=100000');
            request.setMethod('GET');
            response = http.send(request);
            system.debug('response.getBody()###'+response.getBody());
            system.debug('response.getStatusCode()###'+response.getStatusCode());
            // If the request is successful, parse the JSON response.
            if (response.getStatusCode() == istatusCode) {
                
                Map<String, Integer> mapAssetActiveCount = new Map<String, Integer>();
                List<Asset> lstAsset = new List<Asset>();
                //get top level map
                Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                String allJson = json.serialize(jsonMap.get('schemes'));
                //system.debug('Length####'+allJson.length());
                List<SchemeMemberCountWrapper> lstSchemes = (List<SchemeMemberCountWrapper>)json.deserialize(allJson, List<SchemeMemberCountWrapper>.class);
                system.debug('jsonSubset###'+lstSchemes);
                
                for(SchemeMemberCountWrapper scheme: lstSchemes){
                    mapAssetActiveCount.put(scheme.salesforceId, scheme.nomineeCount);
                    
                }
                
                for(Asset objAsset: [Select Id,Scheme_Active_Member_Count__c from Asset where Id IN: mapAssetActiveCount.keyset() AND (RecordTypeId=:corpSchemeRecTypeId OR RecordTypeId=:publicSchemeRecTypeId)]){
                    if(objAsset.Scheme_Active_Member_Count__c != mapAssetActiveCount.get(objAsset.Id)){
                        objAsset.Scheme_Active_Member_Count__c = mapAssetActiveCount.get(objAsset.Id);
                        lstAsset.add(objAsset);
                    }
                } 
                Database.SaveResult[] lstSaveResult = Database.update(lstAsset, False);
                integer i = 0;
                for(Database.SaveResult sr : lstSaveResult){ 
                    if (!sr.isSuccess()) { 
                        Id assetId = lstAsset[i].Id;
                        List<String> lstErrorMSG = new List<String>();
                        for(Database.Error err : sr.getErrors()){
                            lstErrorMSG.add(err.getMessage());
                        }
                        mapError.put(assetId, lstErrorMSG);
                    }
                    i++;
                }                
            }else{
                isException = true;
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Loyalty Stream - Status Issue', 'FetchSchemeMemberCountAPI', 
                'getActiveMemberCount', String.valueOf(response), String.valueOf(request), true, '', null); 
            } 

            //Any DML Exception 
            if(mapError.size() > 0){
                List<Log__c> lstLogException = new List<Log__c>();
                for(String assetId: mapError.keyset()){
                    lstLogException.add(CreateLogs.insertLogBatchRec( 'Log Exception Logs Rec Type', 'Loyalty Stream - Fetch SchemeMemberCount API', 'FetchSchemeMemberCountAPI', 
                                             'getActiveMemberCount', assetId, mapError.get(assetId)));
                }
                insert lstLogException;
            }
            
        }
        catch(Exception ex){
            system.debug('Exception####'+ex);
            isException = true;
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Loyalty Stream - Fetch SchemeMemberCount API', 'FetchSchemeMemberCountAPI', 
            'getActiveMemberCount', String.valueOf(response), String.valueOf(request), true,'', ex);
        }
        finally{
            if(CustomSettingsUtilities.getConfigDataMap('createIntegrationLogSchemeMemCountAPI') == 'Yes' && !isException){
                CreateLogs.insertLogRec( 'Log Integration Logs Rec Type', 'Loyalty Stream - Fetch SchemeMemberCount API', 'FetchSchemeMemberCountAPI', 
               'getActiveMemberCount', String.valueOf(response), String.valueOf(request), true, '', null);        
            }             
        } 
    }
}