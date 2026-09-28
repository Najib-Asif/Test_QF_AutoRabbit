/*----------------------------------------------------------------------------------------------------------------------
Author:        Raj Sharma
Company:       Publicis
Description:   Class used for AWB Details tile for lightning component
Test Class:    FreightAWBPopUpControllerTest    
*********************************************************************************************************************************
History
22-Nov-2018   Raj                Initial Design
14-May-2019   Vinoth             Commented the code for not executing through Test Class
10-June-2026	Lerry Cabanding		//CRM-10380 Code Security Remediation

********************************************************************************************************************************/
global class FreightAWBCampaignController {
    
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    
    @AuraEnabled
    public String msg { get; set; }
    
    @AuraEnabled
    public CampaignMember ControllerCampaignMember { get; set; }
    
    @AuraEnabled
    public String LatestStatusString {get;set;}
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getBeforeAWBDetails
Description:        Method for getting static AWB Details tile for CampaignMember
Parameter:          CampaignMember Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static CampaignMember getBeforeAWBDetails(Id CampaignMemberId){
        try{
        CampaignMember CampaignMemberRecord = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                               Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                               Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                               FROM CampaignMember WHERE Id =: CampaignMemberId WITH SYSTEM_MODE]; //Added WITH SYSTEM_MODE for CRM-10380 Code Security Remediation
        
        return CampaignMemberRecord;
        } catch (QueryException e) { //CRM-10380 Added QueryException for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAWBCampaignController', 'FreightAWBCampaignController', 
                        'getBeforeAWBDetails', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
            String msg = 'You don\'t have access to these fields: ' + inaccessibleFields.keySet() + ': ' + inaccessibleFields.values();
            throw new AuraHandledException(msg);
        }
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRecordUpdate
Description:        Method for getting AWB Refresh values from iCargo system and table content 
and update record values for CampaignMember
Parameter:          CampaignMember Id
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static FreightAWBCampaignController getRecordUpdate(Id CampaignMemberId)
    {
        FreightAWBCampaignController obj = new FreightAWBCampaignController();
        //list<Freight_AWBResponseParsing.LatestStatus> lsList = new list<Freight_AWBResponseParsing.LatestStatus>();
         list<Freight_AWBResponseParsing.shipmentHistory> lsList = new list<Freight_AWBResponseParsing.shipmentHistory>();
        system.debug('@@ CampaignMember Id @@ '+ CampaignMemberId);
        // Querying CampaignMember to retrieve AWB Number
        CampaignMember CampaignMemberRecord     = [SELECT Id, Freight_AWB_Number__c, Freight_Weight__c,Freight_AWB_Pieces__c,Latest_Status__c,
                                                   Freight_AWB_Handling_Code__c, Freight_Origin__c, Freight_Destination__c,
                                                   Freight_AWB_Shipment_Description__c,Freight_AWB_Weight_Unit__c,Freight_AWB_Unit_Type__c
                                                   FROM CampaignMember WHERE Id =: CampaignMemberId WITH SYSTEM_MODE]; //CRM-10380 Code Security Remediation
        
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
            Boolean responseSuccess;
            String AWB=CampaignMemberRecord.Freight_AWB_Number__c;
            //HttpResponse res = getAWBResponse(requestJson, freightIcargoUserDetails);  
              HttpResponse res = getAWBResponse(requestJson, freightIcargoUserDetails,AWB);          
            System.debug('response VALUES' +res.getBody());
            
            if(res.getStatusCode() == 200){
                responseSuccess = true;
            }
            else if(res.getStatusCode() == 400){
                //res = getAWBResponse(requestJson, freightIcargoUserDetails);
                 res = getAWBResponse(requestJson, freightIcargoUserDetails,AWB);
                if(res.getStatusCode() == 200)
                    responseSuccess = true;
                else if(res.getStatusCode() == 400)
                    responseSuccess = false;
            }
            
            if(responseSuccess)
            {
                system.debug('Res.getbody###'+res.getBody());
                Freight_AWBResponseParsing awbResponseParsed = (Freight_AWBResponseParsing) System.JSON.deserialize(res.getBody(), Freight_AWBResponseParsing.class);//CRM-6919
                
                System.debug('awbResponseParsed'+awbResponseParsed);
                lsList =awbResponseParsed.shipmentHistory;
                //Freight_AWBResponseParsing awbResponseParsed = Freight_AWBResponseParsing.parse(res.getBody());        
                //lsList = awbResponseParsed.ShipmentMilestones.shipmentsTracked.history;
                system.debug('lsList'+lsList);
                obj.LatestStatusString = JSON.serialize(lsList);
                system.debug(' @@ Latest Status List @@ ' + obj.LatestStatusString);
                
                CampaignMemberRecord = returnParsedCampaignMember(res.getBody(), CampaignMemberRecord);
                CampaignMemberRecord.Freight_AWB_Status__c = 'Information Received';
                CampaignMemberRecord.Latest_Status__c = system.now();
                
                system.debug('CampaignMember rec***'+CampaignMemberRecord);
                update as system CampaignMemberRecord; //CRM-10380 Added as system for Code Security Remediation
                
                obj.isSuccess = true;
                //obj.msg='';
                obj.controllerCampaignMember = CampaignMemberRecord;
                return obj;
            }
            else{
                // error message for false
                obj.msg = 'Contact Relevant IT Team';
                obj.isSuccess = false;
                obj.ControllerCampaignMember = CampaignMemberRecord;
                return obj;
            }
            
        }
        catch (JSONException jsonExcep){
            system.debug(' @@ No Response @@ ' + jsonExcep);
            CampaignMemberRecord.Freight_AWB_Status__c = 'Information Not Available';
            update as system CampaignMemberRecord; //CRM-10380 Added as system for Code Security Remediation
            
            obj.msg = 'Tracking Information is not available with the iCargo system for the provided AWB Number :- '+CampaignMemberRecord.Freight_AWB_Number__c;
            obj.isSuccess = true;
            obj.ControllerCampaignMember = CampaignMemberRecord;
            return obj;
        } catch (Exception e) { //CRM-10380 Added Exception for Code Security Remediation
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'FreightAWBCampaignController', 'FreightAWBCampaignController', 
                        'getRecordUpdate', String.valueOf(''), String.valueOf(''),false,'', e);
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getAWBResponse
Description:        Method for fetching HTTPResponse from iCargo system 
Parameter:          JSON response String , Integration_User_Tradesite__c custom setting
--------------------------------------------------------------------------------------*/
    public static HTTPResponse getAWBResponse(string requestJson, Integration_User_Tradesite__c freightIcargoUserDetails,String AWB){//CRM-6919
        system.debug('AWB number##'+AWB);
        // Parameters to be passed for authentication in Qsova
        String username     = freightIcargoUserDetails.UserName__c;             
        String password     = freightIcargoUserDetails.Password__c; 
        System.debug('freightIcargoUserDetails Endpoint'+freightIcargoUserDetails.Endpoint__c);
        // Http request parameter declaration
        String dynamicURL=AWB;
        string endPoint     = freightIcargoUserDetails.Endpoint__c+''+dynamicURL;//CRM-6919
        System.debug('Endpoint***'+endPoint);
        string method       = 'GET';
        //string endPoint     = freightIcargoUserDetails.Endpoint__c; 
        //string method       = 'POST';
        
        String accessToken;
        accessToken = Freight_AuthenticateAPIGateWay.returnAccessToken();
        
        system.debug(' @@ accessToken Recieved  @@ -- ' + accessToken);
        // Http Request formation to be sent to iCargo system.
        HttpRequest req     = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(method);
        //req.setBody(requestJson);
        req.setHeader('Authorization','Bearer ' + accessToken);
        req.setHeader('Content-Type','application/json');
        //req.setHeader('accept','application/json');
        // req.setHeader('Accept-Encoding','deflate');
        
        system.debug(' @@ request @@ -- ' + req);
        
        // Http Response requested from iCargo system.
        Http http           = new Http();
        HTTPResponse res    = new HTTPResponse();
        
        /*if(!Test.isRunningTest()){
            res    = http.send(req);
            return res;
        }*/
        
        res    = http.send(req);
        return res;
        
        //return null;        
        
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        returnParsedCampaignMember
Description:        Method for values from iCargo system and update record values for Case
Parameter:          CampaignMember Record , JSON response String
--------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static CampaignMember returnParsedCampaignMember(string jsonResponse, CampaignMember CampaignMemberRecord){//CRM-6919
        
        System.debug('json***'+jsonResponse);
        Freight_AWBResponseParsing awbResponseParsed = (Freight_AWBResponseParsing) System.JSON.deserialize(jsonResponse, Freight_AWBResponseParsing.class);
          
        /* Retrieving Weight Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.weight != null){
            CampaignMemberRecord.Freight_Weight__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.weight;    
        }
        if(awbResponseParsed.shipmentSummary.totalWeight != null){
            CampaignMemberRecord.Freight_Weight__c = awbResponseParsed.shipmentSummary.totalWeight;    
        }*/
        if(awbResponseParsed.shipmentSummary.statedWeight != null){//CRM-8081
            CampaignMemberRecord.Freight_Weight__c = awbResponseParsed.shipmentSummary.statedWeight;    
        }
        /*Retrieving HandlingCOde Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.handlingCode != null){
            CampaignMemberRecord.Freight_AWB_Handling_Code__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.handlingCode;    
        }*/
        if(awbResponseParsed.shipmentSummary.handlingCodes != null){
            CampaignMemberRecord.Freight_AWB_Handling_Code__c = awbResponseParsed.shipmentSummary.handlingCodes;    
        }
        /* Retrieving Pieces Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.pieces != null){
            CampaignMemberRecord.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.ShipmentMilestones.shipmentsTracked.pieces);    
        }
        if(awbResponseParsed.shipmentSummary.totalPieces != null){
            CampaignMemberRecord.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.shipmentSummary.totalPieces);    
        }*/
        if(awbResponseParsed.shipmentSummary.statedPieces != null){//CRM-8081
            CampaignMemberRecord.Freight_AWB_Pieces__c = Decimal.valueOf(awbResponseParsed.shipmentSummary.statedPieces);    
        }
        /* Retrieving Origin Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.origin != null){
            CampaignMemberRecord.Freight_Origin__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.origin;    
        }
        if(awbResponseParsed.shipmentSummary.shipmentOriginName != null){
            CampaignMemberRecord.Freight_Origin__c = awbResponseParsed.shipmentSummary.shipmentOriginName;    
        }*/
        if(awbResponseParsed.shipmentSummary.origin != null){//CRM-8081
            CampaignMemberRecord.Freight_Origin__c = awbResponseParsed.shipmentSummary.origin;    
        }
        
        /* Retrieving Destination Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.destination != null){
            CampaignMemberRecord.Freight_Destination__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.destination;    
        }
        if(awbResponseParsed.shipmentSummary.shipmentDestinationName != null){
            CampaignMemberRecord.Freight_Destination__c = awbResponseParsed.shipmentSummary.shipmentDestinationName;    
        }*/
        if(awbResponseParsed.shipmentSummary.destination != null){
            CampaignMemberRecord.Freight_Destination__c = awbResponseParsed.shipmentSummary.destination;    
        }
        /* Retrieving shipmentDescription Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.shipmentDescription != null){
            CampaignMemberRecord.Freight_AWB_Shipment_Description__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.shipmentDescription;    
        }*/
        if(awbResponseParsed.shipmentSummary.shipmentDescription  != null){
            CampaignMemberRecord.Freight_AWB_Shipment_Description__c = awbResponseParsed.shipmentSummary.shipmentDescription ;    
        }
        /* Retrieving weightUnit Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.weightUnit != null){
            CampaignMemberRecord.Freight_AWB_Weight_Unit__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.weightUnit;    
        } */      
        if(awbResponseParsed.unitOfMeasures.weight != null){
            CampaignMemberRecord.Freight_AWB_Weight_Unit__c = awbResponseParsed.unitOfMeasures.weight;    
        }
        /* Retrieving weightUnit Info
        if(awbResponseParsed.ShipmentMilestones.shipmentsTracked.units != null){
            CampaignMemberRecord.Freight_AWB_Unit_Type__c = awbResponseParsed.ShipmentMilestones.shipmentsTracked.units;    
        } */      
        
        return CampaignMemberRecord;
    } 
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRequestString
Description:        Method to get json String from AWB Request class 
Parameter:          String userName , password and Awb number
--------------------------------------------------------------------------------------*/
    @AuraEnabled
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
        
    }    
    
}