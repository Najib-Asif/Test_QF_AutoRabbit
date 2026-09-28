@isTest
global class Freight_AWBMockRequest implements HttpCalloutMock{

    public String awbOn;
    
    public Freight_AWBMockRequest(String awbOn){
        this.awbOn = awbOn;
    }
    
    global HttpResponse respond(HTTPRequest req)
    {
        //System.assertEquals('https://api-stage.qantas.com/customer/freightservice/v1/trackFreight/shipment', req.getEndpoint());
       // System.assertEquals('POST', req.getMethod());
        
    // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(awbOn == 'yes'){
        //String json = '{"@xmlns:soapenv":"http://schemas.xmlsoap.org/soap/envelope/","shipmentMilestones":{"shipmentsTracked":{"shipmentPrefix":"081","masterDocumentNumber":"27188534","origin":"CAIRNS","destination":"SYDNEY","consigneeName":"STARTRACK","shipperName":"STARTRACK","shipmentDescription":"COMPUTER PARTS","handlingCode":"GEN","pieces":"2","weight":"11.0","weightUnit":"Kg","units":null,"latestStatus":{"station":"SYD","milestone":"Delivered","shipmentdate":"24-Jul-2017 08:49:33","weight":"11.0","pieces":"2","flightDetails":null},"history":[{"station":"SYD","milestone":"Delivered","shipmentdate":"24-Jul-2017 08:49:33","weight":"11.0","pieces":"2","flightDetails":null},{"station":"SYD","milestone":"Checked In","shipmentdate":"22-Jul-2017 13:58:05","weight":"11.0","pieces":"2","flightDetails":"JQ0957, ARR ; SYD. 22-Jul-2017 12:54(A)"},{"station":"CNS","milestone":"Departed","shipmentdate":"22-Jul-2017 10:39:02","weight":"11.0","pieces":"2","flightDetails":"JQ0957,DEP ; CNS.22-Jul-2017 10:08(A) ARR ; SYD. 22-Jul-2017 12:57(E)"},{"station":"CNS","milestone":"Manifested","shipmentdate":"22-Jul-2017 07:16:06","weight":"11.0","pieces":"2","flightDetails":"JQ0957,DEP ; CNS.22-Jul-2017 10:10(S) ARR ; SYD. 22-Jul-2017 13:05(S)"},{"station":"CNS","milestone":"Accepted","shipmentdate":"21-Jul-2017 17:10:53","weight":"11.0","pieces":"2","flightDetails":null},{"station":"MEL","milestone":"Booked","shipmentdate":"21-Jul-2017 16:30:17","weight":"11.0","pieces":"2","flightDetails":"QF0931,DEP ; CNS.22-Jul-2017 06:00(S) ARR ; SYD. 22-Jul-2017 08:55(S)"}]}}}'; 
         String json =
            '{' +
            '"shipmentSummary": {' +
            '"awb": "081-14290113",' +
            '"origin": "SYD",' +
            '"destination": "MNL",' +
            '"statedPieces": 1,' +
            '"statedWeight": "58.0",' +
            '"handlingCodes": "AVI,TEST",' +
            '"shipmentDescription": "TEST DESC",' +
            '"product": "TEST PROD",' +
            '"consigneeName": "TEST CONSIGNEE",' +
            '"shipperName": "TEST SHIPPER"' +
            '},' +
            
            '"shipmentHistory": [' +
            '{' +
            '"eventName":"Flight landed",' +
            '"pieces":1,' +
            '"eventDetails":{"uldNumber":"ULD123"},' +
            '"flightDetails":{"flightNumber":"QF001","flightArrivalDate":"2024-02-14T17:30:00+08:00"}' +
            '},' +
            '{' +
            '"eventName":"Ready for Collection",' +
            '"pieces":1,' +
            '"transactionDate":"2024-01-01T10:00:00Z",' +
            '"eventDetails":{"uldNumber":null}' +
            '}' +
            '],' +
            
            '"unitOfMeasures":{"weight":"kg"}' +
            '}';
         // res.setBody(json);
          res.setStatusCode(200);
        // Added by Bharath Inti
          res.setBody(json);
      }
        else if(awbOn == 'no'){
            String json = '{"shipmentSummary":{"awb":"081-18413673","shipmentDescription":"CRICKETS","handlingCodes":"AVI,SPX","shipmentOriginName":"ADELAIDE","shipmentDestinationName":"WHYALLA","shipmentOriginCode":"ADL","shipmentDestinationCode":"WYA","totalPieces":3,"totalWeight":5,"totalVolume":0.03,"productName":"APG PREMIUM","agentName":"STARTRACK MEL DOM"},"shipmentHistory":[{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T07:25:35+10:00","transactionDateUtc":"2023-04-12T21:25:35Z","pieces":3,"weight":5.3,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"ZL4512","flightDepartureDate":"2023-04-13T06:40:00+09:30","flightArrivalDate":"2023-04-13T07:30:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T07:40:14+10:00","transactionDateUtc":"2023-04-12T21:40:14Z","pieces":3,"weight":5.3,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:20:00+09:30","flightArrivalDate":"2023-04-13T17:10:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T08:00:58+10:00","transactionDateUtc":"2023-04-12T22:00:58Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:20:00+09:30","flightArrivalDate":"2023-04-13T17:10:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"DEP","airportCode":"ADL","transactionDate":"2023-04-13T16:13:00+09:30","transactionDateUtc":"2023-04-13T06:43:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:13:00+09:30","departureDateStatus":"Estimated","flightArrivalDate":"2023-04-13T16:57:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Departed"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"RCF","airportCode":"WYA","transactionDate":"2023-04-13T17:42:20+09:30","transactionDateUtc":"2023-04-13T08:12:20Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Checked In"},{"eventType":"NFD","airportCode":"WYA","transactionDate":"2023-04-13T17:42:20+09:30","transactionDateUtc":"2023-04-13T08:12:20Z","pieces":3,"weight":5,"flightDetails":{},"eventDetails":{},"eventName":"Notified"},{"eventType":"DLV","airportCode":"WYA","transactionDate":"2023-04-13T17:43:00+09:30","transactionDateUtc":"2023-04-13T08:13:00Z","pieces":3,"weight":5,"flightDetails":{},"eventDetails":{},"eventName":"Delivered"}],"unitOfMeasures":{"weight":"kg","volume":"cbm","length":"cm"}}';
         // res.setBody(json);
          res.setStatusCode(200);
         // Added by Bharath Inti
          res.setBody(json);
        }
        else if(awbOn == 'error'){ //CRM-10380 Added for Code Security Remediation
            String json = '{,,,,,,,,,",,{,,,[shipmentSummary":{"awb":"081-18413673","shipmentDescription":"CRICKETS","handlingCodes":"AVI,SPX","shipmentOriginName":"ADELAIDE","shipmentDestinationName":"WHYALLA","shipmentOriginCode":"ADL","shipmentDestinationCode":"WYA","totalPieces":3,"totalWeight":5,"totalVolume":0.03,"productName":"APG PREMIUM","agentName":"STARTRACK MEL DOM"},"shipmentHistory":[{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T07:25:35+10:00","transactionDateUtc":"2023-04-12T21:25:35Z","pieces":3,"weight":5.3,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"ZL4512","flightDepartureDate":"2023-04-13T06:40:00+09:30","flightArrivalDate":"2023-04-13T07:30:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T07:40:14+10:00","transactionDateUtc":"2023-04-12T21:40:14Z","pieces":3,"weight":5.3,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:20:00+09:30","flightArrivalDate":"2023-04-13T17:10:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"BKD","airportCode":"SYD","transactionDate":"2023-04-13T08:00:58+10:00","transactionDateUtc":"2023-04-12T22:00:58Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:20:00+09:30","flightArrivalDate":"2023-04-13T17:10:00+09:30","arrivalDateStatus":"Scheduled"},"eventDetails":{},"eventName":"Booked"},{"eventType":"DEP","airportCode":"ADL","transactionDate":"2023-04-13T16:13:00+09:30","transactionDateUtc":"2023-04-13T06:43:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightDepartureDate":"2023-04-13T16:13:00+09:30","departureDateStatus":"Estimated","flightArrivalDate":"2023-04-13T16:57:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Departed"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"ARR","airportCode":"WYA","transactionDate":"2023-04-13T16:55:00+09:30","transactionDateUtc":"2023-04-13T07:25:00Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071","flightArrivalDate":"2023-04-13T16:55:00+09:30","arrivalDateStatus":"Arrived"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Flight Arrived"},{"eventType":"RCF","airportCode":"WYA","transactionDate":"2023-04-13T17:42:20+09:30","transactionDateUtc":"2023-04-13T08:12:20Z","pieces":3,"weight":5,"flightDetails":{"segmentOrigin":"ADL","segmentDestination":"WYA","flightNumber":"QF2071"},"eventDetails":{"uldNumber":"BULK"},"eventName":"Checked In"},{"eventType":"NFD","airportCode":"WYA","transactionDate":"2023-04-13T17:42:20+09:30","transactionDateUtc":"2023-04-13T08:12:20Z","pieces":3,"weight":5,"flightDetails":{},"eventDetails":{},"eventName":"Notified"},{"eventType":"DLV","airportCode":"WYA","transactionDate":"2023-04-13T17:43:00+09:30","transactionDateUtc":"2023-04-13T08:13:00Z","pieces":3,"weight":5,"flightDetails":{},"eventDetails":{},"eventName":"Delivered"}],"unitOfMeasures":{"weight":"kg","volume":"cbm","length":"cm"}}';
         // res.setBody(json);
          res.setStatusCode(400); // CRM-13514: Fix test class Batch 4
         // Added by Bharath Inti
          res.setBody(json);
        }
        else{
            res.setStatusCode(400);
        }
        return res;
    }
}