/**
 * author: dattaraj.deshmukh@qantas.com.au
 * desc:    Mock class for Exgratia Flight Pass search
 * history:
 * 			07/11/2023	- Dattaraj Deshmukh - Created
 */
@isTest
public class ExgratiaFlightPassSearchMock implements HttpCalloutMock {
    String responseBody;

    public ExgratiaFlightPassSearchMock(String body) {
        this.responseBody = body;
    }

    public HttpResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setHeader('Content-Type', 'application/json');

        if(req.getEndpoint() == 'https://api-stage.qantas.com/token') {
            String tokenResponseBody = '{"token_type": "Bearer", "access_token":"eyJ4NXQiOiJNalprTkdVeU5qQXdZMkpsTUdVM"}';
            res.setBody(tokenResponseBody);
        } 
        else {
            res.setBody(this.responseBody);
        }
        res.setStatusCode(200);
        return res;
    }
}