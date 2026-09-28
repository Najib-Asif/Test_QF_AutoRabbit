/*
Main Class: BcpIntegration
Author: Navpreet Kaur
Jira Ticket: CRM-7937
Description: 
 */
@isTest
private with sharing class BcpIntegrationTest {
   
    private static testmethod void myUnitTestWithData() 
    {
        try 
        {
            test.startTest();

            String bcpPayload = '{"serviceType":{"bookingType":"Existing Booking","departureType":"Departureoutside24hwindow",'
            + '"serviceRequest":"Schedule Change","requestType":"Rebook flight","critRequirement":"Yes",'
            + '"affectedByScheduleChange":"Yes","classUpgrade":"Business","nameChangeAgree":"Yes","holdingTicket":"Economy",'
            + '"ticketNumber":"UTYPO9","holdingCreditReason":"Loyalty"},"bookingDetails":{"fareType":"Business",'
            + '"accountCode":"010","flexibleWithFare":"Yes","flexibleWithCabin":"Yes","cabinClass":"A",'
            + '"destination":"Melbourne","departureDate":"22/02/2025","returnDate":"22/03/2025","flexibleWithDates":"Yes",'
            + '"bookingNumber":"PNR123","surName":"Kaur","ticketNumber":"UTYPO9","firstName":"Navpreet",'
            + '"cancelType":"FullRefundable","tripType":"round","segmentDetails":[{"origin":"Sydney","destination":"Melbourne",'
            + '"departureDate":"22/02/2025","returnDate":"22/03/2025","flexibleWithDates":"Yes"}],"flightDetails":'
            + '[{"flightNumber":"QF-809","flightDate":"22/02/2025"}],"paxDetails":[{"firstName":"Navpreet","surName":"Kaur"},'
            + '{"firstName":"Zain","surName":"Seraj"}]},"requestDetails":{"bookingQuoted":"Yes","requestNumber":"REQ009",'
            + '"emd":"REQ009","holdTicket":"PNR123","fareType":"Business","accountCode":"010","change":"Cabin",'
            + '"ticketNumber":"UTYPO9","changeDescription":"CABINChangeUrgent","waiverType":"Y","waiverReason":"CCU",'
            + '"detailDescription":"NOTAPPLICABLE","supportDoc":[],"flightDetails":[{"currentFlightNumber":"QF-809",'
            + '"desiredTime":"23/02/2025","preferredFlightNumber":"QF-810","departureDate":"22/02/2025","newOrigin":"Melbourne",'
            + '"newDestination":"Sydney","preferredTimeOrFlight":"Time","cancelSegment":"Yes","flexibleWithTime":"Yes",'
            + '"newDepartureDate":"23/02/2025","newReturnDate":"23/03/2025","flexibleWithDate":"Yes","newFareType":"Business",'
            + '"accountCode":"010","bestFare":"120","cabinClass":"Business","hasSpecialReq":"Yes","specialRequirements":'
            + '[{"requirement":"Yes","flightNumber":"QF-809","companionFirstName":"Navpreet","companionMiddleName":"SomeName",'
            + '"companionSurName":"Kaur","companionBookingNumber":"PNR234","preferredLang":"English","travelType":"round",'
            + '"meetAssist":"Yes","wheelchairType":"Yes","additionalInfo":"Yes"}]}],"paxDetails":[{"isPrimary":"Yes",'
            + '"firstName":"Navpreet","middleName":"Somename","surName":"Kaur","dateOfBirth":"04/12/2001","countryCode":"AU",'
            + '"contact":"8738478473","loyaltyProgram":"Yes","loyaltyProgramNumber":"6142209","mealRequirement":"Non-Veg",'
            + '"hasSpecialReq":"Yes","assoAdultFirstName":"Navpreet","assoAdultSurName":"Kaur","babyMealRequirement":"Yes",'
            + '"specialRequirements":[{"requirement":"Yes","flightNumber":"QF-809","companionFirstName":"Navpreet",'
            + '"companionMiddleName":"SomeName","companionSurName":"Kaur","companionBookingNumber":"PNR234",'
            + '"preferredLang":"English","travelType":"round","meetAssist":"Yes","wheelchairType":"Yes",'
            + '"additionalInfo":"Yes"}]}]},"contactDetails":{"agencyName":"TravelLimitless","yourName":"Navpreet",'
            + '"email":"navpreet.kaur@qantas.com.au","countryCode":"AU","mobile":"7846384783","submitType":"online"}}';
            
            //StaticResource getJson=[select id,body from staticResource where name=:'qacBcpPayload' and ContentType=: 'application/json' limit 1];   
            Map<String,object> createArgs=new Map<String,object>();
            String resourcePath='/services/apexrest/customapi/*';
            String requestURI='/customapi/Qantas/v1/createcase';
            String extensionClass = 'BcpIntegration'; 
            Map<String,String> createHeaders=new Map<String,String>();
            createHeaders.put('Accept','application/json');
            createHeaders.put('Accept-Encoding','gzip');
            createHeaders.put('Content-Type','application/json');
            createHeaders.put('Host','qantas--baudev.sandbox.my.salesforce.com');
            
            
    
            System.RestRequest newReq=new System.RestRequest();
            newReq.headers.putAll(createHeaders);
            newReq.httpMethod='POST';
            newReq.params.put('source','bcp');
            newReq.requestBody=Blob.valueof(bcpPayload);
            newReq.requestURI=requestURI;
            newReq.resourcePath=resourcePath;
            
            System.RestResponse newRes=new System.RestResponse();
            newRes.responseBody=null;
            newRes.statusCode=200;
    
            createArgs.put('restRequest',newReq);
            createArgs.put('restResponse',newRes);
            //Object objReqHeader=new Object('Accept:','','');
            
            List<Trigger_Status__c> records = new List<Trigger_Status__c>();
            Trigger_Status__c record1 = new Trigger_Status__c(
            Name = 'ContentDocLinkTriggerCheck',
            Active__c = true
            );
            records.add(record1);
            upsert records;
            
    
            Callable extension = (Callable) Type.forName(extensionClass).newInstance();
            extension.call('createCase', createArgs);
            //extension.call('null', createArgs);
    
            test.stopTest();    
        } catch (Exception e) {
            system.debug('Exception has occurred in myUnitTestWithData'+ e.getMessage()); 
        }

       
    }
    private static testmethod void myUnitTestWithoutData() 
    {
        try 
        {
            String extensionClass = 'BcpIntegration';
            Map<String,object> createArgs=new Map<String,object>();    

            test.startTest();
            Callable extension = (Callable) Type.forName(extensionClass).newInstance();
            
            extension.call('null', createArgs);
            test.stopTest();
            
        } catch (Exception e) 
        {
            system.debug('Exception has occurred in myUnitTestWithoutData'+ e.getMessage());    
        }
    }
}