/***********************************************************************************************************************************

Description: Apex class for TA Insertion. 

History:
======================================================================================================================
Name                          Description                                               Tag
======================================================================================================================
Yuvaraj MV                  TA record insertion Class                                 	T01

Created Date    : 			11/05/18 (DD/MM/YYYY)

TestClass		:			QAC_TAInsertion_Test
**********************************************************************************************************************************/

@RestResource(urlMapping='/QACTAInformationInsertion/*')
global with sharing class QAC_TAInsertion 
{
    
    public static string responseJson='';
    
    @HttpPost
    global static void doTAInsertion()
    {
        RestRequest request                 		= 	RestContext.request;
        RestResponse response 						= 	RestContext.response;
        string myRequest;
        Boolean primaryAccExists					=	false;
        List<Account_Relation__c> lstInsTA 			= 	new List<Account_Relation__c>();
        
        Set<string> incomingRelIATA					=	new Set<string>();
        Set<string> validRelatedIATASet				=	new Set<string>();
        Set<string> existingRelatedIATASet			=	new Set<string>();
        Set<string> invalidRelatedIATASet			=	new Set<string>();
        
        map<String,Account> qicAccountMap			=	new map<String,Account>();
        map<String,Account_Relation__c> arRelatedAccMap			=	new map<String,Account_Relation__c>();
        map<Id,Account_Relation__c> newTaMap = new map<Id,Account_Relation__c>();
        Set<Id> taIds = new Set<Id>();
        
        // All Responses from Salesforce after processing
        QAC_TAInsertionResponse qacResp = new QAC_TAInsertionResponse();
        QAC_TAInsertionResponse.TaResponse myTaResp;
        QAC_TAInsertionResponse.ExceptionResponse myExcepResp;
        
        // some object responses are returned as lists after processing
        list<QAC_TAInsertionResponse.TaResponse> myTaRespList = new list<QAC_TAInsertionResponse.TaResponse>();
        list<QAC_TAInsertionResponse.ExceptionResponse> myExcepRespList = new list<QAC_TAInsertionResponse.ExceptionResponse>();
        
        string taRelation	=	Label.QAC_AccRet_TA_Relationship;
        try
        {
            String primaryIATA = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            List<QAC_TAInforWrapper> lstQACInfoWrapper	= new List<QAC_TAInforWrapper>();
            
            if(string.isNotBlank(primaryIATA))
            {
                myRequest = request.requestBody.toString();
                lstQACInfoWrapper = QAC_TAInforWrapper.parse(request.requestBody.toString()) ;
                system.debug('@@ show data @@ ' + lstQACInfoWrapper);
                
                for(QAC_TAInforWrapper qac_ta : lstQACInfoWrapper)
                {   
                    if(string.isNotBlank(qac_ta.iataCode))
                        incomingRelIATA.add(qac_ta.iataCode);
                }
                
                qicAccountMap = checkAcctExists(primaryIATA,incomingRelIATA);
                system.debug('qccount map**'+qicAccountMap);
                if(qicAccountMap != null && qicAccountMap.get(primaryIATA) != null)
                {
                    primaryAccExists = true;
                    for(Account_Relation__c eachTA : [SELECT Id, Name, Primary_Account__c, Primary_Account_f__c, Related_Account_f__c,
                                                      Primary_Account__r.Qantas_Industry_Centre_ID__c, Related_Account__c,Related_Account__r.Qantas_Industry_Centre_ID__c
                                                      From Account_Relation__c 
                                                      Where Primary_Account__r.Qantas_Industry_Centre_ID__c =: primaryIATA
                                                      And Relationship__c = :taRelation])
                    {
                        if(eachTA!=null)
                            arRelatedAccMap.put(eachTA.Related_Account__r.Qantas_Industry_Centre_ID__c,eachTA);    
                    }
                    
                    // to check Duplicates && related account exists
                    for(String eachRelIATA : incomingRelIATA)
                    {
                        // checks for existing
                        if(!arRelatedAccMap.isEmpty() && arRelatedAccMap.containsKey(eachRelIATA)){
                            existingRelatedIATASet.add(eachRelIATA);
                        }
                        else
                        {
                            if(!qicAccountMap.isEmpty())
                            {
                                // checks for Valid Iata
                                if(qicAccountMap.containsKey(eachRelIATA))
                                    validRelatedIATASet.add(eachRelIATA);
                                // checks for InValid Iata
                                else
                                    invalidRelatedIATASet.add(eachRelIATA);
                            }
                        }
                        
                    }                    
                    
                }
                if(!primaryAccExists)
                {
                    myExcepResp = new QAC_TAInsertionResponse.ExceptionResponse('404', 'primary account doesnt exists', '', ''); 
                    myExcepRespList.add(myExcepResp);
                    response.statusCode= 404;
                    qacResp.exceptionResponses = myExcepRespList;
                }                
                
                if(validRelatedIATASet.size()>0)
                {
                    for(string validIATA: validRelatedIATASet)
                    {
                        Account_Relation__c newTa= new Account_Relation__c();
                        newTa.Primary_Account__c= qicAccountMap.get(primaryIATA).Id;
                        newTa.Related_Account__c= qicAccountMap.get(validIATA).Id;
                        newTa.Relationship__c = taRelation;
                        lstInsTA.add(newTa);
                    }
                    
                    if(!lstInsTA.isEmpty())
                    {
                        insert lstInsTA;
                        for(Account_Relation__c TA: lstInsTA)
                        {
                            taIds.add(TA.Id);
                        }
                        newTaMap = fetchTA(taIds);
                        for(Id myId : taIds)
                        {
                            response.statusCode = 201;
                            
                            myTaResp = new QAC_TAInsertionResponse.TaResponse(newTaMap.get(myId).Primary_Account__r.Qantas_Industry_Centre_ID__c,
                                                                              newTaMap.get(myId).Related_Account__r.Qantas_Industry_Centre_ID__c,
                                                                              newTaMap.get(myId).Relationship__c);
                            myTaRespList.add(myTaResp);
                            
                        }
                        qacResp.ticketingAuthorityResponses = myTaRespList;
                    }
                }
                if(!existingRelatedIATASet.isEmpty())
                {
                    for(String existingIATA : existingRelatedIATASet) 
                    {
                        myExcepResp = new QAC_TAInsertionResponse.ExceptionResponse('409', 'Relationship already exists between PrimaryIATA:'+primaryIATA+' & relatedIATA:'+existingIATA, '', 'Relationship already exists'); 
                        myExcepRespList.add(myExcepResp);
                        response.statusCode= 409;
                    }   
                    qacResp.exceptionResponses = myExcepRespList;
                }
                if(!invalidRelatedIATASet.isEmpty())
                {
                    for(String invalidIATA : invalidRelatedIATASet) 
                    {
                        myExcepResp = new QAC_TAInsertionResponse.ExceptionResponse('404', 'No Data found for related account:'+invalidIATA, '', 'Travel Agency doesnt exists'); 
                        myExcepRespList.add(myExcepResp);
                        response.statusCode= 404;
                    }
                    qacResp.exceptionResponses = myExcepRespList;
                }
                
            }
            else if(string.isBlank(primaryIATA))
            {
                myExcepResp = new QAC_TAInsertionResponse.ExceptionResponse('400', 'IATA is Empty', '', 'Bad Request'); 
                myExcepRespList.add(myExcepResp);
                response.statusCode= 400;
                qacResp.exceptionResponses = myExcepRespList;
            }
            responseJson += JSON.serializePretty(qacResp,true);
            response.responseBody = Blob.valueOf(responseJson);
            
        }
        catch(Exception ex)
        {
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_TAInsertion', 'QAC_TAInsertion',
                                    'doTAInsertion', (myRequest.length() > 32768) ? myRequest.substring(0,32767) : myRequest, String.valueOf(''), true,'', ex);
            
            myExcepResp = new QAC_TAInsertionResponse.ExceptionResponse('500', 'Salesforce Internal Issue', ex.getMessage(), 'Internal Server Exception');
            myExcepRespList.add(myExcepResp);
            response.statusCode= 500;
            qacResp.exceptionResponses = myExcepRespList;
            responseJson += JSON.serializePretty(qacResp,true);
            response.responseBody = Blob.valueOf(responseJson);
        }
        /**finally
        {
            CreateLogs.insertLogRec('Log Integration Logs Rec Type', 'QAC Tradesite - QAC_TAInsertion', 'QAC_TAInsertion',
                                    'doTAInsertion',(myRequest.length() > 32768) ? myRequest.substring(0,32767) : myRequest, String.valueOf(''), true,'', null);
        }**/
    }
    
    public static map<String,Account> checkAcctExists(String primaryIata, Set<string> myIncomingRelIATA)
    {
        map<String,Account> myAccounts = new map<String,Account>();
        Set<String> allIATA = new Set<String>();
        
        If(!myIncomingRelIATA.isEmpty() && String.isNotBlank(primaryIata))
        {
            allIATA.add(primaryIATA);
            allIATA.addAll(myIncomingRelIATA);
        }
        
        if(!allIATA.isEmpty())
        {
            for(Account eachAcc : [select id, Qantas_Industry_Centre_ID__c from Account where Qantas_Industry_Centre_ID__c in :allIATA])
            {
                if(eachAcc != null)
                    myAccounts.put(eachAcc.Qantas_Industry_Centre_ID__c,eachAcc);
            }
            return myAccounts;            
        }
        return null;
    }
    
    public static map<Id,Account_Relation__c> fetchTA(Set<Id> myTAids)
    {
        map<Id,Account_Relation__c> myTA = new map<Id,Account_Relation__c>();
        for(Account_Relation__c eachTA : [SELECT Id, Name, Primary_Account__c, Primary_Account_f__c, Related_Account_f__c,Relationship__c,
                                          Primary_Account__r.Qantas_Industry_Centre_ID__c, Related_Account__c,Related_Account__r.Qantas_Industry_Centre_ID__c
                                          From Account_Relation__c 
                                          Where Id IN: myTAids])
        {
            if(eachTA != null)
                myTA.put(eachTA.id,eachTA);
        }
        return myTA;
    }
}