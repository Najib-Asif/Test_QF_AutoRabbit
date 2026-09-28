@isTest
global with sharing class QCC_PromoCodeMockResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('https://api.services-sit.qantasloyalty.com/member/53762356/bonus/rewards', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "bonusRewards": [ { "voucherCode": "PROMO09S12AB56", "offer": "VACCINE_BONUS", "selectedReward": "QF FLIGHT VOUCHER", "expiryDate": "2022-03-31", "selectedDate": "2021-09-24" } ] }');
        res.setStatusCode(200);
        return res;
    }
}