/* 
* Created By : Yuvaraj | TCS | Cloud Developer 
* Modified By : Ajay | Purpose to create a Mock Response
* Main Class : QAC_SiteAdministrator_Controller
* Test Class : QAC_SiteAdministrator_Controller_Test
=====================================================================
*/


@isTest
public class QAC_SiteAdministrator_Controller_Mock implements HttpCalloutMock 
{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
     public QAC_SiteAdministrator_Controller_Mock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}