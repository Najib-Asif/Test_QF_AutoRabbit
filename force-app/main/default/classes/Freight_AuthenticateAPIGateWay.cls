/*==================================================================================================================================
Author:         Abhijeet P
Company:        TCS
Purpose:        Freight - Class will be used for Authentication in API Gateway 
Date:           10/08/2017         
TestClass:      Freight_AuthenticateAPIGateWayTest

==================================================================================================================================
History
10-Aug-2017     Abhijeet            Initial Design
30-Aug-2017     Ajay                Error Handling consideration for Authentication request    
14-May-2019     Vinoth              Commented the code for not executing through Test Class 
==================================================================================================================================*/

public class Freight_AuthenticateAPIGateWay {
    
    public static Boolean isTokenValid = false;
    
    
    /*--------------------------------------------------------------------------------------      
Method Name:        getRequestString
Description:        Method to get json String from AWB Request class 
Parameter:          
--------------------------------------------------------------------------------------*/
   public static String returnAccessToken(){
        
        string accessToken;
        
        if((String)Cache.Org.get('local.FreightAPIGateWayToken.iCargoAccessToken') != null && !isTokenValid){
            accessToken = (String)Cache.Org.get('local.FreightAPIGateWayToken.iCargoAccessToken');
            isTokenValid = TRUE;
        }
        else{
            accessToken = authenticateAPIGateway();
        }
        
        return accesstoken;
   // updateAccessTokenOnCache
   }
    
    
    /*--------------------------------------------------------------------------------------      
Method Name:        updateAccessTokenOnCache
Description:        To update Access token in Cache Memory of Salesforce
Parameter:          String iCargoAccessToken
--------------------------------------------------------------------------------------*/ 
  //  private static void updateAccessTokenOnCache(string iCargoAccessToken){ 
        
    //    if(iCargoAccessToken != null){
      //      Cache.Org.put('local.FreightAPIGateWayToken.iCargoAccessToken',iCargoAccessToken, 86400);
        //}
        
    //}
    
    /*--------------------------------------------------------------------------------------      
Method Name:        authenticateAPIGateway
Description:        To make OAuth 2.0 Authenticate call out to API Gateway
Parameter:          
--------------------------------------------------------------------------------------*/     
    private static string authenticateAPIGateway(){
        
        // iCargo AWB Details Credentials retrieval from Custom setting
      //  Integration_User_Tradesite__c freightIcargoUserDetails = Integration_User_Tradesite__c.getValues('Freight_iCargo_Integration');        
        
        // Declaring variable for ClientId and ClientSecret
       // String clientId     = freightIcargoUserDetails.Client_Id__c;
       // String clientSecret   = freightIcargoUserDetails.Client_Secret__c;
       // String reqbody     = 'grant_type=client_credentials&client_id='+clientId+'&client_secret='+clientSecret;
       // Http httpReq     = new Http();
       // HttpRequest req   = new HttpRequest();
      //  req.setBody(reqbody);
      //  req.setMethod('POST');
      //  req.setEndpoint(freightIcargoUserDetails.Authentication_Endpoint_URL__c);
        
       // HttpResponse response;
       // JSONParser parser;
        
        // Bypassing logic for Test Class excecution
        /*if(!Test.isRunningTest()){
response = httpReq.send(req);
parser = JSON.createParser(response.getBody());
system.debug(' @@ Access Token @@ -- ' + response.getBody());
}*/
        
      //  response = httpReq.send(req);
      //  parser = JSON.createParser(response.getBody());
       // system.debug(' @@ Access Token @@ -- ' + response.getBody());
        
       // string accessToken;
        //if(response != null){
          //  if(response.getStatusCode() == 200){
            //    while (parser.nextToken() != null) {
              //      if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                //        parser.nextValue();                     
                  //      accessToken = (parser.getText()==null?'':parser.getText());
                        //return accessToken;
                    //    break;
                  //  }
                //}
            //}
            //else{
              //  accessToken ='';
                //return '';
            //}
        //}
       
       // if(String.IsNotBlank(accessToken)){
        //    return accessToken;
       // }
       // else{
        //    return '';  
        //}
       
   return '';
       
           }
}