/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : Utility Class referred in QAC_ServiceReqCaseCreationProcess
*/

public with sharing class QAC_CaseMappingUtility 
{
    public static String fetchGDSValues(String gdsCode)
    {
        String gds;
        gds = (gdsCode == '1A') ? 'Amadeus' : 
        (gdsCode == '1G') ? 'Galileo' : 
        (gdsCode == '1S') ? 'Sabre' : 
        (gdsCode == '1V') ? 'Apollo' : 
        (gdsCode == '1P') ? 'Worldspan' :
        (gdsCode == 'F1') ? 'QDP':'';
        return gds;
    }    
    public static String fetchCustomerTierValues(String tierCode)
    {
        String tier;
        //String formattedString = String.format('Chairman\'\'{0} {1}', new String[]{'s', 'Lounge'});
        tier = (tierCode == 'FFBR') ? 'BR-NON' : 
        (tierCode == 'FFSL') ? 'SL' : 
        (tierCode == 'FFGD') ? 'GD' : 
        (tierCode == 'FFPL') ? 'PL' : 
        (tierCode == 'CLQF') ? 'CL' : 
        (tierCode == 'FFPO') ? 'PO' : 'NON-TIERED';
        return tier;
    } 
    
    
    public static String fetchPassengerType(String passtype){
        String passengerType;
        passengerType = (Passtype == 'INF') ? 'Infant' : 
                        (Passtype == 'CHD') ? 'Child' : 'Adult';
        return passengerType;
    }  
}