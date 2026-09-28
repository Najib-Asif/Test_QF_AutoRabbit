/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Sadhanand B
Company:       TCS
Description:   Class used for AWB Details tile for lightning component
Test Class:    FreightAWBPopUpControllerTest     
*********************************************************************************************************************************
History
16-Aug-2017   Ajay                Initial Design
30-Aug-2017   Ajay                Updating Integration part
14-May-2019   Vinoth              Commented the code for not executing through Test Class  
12-Jan-2026   Mark                CRM-10359 Code Security Remediation
********************************************************************************************************************************/
global without sharing class FreightAWBPopUpController { //CRM-10359 added without sharing for Code Security Remediation.
public class CustomException extends Exception {}
    
      
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    
    @AuraEnabled
    public String msg { get; set; }
    
    @AuraEnabled
    //public Case controllerCase { get; set; }
    public AWB_Info__c controllerCase { get; set; }
    
    @AuraEnabled
    public CampaignMember ControllerCampaignMember { get; set; }
    
    @AuraEnabled
    public Opportunity ControllerOpportunity { get; set; }
    
    @AuraEnabled
    public String LatestStatusString {get;set;}
    
    private static final String CASE_STYPE_CHECKINSTATUS = CustomSettingsUtilities.getConfigDataMap('SubType2_Check_in_Status');
    private static final String CASE_STYPE_MAPPING = CustomSettingsUtilities.getConfigDataMap('SubType2_Mapping');
    private static final String CASE_STYPE_DELIVERY = CustomSettingsUtilities.getConfigDataMap('SubType2_Delivery');
  
    /*--------------------------------------------------------------------------------------      
Method Name:        getBeforeAWBDetails
Description:        Method for getting static AWB Details tile for Case
Parameter:          Case Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static AWB_Info__c getBeforeAWBDetails(Id CaseId){
        try{
        Case caseRecord = [SELECT Id, Freight_AWB_Number__c,Latest_Status__c,Port_override_transit__c,Freight_Port__c,Sub_Type_2__c,Type,Sub_Type_1__c,Freight_AWB_Status__c,
                           OwnerId,Product__c,Port_Override_Flag__c,Freight_Origin__c,Freight_Destination__c,Commodity__c,Freight_Weight__c,Freight_AWB_Pieces__c
                           FROM Case WHERE Id =: CaseId WITH SYSTEM_MODE]; //CRM-10359 added WITH SYSTEM_MODE for Code Security Remediation
        List<AWB_Relationship__c> AWBRecord = [select id,AWB__c from AWB_Relationship__c where Case__c =:CaseId WITH SYSTEM_MODE order by CreatedDate DESC]; //CRM-10359 added WITH SYSTEM_MODE for Code Security Remediation
        AWB_Info__c newAWB = [select id,Transit__c,Product__c,Name,Port_Override_Flag__c,Pieces_Arrived__c,Ready_for_Collection__c,Collected_From_Terminal__c,Pieces_for_Collection__c,Freight_Origin__c,Flight_Arrival__c,Consignee__c,Shipper__c,Flight_Number__c,Reason_Code__c,
                              Freight_Weight__c,Freight_AWB_Handling_Code__c,Freight_AWB_Pieces__c,Booking_Status__c,Freight_Destination__c,Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c from AWB_Info__c where id =:AWBRecord[0].AWB__c WITH SYSTEM_MODE];//newAWB //CRM-10359 added WITH USER_MODE for Code Security Remediation
        /*Case caseRecord = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__cFROM Case WHERE Id =: CaseId];
          FreightAWBPopUpController.getRecordUpdate(caseRecord.Id);*/
        FreightAWBPopUpController.getRecordUpdate(caseRecord.Id);
        return newAWB;
        } catch (QueryException e) { //CRM-10359 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();           
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAWBPopUpController', 'FreightAWBPopUpController', 
                                    'getBeforeAWBDetails', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
           String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
           throw new AuraHandledException(msg);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRecordUpdate
Description:        Method for getting AWB Refresh values from iCargo system and table content 
and update record values for Case
Parameter:          Case Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static FreightAWBPopUpController getRecordUpdate(Id CaseId)
    {
        
        FreightAWBPopUpController obj = new FreightAWBPopUpController();
        //  list<Freight_AWBResponseParsing.LatestStatus> lsList = new list<Freight_AWBResponseParsing.LatestStatus>();
        list<Freight_AWBResponseParsing.shipmentHistory> lsList = new list<Freight_AWBResponseParsing.shipmentHistory>();
        
        system.debug('@@ Case Id @@ '+ CaseId);
        // Querying Case to retrieve AWB Number
         Case caseRecord = [SELECT Id, Freight_AWB_Number__c,Latest_Status__c,Port_override_transit__c,Freight_Port__c,Sub_Type_2__c,Type,Sub_Type_1__c,Freight_AWB_Status__c,
                           OwnerId,Product__c,Port_Override_Flag__c,Freight_Origin__c,Freight_Destination__c,Commodity__c,Freight_Weight__c,Freight_AWB_Pieces__c
                           FROM Case WHERE Id =: CaseId WITH SYSTEM_MODE]; //CRM-10359 added WITH SYSTEM_MODE for Code Security Remediation
        List<AWB_Relationship__c> AWBRecord = [select id,AWB__c,Case__c from AWB_Relationship__c where Case__c =:CaseId WITH SYSTEM_MODE order by CreatedDate DESC]; //CRM-10359 added WITH SYSTEM_MODE for Code Security Remediation
        AWB_Info__c newAWB = [select id,Product__c,Freight_Port__c,Transit__c,Name,Port_Override_Flag__c,Pieces_Arrived__c,Ready_for_Collection__c,Collected_From_Terminal__c,Pieces_for_Collection__c,Freight_Origin__c,Consignee__c,Shipper__c,Flight_Number__c,Reason_Code__c,
                              Freight_Weight__c,Freight_AWB_Handling_Code__c,Freight_AWB_Pieces__c,Booking_Status__c,Freight_Destination__c,Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c,Freight_AWB_Status__c from AWB_Info__c where id =:AWBRecord[0].AWB__c WITH SYSTEM_MODE];//newAWB //CRM-10359 added WITH SYSTEM_MODE for Code Security Remediation
        
        
        // iCargo AWB Details Credentials retrieval from Custom setting
       // Integration_User_Tradesite__c freightIcargoUserDetails = Integration_User_Tradesite__c.getValues('Freight_iCargo_Integration');        
        
        // Parameters to be passed for authentication in Qsova
       // String username     = freightIcargoUserDetails.UserName__c;             
       // String password     = freightIcargoUserDetails.Password__c;         
       // string requestJson;
        
        // Checking availability of AWB Number, accordingly requesting 
       // if(String.isNotBlank(caseRecord.Freight_AWB_Number__c)){
        //    requestJson = getRequestString(username, password, caseRecord.Freight_AWB_Number__c);
          //  system.debug('requestJson##'+requestJson);
        //}
        if(String.isBlank(caseRecord.Freight_AWB_Number__c)){
            // show error AWB Number not provided. Lighting work to be done
            obj.msg = 'AWB Number not provided for the Case';
            obj.isSuccess = false;
            obj.controllerCase = newAWB;
            return obj;
        }
        
        
        try{
            Boolean responseSuccess;
            String AWB=caseRecord.Freight_AWB_Number__c;
            //HttpResponse res = getAWBResponse(requestJson, freightIcargoUserDetails);//CRM-6919
            HttpResponse res = getAWBResponse(AWB);              
            System.debug('response VALUES' +res);
            //check here for res=500-/getbody not null CRM-5487
            System.debug('res.getStatus()***'+res.getStatusCode());
            System.debug('res.getbody'+res.getBody());
            if(res.getStatusCode() == 200 && res.getbody() != null){
                responseSuccess = true;
            }
            else if(res.getStatusCode() == 400){
                //res = getAWBResponse(requestJson, freightIcargoUserDetails);//CRM-6919
                res = getAWBResponse(AWB);
                if(res.getStatusCode() == 200 && res.getbody() != null)
                    responseSuccess = true;
                else if(res.getStatusCode() == 400)
                    responseSuccess = false;
            }
            else{ // Added additional Status code check to cover statuscode=500 - CRM 7487
                responseSuccess = false;
            }
            if(responseSuccess)
            { 
                Freight_AWBResponseParsing awbResponseParsed;
                awbResponseParsed = Freight_AWBResponseParsing.parseWithoutJsonException(res.getBody());
                //awbResponseParsed = (Freight_AWBResponseParsing) System.JSON.deserialize(res.getBody(), Freight_AWBResponseParsing.class);//CRM-6919
                lsList =awbResponseParsed.shipmentHistory;
                system.debug('lsList'+lsList);
                obj.LatestStatusString = JSON.serialize(lsList);
                newAWB = returnParsedCase(res.getBody(), newAWB);
                newAWB.Freight_AWB_Status__c = 'c';
                UPDATE as system newAWB; //CRM-10359 CRUD check before DML
                //New mappings while migrating awb object
                caseRecord.Latest_Status__c = system.now();
                
                set<String> Port_Override_Flag_Combinations = new set<String>{CASE_STYPE_MAPPING,CASE_STYPE_CHECKINSTATUS,CASE_STYPE_DELIVERY};//CRM-9847
                string key = caseRecord.Type+'-'+caseRecord.Sub_Type_1__c+'-'+caseRecord.Sub_Type_2__c;
                List<Airport_Code__c> getMatchingAirportCodes=[select id,name from Airport_Code__c where (name =:newAWB.Freight_Destination__c) AND QF_Freight_Presence__c=: true WITH USER_MODE limit 1 ]; //CRM-10359 added WITH USER_MODE for Code Security Remediation
               if( (caseRecord.Port_Override_Flag__c == true) || (Port_Override_Flag_Combinations.contains(key) && caseRecord.Freight_AWB_Status__c == 'Update Port to AWB Destination')){
                    if(getMatchingAirportCodes.size()>0){
                    caseRecord.Freight_Port__c = getMatchingAirportCodes[0].id;
                    caseRecord.Port_Override_Flag__c = true;
                    }
                }
                else if(caseRecord.Port_override_transit__c == true){
                    //remains same port value
                }
                else{
                    caseRecord.Freight_Port__c = newAWB.Freight_Port__c;
                    //caseRecord.Port_Override_Flag__c = false;
                }
                 //CRM-9897 and CRM-9896 assigned value for Origin,Destination,Commodity for email template usage
                caseRecord.Product__c = newAWB.Product__c;
                caseRecord.Freight_Origin__c = newAWB.Freight_Origin__c;
                caseRecord.Freight_Destination__c = newAWB.Freight_Destination__c;
                caseRecord.Commodity__c = newAWB.Commodity__c;
                caseRecord.Freight_AWB_Pieces__c = newAWB.Freight_AWB_Pieces__c;
                caseRecord.Freight_Weight__c = newAWB.Freight_Weight__c;
                //Added for CRM-13733
                CaseRecord.Ready_for_Collection__c = newAWB.Ready_for_Collection__c;
				CaseRecord.Flight_Arrival__c = newAWB.Flight_Arrival__c;

                UPDATE as user caseRecord; //CRM-10359 CRUD check before DML
                System.debug('@@@@@@ case updated successfully...');
                obj.isSuccess = true;
                obj.controllerCase = newAWB;
                return obj;
            } 
            else{
                // error message for false
                // obj.msg = 'Contact Relevant IT Team';
                obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+caseRecord.Freight_AWB_Number__c; //CRM-7487
                /*CRM- 8635*/
                Freight_AWBResponseParsing awbResponseParsed;
                awbResponseParsed = Freight_AWBResponseParsing.parseWithoutJsonException(res.getBody());
                lsList =awbResponseParsed.shipmentHistory;
                obj.LatestStatusString = JSON.serialize(lsList);
                System.debug('res.getBody()'+res.getBody());
                newAWB = returnParsedCase(res.getBody(), newAWB);
                UPDATE as System newAWB; //CRM-10359 CRUD check before DML
                /*caseRecord = returnParsedCase(res.getBody(), caseRecord);
                caseRecord.Latest_Status__c = null;
                caseRecord.IsPortEnabled__c=True;*/
                caseRecord.Latest_Status__c = null;//CRM 9611
                UPDATE as user caseRecord; //CRM-10359 CRUD check before DML
                obj.isSuccess = false;
                obj.controllerCase = newAWB;
                return obj;
            }
         }
        catch (JSONException jsonExcep){
            system.debug(' @@ No Response @@ ' + jsonExcep);
            //caseRecord.Freight_AWB_Status__c = 'Information Not Available';
            newAWB.Freight_AWB_Status__c = 'Information Not Available';
            UPDATE as system newAWB; //CRM-10359 CRUD check before DML
            obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+newAWB.Name;
            obj.isSuccess = true;
            obj.controllerCase = newAWB;
            System.debug('obj'+obj);
            return obj;
            
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getAWBResponse
Description:        Method for fetching HTTPResponse from iCargo system 
Parameter:          JSON response String , Integration_User_Tradesite__c custom setting
--------------------------------------------------------------------------------------*/
    /*public static HTTPResponse getAWBResponseDeprecated(string requestJson, Integration_User_Tradesite__c freightIcargoUserDetails,String AWB){ //CRM-6919   
        // Parameters to be passed for authentication in Qsova
        String username     = freightIcargoUserDetails.UserName__c;             
        String password     = freightIcargoUserDetails.Password__c; 
        System.debug('freightIcargoUserDetails Endpoint'+freightIcargoUserDetails.Endpoint__c);
        // Http request parameter declaration
        String dynamicURL=AWB;
        string endPoint     = freightIcargoUserDetails.Endpoint__c+''+dynamicURL;//CRM-6919
        System.debug('Endpoint***'+endPoint);
        string method       = 'GET';
        //string method       = 'POST';//CRM-6919
        String accessToken;
        accessToken = Freight_AuthenticateAPIGateWay.returnAccessToken();
        
        system.debug(' @@ accessToken Recieved  @@ -- ' + accessToken);
        // Http Request formation to be sent to iCargo system.
        HttpRequest req     = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setHeader('Authorization','Bearer ' + accessToken);
        req.setHeader('Content-Type','application/json');
        // Http Response requested from iCargo system.
        Http http           = new Http();
        HTTPResponse res    = new HTTPResponse();
        res    = http.send(req);
        return res;
        
    }*/
    /*--------------------------------------------------------------------------------------
Method Name : getAWBResponse

Description :
Retrieves AWB (Air Waybill) information from the iCargo system using a
Salesforce Named Credential. OAuth authentication is handled automatically
by Salesforce through the configured External Credential.

Parameter :awb - Air Waybill number.
Returns :HttpResponse from the iCargo API.
--------------------------------------------------------------------------------------*/
public static HttpResponse getAWBResponse(String awb) {

    HttpRequest req = new HttpRequest();
    // Build endpoint using Named Credential
    req.setEndpoint(
        'callout:Freight_iCargo_NC/' + awb
    );

    req.setMethod('GET');
    req.setHeader('Content-Type', 'application/json');
    req.setTimeout(60000);

    Http http = new Http();

    // Execute callout and return response
    return http.send(req);
}
    /*--------------------------------------------------------------------------------------      
Method Name:        returnParsedCase
Description:        Method for values from iCargo system and update record values for Case
Parameter:          Case Record , JSON response String
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static AWB_Info__c returnParsedCase(String jsonResponse, AWB_Info__c newAWB){
        try{
        Freight_AWBResponseParsing awbResponseParsed = Freight_AWBResponseParsing.parseWithoutJsonException(jsonResponse);
        
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getStatedWeight() != null) 
        {   
            newAWB.Freight_Weight__c = awbResponseParsed.getShipmentSummary().getStatedWeight();
         }
        else{
            newAWB.Freight_Weight__c = ''; 
        }
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getHandlingCodes() != null) {
               newAWB.Freight_AWB_Handling_Code__c = awbResponseParsed.getShipmentSummary().getHandlingCodes();
           }
        else{
            newAWB.Freight_AWB_Handling_Code__c =''; 
            
        }
        
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getStatedPieces() != null) {
               newAWB.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.getShipmentSummary().getStatedPieces()); 
            }
        else{
            newAWB.Freight_AWB_Pieces__c =null; 
            
        }
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getOrigin() != null)
        {   
            newAWB.Freight_Origin__c = awbResponseParsed.getShipmentSummary().getOrigin(); 
       }
        else{
            newAWB.Freight_Origin__c = ''; 
        }
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getDestination() != null)
        {   
            newAWB.Freight_Destination__c = awbResponseParsed.getShipmentSummary().getDestination();
            
        }
        else{
            newAWB.Freight_Destination__c=''; 
        }
        
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getBookingStatus() != null)
        {   
           newAWB.Booking_Status__c = awbResponseParsed.getShipmentSummary().getBookingStatus();
            
        }
        else{
            newAWB.Booking_Status__c =''; 
        }
        
        if(awbResponseParsed.getShipmentSummary() != null
           && awbResponseParsed.getShipmentSummary().getShipmentDescription() != null){
               newAWB.Freight_AWB_Shipment_Description__c = awbResponseParsed.getShipmentSummary().getShipmentDescription(); 
            }
        else{
            newAWB.Freight_AWB_Shipment_Description__c=''; //CRM- 8635
        }
        
        // Retrieving weightUnit Info CRM-6919
        if(awbResponseParsed.getUnitOfmeasures() != null
           && awbResponseParsed.getUnitOfmeasures().getWeight() != null)
        {
            newAWB.Freight_AWB_Weight_Unit__c = awbResponseParsed.getUnitOfmeasures().getWeight();
        } 
        else{
            newAWB.Freight_AWB_Weight_Unit__c=''; //CRM- 8635
        }
        
        /*Retrieving Unit Info - CRM- 8635*/
        
        newAWB.Freight_AWB_Unit_Type__c='';  
        if (awbResponseParsed.getShipmenthistory() != null) {
            for (Freight_AWBResponseParsing.shipmentHistory currElement : awbResponseParsed.getShipmenthistory())
            {
                if (currElement.getEventDetails() != null && String.isNotBlank(currElement.getEventDetails().getUldNumber()))
                {
                    newAWB.Freight_AWB_Unit_Type__c = currElement.getEventDetails().getUldNumber();
                }
            }
        }
        /*CRM 8455 iCargo New Field mappings*/
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getproduct() != null)
        {   
            newAWB.Product__c = awbResponseParsed.getShipmentSummary().getproduct();
        
        }
        else{
            newAWB.Product__c = ''; //CRM- 8635
            
        }
        
        
        if(awbResponseParsed.getShipmentSummary() != null && awbResponseParsed.getShipmentSummary().gethandlingCodes() != null)
        {   
            newAWB.Commodity__c = awbResponseParsed.getShipmentSummary().gethandlingCodes().substringBefore(',');
         }else{
            newAWB.Commodity__c = 'None';    
            
        }
        
        if(awbResponseParsed.getShipmentSummary() != null 
           && awbResponseParsed.getShipmentSummary().getOrigin() != null && newAWB.Port_Override_Flag__c == False)
        {
            String Port = awbResponseParsed.getShipmentSummary().getOrigin(); 
            List<Airport_Code__c> airportcode=[Select id,Name from Airport_Code__c where Name =:port WITH USER_MODE limit 1 ]; //CRM-10359 added WITH USER_MODE for Code Security Remediation
            for(Airport_Code__c airportcodes:airportcode){
                newAWB.Freight_Port__c = airportcodes.Id;
            }
            
            
        }else{ //CRM- 8635
            if(newAWB.Port_Override_Flag__c == False){
                List<Airport_Code__c> airportcodes=[Select id,Name from Airport_Code__c WITH USER_MODE limit 1 ]; //CRM-10359 added WITH USER_MODE for Code Security Remediation
                for(Airport_Code__c airport:airportcodes){
                    airport.Id=null;
                    newAWB.Freight_Port__c = airport.Id;
                }
            }
        }
        
        newAWB.Flight_Arrival__c =Null;   
        if (awbResponseParsed.getShipmenthistory() != null) {
            for (Freight_AWBResponseParsing.shipmentHistory ADate : awbResponseParsed.getShipmenthistory())
            {
                if ((ADate.flightDetails != null) && String.isNotBlank(ADate.flightDetails.flightArrivalDate))
                {   
                    newAWB.Flight_Arrival__c = (DateTime)JSON.deserialize('"'+ADate.flightDetails.flightArrivalDate+'"', DateTime.class);
                 }
            }
        }
        
        newAWB.Pieces_Arrived__c ='';
        if (awbResponseParsed.getShipmenthistory() != null) {
            for(Freight_AWBResponseParsing.shipmentHistory piecesArrived:awbResponseParsed.shipmenthistory){
                if((piecesArrived.getEventDetails()?.getUldNumber()!='') &&  piecesArrived.eventName =='Flight landed'){
                    newAWB.Pieces_Arrived__c = piecesArrived.pieces +' '+piecesArrived.eventDetails.uldNumber ;    
                }else {if((piecesArrived.getEventDetails()?.getUldNumber()==Null) &&  piecesArrived.eventName =='Flight landed'){
                    newAWB.Pieces_Arrived__c = piecesArrived.pieces +' '+'LOOSE' ;    
                 }
                      }
            }
        }
        newAWB.Ready_for_Collection__c=Null;
        if (awbResponseParsed.getShipmenthistory() != null) {
            for(Freight_AWBResponseParsing.shipmentHistory tDate:awbResponseParsed.shipmenthistory){
                if(tDate.transactionDate!=Null && tDate.eventName == 'Ready for Collection'){
                    newAWB.Ready_for_Collection__c=(DateTime)JSON.deserialize('"'+tDate.transactionDate+'"', DateTime.class);
                }
            }
        }
        
         newAWB.Collected_From_Terminal__c = null;
            if (awbResponseParsed.getShipmenthistory() != null) {
                for(Freight_AWBResponseParsing.shipmentHistory tDate:awbResponseParsed.shipmenthistory) {
                    if(tDate.transactionDate!=Null && tDate.eventName == 'Collected from terminal') {
                        System.debug('Collected_From_Terminal__c assigned = ' +tdate.transactionDate);
                        newAWB.Collected_From_Terminal__c =(DateTime)JSON.deserialize('"' + tdate.transactionDate + '"',DateTime.class);
                    }
                }
            }
        
        newAWB.Pieces_for_Collection__c ='';
        if (awbResponseParsed.getShipmenthistory() != null) {
            for(Freight_AWBResponseParsing.shipmentHistory piecesforCollection:awbResponseParsed.shipmenthistory){
                if((piecesforCollection.getEventDetails()?.getUldNumber()!=Null) &&  piecesforCollection.eventName =='Ready for Collection'){
               newAWB.Pieces_for_Collection__c = piecesforCollection.pieces +' '+piecesforCollection.getEventDetails().getUldNumber() ;    
                }else{ if ((piecesforCollection.getEventDetails()?.getUldNumber()==Null) &&  piecesforCollection.eventName =='Ready for Collection'){
                    newAWB.Pieces_for_Collection__c = piecesforCollection.pieces +' '+'LOOSE';    
                }
                     }           
                
            }
        }
           //new field   
        newAWB.Flight_Number__c='';     
        if (awbResponseParsed.getShipmenthistory() != null) {
            for (Freight_AWBResponseParsing.shipmentHistory FlightNumber : awbResponseParsed.getShipmenthistory())
            {
                if ((FlightNumber.flightDetails != null) && String.isNotBlank(FlightNumber.flightDetails.flightNumber))
                {   
                    newAWB.Flight_Number__c = FlightNumber.flightDetails.flightNumber;
                    break;
                }
            }
        }else{
            newAWB.Flight_Number__c = '';
        }
       // CRM - 10152
        if (awbResponseParsed.getShipmenthistory() != null) {
            for(Freight_AWBResponseParsing.shipmentHistory discrepancyReason:awbResponseParsed.shipmenthistory){
                    if(String.isNotBlank(discrepancyReason.eventDetails?.discrepancyReasoncode)){
                    newAWB.Reason_Code__c = discrepancyReason.eventDetails.discrepancyReasoncode ; // INC2916242 Fix   
                }
            }
        }else{
             newAWB.Reason_Code__c = '';
        } 
        if(awbResponseParsed.getShipmentSummary() != null && awbResponseParsed.getShipmentSummary().getConsigneeName() != null){
            newAWB.Consignee__c = awbResponseParsed.getShipmentSummary().getConsigneeName(); 
         }
        else{
            newAWB.Consignee__c=''; //CRM- 8635
        }
          
        if(awbResponseParsed.getShipmentSummary() != null && awbResponseParsed.getShipmentSummary().getShipperName() != null){
            newAWB.Shipper__c = awbResponseParsed.getShipmentSummary().getShipperName(); 
         }
        else{
            newAWB.Shipper__c=''; //CRM- 8635
        }
        newAWB.Transit__c ='';
        if (awbResponseParsed.getShipmenthistory() != null) {
            for(Freight_AWBResponseParsing.shipmentHistory Transit:awbResponseParsed.shipmenthistory){
                if((Transit.getEventDetails()?.getUldNumber()!='') &&  Transit.eventName =='Arrived at transfer port' && Transit.airportCode != null){
                    newAWB.Transit__c = Transit.airportCode;   
                }            }
        }
     
    
        return newAWB;
        } catch (QueryException e) { //CRM-10359 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
             CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAWBPopUpController', 'FreightAWBPopUpController', 
                                    'returnParsedCase', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
             String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
             throw new AuraHandledException(msg);
        }
    } 
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRequestString
Description:        Method to get json String from AWB Request class 
Parameter:          String userName , password and Awb number
--------------------------------------------------------------------------------------*/
    /*@AuraEnabled
    public static string getRequestString(string userName, string Password, string awbNumber){
        
        // Parameters to be passed for AWB Number
        string shipmentPrefix = awbNumber.substringBefore('-');
        string masterDocNumber = awbNumber.substringAfter('-');
        
        // Parameters to generate startdate and expiry date for Request message
        Datetime befcdformat = System.now();
        String creationDate = string.valueOfGmt(befcdformat);
        CreationDate = CreationDate.replace(' ', 'T' )+ 'Z';
        befcdformat = System.now().addMinutes(10);
        String expireDate = string.valueOfGmt(befcdformat);
        expireDate = expireDate.replace(' ', 'T' )+ 'Z';
        
        // Initialising class 
        Freight_AWBRequestJson awbRequestJson                       = new Freight_AWBRequestJson();
        awbRequestJson.Shipments                                    = new Freight_AWBRequestJson.Shipments();
        
        // Setting up Authentication details
        awbRequestJson.Shipments.AuthorisationToken                 = new Freight_AWBRequestJson.AuthorisationToken();
        awbRequestJson.Shipments.AuthorisationToken.username        = username;
        awbRequestJson.Shipments.AuthorisationToken.password        = password;
        awbRequestJson.Shipments.AuthorisationToken.MessageCreationDateTime = creationDate;
        awbRequestJson.Shipments.AuthorisationToken.MessageExpireDateTime   = expireDate;
        
        // Setting up AWB request parameter
        awbRequestJson.Shipments.TrackingFilters                    = new Freight_AWBRequestJson.TrackingFilters();
        awbRequestJson.Shipments.TrackingFilters.shipmentPrefix     = shipmentPrefix;
        awbRequestJson.Shipments.TrackingFilters.masterDocumentNumber = masterDocNumber;
        
        // return json string to be sent as request to iCargo
        return awbRequestJson.convertToJsonString(awbRequestJson);
        
    }*/
    
    
    //FreightAWBCampaignController
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getBeforeAWBDetails
Description:        Method for getting static AWB Details tile for CampaignMember
Parameter:          CampaignMember Id
--------------------------------------------------------------------------------------*/
  /* @AuraEnabled
    public static CampaignMember getBeforeAWBDetailsCampMember(Id CampaignMemberId){
        CampaignMember CampaignMemberRecord = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                               Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                               Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                               FROM CampaignMember WHERE Id =: CampaignMemberId];
        
        return CampaignMemberRecord;
    }*/
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRecordUpdate
Description:        Method for getting AWB Refresh values from iCargo system and table content 
and update record values for CampaignMember
Parameter:          CampaignMember Id
--------------------------------------------------------------------------------------*/
   /* @AuraEnabled
    public static FreightAWBPopUpController getRecordUpdateCampMember(Id CampaignMemberId)
    {
        
        FreightAWBPopUpController obj = new FreightAWBPopUpController();
        //list<Freight_AWBResponseParsing.LatestStatus> lsList = new list<Freight_AWBResponseParsing.LatestStatus>();
        list<Freight_AWBResponseParsing.shipmentHistory> lsList = new list<Freight_AWBResponseParsing.shipmentHistory>();
        system.debug('@@ CampaignMember Id @@ '+ CampaignMemberId);
        // Querying CampaignMember to retrieve AWB Number
        CampaignMember CampaignMemberRecord     = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                                Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                                Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                                FROM CampaignMember WHERE Id =: CampaignMemberId];
        
        // iCargo AWB Details Credentials retrieval from Custom setting
        Integration_User_Tradesite__c freightIcargoUserDetails = Integration_User_Tradesite__c.getValues('Freight_iCargo_Integration');        
        
        // Parameters to be passed for authentication in Qsova
        String username     = freightIcargoUserDetails.UserName__c;             
        String password     = freightIcargoUserDetails.Password__c;         
        string requestJson;
        
        // Checking availability of AWB Number, accordingly requesting 
        if(String.isNotBlank(CampaignMemberRecord.Freight_AWB_Number__c)){
            requestJson = getRequestString(username, password, CampaignMemberRecord.Freight_AWB_Number__c);
        }
        else{
            // show error AWB Number not provided. Lighting work to be done
            obj.msg = 'AWB Number not provided for the CampaignMember';
            obj.isSuccess = false;
            obj.ControllerCampaignMember = CampaignMemberRecord;
            return obj;
        }
        
        system.debug(' @@ j2Apex.sample string @@ ' + requestJson);
        
        try{
            String AWB=CampaignMemberRecord.Freight_AWB_Number__c;
            Boolean responseSuccess;
            HttpResponse res = getAWBResponse(AWB);            
            System.debug('response VALUES' +res.getBody());
            //check here for res=500-/getbody not null CRM-5487
            if(res.getStatusCode() == 200 && res.getbody() != null){
                responseSuccess = true;
            }
            else if(res.getStatusCode() == 400){
                res = getAWBResponse(AWB);
                if(res.getStatusCode() == 200 && res.getbody() != null)
                    responseSuccess = true;
                else if(res.getStatusCode() == 400)
                    responseSuccess = false;
            }
            else{ // Added additional Status code check to cover statuscode=500 - CRM 7487
                responseSuccess = false;
            }
            if(responseSuccess)
            {
                Freight_AWBResponseParsing awbResponseParsed = (Freight_AWBResponseParsing) System.JSON.deserialize(res.getBody(), Freight_AWBResponseParsing.class);
                System.debug('awbResponseParsed'+awbResponseParsed);
                lsList =awbResponseParsed.shipmentHistory;
                obj.LatestStatusString = JSON.serialize(lsList);
                system.debug(' @@ Latest Status List @@ ' + obj.LatestStatusString);
                
                CampaignMemberRecord = returnParsedCampaignMember(res.getBody(), CampaignMemberRecord);
                CampaignMemberRecord.Freight_AWB_Status__c = 'Information Received';
                CampaignMemberRecord.Latest_Status__c = system.now();
                
                system.debug('CampaignMember rec***'+CampaignMemberRecord);
                update CampaignMemberRecord;
                
                obj.isSuccess = true;
                //obj.msg='';
                obj.controllerCampaignMember = CampaignMemberRecord;
                return obj;
            }
            else{
                // error message for false
                //obj.msg = 'Contact Relevant IT Team';
                obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+CampaignMemberRecord.Freight_AWB_Number__c; //CRM-7487
                obj.isSuccess = false;
                obj.ControllerCampaignMember = CampaignMemberRecord;
                return obj;
            }
            
        }
        catch (JSONException jsonExcep){
            system.debug(' @@ No Response @@ ' + jsonExcep);
            CampaignMemberRecord.Freight_AWB_Status__c = 'Information Not Available';
            update CampaignMemberRecord;
            
            obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+CampaignMemberRecord.Freight_AWB_Number__c;
            obj.isSuccess = true;
            obj.ControllerCampaignMember = CampaignMemberRecord;
            return obj;
        }
    }*/
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getAWBResponse
Description:        Method for fetching HTTPResponse from iCargo system 
Parameter:          JSON response String , Integration_User_Tradesite__c custom setting
--------------------------------------------------------------------------------------*/
    /*public static HTTPResponse getAWBResponseCampMember(string requestJson, Integration_User_Tradesite__c freightIcargoUserDetails,String AWB){
        system.debug('AWB number##'+AWB);
        // Parameters to be passed for authentication in Qsova
        String username     = freightIcargoUserDetails.UserName__c;             
        String password     = freightIcargoUserDetails.Password__c; 
        
        // Http request parameter declaration
        String dynamicURL=AWB;
        string endPoint     = freightIcargoUserDetails.Endpoint__c+''+dynamicURL;
        System.debug('Endpoint***'+endPoint);
        string method       = 'GET';
        String accessToken;
        accessToken = Freight_AuthenticateAPIGateWay.returnAccessToken();
        
        system.debug(' @@ accessToken Recieved  @@ -- ' + accessToken);
        // Http Request formation to be sent to iCargo system.
        HttpRequest req     = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setBody(requestJson);
        req.setHeader('Authorization','Bearer ' + accessToken);
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        // Http Response requested from iCargo system.
        Http http           = new Http();
        HTTPResponse res    = new HTTPResponse();
        res    = http.send(req);
        return res;
    }*/
    
    /*--------------------------------------------------------------------------------------      
Method Name:        returnParsedCampaignMember
Description:        Method for values from iCargo system and update record values for Case
Parameter:          CampaignMember Record , JSON response String
--------------------------------------------------------------------------------------*/
    /*@AuraEnabled
    public static CampaignMember returnParsedCampaignMember(string jsonResponse, CampaignMember CampaignMemberRecord){
        
        Freight_AWBResponseParsing awbResponseParsed = Freight_AWBResponseParsing.parse(jsonResponse);
        
        
        
        if(awbResponseParsed.shipmentSummary.statedWeight != null){//Jira CRM-8081
            CampaignMemberRecord.Freight_Weight__c = awbResponseParsed.shipmentSummary.statedWeight ;    
        }
        
        //Jira CRM-6919
        //Retrieving HandlingCOde Info
        if(awbResponseParsed.shipmentSummary.handlingCodes != null){
            CampaignMemberRecord.Freight_AWB_Handling_Code__c = awbResponseParsed.shipmentSummary.handlingCodes;    
        }
        
        
        //Jira CRM-6919
        
        if(awbResponseParsed.shipmentSummary.statedPieces != null){//Jira CRM-8081
            CampaignMemberRecord.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.shipmentSummary.statedPieces);    
        }
        
        
        //Jira CRM-6919
        if(awbResponseParsed.shipmentSummary.origin  != null){//Jira CRM-8081
            CampaignMemberRecord.Freight_Origin__c = awbResponseParsed.shipmentSummary.origin;    
        }
        
        //Jira CRM-6919
        
        if(awbResponseParsed.shipmentSummary.destination != null){//Jira CRM-8081
            CampaignMemberRecord.Freight_Destination__c = awbResponseParsed.shipmentSummary.destination;    
        }        
        
        
        //Jira CRM-6919
        //Retrieving shipmentDescription Info
        if(awbResponseParsed.shipmentSummary.shipmentDescription != null){
            CampaignMemberRecord.Freight_AWB_Shipment_Description__c = awbResponseParsed.shipmentSummary.shipmentDescription;    
        }
        
        
       
        //Jira CRM-6919
        // Retrieving weightUnit Info
        if(awbResponseParsed.unitOfMeasures.weight != null){
            CampaignMemberRecord.Freight_AWB_Weight_Unit__c = awbResponseParsed.unitOfMeasures.weight;    
        } 
        
        // Retrieving weightUnit Info
        
        for(Freight_AWBResponseParsing.shipmentHistory uidnum:awbResponseParsed.shipmenthistory){
            if(String.isNotBlank(uidnum.eventDetails.uldNumber)){
                CampaignMemberRecord.Freight_AWB_Unit_Type__c = uidnum.eventDetails.uldNumber ;    
            }
        }
        return CampaignMemberRecord;
    } */
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRequestString
Description:        Method to get json String from AWB Request class 
Parameter:          String userName , password and Awb number
--------------------------------------------------------------------------------------*/
   /* @AuraEnabled
    public static string getRequestStringCampMember(string userName, string Password, string awbNumber){
        
        // Parameters to be passed for AWB Number
        string shipmentPrefix = awbNumber.substringBefore('-');
        string masterDocNumber = awbNumber.substringAfter('-');
        
        // Parameters to generate startdate and expiry date for Request message
        Datetime befcdformat = System.now();
        String creationDate = string.valueOfGmt(befcdformat);
        CreationDate = CreationDate.replace(' ', 'T' )+ 'Z';
        befcdformat = System.now().addMinutes(10);
        String expireDate = string.valueOfGmt(befcdformat);
        expireDate = expireDate.replace(' ', 'T' )+ 'Z';
        
        // Initialising class 
        Freight_AWBRequestJson awbRequestJson                       = new Freight_AWBRequestJson();
        awbRequestJson.Shipments                                    = new Freight_AWBRequestJson.Shipments();
        
        // Setting up Authentication details
        awbRequestJson.Shipments.AuthorisationToken                 = new Freight_AWBRequestJson.AuthorisationToken();
        awbRequestJson.Shipments.AuthorisationToken.username        = username;
        awbRequestJson.Shipments.AuthorisationToken.password        = password;
        awbRequestJson.Shipments.AuthorisationToken.MessageCreationDateTime = creationDate;
        awbRequestJson.Shipments.AuthorisationToken.MessageExpireDateTime   = expireDate;
        
        // Setting up AWB request parameter
        awbRequestJson.Shipments.TrackingFilters                    = new Freight_AWBRequestJson.TrackingFilters();
        awbRequestJson.Shipments.TrackingFilters.shipmentPrefix     = shipmentPrefix;
        awbRequestJson.Shipments.TrackingFilters.masterDocumentNumber = masterDocNumber;
        
        // return json string to be sent as request to iCargo
        return awbRequestJson.convertToJsonString(awbRequestJson);
        
    } */    
    
    
    //FreightAWBOpportunitycontroller
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getBeforeAWBDetails
Description:        Method for getting static AWB Details tile for Opportunity record
Parameter:          Opportunity Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static Opportunity getBeforeAWBDetailsOppty(Id OpportunityId){
        try{
            Opportunity OpportunityRecord = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                            Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                            Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                            FROM Opportunity WHERE Id =: OpportunityId WITH USER_MODE]; //CRM-10359 added WITH USER_MODE for Code Security Remediation
            
            return OpportunityRecord;
        } catch (QueryException e) { //CRM-10359 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
             CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAWBPopUpController', 'FreightAWBPopUpController', 
                                    'getBeforeAWBDetailsOppty', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
             String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
             throw new AuraHandledException(msg);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRecordUpdate
Description:        Method for getting AWB Refresh values from iCargo system and table content 
and update record values for Opportunity
Parameter:          Opportunity Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static FreightAWBPopUpController getRecordUpdateOppty(Id OpportunityID)
    {
        
        FreightAWBPopUpController obj = new FreightAWBPopUpController();   
        list<Freight_AWBResponseParsing.shipmentHistory> lsList = new list<Freight_AWBResponseParsing.shipmentHistory>();
        
        
        system.debug('@@ Opportunity Id @@ '+ OpportunityID);
        // Querying Opportunity to retrieve AWB Number
        Opportunity OpportunityRecord     = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                            Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                            Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                            FROM Opportunity WHERE Id =: OpportunityID WITH USER_MODE]; //CRM-10359 added WITH USER_MODE for Code Security Remediation
        
        // iCargo AWB Details Credentials retrieval from Custom setting
        //Integration_User_Tradesite__c freightIcargoUserDetails = Integration_User_Tradesite__c.getValues('Freight_iCargo_Integration');        
        
        // Parameters to be passed for authentication in Qsova
        //String username     = freightIcargoUserDetails.UserName__c;             
        //String password     = freightIcargoUserDetails.Password__c;         
        //string requestJson;
        
        // Checking availability of AWB Number, accordingly requesting 
        //if(String.isNotBlank(OpportunityRecord.Freight_AWB_Number__c)){
           // requestJson = getRequestString(username, password, OpportunityRecord.Freight_AWB_Number__c);
        //}
        if(String.isBlank(OpportunityRecord.Freight_AWB_Number__c)){
            // show error AWB Number not provided. Lighting work to be done
            obj.msg = 'AWB Number not provided for the Opportunity';
            obj.isSuccess = false;
            obj.ControllerOpportunity = OpportunityRecord;
            return obj;
        }
        
        //system.debug(' @@ j2Apex.sample string @@ ' + requestJson);
        
        try{
            Boolean responseSuccess;
            String AWB=OpportunityRecord.Freight_AWB_Number__c;
            HttpResponse res = getAWBResponse(AWB);        
            System.debug('response VALUES' +res.getBody());
            //check here for res=500-/getbody not null CRM-5487
            if(res.getStatusCode() == 200 && res.getbody() != null){
                responseSuccess = true;
            }
            else if(res.getStatusCode() == 400){
                res = getAWBResponse(AWB);
                if(res.getStatusCode() == 200 && res.getbody() != null)
                    responseSuccess = true;
                else if(res.getStatusCode() == 400)
                    responseSuccess = false;
            }
            else{ // Added additional Status code check to cover statuscode=500 - CRM 7487
                responseSuccess = false;
            }
            if(responseSuccess)
            {
                Freight_AWBResponseParsing awbResponseParsed = Freight_AWBResponseParsing.parse(res.getBody());        
                lsList = awbResponseParsed.shipmentHistory;
                obj.LatestStatusString = JSON.serialize(lsList);
                OpportunityRecord = returnParsedOpptyMember(res.getBody(), OpportunityRecord);
                OpportunityRecord.Freight_AWB_Status__c = 'Information Received';
                OpportunityRecord.Latest_Status__c = system.now();
                UPDATE as user OpportunityRecord; //CRM-10359 CRUD check before DML
                
                obj.isSuccess = true;
                //obj.msg='';
                obj.ControllerOpportunity = OpportunityRecord;
                return obj;
            }
            else{
                obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+OpportunityRecord.Freight_AWB_Number__c; //CRM-7487
                obj.isSuccess = false;
                obj.ControllerOpportunity = OpportunityRecord;
                return obj;
                
            }
            
        }
        catch (JSONException jsonExcep){
            system.debug(' @@ No Response @@ ' + jsonExcep);
            OpportunityRecord.Freight_AWB_Status__c = 'Information Not Available';
            UPDATE as user OpportunityRecord; //CRM-10359 CRUD check before DML
            
            obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+OpportunityRecord.Freight_AWB_Number__c;
            obj.isSuccess = true;
            obj.ControllerOpportunity = OpportunityRecord;
            return obj;
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getAWBResponse
Description:        Method for fetching HTTPResponse from iCargo system 
Parameter:          JSON response String , Integration_User_Tradesite__c custom setting
--------------------------------------------------------------------------------------*/
  /* public static HTTPResponse getAWBResponseOppty(string requestJson, Integration_User_Tradesite__c freightIcargoUserDetails,String AWB){
        
        // Parameters to be passed for authentication in Qsova
        String username     = freightIcargoUserDetails.UserName__c;             
        String password     = freightIcargoUserDetails.Password__c; 
        String dynamicURL=AWB;
        string endPoint     = freightIcargoUserDetails.Endpoint__c+''+dynamicURL;
        System.debug('Endpoint***'+endPoint);
        // Http request parameter declaration
        string method='GET';
        
        
        String accessToken;
        accessToken = Freight_AuthenticateAPIGateWay.returnAccessToken();
        
        system.debug(' @@ accessToken Recieved  @@ -- ' + accessToken);
        // Http Request formation to be sent to iCargo system.
        HttpRequest req     = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setBody(requestJson);
        req.setHeader('Authorization','Bearer ' + accessToken);
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        
        // Http Response requested from iCargo system.
        Http http           = new Http();
        HTTPResponse res    = new HTTPResponse();
        res    = http.send(req);
        return res;
    }*/
    
    /*--------------------------------------------------------------------------------------      
Method Name:        returnParsedOpportuntiy
Description:        Method for values from iCargo system and update record values for Case
Parameter:          Opportunity Record , JSON response String
--------------------------------------------------------------------------------------*/
   @AuraEnabled
    public static Opportunity returnParsedOpptyMember(string jsonResponse, Opportunity OpportunityRecord){
        system.debug('Json***'+jsonResponse);
        Freight_AWBResponseParsing awbResponseParsed = Freight_AWBResponseParsing.parse(jsonResponse);
        
        
        if(awbResponseParsed.shipmentSummary.statedWeight != null){//Jira CRM-8081
            OpportunityRecord.Freight_Weight__c = awbResponseParsed.shipmentSummary.statedWeight;    
        }
        
        
        
        if(awbResponseParsed.shipmentSummary.handlingCodes != null){
            OpportunityRecord.Freight_AWB_Handling_Code__c = awbResponseParsed.shipmentSummary.handlingCodes;    
        }
      
        //Jira CRM-6919
        // Retrieving Pieces Info
        if(awbResponseParsed.shipmentSummary.statedPieces != null){//Jira CRM-8081
            OpportunityRecord.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.shipmentSummary.statedPieces);    
        }
        
        
        
        if(awbResponseParsed.shipmentSummary.origin != null){//Jira CRM-8081
            OpportunityRecord.Freight_Origin__c = awbResponseParsed.shipmentSummary.origin;    
        }
        
        if(awbResponseParsed.shipmentSummary.destination  != null){//Jira CRM-8081
            OpportunityRecord.Freight_Destination__c = awbResponseParsed.shipmentSummary.destination ;    
        }
        
        
        //Jira CRM-6919
        //Retrieving shipmentDescription Info
        if(awbResponseParsed.shipmentSummary.shipmentDescription  != null){
            OpportunityRecord.Freight_AWB_Shipment_Description__c = awbResponseParsed.shipmentSummary.shipmentDescription ;    
        }
        
        
        //Jira CRM-6919
        //Retrieving weightUnit Info
        if(awbResponseParsed.unitOfMeasures.weight != null){
            OpportunityRecord.Freight_AWB_Weight_Unit__c = awbResponseParsed.unitOfMeasures.weight;    
        } 
        
        //Retrieving weightUnit Info
        
        for(Freight_AWBResponseParsing.shipmentHistory uidnum:awbResponseParsed.shipmenthistory){
            if(String.isNotBlank(uidnum.eventDetails.uldNumber)){
                OpportunityRecord.Freight_AWB_Unit_Type__c = uidnum.eventDetails.uldNumber ;    
            }
        }
        return OpportunityRecord;
    } 
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRequestString
Description:        Method to get json String from AWB Request class 
Parameter:          String userName , password and Awb number
--------------------------------------------------------------------------------------*/
    /*@AuraEnabled
    public static string getRequestStringOppty(string userName, string Password, string awbNumber){
        
        // Parameters to be passed for AWB Number
        string shipmentPrefix = awbNumber.substringBefore('-');
        string masterDocNumber = awbNumber.substringAfter('-');
        
        // Parameters to generate startdate and expiry date for Request message
        Datetime befcdformat = System.now();
        String creationDate = string.valueOfGmt(befcdformat);
        CreationDate = CreationDate.replace(' ', 'T' )+ 'Z';
        befcdformat = System.now().addMinutes(10);
        String expireDate = string.valueOfGmt(befcdformat);
        expireDate = expireDate.replace(' ', 'T' )+ 'Z';
        
        // Initialising class 
        Freight_AWBRequestJson awbRequestJson                       = new Freight_AWBRequestJson();
        awbRequestJson.Shipments                                    = new Freight_AWBRequestJson.Shipments();
        
        // Setting up Authentication details
        awbRequestJson.Shipments.AuthorisationToken                 = new Freight_AWBRequestJson.AuthorisationToken();
        awbRequestJson.Shipments.AuthorisationToken.username        = username;
        awbRequestJson.Shipments.AuthorisationToken.password        = password;
        awbRequestJson.Shipments.AuthorisationToken.MessageCreationDateTime = creationDate;
        awbRequestJson.Shipments.AuthorisationToken.MessageExpireDateTime   = expireDate;
        
        // Setting up AWB request parameter
        awbRequestJson.Shipments.TrackingFilters                    = new Freight_AWBRequestJson.TrackingFilters();
        awbRequestJson.Shipments.TrackingFilters.shipmentPrefix     = shipmentPrefix;
        awbRequestJson.Shipments.TrackingFilters.masterDocumentNumber = masterDocNumber;
        
        // return json string to be sent as request to iCargo
        return awbRequestJson.convertToJsonString(awbRequestJson);
        
    }  */
    
    
}