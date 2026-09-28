@isTest
public class QCC_InvokeEQAPIMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
    public QCC_InvokeEQAPIMock(Integer code, String body) {
        this.code = code;
        this.body = body;
    }
    
    public HTTPResponse respond(HTTPRequest req) {

        System.assertEquals('POST', req.getMethod());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.body);
        res.setStatusCode(200);
        return res;
    }

}