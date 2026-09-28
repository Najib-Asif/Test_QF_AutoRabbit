/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_ServiceReqCaseCreationAPI
 History
************************************************************************************************
13-Feb-2025      Gandla Mallikarjuna               CRM-9196 Included EMD Details for Seats And Baggage Service Request


*/
@IsTest
public class QAC_ServiceReqCaseCreationAPI_Test {
    
    @isTest
    public static QAC_ServiceReqCaseCreationAPI testParse() {
        
		String json = '{'+
		'\"serviceRequest\":{'+
		'    \"correlationId\":\"C-94794998100001\",'+
		'    \"requestTimeStamp\":\"\",'+
		'    \"parentRequest\":\"\",'+
		'    \"requestCountryCode\": \"NZ\",'+
		'    \"requestOrigin\":\"QAC Website\",'+
		'    \"requestType\":\"Commercial Waiver (BART)\",'+
		'    \"requestSubType1\":\"Name Correction\",'+
		'    \"requestSubType2\":\"Ticketed - Qantas Operated and Marketed\",'+
		'    \"requestStatus\":\"Open\",'+
		'    \"remarkCategory\":\"some dummy value\",'+
		'    \"subject\":\"All Payments Test 100001\",'+
		'    \"description\":\"some dummy description value\",'+
		'    \"totalAttachments\" : \"5\",'+
		'    \"requestReason\":\"Typing Error in FirstName\",'+
		'    \"requestReasonSubType\":\"Correction more than three characters\",'+
		'    \"otherReason\":\"some dummy value\",'+
		'    \"authorityStatus\":\"Approved\",'+
		'    \"additionalRequirements\":\"some dummy addition requirements value\",'+
		'    \"costOfSale\":\"400\",'+
		'    \"isoCurrency\":\"NZD\",'+
		'    \"agencyIdentification\":{'+
		'        \"agencyReference\":\"9797979\",'+
		'        \"agentName\":\"Payments test\",'+
		'        \"agentPhone\":\"+61-410 510 610\",'+
		'        \"agentEmail\":\"abhijeet@gmail.com\"'+
		'    },'+
		'    \"bookingDetails\":{'+
		'        \"bookingReference\":\"454545\",'+
		'        \"oldBookingReference\":\"\",'+
		'        \"surname\":\"TestUser\",'+
		'        \"ticketNumber\":\"1111111\",'+
		'        \"emdNumber\":\"0818209997417\",'+
		'        \"bookingAgencyReference\":\"\",'+
		'        \"pseudoCityCode\":\"\",'+
		'        \"gds\":\"\",'+
		'        \"pointOfSale\":\"\",'+
		'        \"abn\":\"\",'+
		'        \"qantasCorportateIdentifier\":\"XYZ\",'+
		'        \"numberOfPassengers\":\"06\",'+
		'        \"travelType\":\"Domestic\",'+
		'        \"nextTravelDate\":\"2018-04-22\",'+
		'        \"waiverDate\":\"2018-04-22\",'+
		'        \"gdsJobReference\":\"\",'+
		'        \"ticketingTimeLimit\":\"\",'+
		'        \"highestFrequentFlyerTier\":\"\",'+
		'        \"frequentFlyerReference\":\"\",'+
		'        \"fareBasis\":\"\",'+
		'		\"emdDetails\": ['+
		'			{'+
		'				\"emdNum\": \"1233123\",'+
		'				\"emdType\": \"Seats - select a seat\"'+       
		'			},'+
		'			{'+
		'				\"emdNum\": \"1233123AS\",'+
		'				\"emdType\": \"Baggage\"'+
		'			}'+
		'		]'+
		'    },'+
		'    \"fareDetails\":{'+
		'        \"fareType\":\"\",'+
		'        \"privateFareCode\":\"\",'+
		'        \"regionCode\":\"\"'+
		'    },'+
		'    \"flights\":['+
		'    {'+
		'        \"flightNumber\":\"QF001\",'+
		'        \"cabinClass\":\"Y\",'+
		'        \"newCabinClass\":\"S\",'+
		'        \"couponNumber\":\"13\",'+
		'        \"flightDate\":\"2018-04-22\",'+
		'        \"departurePort\":\"SYD\",'+
		'        \"arrivalPort\":\"MEL\",'+
		'        \"arrivalTime\":\"0415+1\",'+
		'        \"departureTime\":\"2210-2\",'+
		'        \"fareBasis\":\"\"'+
		'    }'+
		'    ],'+
		'    \"passengers\":['+
		'    {'+
		'        \"salutation\":\"MR\",'+
		'        \"firstName\":\"Arun\",'+
		'        \"surname\":\"Rajendran\",'+
		'        \"passengerType\":\"Adult\",'+
		'        \"passengerSequence\":\"1\",'+
		'        \"passengerTattoo\":\"1\",'+
		'        \"frequentFlyerNumber\":\"\",'+
		'        \"flightNumber\":\"\",'+
		'        \"oldTicketNumber\":\"\",'+
		'        \"ticketNumber\":\"\",'+
		'        \"dateOfBirth\":\"\",'+
		'        \"newSalutation\":\"\",'+
		'        \"newFirstName\":\"\",'+
		'        \"newSurname\":\"\"'+
		'    },'+
		'    {'+
		'        \"salutation\":\"MR\",'+
		'        \"firstName\":\"Ajay\",'+
		'        \"surname\":\"Bharathan\",'+
		'        \"passengerType\":\"Adult\",'+
		'        \"passengerSequence\":\"2\",'+
		'        \"passengerTattoo\":\"1\",'+
		'        \"frequentFlyerNumber\":\"\",'+
		'        \"flightNumber\":\"\",'+
		'        \"oldTicketNumber\":\"\",'+
		'        \"ticketNumber\":\"\",'+
		'        \"dateOfBirth\":\"\",'+
		'        \"newSalutation\":\"\",'+
		'        \"newFirstName\":\"\",'+
		'        \"newSurname\":\"\"'+
		'    },'+
		'    {'+
		'        \"salutation\":\"\",'+
		'        \"firstName\":\"Aaron\",'+
		'        \"surname\":\"Littleton\",'+
		'        \"passengerType\":\"Infant\",'+
		'        \"passengerSequence\":\"1\",'+
		'        \"passengerTattoo\":\"1\",'+
		'        \"frequentFlyerNumber\":\"\",'+
		'        \"flightNumber\":\"\",'+
		'        \"oldTicketNumber\":\"\",'+
		'        \"ticketNumber\":\"\",'+
		'        \"dateOfBirth\":\"\",'+
		'        \"newSalutation\":\"\",'+
		'        \"newFirstName\":\"\",'+
		'        \"newSurname\":\"\"'+
		'    }'+
		'    ],'+
		'    \"comments\":['+
		'    {'+
		'        \"commentDescription\":\"Comment 1\",'+
		'        \"creationTimestamp\":\"2018-04-21 11:22:33\"'+
		'    },'+
		'    {'+
		'        \"commentDescription\":\"Comment 2\",'+
		'        \"creationTimestamp\":\"2018-04-22 12:22:33\"'+
		'    }'+
		'    ],'+
		'	\"agencyClassifications\": ['+
		'	{'+
		'			\"type\": \"Commercial Deal or Buying Group\",'+
		'			\"subType\": \"\"'+
		'    }'+
		'    ]'+
		'}'+
		'}';
        
        QAC_ServiceReqCaseCreationAPI obj = QAC_ServiceReqCaseCreationAPI.parse(json);
        System.assert(obj != null);
        return obj;
    }
}