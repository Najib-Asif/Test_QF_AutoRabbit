/***********************************************************************************************************************************

Description: Apex class for retrieving the account relation (TA) Information. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Yuvaraj MV				    Account relation  record retrieval class                     T01

Created Date    : 			04/05/18 (DD/MM/YYYY)

Test Class		:			QAC_TaRetrieval_Test
**********************************************************************************************************************************/

@RestResource(urlmapping='/QACTAInformationRetrieval/*')
global with sharing class QAC_TaRetrieval 
{
    public static string responseJson='';
    
    @HttpGet
    global static void doTARetrieval()
    {
        
        Boolean sendRecords = false;
        list<Account> lstIataAcc = new list<Account>();
        Map<Id,string> existIata = new Map<Id,string>();
        
        list<QAC_TaInfoWrapper> taResponsesList	= new list<QAC_TaInfoWrapper>();
        list<Account_Relation__c> listTaInfo = new list<Account_Relation__c>();
        QAC_TAInsertionResponse qacResp = new QAC_TAInsertionResponse();
        QAC_AgencyProfileResponses.exceptionResponse mapErrorResponse;
        List<QAC_AgencyProfileResponses.FieldErrors> listFieldErrorResp = new List<QAC_AgencyProfileResponses.FieldErrors>();
        
        string taRelation	=	Label.QAC_AccRet_TA_Relationship;
        
        try
        {
            RestRequest request = RestContext.request;
        	RestResponse response = RestContext.response;
            String iataCode = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
            
            if(string.isNotBlank(iataCode)) 
            {
                lstIataAcc = [select Id,Qantas_Industry_Centre_ID__c 
                           from Account 
                           where Qantas_Industry_Centre_ID__c =: iataCode];
                
                listTaInfo = [select Id, Active__c, Related_Account_f__c, 
                              Related_account__r.Qantas_Industry_Centre_ID__c,
                              Primary_account__r.Agency_Sales_Region__r.Hide_TMCTA__c
                              from Account_Relation__c 
                              where primary_account__r.Qantas_Industry_Centre_ID__c =: iataCode
                              and Relationship__c =: taRelation];
                //lstIataAcc.add(new)
            }
            
            if(listTaInfo.Size()> 0)
            {   
                for(Account_Relation__c eachAccRel: listTaInfo)
                {
                    // Changes added by Ajay - For hide Tmc values
                    if((eachAccRel.Primary_account__r.Agency_Sales_Region__r != null && !eachAccRel.Primary_account__r.Agency_Sales_Region__r.Hide_TMCTA__c)
                       || eachAccRel.Primary_account__r.Agency_Sales_Region__r == null)
                    {
                        sendRecords = true;
                        taResponsesList.add(new QAC_TaInfoWrapper(eachAccRel.Active__c,eachAccRel.Id,  
                                                                  eachAccRel.related_account__r.Qantas_Industry_Centre_ID__c,
                                                                  eachAccRel.Related_Account_f__c));
                    }
                    
                }
                if((sendRecords) && listTaInfo.Size()> 0)
                {
                    response.statusCode 		= 200;
                    response.responseBody  		= blob.valueOf(JSON.serializePretty(taResponsesList));
                }
                
                else{
                    listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('TA Record', 'Agency Cannot Access TA'));
                    mapErrorResponse			= new QAC_AgencyProfileResponses.ExceptionResponse('401', 'Unauthorized Request', listFieldErrorResp); 
                    response.statusCode 		= 401;
                    response.responseBody		= Blob.valueOf(JSON.serializePretty(mapErrorResponse, true));
                }
                // Changes by Ajay - ended
            }
            
            else if(string.isBlank(iataCode))
            {
                response.statusCode 		= 400;
                listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('Id','IATA is Blank, Please enter valid IATA code' ));
                mapErrorResponse           = new QAC_AgencyProfileResponses.exceptionResponse('400', 'Bad Request', listFieldErrorResp);
                responseJson 				+= JSON.serializePretty(mapErrorResponse,true);
                response.responseBody   	= Blob.valueOf(responseJson);
                
            }
            else if(listTaInfo.Size() == 0 && lstIataAcc.Size() > 0 )
                {
                    List<object> objAcc = new List<object>();
                    list<QAC_TaInfoWrapper> taResponsesList1	= new list<QAC_TaInfoWrapper>();
                    response.statusCode 		= 200;
                    response.responseBody  		= blob.valueOf(JSON.serialize(taResponsesList));
                    
                }
            else if(lstIataAcc.size() == 0)
            {
                response.statusCode 		= 404;
                listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('Id','IATA doesnt exits' ));
                mapErrorResponse           	= new QAC_AgencyProfileResponses.exceptionResponse('404', 'Bad Request', listFieldErrorResp);
                responseJson 				+= JSON.serializePretty(mapErrorResponse,true);
                response.responseBody   	= Blob.valueOf(responseJson);
            }
        }
        catch(Exception ex)
        {   
            RestRequest request = RestContext.request;
        	RestResponse response = RestContext.response;
            CreateLogs.insertLogRec('Log Exception Logs Rec Type', 'QAC Tradesite - QAC_TARetrieval', 'QAC_TARetrieval',
                                    'doTARetrieval', (responseJson.length() > 32768) ? responseJson.substring(0,32767) : responseJson, String.valueOf(''), true,'', ex);
            
            response.statusCode= 500;
            listFieldErrorResp.add(new QAC_AgencyProfileResponses.FieldErrors('', ex.getMessage() ));
            mapErrorResponse           = new QAC_AgencyProfileResponses.ExceptionResponse('500', 'Salesforce Internal Error', listFieldErrorResp);
            response.responseBody       = Blob.valueOf(JSON.serializePretty(mapErrorResponse));
        }
    }
}