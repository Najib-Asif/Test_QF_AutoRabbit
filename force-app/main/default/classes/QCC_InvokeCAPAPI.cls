/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Description:   Webservice Class to Invoke CAP System
Inputs:
Test Class:     QCC_InvokeCAPAPITest - 76%
************************************************************************************************
History
************************************************************************************************
27-Oct-2017      Praveen Sampath               Initial Design
11-Sep-2019      Leslie May Padilla             Added method (invokeFlightStatusDepsAPI) to call out the Flight Status API based on departure port and departure date
17-Sep-2019      Francis Bagtas                 Added method (invokeRetrieveCustomerFlightsAPI) to callout and retrieve Customer Flights
20-Sep-2019      Raymart Tolentino              Added method (invokeLoyaltySendSMSAPI) to send the actual callout that will send the SMS message through LivePerson
25-Oct-2019      Raymart Tolentino              Added method (getAPIGatewayValidToken) to get all fee waiver related to ff number
30-Oct-2019      Raymart Tolentino              Updated invokeFlightPassengerAPI to add a new parameter in the endpoint
06-Dec-2019      Lora Mae Dapulang              Added method (modifyJSON) to modify JSONresponse to be able to deserialize Salesforce reserved words
26-Dec-2019      Raymart Tolentino              Rename the invokeLoyaltySendSMSAPI to invokeLivePersonSendSMSAPI
04-Apr-2023      Jamie Wang               Added method (invokeLoyaltyRawContact) to get ff contact form loyalty
14-Apr-2023      Van Cabezas               Added method (invokeBookingTicketCAPAPI,invokeProductFlightCAPAPI,invokeLoyaltyRawProfileAPI,invokeLoyaltyRawContact,invokeQCCAccountAPI,invokeQCCProgramAPI,invokeQCCTierAPI) to get ff contact Details
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_InvokeCAPAPI {

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeTokenCapAPI
    Description:        Invoke authorization Token from CAP system
    Parameter:          Custom Setting
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CAPTokenWrapper invokeTokenCapAPI( Qantas_API__c qantasAPI ){
        HTTPRequest req=new HTTPRequest();
        req.setEndpoint(qantasAPI.EndPoint__c);
        req.setHeader('client_id',qantasAPI.ClientId__c);
        req.setHeader('client_secret',qantasAPI.ClientSecret__c);
        req.setHeader('grant_type',qantasAPI.GrantType__c);
        req.setMethod(qantasAPI.Method__c); 
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(req);
        QCC_CAPTokenWrapper token;
        if(response.getStatusCode() == 200){
           token = (QCC_CAPTokenWrapper) System.JSON.deserialize(response.getBody(), QCC_CAPTokenWrapper.class);
        }        
        return token;        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeTokenAPIGateway
    Description:        Invoke authorization Token for API Gateway(New Encrption logic)
    Parameter:          Custom Setting
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CAPTokenWrapper invokeTokenAPIGateway( Qantas_API__c qantasAPI ){
        system.debug('inside invokeTokenAPIGateway'+qantasAPI);
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(qantasAPI.EndPoint__c);
        Blob auth = Blob.valueOf(qantasAPI.ClientId__c+':'+qantasAPI.ClientSecret__c);
        String authEncode =  EncodingUtil.base64Encode(auth);
        req.setHeader('Authorization','Basic '+authEncode);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST'); 
        req.setTimeout(120000);
        String body = 'grant_type='+qantasAPI.GrantType__c;
        // Check Scope
        if(!String.isBlank(qantasAPI.Scope__c)){
            body += '&scope=' + qantasAPI.Scope__c;

            //GRAPHITE-2454 Include the QCC_Extended_Scope__c as part of the Scope when generating the token.
            if(!String.isBlank(qantasAPI.QCC_Extended_Scope__c)){
                body += qantasAPI.QCC_Extended_Scope__c;
            }
        }

        body += '&validity_period=172800';
        req.setBody(body);

        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug('response.getBody(): '+response.getBody());
        system.debug('response.getStatusCode()'+response.getStatusCode());
        QCC_CAPTokenWrapper token;
        system.debug('QCC_CAPTokenWrapper'+token);
        if(response.getStatusCode() == 200){
           system.debug('inside if');
          token = (QCC_CAPTokenWrapper) System.JSON.deserialize(response.getBody(), QCC_CAPTokenWrapper.class);
           //token = (QCC_CAPTokenWrapper) JSON.deserialize(response.getBody(), QCC_CAPTokenWrapper.class);
           system.debug('after token deserialise'+token);
        }
        system.debug('token123'+token);
        return token;
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        invokeTokenLoyaltyAPI
    Description:        Invoke authorization Token from CAP system
    Parameter:          Custom Setting
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CAPTokenWrapper invokeTokenLoyaltyAPI( Qantas_API__c qantasAPI ){
        HTTPRequest req=new HTTPRequest();
        req.setEndpoint(qantasAPI.EndPoint__c);
        req.setHeader('client_id',qantasAPI.ClientId__c);
        req.setHeader('client_secret',qantasAPI.ClientSecret__c);
        req.setHeader('grant_type',qantasAPI.GrantType__c);
        req.setMethod(qantasAPI.Method__c); 
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        QCC_CAPTokenWrapper token = (QCC_CAPTokenWrapper) System.JSON.deserialize(response.getBody(), QCC_CAPTokenWrapper.class);
        
        return token;        
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeCustomerDetailCAPAPI
    Description:        Fetch Customer address Information from CAP system
    Parameter:          QCC_CustomerDetailsRequest
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CustomerDetailsResponse.Response invokeCustomerDetailCAPAPI(QCC_CustomerDetailsRequest capReqBody) {
        
         //Callout using Named credential CRM-9361
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            
            Http callOut = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:QCC_CAPDetailsAPI');
            request.setMethod('POST'); 
            
            // A map of existing key to replacement key
            Map<String, String> replacementsReq = new Map<String, String> {'system_z' => 'system'};            
            String reqStr = QCC_GenericUtils.mogrifyJSON(JSON.serialize(capReqBody, true), replacementsReq);
            request.setBody(reqStr);
            system.debug('request########'+request);
            system.debug('requestBody########'+request.getBody());
            HttpResponse response =  callOut.send(request);
            system.debug('response$$$$$$$'+response);
            system.debug('Response Boy######'+response.getBody());
            
            if(response.getStatusCode() == 200){
                QCC_CustomerDetailsResponse.Response custResp = (QCC_CustomerDetailsResponse.Response) System.JSON.deserialize(response.getBody(), QCC_CustomerDetailsResponse.Response.class);
                return custResp;
            } 
          }
        
          //Callout using QantasAPI object.
        else{
            
            String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
            if(String.isBlank(token)) return null;
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPDetailsAPI');
            
            Http callOut = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(qantasAPI.EndPoint__c);
            request.setMethod(qantasAPI.Method__c); 
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', token);
            
            // A map of existing key to replacement key
            Map<String, String> replacementsReq = new Map<String, String> {'system_z' => 'system'};            
            String reqStr = QCC_GenericUtils.mogrifyJSON(JSON.serialize(capReqBody, true), replacementsReq);
            request.setBody(reqStr);
            system.debug('request########'+request);
            system.debug('requestBody########'+request.getBody());
            HttpResponse response =  callOut.send(request);
            
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                request.setHeader('Authorization', token);
                response = callOut.send(request);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
            }
            system.debug('response$$$$$$$'+response);
            system.debug('Response Boy######'+response.getBody());
            
            if(response.getStatusCode() == 200){
                QCC_CustomerDetailsResponse.Response custResp = (QCC_CustomerDetailsResponse.Response) System.JSON.deserialize(response.getBody(), QCC_CustomerDetailsResponse.Response.class);
                return custResp;
            } 
        }
        
        return null;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeTransactionCAPAPI
    Description:        Customer Transaction Summary from CAP system
    Parameter:          CustomerTransactionRequest
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_CAPTransactionWrapper.CAPTransactionResponse invokeTransactionCAPAPI(QCC_CAPTransactionWrapper.CAPTransactionRequest qccCapTransactionreq) {
        
        //Callout using Named credential CRM-9361
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            String body = JSON.serialize(qccCapTransactionreq, true);
            body = body.replace('system_x', 'system');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();        
            req.setEndpoint('callout:QCC_CAPCustomerTransAPI');
            req.setMethod('POST'); 
            req.setBody(body);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            system.debug('response#########'+response);
            system.debug('response Body#########'+response.getBody());
            system.debug('req#########'+req);
            system.debug('req body#########'+req.getBody());
    
            if(response.getStatusCode() == 200){
                QCC_CAPTransactionWrapper.CAPTransactionResponse responseWrap = (QCC_CAPTransactionWrapper.CAPTransactionResponse)JSON.deserialize(response.getBody(), QCC_CAPTransactionWrapper.CAPTransactionResponse.class);
                return responseWrap; 
            } 
            }    
        
         //Callout using Named credential CRM-9361
        else{
            
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPCustomerTransAPI');
            String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
            if(String.isBlank(token)) return null;
                
            String body = JSON.serialize(qccCapTransactionreq, true);
            body = body.replace('system_x', 'system');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();        
            req.setEndpoint(qantasAPI.EndPoint__c);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', token);
            req.setBody(body);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
            }
            system.debug('response#########'+response);
            system.debug('response Body#########'+response.getBody());
            system.debug('req#########'+req);
            system.debug('req body#########'+req.getBody());
    
            if(response.getStatusCode() == 200){
                QCC_CAPTransactionWrapper.CAPTransactionResponse responseWrap = (QCC_CAPTransactionWrapper.CAPTransactionResponse)JSON.deserialize(response.getBody(), QCC_CAPTransactionWrapper.CAPTransactionResponse.class);
                return responseWrap; 
            } 
            }
        
        return null;      
    }
    /* Commented below method as part of Member API V2 Changes CRM - 5003  */
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyAPI
    Description:        Fetch Booking Summary Information from CAP system
    Parameter:          
    -------------------------------------------------------------------------------------- 
    
        public static  QCC_LoyaltyResponseWrapper invokeLoyaltyAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+ffNumber+'/profile';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());
        QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            QCC_LoyaltyResponseWrapper formattedJSON = (QCC_LoyaltyResponseWrapper)JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.class);
            system.debug('formattedJSON Body#########'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
  /* -----------------End of Comment CRM-5003 ------------------------------ */
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyPostAPI
    Description:        Fetch Booking Summary Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
      /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyPostAPI
    Description:        Fetch Booking Summary Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static  Boolean invokeLoyaltyPostAPIResponse(String ffNumber, LoyaltyRequestWrapper loyaltyReq) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAccrualAPI');
        String body = JSON.serialize(loyaltyReq, true);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+ffNumber+'/accrual';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setBody(body);
        req.setTimeout(120000);
        System.debug('Request :' +  req);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            return true;
        } 
        return false; 
    }
    public static  HttpResponse invokeLoyaltyPostAPI(String ffNumber, LoyaltyRequestWrapper loyaltyReq) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAccrualAPI');
        String body = JSON.serialize(loyaltyReq, true);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+ffNumber+'/accrual';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setBody(body);
        req.setTimeout(120000);
        System.debug('Request :' +  req);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        /*if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            return true;
        } */
        return response; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRFlightInfoCAPAPI
    Description:        Fetch Booking Flight Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRFlightInfoWrapper invokePNRFlightInfoCAPAPI(String pnr, string creationDate,String token, Boolean isHistory, String archivalData){
        
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/flights?creationDate='+creationDate+'&archivalData='+archivalData;
            if(isHistory){
                dynamicURL = '/'+pnr+'/flights?creationDate='+creationDate+'&deleted=true&archivalData=true';
            }
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);  
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRFlightInfoWrapper pnrBooking = (QCC_PNRFlightInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRFlightInfoWrapper.class);
                system.debug('QCC_PNRFlightInfoWrapper#########'+pnrBooking);
                return pnrBooking;
            }
        }
		*/
        //else{
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL =(qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/flights?creationDate='+creationDate+'&archivalData='+archivalData;
            if(isHistory){
                dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/flights?creationDate='+creationDate+'&deleted=true&archivalData=true';
            }
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
            
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRFlightInfoWrapper pnrBooking = (QCC_PNRFlightInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRFlightInfoWrapper.class);
                system.debug('QCC_PNRFlightInfoWrapper#########'+pnrBooking);
                return pnrBooking;
            }
        // }
        return null; 
    }
        
       
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRFlightInfoCAPAPI
    Description:        Fetch Booking Flight Information from CAP system Jira: CRM-8119
    Parameter:          PNR, Lastname, token, archivalData
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRFlightInfoWrapper invokePNRFlightInfoCAPAPI(String pnr, string lastName, String token, String archivalData) {
        return invokePNRFlightInfoCAPAPI(pnr, lastName, token, archivalData, false);
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRFlightInfoCAPAPI
    Description:        Fetch Booking Flight Information from CAP system
    Parameter:          PNR, Lastname, token, isHistory, archivalData
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRFlightInfoWrapper invokePNRFlightInfoCAPAPI(String pnr, string lastName, String token, String archivalData, Boolean isHistory){
         
       if(String.isBlank(pnr) || String.isBlank(lastName)){
            return null;
        }
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
        //lastName = lastName.replaceALL('[^a-zA-Z0-9]',' ');[INC2757865-for this INC we have commented this line [In this line we are replacing the special characters into space so the url is not correctly]]
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/flights?lastName='+lastName.toUpperCase()+'&archivalData='+archivalData;
         
        //Jira: CRM-8119
        if(isHistory) {
            dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/flights?lastName='+lastName.toUpperCase()+'&deleted=true&archivalData=true';
          
        }
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        system.debug('response Body#########'+response);
        system.debug(response);
        
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
        }
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_PNRFlightInfoWrapper pnrBooking = (QCC_PNRFlightInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRFlightInfoWrapper.class);
            system.debug('QCC_PNRFlightInfoWrapper#########'+pnrBooking);
            return pnrBooking;
        }
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRPassengerInfoCAPAPI
    Description:        Fetch Booking Passenger Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRPassengerInfoWrapper invokePNRPassengerInfoCAPAPI(String pnr, string creationDate, String token, String archivalData){
		system.debug('archivalData---'+archivalData);
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/passengers?creationDate='+creationDate+'&archivalData='+archivalData;
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+''+dynamicURL;
            system.debug('dynamicURL---'+dynamicURL);
            system.debug('endpointURL---'+endpointURL);
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
                            
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRPassengerInfoWrapper pnrPassenger = (QCC_PNRPassengerInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRPassengerInfoWrapper.class);
                system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
                return pnrPassenger;
            }
            }
*/
        //else{
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/passengers?creationDate='+creationDate+'&archivalData='+archivalData;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
                    
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
            
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRPassengerInfoWrapper pnrPassenger = (QCC_PNRPassengerInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRPassengerInfoWrapper.class);
                system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
                return pnrPassenger;
            }
        //}
        return null; 
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRPassengerInfoCAPAPI
    Description:        Fetch Booking Passenger Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRPassengerInfoWrapper invokePNRPassengerInfoCAPAPI(String pnr, String token, String lastName){
        /*
         if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
             
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/passengers?lastName='+lastName;
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
           
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRPassengerInfoWrapper pnrPassenger = (QCC_PNRPassengerInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRPassengerInfoWrapper.class);
                system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
                return pnrPassenger;
            }
        }
*/
         //else{
			Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/passengers?lastName='+lastName;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
           
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRPassengerInfoWrapper pnrPassenger = (QCC_PNRPassengerInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRPassengerInfoWrapper.class);
                system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
                return pnrPassenger;
            }
    
            //}
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRContactInfoCAPAPI
    Description:        Fetch Booking Contact Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRContactInfoWrapper invokePNRContactInfoCAPAPI(String pnr, string creationDate, String token, String archivalData){
        
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/contacts?creationDate='+creationDate+'&archivalData='+archivalData;
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);    
    
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRContactInfoWrapper pnrContact = (QCC_PNRContactInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRContactInfoWrapper.class);
                system.debug('QCC_PNRContactInfoWrapper#########'+pnrContact);
                return pnrContact;
            }
        }
	*/
        
        //else{
             Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/contacts?creationDate='+creationDate+'&archivalData='+archivalData;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
    
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRContactInfoWrapper pnrContact = (QCC_PNRContactInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRContactInfoWrapper.class);
                system.debug('QCC_PNRContactInfoWrapper#########'+pnrContact);
                return pnrContact;
            }
           // }
           return null; 
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRContactInfoCAPAPI
    Description:        Fetch Booking Contact Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRContactInfoWrapper invokePNRContactInfoCAPAPI(String pnr,String token,String lastName){
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/contacts?lastName='+lastName;
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
         	system.debug('statuscode:' +response.getStatusCode());
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRContactInfoWrapper pnrContact = (QCC_PNRContactInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRContactInfoWrapper.class);
                system.debug('QCC_PNRContactInfoWrapper#########'+pnrContact);
                return pnrContact;
            }
        }
           */ 
        //else{
           Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/contacts?lastName='+lastName;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
    
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRContactInfoWrapper pnrContact = (QCC_PNRContactInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRContactInfoWrapper.class);
                system.debug('QCC_PNRContactInfoWrapper#########'+pnrContact);
                return pnrContact;
            } 
            //}
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRAncillaryInfoCAPAPI
    Description:        Fetch Booking Ancillary Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRAncillaryInfoWrapper invokePNRAncillaryInfoCAPAPI(String pnr, string creationDate,String token, String archivalData){
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
			 Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+pnr+'/ancillaries?creationDate='+creationDate+'&archivalData='+archivalData;
        String endpointURL = 'callout:QCC_CAPPNRRetrieve'+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
 
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_PNRAncillaryInfoWrapper pnrAncillary = (QCC_PNRAncillaryInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRAncillaryInfoWrapper.class);
            system.debug('QCC_PNRAncillaryInfoWrapper#########'+pnrAncillary);
            return pnrAncillary;
        }
        }
		*/
        
        //else{
			Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/ancillaries?creationDate='+creationDate+'&archivalData='+archivalData;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
            
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRAncillaryInfoWrapper pnrAncillary = (QCC_PNRAncillaryInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRAncillaryInfoWrapper.class);
                system.debug('QCC_PNRAncillaryInfoWrapper#########'+pnrAncillary);
                return pnrAncillary;
            }
        //}
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRLegStatusInfoCAPAPI
    Description:        Fetch Passer Leg Info from CAP Booking Service
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRLegStatusInfoWrapper invokePNRLegStatusInfoCAPAPI(String pnr, string creationDate, String passengerId, 
                                                                           String segmentId, String token, Boolean isHistory, String archivalData)
    {
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
             Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/legstatus?creationDate='+creationDate+ (String.isNotBlank(segmentId) ? '&segmentId='+segmentId : '') + (String.isNotBlank(passengerId) ? '&passengerId='+passengerId : '') +'&archivalData='+archivalData;
            
            if(isHistory){
                 dynamicURL = '/'+pnr+'/legstatus?creationDate='+creationDate+'&segmentTattoo='+segmentId+'&passengerTattoo='+passengerId+'&archivalData=true';
            }
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            
    
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRLegStatusInfoWrapper pnrLegStatus = (QCC_PNRLegStatusInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRLegStatusInfoWrapper.class);
                system.debug('pnrLegStatus#########'+pnrLegStatus);
                return pnrLegStatus;
            }

        }
		*/
        
        //else{
           Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = pnr+'/legstatus?creationDate='+creationDate+ (String.isNotBlank(segmentId) ? '&segmentId='+segmentId : '') + (String.isNotBlank(passengerId) ? '&passengerId='+passengerId : '') +'&archivalData='+archivalData;
            
            if(isHistory){
                 dynamicURL = pnr+'/legstatus?creationDate='+creationDate+'&segmentTattoo='+segmentId+'&passengerTattoo='+passengerId+'&archivalData=true';
            }
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRLegStatusInfoWrapper pnrLegStatus = (QCC_PNRLegStatusInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRLegStatusInfoWrapper.class);
                system.debug('pnrLegStatus#########'+pnrLegStatus);
                return pnrLegStatus;
            }
        //}
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRSSRInfoCAPAPI
    Description:        Fetch Passer SSr Info from CAP Booking Servivce
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PNRSSRInfoWrapper invokePNRSSRInfoCAPAPI(String pnr, string creationDate, String passengerId, 
                                                               String segmentId, string token, Boolean isHistory, String archivalData)
    {
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
			Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/ssr?creationDate='+creationDate+'&segmentId='+segmentId+'&passengerId='+passengerId+'&archivalData='+archivalData;
            if(isHistory){
                dynamicURL = '/'+pnr+'/ssr?creationDate='+creationDate+'&segmentTattoo='+segmentId+'&passengerTattoo='+passengerId+'&archivalData=true';
            }
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);  
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_PNRSSRInfoWrapper pnrSSR = (QCC_PNRSSRInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRSSRInfoWrapper.class);
                system.debug('QCC_PNRSSRInfoWrapper#########'+pnrSSR);
                return pnrSSR;
            }
        }
		*/
       // else{
        
       Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        String dynamicURL = pnr+'/ssr?creationDate='+creationDate+'&segmentId='+segmentId+'&passengerId='+passengerId+'&archivalData='+archivalData;

        if(isHistory){
            dynamicURL = pnr+'/ssr?creationDate='+creationDate+'&segmentTattoo='+segmentId+'&passengerTattoo='+passengerId+'&archivalData=true';
        }
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
        }

        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_PNRSSRInfoWrapper pnrSSR = (QCC_PNRSSRInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRSSRInfoWrapper.class);
            system.debug('QCC_PNRSSRInfoWrapper#########'+pnrSSR);
            return pnrSSR;
        }
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeBookingCAPAPI
    Description:        Fetch Booking Summary Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    //QCC_BookingSummaryAPI using 2 tokens: QCC_CAPToken and QCC_BookingToken

    public static QCC_BookingSummaryWrapper invokeBookingCAPAPI(String capID, String bookingPerPage, Integer pageNumber){
		
        //Callout using Named credential CRM-9361
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+capID+'/bookings/summary?bookingPerPage='+bookingPerPage+'&pageNumber='+pageNumber;
        String endpointURL = 'callout:QCC_BookingSummaryAPI'+dynamicURL;
        system.debug('>>>endpointURL: ' + endpointURL);
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        system.debug('>>>response.getStatusCode(): ' + response.getStatusCode());
        system.debug('>>>response message: ' + response.getStatus());
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_BookingSummaryWrapper bookingSummary = (QCC_BookingSummaryWrapper)JSON.deserialize(response.getBody(), QCC_BookingSummaryWrapper.class);
            system.debug('QCC_BookingSummaryWrapper#########'+bookingSummary);
            return bookingSummary;
        }    
        }
       
        //Callout using QantasAPI object.
        else{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
            if(String.isBlank(token)) return null;
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_BookingSummaryAPI');
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+capID+'/bookings/summary?bookingPerPage='+bookingPerPage+'&pageNumber='+pageNumber;
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            system.debug('>>>endpointURL: ' + endpointURL);
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
            }
            system.debug('>>>response.getStatusCode(): ' + response.getStatusCode());
            system.debug('>>>response message: ' + response.getStatus());
            if(response.getStatusCode() == 200){
                system.debug('response Body#########'+response.getBody());
                QCC_BookingSummaryWrapper bookingSummary = (QCC_BookingSummaryWrapper)JSON.deserialize(response.getBody(), QCC_BookingSummaryWrapper.class);
                system.debug('QCC_BookingSummaryWrapper#########'+bookingSummary);
                return bookingSummary;
            }     
        }
        
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRSSRInfoCAPAPI
    Description:        Fetch Passer SSr Info from CAP Booking Servivce
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_FlightPassengersResponse invokeFlightPassengerAPI(String flightNumber , Date scheduleDepDate , String departurePort , String arrivalPort, Integer pagNo)
    {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken');
        String updatedToken;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPassengersRetrieve');
        //CRM-6900: replacing qantas api with lable.
        String endpoint = System.Label.QCC_CAP_Passengers_Retrive_API;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        if(String.isBlank(flightNumber)) return null;
        System.debug('$$$scheduleDepDate ' + scheduleDepDate);
        System.debug('$$$flightNumber length ' + flightNumber.length());
        String operatingCarrier = flightNumber.substring(0,2);
        System.debug('$$$operatingCarrier ' + operatingCarrier);
        String operatingFlightNumber = flightNumber.substring(2);
        System.debug('$$$operatingFlightNumber ' + operatingFlightNumber);
        System.debug('$$$operatingCarrier ' + operatingCarrier);

        //if(scheduleDepDate == null) return null;
        String dateVal = GenericUtils.parseDatetoString(scheduleDepDate);
        //String dynamicURL = 'QF/0516/2018-02-03/SYD/passengers?passengersPerPage=50&frequentFlyersOnly=false&includeLoyaltyDetails=true&includeConnectingFlights=true&includeCustomerContactDetails=true';
        //String endpointURL = 'http://qccare.getsandbox.com/passengers';

        //GRAPHITE-808 Add another parameter in the endpoint '&includeBaggageDetails=true'
        //Jira CRM-8879 added parameter in the endpoint includeSMECorpId=true
        String dynamicURL = operatingCarrier + '/' + operatingFlightNumber + '/' + dateVal + '/' + departurePort +'/passengers?passengersPerPage=20&frequentFlyersOnly=false&includeLoyaltyDetails=true&includeConnectingFlights=true&includeContactDetails=true&includePaxFromPreviousLegs=true&includeBaggageDetails=true&includeSMECorpId=true'; //INC2683863
        dynamicURL = pagNo != Null? dynamicURL+'&pageNo='+pagNo: dynamicURL;
        System.debug('endpoint=====> ' + endpoint);
        String endpointURL = endpoint+''+dynamicURL;
        System.debug('endpointURL: ' + endpointURL);
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);

        //CRM-7330: 201 SOQL limit fix
        if (response.getStatusCode() == 401)
        {
            updatedToken = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken', true);
            req.setHeader('Authorization', updatedToken);
            response = http.send(req);
        }

        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_FlightPassengersResponse passengersResp = (QCC_FlightPassengersResponse)JSON.deserialize(response.getBody(), QCC_FlightPassengersResponse.class);
            if (String.isNotBlank(updatedToken)) {
                passengersResp.token = updatedToken;
            }
            return passengersResp;
        }
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeFlightInfoAPI
    Description:        Fetch Flight info from CAP
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_FlightInfoResponse invokeFlightInfoAPI(String departureDate , String departurePort , String flightNo, String arrivalPort)
    {
        return invokeFlightInfoAPI(departureDate, departurePort, flightNo, arrivalPort, '');
        //String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken');
        //if(String.isBlank(token)) {
        //    return null;
        //}
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPFlightInfoRetrieve');
        
        //Http http = new Http();
        //HttpRequest req = new HttpRequest();
        //String dynamicURL = departureDate + '/' + departurePort + '/schedules?flightNo=' + flightNo + '&arrivalPort=' + arrivalPort;

        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        //req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c); 
        //req.setHeader('System', 'CAPCRE_CC');
        //req.setHeader('Authorization', token);
        //req.setTimeout(120000);
        //HTTPResponse response = http.send(req);
        //if(response.getStatusCode() == 200){
        //    system.debug('response Body#########'+response.getBody());
        //    QCC_FlightInfoResponse flightInfoResp = (QCC_FlightInfoResponse)JSON.deserialize(response.getBody(), QCC_FlightInfoResponse.class);
        //    return flightInfoResp;
        //}else{
        //    system.debug('response: '+response);
        //}
        //return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeFlightInfoAPI
    Description:        Fetch Flight info from CAP
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_FlightInfoResponse invokeFlightInfoAPI(String departureDate , String departurePort , String flightNo, String arrivalPort, String carrier)
    {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken');
        if(String.isBlank(token)) {
            return null;
        }
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPFlightInfoRetrieve');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = departureDate + '/' + departurePort + '/schedules?flightNo=' + flightNo + (!String.isBlank(arrivalPort) ? ('&arrivalPort=' + arrivalPort) : '') + (!String.isBlank(carrier) ? ('&carrier=' + carrier) : '');

        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(60000);
        HTTPResponse response = http.send(req);
        
        //CRM-7330: 201 SOQL limit fix
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            QCC_GenericUtils.updateToken(token, 'QCC_FlightToken');
        }
        
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_FlightInfoResponse flightInfoResp = (QCC_FlightInfoResponse)JSON.deserialize(response.getBody(), QCC_FlightInfoResponse.class);
            return flightInfoResp;
        }else{
            system.debug('response: '+response);
            QCC_FlightInfoResponse flightInfoResp = new QCC_FlightInfoResponse();
            flightInfoResp.errorMessage = '' + response.getStatusCode() + '-=-' + response.getStatus();
            return flightInfoResp;
        }
       // return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeFlightInfoAPI
    Description:        Fetch Flight info from CAP
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_FlightStatusAPIResponse invokeFlightStatusAPI(String departureFrom , String departureTo , String flightNo)
    {
        //String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_FlightStatusToken');
        //if(String.isBlank(token)) {
        //    return null;
        //}
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FlightStatusAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = flightNo + '?departureFrom=' + departureFrom +'&departureTo=' + departureTo;

        String endpointURL = 'callout:QantasFlightStatus/'+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        //req.setHeader('System', 'CAPCRE_CC');
        //req.setHeader('Authorization', token);
        req.setTimeout(2000);
        HTTPResponse response = http.send(req);
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());   
            String jsonRes = response.getBody().replace('"from":', '"from_x":');
            QCC_FlightStatusAPIResponse flightInfoResp = (QCC_FlightStatusAPIResponse)JSON.deserialize(jsonRes, QCC_FlightStatusAPIResponse.class);
            return flightInfoResp;
        }else{
            system.debug('response: '+response);
        }
        return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePassengerServiceDetails 
    Description:        Passenger service details (SSR, SK, OS etc) for the given flight
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    public static QCC_PassengerServiceDetailsResponse invokePassengerServiceDetails(String operatingCarrier , String operatingFightNumber , String departureDate, String departurePort, String arrivalPort, Integer pageNo)
    {   
        String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken');
        if(String.isBlank(token)) {
            //return null;
        }
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPFlightInfoRetrieve');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = operatingCarrier + '/' + operatingFightNumber+'/'+departureDate+'/'+departurePort + '/passengers/servicerequest?arrivalPort=' + arrivalPort + '&pageNo='+pageNo;

        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        
        //CRM-7330: 201 SOQL limit fix
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_FlightToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            QCC_GenericUtils.updateToken(token, 'QCC_FlightToken');
        }

        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            QCC_PassengerServiceDetailsResponse passengerDetails = (QCC_PassengerServiceDetailsResponse)JSON.deserialize(response.getBody(), QCC_PassengerServiceDetailsResponse.class);
            return passengerDetails;
        }else{
            system.debug('response: '+response);
            QCC_PassengerServiceDetailsResponse passengerDetails = new QCC_PassengerServiceDetailsResponse();
            passengerDetails.errorMessage = '' + response.getStatusCode() + '-=-' + response.getStatus();
            return passengerDetails;
        }
      //  return null; 
    }

    /*--------------------------------------------------------------------------------------
    Method Name:        invokeFlightStatusDepsAPI
    Description:        Fetch list of Flight based on Departure port, Departure From and To.
                        This is used by the "Global Heads Up" flight event to autmatically pull and create affected flight events.
    Parameter:          departurePort - airport code set on the Global Heads Up event record
                        departureFrom - start date of the event
                        departureTo - end date of the event
    --------------------------------------------------------------------------------------*/
    public static QCC_FlightStatusDepsAPIResponse invokeFlightStatusDepsAPI(String departurePort, String departureFrom , String departureTo)
    {
        //String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_FlightStatusToken');
        //if(String.isBlank(token)) {
        //    return null;
        //}
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FlightStatusAPI');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = 'v1/departures/' + departurePort + '?departureFrom=' + departureFrom +'&departureTo=' + departureTo;

        String endpointURL = 'callout:QantasFlightStatus/'+dynamicURL;
        system.debug('>>>endpointURL: ' + endpointURL);
        req.setEndpoint(endpointURL);
        req.setMethod('GET');
        req.setTimeout(2000);
        HTTPResponse response = http.send(req);
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            String jsonRes = response.getBody().replace('"from":', '"from_Z":');
            QCC_FlightStatusDepsAPIResponse flightInfoResp = (QCC_FlightStatusDepsAPIResponse)JSON.deserialize(jsonRes, QCC_FlightStatusDepsAPIResponse.class);
            return flightInfoResp;
        }else{
            system.debug('response: '+response);
        }
        return null;
    }
    /*--------------------------------------------------------------------------------------
    Method Name:        invokeRetrieveCustomerFlightsAPI
    Description:        Trigger a callout to retrieve a passenger flight base on a given dates
    Parameter:          token - token use for callout
                        qantasAPI - API callout information
                        FFNo - Passenger Frequent Flyer Number
                        dateFrom - Event Datetime
                        dateTo - Event Datetime
    --------------------------------------------------------------------------------------*/
    public static QCC_CustomerFlightsWrapper.CustomerFlightsWrapper invokeRetrieveCustomerFlightsAPI(String token,Qantas_API__c qantasAPI, String FFNo,Datetime dateFrom,Datetime dateTo)
    {
        // Build Dynamic Endpoint URL by replacing URL parameters
        String endpointURL = qantasAPI.EndPoint__c;
        endpointURL = endpointURL.replace('{ffNo}',FFNo);
        System.debug('dateFrom==> ' + dateFrom);
        System.debug('dateTo==> ' + dateTo);
        
        // Jira: CRM-6052
        if (dateFrom != null && dateTo != null)
        {
            endpointURL = endpointURL.replace('{fromTimestamp}',String.valueOf(dateFrom.getTime())); // Date is converted to Timestamp
            endpointURL = endpointURL.replace('{toTimestamp}',String.valueOf(dateTo.getTime())); // Date is converted to Timestamp
        }
        system.debug('endpointURL : ' + endpointURL);

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(endpointURL);
        request.setMethod(qantasAPI.Method__c);
        request.setHeader('System', 'CAPCRE_CC');
        request.setHeader('client_id', qantasAPI.ClientId__c);
        request.setHeader('client_secret', qantasAPI.ClientSecret__c);
        request.setHeader('grant_type', qantasAPI.GrantType__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);
        request.setTimeout(120000);
        System.debug('request: ' + request);

        if(Test.isRunningTest()){
            String testResponse = '{"flights": [{"travelPlanId": "777042573049505","bookingId": "777042573049505","reloc": "MWHLEP",';
                testResponse += '"creationDate": "18/09/2019","currentPassengerQuantity": 1,"segmentId": "851977107723478","segmentTattoo": 1,"marketingCarrierAlphaCode": "QF",';
                testResponse += '"marketingFlightNumber": "0009","marketingFlightSuffix": null,"departureLocalDate": "20/09/2019","departureLocalTime": "18:45:00",';
                testResponse += '"departureUTCTimestamp": "20/09/2019 10:45:00","estimateDepartureLocalDate": "20/09/2019","estimateDepartureLocalTime": "18:45:00","actualDepartureLocalDate": null,';
                testResponse += '"actualDepartureLocalTime": null,"arrivalLocalDate": "21/09/2019","arrivalLocalTime": "05:05:00","estimateArrivalLocalDate": "21/09/2019",';
                testResponse += '"estimateArrivalLocalTime": "05:05:00","actualArrivalLocalDate": null,"actualArrivalLocalTime": null,"informationalSegment": false,';
                testResponse += '"dateVariance": 1,"departureAirportCode": "PER","departureCityCode": "PER","departureCityName": "PERTH","arrivalAirportCode": "LHR","arrivalCityCode": "LON",';
                testResponse += '"arrivalCityName": "LONDON","reservationStatusCode": "HK","operatingCarrierAlphaCode": "QF","operatingFlightNumber": "0009","operatingFlightSuffix": null,';
                testResponse += '"classOfService": "Y","cabin": "Y"}]}';
            QCC_CustomerFlightsWrapper.CustomerFlightsWrapper customerFlights = (QCC_CustomerFlightsWrapper.CustomerFlightsWrapper)JSON.deserialize(testResponse, QCC_CustomerFlightsWrapper.CustomerFlightsWrapper.class);
            return customerFlights;
        }

        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        if(response.getStatusCode() == 200){
            QCC_CustomerFlightsWrapper.CustomerFlightsWrapper customerFlights = (QCC_CustomerFlightsWrapper.CustomerFlightsWrapper)JSON.deserialize(response.getBody(), QCC_CustomerFlightsWrapper.CustomerFlightsWrapper.class);
            return customerFlights;
        }else{
            system.debug('response: '+response);
        }

        return null;
    }

    //@Purpose: This method is used to send the actual callout that will send the SMS message through LivePerson.
    //@input parameters:
    //  1. qantasAPI - The record holding the endpoint and other variables that is being used to send the callout.
    //  2. requestBody - The request body to be sent to the customer using SMS.
    //@return type: None
    public static Boolean invokeLivePersonSendSMSAPI(Qantas_API__c qantasAPI, String requestBody, String token) {
        System.debug('token: ' + token);
        Boolean isSuccessful = false;

        System.debug('requestBody: ' + requestBody);

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(qantasAPI.EndPoint__c);
        request.setMethod(qantasAPI.Method__c);
        request.setHeader('System', 'CAPCRE_CC');
        //request.setHeader('client_id', qantasAPI.ClientId__c);
        //request.setHeader('client_secret', qantasAPI.ClientSecret__c);
        //request.setHeader('grant_type', qantasAPI.GrantType__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', token);
        request.setBody(requestBody);
        request.setTimeout(120000);

        System.debug('request: ' + request);
        Http http = new Http();

        if (Test.isRunningTest()) {
            String responseBody = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
            Map<String, String> mapHeader= new Map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', responseBody, mapHeader));
        }
        HttpResponse response = http.send(request);

        System.debug('response: ' + response);

        if(response.getStatusCode() == 200 || response.getStatusCode() == 202) {
            isSuccessful = true;
        }

        return isSuccessful;
    }

    //@Purpose: This method is used to send the actual callout to get all fee waiver.
    //@input parameters:
    //  1. qantasAPI - The record holding the endpoint and other variables that is being used to send the callout.
    //  2. requestBody - The request body to be sent to the customer using SMS.
    //@return type: None
    //
    public static QCC_FeeWaiverWrapper.FeeWaiverWrapper invokeFeeWaiverAPI(String pageNumber, String ffNo) {
        System.debug('QCC_InvokeCAPAPI.invokeFeeWaiverAPI');
        QCC_FeeWaiverWrapper.FeeWaiverWrapper myWrapper = new QCC_FeeWaiverWrapper.FeeWaiverWrapper();
        DateTime currentDate = System.now().addMonths(Integer.valueOf(Label.QCC_Fee_Waiver_Related_List_Added_Number_of_Month));
        
         //Callout using Named credential CRM-9361
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            String recordsPerPage =Label.QCC_Fee_Waiver_Related_List_Records_per_Page;
            String fromDate = currentDate.format('yyyy-MM-dd');
            String dynamicUrl =  '/' + ffNo + '/feewaivers?recordsPerPage=' +recordsPerPage + '&pageNo=' +pageNumber + '&fromDate=' + fromDate ;
            String endpoint = 'callout:QCC_FeeWaiverAPI' + dynamicUrl;
            System.debug('endpoint: ' + endpoint);
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('request: ' + request);
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('response: ' + response); 
            
            if(response.getStatusCode() == 200 || response.getStatusCode() == 202) {
            	myWrapper = (QCC_FeeWaiverWrapper.FeeWaiverWrapper)JSON.deserialize(response.getBody(), QCC_FeeWaiverWrapper.FeeWaiverWrapper.class);
        	}
        }
        
        //Callout using QantasAPI object.
        else{            
            String token = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CAPToken');
            System.debug('token: ' + token);  
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FeeWaiverAPI');
            System.debug('qantasAPI: ' + qantasAPI);
            
            String endpoint = qantasAPI.EndPoint__c;
            endpoint = endpoint.replace('{ffNo}', ffNo);
            endpoint = endpoint.replace('{pageNo}', pageNumber);
            endpoint = endpoint.replace('{ffNo}', ffNo);
            endpoint = endpoint.replace('{recordsPerPage}', Label.QCC_Fee_Waiver_Related_List_Records_per_Page);
            endpoint = endpoint.replace('{fromDate}', currentDate.format('yyyy-MM-dd'));
            System.debug('endpoint: ' + endpoint);
            
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint(endpoint);
            request.setMethod(qantasAPI.Method__c);
            request.setHeader('System', 'CAPCRE_CC');
            request.setHeader('client_id', qantasAPI.ClientId__c);
            request.setHeader('client_secret', qantasAPI.ClientSecret__c);
            request.setHeader('grant_type', qantasAPI.GrantType__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', token);
            request.setTimeout(120000);
            System.debug('request: ' + request);
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            //Jira-5620 Token refresh when there is a mismatch Venkat.P
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken', true);
                request.setHeader('Authorization', token);
                response = http.send(request);
            }
            System.debug('response: ' + response); 
            
            if(response.getStatusCode() == 200 || response.getStatusCode() == 202) {
            	myWrapper = (QCC_FeeWaiverWrapper.FeeWaiverWrapper)JSON.deserialize(response.getBody(), QCC_FeeWaiverWrapper.FeeWaiverWrapper.class);
        	}
            
            //Update the token once the callout is done.
            QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
         }

        return myWrapper;
    }

    //@Purpose: This method is used to send the actual callout for the Case Stream
    //@input parameters:
    //  1. qantasAPI - The record holding the endpoint and other variables that is being used to send the callout.
    //  2. token - The token to be used as part of the callout.
    //  3. requestBody - The request body to be used as part of the callout.
    //@return type: None
    public static CaseStreamWrapper invokeCaseStreamUpdateAPI(Qantas_API__c qantasAPI, String token, String requestBody) {
        System.debug('QCC_InvokeCAPAPI.invokeCaseStreamUpdateAPI');
        System.debug('qantasAPI: ' + qantasAPI);
        System.debug('token: ' + token);
        System.debug('requestBody: ' + requestBody);
        CaseStreamWrapper myWrapper = new CaseStreamWrapper();
        myWrapper.isSuccess = false;
        myWrapper.requestLogRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Invoke CAP API', 'QCC_InvokeCAPAPI', 'invokeCaseStreamUpdateAPI - Request', requestBody, '', false, '', null, '');

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(qantasAPI.EndPoint__c);
        request.setMethod(qantasAPI.Method__c);
        //request.setHeader('client_Id', qantasAPI.ClientId__c);
        //request.setHeader('client_secret', qantasAPI.ClientSecret__c);
        request.setHeader('Authorization', token);
        request.setHeader('System', 'CAPCRE_CC');
        //request.setHeader('grant_type', qantasAPI.GrantType__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);

        System.debug('request: ' + request);
        Http http = new Http();
        HttpResponse response = http.send(request);

        System.debug('response: ' + response);
        System.debug('response: ' + response.toString());

        myWrapper.responseLogRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Invoke CAP API', 'QCC_InvokeCAPAPI', 'invokeCaseStreamUpdateAPI - Response', response.toString(), '', false, '', null, '');

        if(response.getStatusCode() == 200 || response.getStatusCode() == 202) {
            myWrapper.isSuccess = true;
        }

        return myWrapper;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyProfileAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /profile as endpoint URL, //CRM-7330: 201 SOQL limit fix
    Parameter:
    Comments :          New V2 Member API Changes //CRM-7330
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile invokeLoyaltyProfileAPI(String ffNumber) {
        return invokeLoyaltyProfileAPI(ffNumber, null);
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyProfileAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /profile as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - 5003 //CRM-7330: 201 SOQL limit fix
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile invokeLoyaltyProfileAPI(String ffNumber, String loyaltyToken) {
        system.debug('inside invokeLoyaltyProfileAPI'+ffNumber );
        //CRM-7330: 201 SOQL limit fix
        String token = (loyaltyToken != null) ? loyaltyToken : QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');

        system.debug('token from QCC_GenericUtils '+token);
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        //system.debug('qantasAPI from CustomSettingsUtilities '+qantasAPI);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/profile';
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod('GET');
        //req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response#########'+response.getStatusCode());
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());
        

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            system.debug('modifiedJSON'+modifiedJSON);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile.class);
            system.debug('formattedJSON Body######### profile'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyContactAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /contact as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM-7330: 201 SOQL limit fix
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact invokeLoyaltyContactAPI(String ffNumber) {
        return invokeLoyaltyContactAPI(ffNumber, null);
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyContactAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /contact as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - 5003, CRM-7330: 201 SOQL limit fix
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact invokeLoyaltyContactAPI(String ffNumber, String loyaltyToken) {
        
        //CRM-7330: 201 SOQL limit fix
        String token = (loyaltyToken != null) ? loyaltyToken : QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/contact';
        //CRM-6900: 201 SOQL limit fix
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());
       

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact.class);
            system.debug('formattedJSON Body######### contact'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    
     /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyProgramAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /program as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - 5003
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.Programs invokeLoyaltyProgramAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/program/QFF';
        //CRM-6900: 201 SOQL limit fix
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            System.debug('modifiedJSON Program=====> ' + modifiedJSON);
            QCC_LoyaltyResponseWrapper.Programs formattedJSON = (QCC_LoyaltyResponseWrapper.Programs)JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.Programs.class);
            system.debug('formattedJSON Body######### program'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyProgramAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /account as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - 5003
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount invokeLoyaltyAccountAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/account';
        //CRM-6900: 201 SOQL limit fix
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c); 
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            System.debug('modifiedJSON Account =====> ' + modifiedJSON);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount.class);
            system.debug('formattedJSON Body######### account'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyTierAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /tier as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - CRM-7330: 201 SOQL limit fix
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier invokeLoyaltyTierAPI(String ffNumber)  {
        return invokeLoyaltyTierAPI(ffNumber, null);
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeLoyaltyTierAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /tier as endpoint URL
    Parameter:
    Comments :          New V2 Member API Changes CRM - 5003, CRM-7330
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier invokeLoyaltyTierAPI(String ffNumber, String loyaltyToken) {
        
        //CRM-7330: 201 SOQL limit fix
        String token = (loyaltyToken != null) ? loyaltyToken : QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');

        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/tier';
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            system.debug('modifiedJSON tier'+modifiedJSON);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier.class);
           // QCC_LoyaltyResponseWrapper formattedJSON = (QCC_LoyaltyResponseWrapper) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.class);
            
            system.debug('formattedJSON Body######### tier'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeBookingTicketCAPAPI
    Description:        Fetch Booking Flight Information from CAP system
    Parameter:          PNR, Lastname
    Comments:           ADT-90 View customer bookings
    --------------------------------------------------------------------------------------*/ 
    public static boolean invokeBookingTicketCAPAPI(String pnr, String token){
        boolean isSuccessfull = false;
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            system.debug('token coming in:' +token);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String dynamicURL = '/'+pnr+'/tktStock';
            String endpointURL = 'callout:QCC_CAPPNRRetrieve'+dynamicURL;
            system.debug('endpointURL:' +endpointURL);
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setHeader('System', 'CAPCRE_CC');
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
           system.debug('response:' +response);
            if(response.getStatusCode() == 200){
                isSuccessfull = true;
            }
         }
        */
        //else{
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+pnr+'/tktStock';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
       
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
        }

        if(response.getStatusCode() == 200){
            isSuccessfull = true;
        	}
        //}
        
        return isSuccessfull; 
    }

    /*--------------------------------------------------------------------------------------      
     Method Name:        invokeProductFlightCAPAPI 
     Description:        Fetch Product Flight info from CAP system
     Parameter:          FF number, toTimestamp
     Comments:           ADT-90 View customer bookings
    --------------------------------------------------------------------------------------*/ 
    public static String invokeProductFlightCAPAPI(String ffNo, String token, Long toTimestamp, Long toTimestampMinusYear, integer pageNumber){
        if(String.isBlank(ffNo)){
            return null;
        }
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_BookingSummaryAPI');
   
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+ffNo+'/product/flights?fromTimestamp=' + toTimestampMinusYear + '&toTimestamp=' + toTimestamp + '&flightsPerPage=' + Label.QCC_Number_of_flights_API + '&pageNo=' + pageNumber + '&sortOrder=DESC';
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');//??
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        system.debug('Endpoint Body#########'+endpointURL);
        system.debug('response Status #########'+ response.getStatusCode());
        
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
        }
        if(response.getStatusCode() == 200){
            String modifiedJSON = response.getBody();
            return modifiedJSON;
        }
        else if(response.getStatusCode() == 404){
            String modifiedJSON = response.getBody();
            system.debug('404 not error ==== ' + modifiedJSON);
            return modifiedJSON;
        }
        return null; 
    }
    
    
    /*--------------------------------------------------------------------------------------      
     Method Name:        invokeProductFlightsCAPAPI 
     Description:        Fetch Product Flight info from CAP system  CRM-6052
     Parameter:          FF number, token, toTimestamp, toTimestampMinusYear, pageNumber, isfetchAllBookings
    --------------------------------------------------------------------------------------*/ 
    //QCC_BookingSummaryAPI using 2 tokens: QCC_CAPToken and QCC_BookingToken
    public static QCC_CustomerFlightsWrapper.CustomerFlightsWrapper invokeProductFlightsCAPAPI(String ffNo, String token, Long toTimestamp, Long toTimestampMinusYear, integer pageNumber, Boolean isfetchAllBookings){
        
        /*
        if(Trigger_Status__c.getValues('UseNamedCred').Active__c){
            
             if(String.isBlank(ffNo)){
            	return null;
        		}
       
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String noofFlights = Label.QCC_Number_of_flights_API;
            if (isfetchAllBookings){
                noofFlights = '1000';
            }
            String dynamicURL = ffNo+'/product/flights?fromTimestamp=' + toTimestampMinusYear + '&toTimestamp=' + toTimestamp + '&flightsPerPage=' + noofFlights + '&pageNo=' + pageNumber + '&sortOrder=DESC';
            String endpointURL = 'callout:QCC_BookingSummaryAPI'+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod('GET'); 
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            system.debug('response Status #########'+ response.getStatusCode());
            system.debug('Endpoint Body#########'+endpointURL);
            
            if(response.getStatusCode() == 200){
                QCC_CustomerFlightsWrapper.CustomerFlightsWrapper formattedJSON = (QCC_CustomerFlightsWrapper.CustomerFlightsWrapper) JSON.deserialize(response.getBody(), QCC_CustomerFlightsWrapper.CustomerFlightsWrapper.class);
                return formattedJSON;
            }
        }
		*/
            	
       // else{
            
                if(String.isBlank(ffNo)){
                return null;
                }
            
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_BookingSummaryAPI');
       
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String noofFlights = Label.QCC_Number_of_flights_API;
            if (isfetchAllBookings){
                noofFlights = '1000';
            }
            String dynamicURL = (qantasAPI.EndPoint__c.endsWith('/')?'': '/')+ffNo+'/product/flights?fromTimestamp=' + toTimestampMinusYear + '&toTimestamp=' + toTimestamp + '&flightsPerPage=' + noofFlights + '&pageNo=' + pageNumber + '&sortOrder=DESC';
            String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('System', 'CAPCRE_CC');//??
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            system.debug('response Status #########'+ response.getStatusCode());
            system.debug('Endpoint Body#########'+endpointURL);
            
            //Jira CRM-6218: Token refresh when there is a mismatch
            if (response.getStatusCode() == 401)
            {
                token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
                req.setHeader('Authorization', token);
                response = http.send(req);
                //CRM-7330: 201 SOQL limit fix
                QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            }
            
            if(response.getStatusCode() == 200){
                QCC_CustomerFlightsWrapper.CustomerFlightsWrapper formattedJSON = (QCC_CustomerFlightsWrapper.CustomerFlightsWrapper) JSON.deserialize(response.getBody(), QCC_CustomerFlightsWrapper.CustomerFlightsWrapper.class);
                return formattedJSON;
            }
        
        
        return null; 
    }

     /*--------------------------------------------------------------------------------------      
     Method Name:        invokeLoyaltyRawProfileAPI
     Description:        Fetch Raw Booking Summary Information from CAP system, invoking /profile as endpoint URL
     Parameter:
     Comments :          ADT-92 Getting Preferred name if it exists or not when we get the return value from this API
     --------------------------------------------------------------------------------------*/ 
     public static  String invokeLoyaltyRawProfileAPI(String ffNumber) {
         system.debug('inside invokeLoyaltyRawProfileAPI'+ffNumber );
         String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
         system.debug('token from QCC_GenericUtils '+token);
         if(String.isBlank(token)) return null;
         //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
         
         //system.debug('qantasAPI from CustomSettingsUtilities '+qantasAPI);
         Http http = new Http();
         HttpRequest req = new HttpRequest();
         String dynamicURL = '/v2/'+ffNumber+'/profile';
         //CRM-6900
         String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
         //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
         req.setEndpoint(endpointURL);
         //req.setMethod(qantasAPI.Method__c); 
         req.setMethod('GET'); 
         req.setHeader('Content-Type', 'application/json');
         req.setHeader('Authorization', token);
         req.setTimeout(120000);
         HTTPResponse response = http.send(req);
         //CRM-5575 Automated token refresh for the loyalty subscription
         if (response.getStatusCode() == 401)
         {
             token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
             req.setHeader('Authorization', token);
             response = http.send(req);
             //CRM-7330: 201 SOQL limit fix
             QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
         }
         system.debug('response#########'+response);
         system.debug('req body#########'+req.getBody());
    
         if(response.getStatusCode() == 200){
             String modifiedJSON = response.getBody();
             return modifiedJSON;
         } 
         return null;      
     }
 
    public class CaseStreamWrapper {
        public Boolean isSuccess {get; set;}
        public Log__c requestLogRecord {get; set;}
        public Log__c responseLogRecord {get; set;}
    }
    
    /************************************
     * Purpose      : call loyalty API
     * Parameter    : FF Number
     * Returns      : String 
     * Throws       :
     * Expectations : 
     * Comments     : ADT-461 AND ADT-92 get loyalty contact infomation 
     ************************************/
    public static String invokeLoyaltyRawContact(String ffNumber) {
        if (String.isBlank(ffNumber)) {
            return null;
        }
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/contact';
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c); 
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
            //CRM-7330: 201 SOQL limit fix
            QCC_GenericUtils.updateToken(token, 'QCC_LoyaltyToken');
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());
        
        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            return modifiedJSON;
        }
        else if(response.getStatusCode() == 404){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            system.debug('404 not error ==== ' + modifiedJSON);
            return modifiedJSON;
        } else {
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            system.debug('>>>invokeLoyaltyRawContact - error' + modifiedJSON);
            return modifiedJSON;
        }
        //return null; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeQCCAccountAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /account as endpoint URL
    Parameter:
    Comments :          New V3 Member API Changes ADT-462
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount invokeQCCAccountAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
        //Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/account';
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        //req.setMethod(qantasAPI.Method__c); 
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            System.debug('modifiedJSON Account =====> ' + modifiedJSON);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount.class);
            system.debug('formattedJSON Body######### account'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeQCCProgramAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /program as endpoint URL
    Parameter:
    Comments :          New V3 Member API Changes ADT-462
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.Programs invokeQCCProgramAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
       // Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/program/QFF';
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
       // req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            System.debug('modifiedJSON Program=====> ' + modifiedJSON);
            QCC_LoyaltyResponseWrapper.Programs formattedJSON = (QCC_LoyaltyResponseWrapper.Programs)JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.Programs.class);
            system.debug('formattedJSON Body######### program'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeQCCTierAPI
    Description:        Fetch Booking Summary Information from CAP system, invoking /tier as endpoint URL
    Parameter:
    Comments :          New V3 Member API Changes ADT-462
    --------------------------------------------------------------------------------------*/ 
    public static  QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier invokeQCCTierAPI(String ffNumber) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken');
        if(String.isBlank(token)) return null;
       // Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_LoyaltyAPI');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/v2/'+ffNumber+'/tier';
        //CRM-6900
        String endpointURL = System.Label.QCCLoyaltyMemberAPI+''+dynamicURL;
        //String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        //req.setMethod(qantasAPI.Method__c); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        //CRM-5575 Automated token refresh for the loyalty subscription
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_LoyaltyToken', true);
            req.setHeader('Authorization', token);
            response = http.send(req);
        }
        system.debug('response#########'+response);
        system.debug('response Body#########'+response.getBody());
        system.debug('req#########'+req);
        system.debug('req body#########'+req.getBody());

        if(response.getStatusCode() == 200){
            String modifiedJSON = QCC_UtilityHelper.modifyJSON(response.getBody());
            system.debug('modifiedJSON tier'+modifiedJSON);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier formattedJSON = (QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier.class);
           // QCC_LoyaltyResponseWrapper formattedJSON = (QCC_LoyaltyResponseWrapper) JSON.deserialize(modifiedJSON, QCC_LoyaltyResponseWrapper.class);
            
            system.debug('formattedJSON Body######### tier'+formattedJSON);

            return formattedJSON;
        } 
        return null;      
    }
}