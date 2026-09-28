public class QCC_RecoveryIntegrationUtility{
    public static HttpResponse actualHttpCall(string endpoint, string requestBody) {
        
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(endpoint);
        request.setMethod('POST');            
        request.setHeader('content-type','application/json');
        request.setHeader('accept', 'application/json');
      
        request.setBody(requestBody);
        request.setTimeout(120000); 
        HttpResponse response = http.send(request);
        return response; 
    }
    
    public static String constructSysLog(SystemLog logParams) {
        String logMess;
        if(logParams.status == 'SUCCESS'){
            logMess = '<ul><li>'+DateTime.Now() + ' ('+logParams.systemName+') ' + '<span style="color: green;">'+ logParams.status+'</span>'+' '+'BatchNumber: '+logParams.batchNumber+' '+'BatchDate: '+DateTime.Now()+ '</li></ul>';
        }else{
            logMess = '<ul><li>'+DateTime.Now() + ' ('+logParams.systemName+') ' + '<span style="color: red;">'+logParams.status+'</span>'+' '+ logParams.errorCode+' '+logParams.errorMessage+ '</li></ul>';
        }
        return logMess;
    }
    
   public class SystemLog {
       public String systemName;
        public String status;
        public String errorCode;
        public String errorMessage;
        public String batchNumber;          
    }
}