/**
 * @author: dattaraj.deshmukh@qantas.com.au
 * @date: 6/11/2023
 * @desc: Controller to make an API call to search Exgratia Flight Pass voucher details.
 * This api call is called from flow.
 * @history:
 *          6/11/2023   - created   - Dattaraj Deshmukh
 */
public without sharing class ExgratiaFlightPassSearchController {
    
    public ExgratiaFlightPassSearchController() {  }

    @InvocableMethod
    public static List<ExGratiaFlightPassOutput> searchFlightPassVoucher(List<ExGratiaFlightPassInput> requestList) {
        try{
            //getting first record. This list will always have one record only.
            //List is passed as method param due to SF limitations.
            ExGratiaFlightPassInput exgratiaInput = requestList[0];

            //get Qantas_API details
            Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_FlightPassSearch');

            //get token
            String token = QCC_GenericUtils.getCAPValidToken('QCC_FlightPassSearchToken');

            //perform HTTP callout
            Http http = new Http();
            HttpRequest req = new HttpRequest();
          
            String pnrNumber = String.isBlank(exgratiaInput.pnrNumber) ? 'none' : exgratiaInput.pnrNumber;
            String ffNumber = String.isBlank(exgratiaInput.ffNumber) ? 'none' : exgratiaInput.ffNumber;
            String lastName = String.isBlank(exgratiaInput.lastName) ? 'none' : exgratiaInput.lastName;
            //String flightNumber = String.isBlank(exgratiaInput.flightNumber) ? 'none' : exgratiaInput.flightNumber;
            String formattedFlightDate='';

            //formatting flight date in yyyy-mm-dd.
            if(exgratiaInput.dateOfTravel != null) {
                formattedFlightDate = ''+exgratiaInput.dateOfTravel.year() + '-' + String.valueOf(exgratiaInput.dateOfTravel.month()).leftPad(2, '0') + '-'+String.valueOf(exgratiaInput.dateOfTravel.day()).leftPad(2, '0');
            }
            String flightDate = exgratiaInput.dateOfTravel == null ? 'none' : formattedFlightDate;
            
            String urlParams = '/pnr/'+pnrNumber+'/lastname/'+lastName+'/flightdate/'+formattedFlightDate+'/frequentflyernumber/'+ffNumber;
            
            String endpointURL = qantasAPI.EndPoint__c + urlParams;
            system.debug(endpointURL);
            system.debug('https://api-stage.qantas.com/customer/disruption/v1/disruptions/pnr/none/lastname/POLITER/flightdate/2023-08-27/frequentflyernumber/1200300012');
            req.setEndpoint(endpointURL);
            req.setMethod(qantasAPI.Method__c); 
            req.setHeader('Authorization', token);
            req.setTimeout(120000);
            HTTPResponse response = http.send(req);
            system.debug('response###'+response);
            if(response.getStatusCode() == 200) { //if all OK

                 //update API details with latest token
                //QCC_GenericUtils.updateToken(token, 'QCC_FlightPassSearchToken');

                try {
                    system.debug('response.getBody()###'+response.getBody());
                    String body = response.getBody().replace('"?"', 'null');
                    system.debug('response.getBody()###'+body);
                    List<ExgratiaFlightPassSearchWrapper> res = ExgratiaFlightPassSearchWrapper.parse(body);
                    system.debug('res###'+res);
                    ExGratiaFlightPassOutput exGrationOutputVar = new ExGratiaFlightPassOutput();
                    exGrationOutputVar.res = res; 
                    system.debug('exGrationOutputVar###'+exGrationOutputVar);
                    return (new List<ExGratiaFlightPassOutput>{exGrationOutputVar});
            
                }
                catch(Exception ex) { 
                    system.debug('res###'+ex.getMessage());
                    
                    // catching possible JSON parse exception with response.
                    // when API do not have any results, it returns a message in JSON. 
                    //As we are parsing string into List of wrapper, this type of response will result in exception.

                    return null;
                }
                 
            }
            else {  //if ERROR / NOT OK
                //throwing exception. This will allow execute Fault Path in flow.s
                //throw new ExgratiaCalloutException();
                return null;
            }
        }
        catch(Exception ex) {
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Integration Logs Rec Type', 'QCC - Flight Pass Search', 'ExgratiaFlightPassSearchController', 
                                    'searchFlightPass', '', '', false,'', ex);
            throw ex;
        }
       
    }


    public class ExGratiaFlightPassInput {
        @InvocableVariable(label='FF Number' description='Frequent flyer number' required=false)
        public String ffNumber;
        
        @InvocableVariable(label='PNR Number' description='PNR number' required=false)
        public String pnrNumber;
        
        @InvocableVariable(label='Last Name' description='Last name of pax' required=true)
        public String lastName;
        
        @InvocableVariable(label='Date of Travel' description='Date of travel' required=true)
        public Date dateOfTravel;
        
        @InvocableVariable(label='Flight Number' description='Flight number' required=false)
        public String flightNumber;
        
    }

    public class ExGratiaFlightPassOutput{
        @InvocableVariable(label='Response' description='API response' required=true)
        public List<ExgratiaFlightPassSearchWrapper> res;
   }
}