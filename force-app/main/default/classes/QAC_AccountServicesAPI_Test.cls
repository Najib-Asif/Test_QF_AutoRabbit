/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Bharathan
Company:       TCS
Description:   RestAPI JSON Parsing Class - QAC_AccountServicesAPI's test class
Test Class:         
*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design
********************************************************************************************************************************/
@IsTest
public class QAC_AccountServicesAPI_Test {
    
    static testMethod void testParse() {
        String json = '{  '+
            '    \"agencyRegistration\":{  '+
            '        \"accountDetail\":{  '+
            '            \"referenceID\":\"TBD\",'+
            '            \"agencyName\":\"Qantas Test 1\",'+
            '            \"legalName\":\"Flight Centre Travel Group Limited \",'+
            '            \"agencyChain\":\"Flight Centre Retail North\",'+
            '            \"agencySubChain\" : \"Flight Centre Brand\",'+
            '            \"primaryAgencyBusiness\":\"Agency Prospect\",'+
            '            \"iataCode\":\"9934567\",'+
            '            \"tidsCode\":\"1114000\",'+
            '            \"agencyABN\":\"84003237789\",'+
            '            \"qbrMembershipNumber\":\"11221122\",'+
            '            \"agencyAddressLine1\":\"abcd Street\",'+
            '            \"city\":\"Sydney\",'+
            '            \"stateCode\":\"NSW\",'+
            '            \"countryCode\":\"AU\",'+
            '            \"postalCode\":\"2135\",'+
            '            \"atolNumber\":\"\",'+
            '            \"abtaNumber\":\"\",'+
            '            \"bookingEngineAccess\":\"True\",'+
            '            \"dialCode\":\"+61\",'+   
            '            \"phoneNumber\":\"-02-02345678\",'+
            '            \"faxNumber\":\"+61-02-44555666\",'+
            '            \"employees\":\"5000\",'+
            '            \"officeType\":\"Qantas Office\",'+
            '            \"website\":\"somesite.com\",'+
            '            \"accountEmail\":\"test@example.com\",'+
            '            \"contactDetails\":[  '+
            '                {  '+
            '                    \"referenceID\":\"TBD\",'+
            '                    \"salutation\":\"Ms\",'+
            '                    \"firstName\":\"Caley\",'+
            '                    \"lastName\":\"Britto\",'+
            '                    \"preferredName\":\"caleyB\",'+
            '                    \"jobTitle\":\"Developer\",'+
            '                    \"jobFunction\":\"IT\",'+
            '                    \"frequentFlyerNumber\":\"\",'+
            '                    \"jobRole\":\"Board member\",'+
            '                    \"email\":\"sample1@salesforce.com\",'+
            '                    \"phone\":\"+61-02-12345678\",'+
            '                    \"mobile\":\"+61-02-11222666\"'+
            '                },'+
            '                {  '+
            '                    \"referenceID\":\"QACNewContact2\",'+
            '                    \"salutation\":\"Mr\",'+
            '                    \"firstName\":\"John\",'+
            '                    \"lastName\":\"Smith\",'+
            '                    \"preferredName\":\"JohnnyS\",'+
            '                    \"jobTitle\":\"Executive\",'+
            '                    \"jobFunction\":\"HR\",'+
            '                    \"frequentFlyerNumber\":\"\",'+
            '                    \"jobRole\":\"Director\",'+
            '                    \"email\":\"sample2@salesforce.com\",'+
            '                    \"phone\":\"+61-02-12346678\",'+
            '                    \"mobile\":\"+61-02-11222333\"'+
            '                }'+
            '            ],'+
            '            \"tmcDetails\":[  '+
            '                {  '+
            '                    \"referenceID\":\"QACNewTMC1\",'+
            '                    \"recordType\":\"GDS\",'+
            '                    \"gdsCode\":\"Amadeus\",'+
            '                    \"pseudoCityCode\":\"2yu4\"'+
            '                },'+
            '                {  '+
            '                    \"referenceID\":\"QACNewTMC2\",'+
            '                    \"recordType\":\"GDS\",'+
            '                    \"gdsCode\":\"Galileo\",'+
            '                    \"pseudoCityCode\":\"12mt\"'+
            '                }'+
            '            ],'+
            '            \"ticketingAuthorityDetails\":[  '+
            '                {  '+
            '                    \"iataCode\":\"1114700\",'+
            '                    \"iataName\":\"Qantas Test 1a\"'+
            '                },'+
            '                {  '+
            '                    \"iataCode\":\"1114701\",'+
            '                    \"iataName\":\"Qantas Test 1b\"'+
            '               },'+
            '                {  '+
            '                    \"iataCode\":\"1114702\",'+
            '                    \"iataName\":\"Qantas Test 1c\"'+
            '                },'+
            '                {  '+
            '                    \"iataCode\":\"1114703\",'+
            '                    \"iataName\":\"Qantas Test 1d\"'+
            '               }               '+
            '            ]          '+
            '        }'+
            '    }'+
            '}';
        QAC_AccountServicesAPI obj = QAC_AccountServicesAPI.parse(json);
        System.assert(obj != null);
    }
}