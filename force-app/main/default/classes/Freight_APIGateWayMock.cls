@isTest
global class Freight_APIGateWayMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req)
    {
        System.assertEquals('https://api-stage.qantas.com/customer/oauth/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
    // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"bearer","expires_in":172800,"access_token":"12341234"}');
        res.setStatusCode(200);
        return res;
    }

}