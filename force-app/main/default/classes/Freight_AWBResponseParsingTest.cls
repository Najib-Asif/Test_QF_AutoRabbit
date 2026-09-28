@isTest
private class Freight_AWBResponseParsingTest {
    
    static testMethod void testParse() {
        String json = '{'+
        '  \"Envelope\": {'+
        '    \"Body\": {'+
        '      \"shipmentMilestones\": {'+
        '        \"shipmentsTracked\": {'+
        '          \"shipmentPrefix\": \"081\",'+
        '          \"masterDocumentNumber\": \"85606625\",'+
        '          \"origin\": \"SYDNEY\",'+
        '          \"destination\": \"SINGAPORE\",'+
        '          \"shipmentDescription\": \"CHILLED MEAT\",'+
        '          \"handlingCode\": \"ECC,ICE,PEM\",'+
        '          \"pieces\": \"1\",'+
        '          \"weight\": \"1450.0\",'+
        '          \"weightUnit\": \"Kg\",'+
        '          \"units\": \"AKE\",'+
        '          \"latestStatus\": {'+
        '            \"station\": \"SYD\",'+
        '            \"milestone\": \"Booked\",'+
        '            \"shipmentdate\": \"09-Jun-2017 13:06:41\",'+
        '            \"weight\": \"1450.0\",'+
        '            \"pieces\": \"1\",'+
        '            \"flightDetails\": \"QF0005,DEP ; SYD.22-Jun-2017 15:50(S) ARR ; SIN. 22-Jun-2017 22:15(S)\",'+
        '            \"unit\": \"AKE-1\"'+
        '          },'+
        '          \"history\": {'+
        '            \"station\": \"SYD\",'+
        '            \"milestone\": \"Booked\",'+
        '            \"shipmentdate\": \"09-Jun-2017 13:06:41\",'+
        '            \"weight\": \"1450.0\",'+
        '            \"pieces\": \"1\",'+
        '            \"flightDetails\": \"QF0005,DEP ; SYD.22-Jun-2017 15:50(S) ARR ; SIN. 22-Jun-2017 22:15(S)\",'+
        '            \"unit\": \"AKE-1\"'+
        '          }'+
        '        }'+
        '      }'+
        '    }'+
        '  }'+
        '}';
        Freight_AWBResponseParsing obj = Freight_AWBResponseParsing.parse(json);
        System.assert(obj != null);
    }

    static testMethod void testParseWithoutJsonException() {
        String json = '{'+
                        '"shipmentSummary": {'+
                        '"awb": "081-56274540", "origin": "SYD", "originStationName": "SYDNEY",'+
                        '"destination": "MNL", "destinationStationName": "MANILA", "statedPieces": 1,'+
                        '"statedWeight": "58.0", "statedVolume": 0.645, "shipmentDescription": "1 X LIVE DOG",'+
                        '"handlingCodes": "AVI,EAP,PSR,SPX", "product": "QGO PETS", "productDisplayName": "QGO PETS",'+
                        '"agent": "CT FREIGHT PTY LTD", "consigneeName": "KARL CHWALCZYK C O PET TRANSPRO", "shipperName": "PETFLYERS PTY LTD",'+
                        '"subProduct": null,'+
                        '"stageSummary": {'+
                            '"STAGE_BOOKED": "INACTIVE", "STAGE_DELIVERY": "INACTIVE",'+
                            '"STAGE_GOT_YOUR_FREIGHT": "INACTIVE", "STAGE_INTRANSIT": "INACTIVE",'+
                            '"STAGE_PREDELIVERY": "ACTIVE"'+
                        '},'+
                        '"bookingStatus": null'+
                    '},'+
                    '"shipmentHistory": ['+
                        '{ "eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                            '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                            '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                            '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00","arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                            '},'+
                            '"eventDetails": {},"bookingSequence": 1,"eventName": "Flight details",'+
                            '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                        '}'+
                    '],'+
                    '"unitOfMeasures": { "weight": "kg","volume": "cbm","length": "cm"},'+
                    '"shipmentStages": {'+
                        '"STAGE_BOOKED": {'+
                            '"events": ['+
                                '{'+
                                    '"eventType": "BKD","airportCode": "SYD","transactionDate": "2024-01-31T14:42:49+11:00",'+
                                    '"transactionDateUtc": "2024-01-31T03:42:49Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                    '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                    '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {}, "bookingSequence": 1, "eventName": "Flight details",'+ 
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '},'+
                                '{'+
                                    '"eventType": "BKD","airportCode": "AKL","transactionDate": "2024-02-09T11:41:02+13:00",'+
                                    '"transactionDateUtc": "2024-02-08T22:41:02Z","pieces": 1,"weight": 58,'+
                                    '"flightDetails": { "segmentOrigin": "SYD","segmentDestination": "MNL","flightNumber": "QF0019",'+
                                        '"flightDepartureDate": "2024-02-14T12:20:00+11:00","flightArrivalDate": "2024-02-14T17:30:00+08:00",'+
                                        '"arrivalDateStatus": "Scheduled","arrivalStatus": "S"'+
                                    '}, "eventDetails": {},"bookingSequence": 2,"eventName": "Updated flight details",'+
                                    '"stageCode": "STAGE_BOOKED","stageName": "Booked","isLatest": false'+
                                '}'+
                            '],'+
                            '"status": "INACTIVE"'+
                        '}'+
                    '}'+
                '}';
        Freight_AWBResponseParsing obj = Freight_AWBResponseParsing.parseWithoutJsonException(json);
        System.assert(obj != null);
    }
}