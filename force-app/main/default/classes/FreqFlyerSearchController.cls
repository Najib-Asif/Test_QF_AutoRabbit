/***********************************************************************************************************************************

Description: Apex controller to Make a callout and create Frequent flyer records once the Frequent Flyer Number's entered in Case as comma seperated values 
History:
======================================================================================================================
Name                    Jira        Description                                                                Tag
======================================================================================================================
Priyadharshini Vellingiri   CRM-3356    Apex controller to retrieve the Loyalty response in the JSON Format and 
create Frequent flyer records once the Frequent Flyer Number's entered in Case as comma seperated values            T01

Created Date    : 11/10/2018 (DD/MM/YYYY) 
***************************************************************************************
Modified Date : 6 October 2021
Comments     : JIRA CRM - 5003 | Introduced 3 different callouts |Modified existing wrapper structure | Member API Version 2 changes 
*********************************************************************************/

public with sharing class FreqFlyerSearchController {
    
    @auraEnabled
    Public static List<string> invokeWebServiceCAP(String ffnumber) {
        system.debug('ffnumber'+ffnumber);
        String [] arrayOfResponsestrings = new List<String>();
        String [] arrayOfResponseContactstrings = new List<String>();
        String [] arrayOfResponsesTierstrings = new List<String>();
        Set<String> uniqueValues = new Set<String>();
        
        for(String numb : ffnumber.split(',')) {
            String num = numb.trim();
            System.debug('num========> ' + num);
            /* Commented below loyaltyResponse callout and introduced 4 different API callouts as part of
              Member API V2 changes CRM - 5003 */
            /*QCC_LoyaltyResponseWrapper loyaltyResponse = QCC_InvokeCAPAPI.invokeLoyaltyAPI(num);*/
            QCC_LoyaltyResponseWrapper.Programs loyaltyProgramResponse = QCC_InvokeCAPAPI.invokeLoyaltyProgramAPI(num);
            system.debug('loyaltyProgramResponse'+loyaltyProgramResponse);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile loyaltyProfileResponse = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI(num);
            system.debug('loyaltyProfileResponse'+loyaltyProfileResponse);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(num);
            system.debug('loyaltyContactResponse'+loyaltyContactResponse);
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier loyaltyTierResponse = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI(num);
            system.debug('loyaltyTierResponse'+loyaltyTierResponse);
            /*if(loyaltyResponse != null){  
                uniqueValues.add(JSON.serialize(loyaltyResponse));*/ /*CRM-5003*/
            QCC_LoyaltyResponseWrapper loyaltyResponse = new QCC_LoyaltyResponseWrapper();
            if (loyaltyProgramResponse != null) {
                loyaltyResponse.programs.add(loyaltyProgramResponse);
            }
            if(loyaltyProfileResponse != null){
                loyaltyResponse.qantasFrequentFlyerProfile = loyaltyProfileResponse;
                System.debug('loyaltyResponse.QantasFrequentFlyerProfile :'+ loyaltyResponse.QantasFrequentFlyerProfile);
            }
                       
            if(loyaltyContactResponse != null) {
                loyaltyResponse.qantasFrequentFlyerContact = loyaltyContactResponse;
                System.debug('loyaltyResponse.qantasFrequentFlyerContact :' + loyaltyResponse.qantasFrequentFlyerContact);
            }
            
            if(loyaltyTierResponse != null) {
                loyaltyResponse.qantasFrequentFlyerTiers.add(loyaltyTierResponse);
                System.debug('loyaltyResponse.qantasFrequentFlyerTiers :'+ loyaltyResponse.qantasFrequentFlyerTiers);
            }
            System.debug('loyaltyResponse '+ loyaltyResponse);
            if(loyaltyResponse != null){
                uniqueValues.add(JSON.serialize(loyaltyResponse));
                System.debug('uniqueValues :'+uniqueValues);
            }
        }
        for(Integer i=0 ;i<arrayOfResponsestrings.size() ; i++) {
            system.debug('IterateoverResponseofStrings- 1 '+arrayOfResponsestrings[i]);
        }
        //add unique values to list
        arrayOfResponsestrings.addall(uniqueValues);
        System.debug('arrayOfResponsestrings :'+arrayOfResponsestrings);
        return arrayOfResponsestrings;
    } 
    
    @AuraEnabled
    public static String addParentCase(String caseId, String accountId, String results,String RecordType)
    {      
        try {
            Map<String, Integer> monthAndMonthNumberMap = new Map<String, Integer>();
            /*monthAndMonthNumberMap.put('Jan', 1);
            monthAndMonthNumberMap.put('Feb', 2);
            monthAndMonthNumberMap.put('Mar', 3);
            monthAndMonthNumberMap.put('Apr', 4);
            monthAndMonthNumberMap.put('May', 5);
            monthAndMonthNumberMap.put('Jun', 6);
            monthAndMonthNumberMap.put('Jul', 7);
            monthAndMonthNumberMap.put('Aug', 8);
            monthAndMonthNumberMap.put('Sep', 9);
            monthAndMonthNumberMap.put('Oct', 10);
            monthAndMonthNumberMap.put('Nov', 11);
            monthAndMonthNumberMap.put('Dec', 12);Commented and modified based on new response V2*/
            monthAndMonthNumberMap.put('01', 1);
            monthAndMonthNumberMap.put('02', 2);
            monthAndMonthNumberMap.put('03', 3);
            monthAndMonthNumberMap.put('04', 4);
            monthAndMonthNumberMap.put('05', 5);
            monthAndMonthNumberMap.put('06', 6);
            monthAndMonthNumberMap.put('07', 7);
            monthAndMonthNumberMap.put('08', 8);
            monthAndMonthNumberMap.put('09', 9);
            monthAndMonthNumberMap.put('10', 10);
            monthAndMonthNumberMap.put('11', 11);
            monthAndMonthNumberMap.put('12', 12);
            Set<String> loffinstr = new Set<String>();
            List<Frequent_Flyer_Information__c> DFFlist= new list<Frequent_Flyer_Information__c>([SELECT Frequent_Flyer_Number__c FROM Frequent_Flyer_Information__c WHERE Case__c =:CaseId ]);
            Map<String,String> ffmap = new Map<String,String>();
            
            for(Frequent_Flyer_Information__c finfo : DFFlist ){
                loffinstr.add(finfo.Frequent_Flyer_Number__c);
                ffmap.put(finfo.Frequent_Flyer_Number__c, finfo.id);
            }
            List<Frequent_Flyer_Information__c> lstFreqFlyers = new List<Frequent_Flyer_Information__c>();
            List<Frequent_Flyer_Information__c> lstFreqFlyersUpdate = new List<Frequent_Flyer_Information__c>();
            List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(results);
            System.debug('ffmap'+results);
            
            if(!fieldList.isEmpty()) {
                for(Object fld : fieldList){  
                    system.debug('fld______)))************'+fld);
                    Map<String,Object> data = (Map<String,Object>)fld;
                    system.debug(data.get('key1'));
                    if(!loffinstr.contains(String.valueOf(data.get('key2'))))  {    
                        Frequent_Flyer_Information__c FFrecs = new Frequent_Flyer_Information__c();
                        system.debug('InsideIf'+(String.valueOf(data.get('key2'))));
                        FFrecs.Case__c = caseId;
                        FFrecs.Account__c = accountId;
                        FFrecs.Name = String.valueOf(data.get('key1'));
                        FFrecs.Frequent_Flyer_Number__c = String.valueOf(data.get('key2'));
                        FFrecs.Frequent_Flyer_Email__c = String.valueOf(data.get('key3'));
                        FFrecs.Current_Tier__c = String.valueOf(data.get('key4'));
                        
                        String myDateStr = String.valueOf(data.get('key5'));
                        System.debug('$$$ mydateStr: '+ myDateStr);
                        if (myDateStr != null)
                        {
                            List<String> myDateList = myDateStr.split('-');
                            Integer yearVal = Integer.valueOf(myDateList.get(0));
                            system.debug('yearVal'+yearVal);
                            Integer monthVal = monthAndMonthNumberMap.get(myDateList.get(1));
                            system.debug('monthVal'+monthVal);
                            Integer dayVal = Integer.valueOf(myDateList.get(2));
                            system.debug('dayVal'+dayVal);
                            date mydate = date.newinstance(yearVal,monthVal,dayVal);
                            system.debug('mydate'+mydate);
                            FFrecs.Freq_Flyer_Expiry_Date__c = mydate;  
                        }
                        
                        System.debug('FerqFlyerExpiryDate'+FFrecs.Freq_Flyer_Expiry_Date__c);
                        FFrecs.Request_Type__c = String.valueOf(data.get('key6'));
                        FFrecs.Upgrade_Tier_Requested__c = String.valueOf(data.get('key7'));  
                        
                        lstFreqFlyers.add(FFrecs);     
                    }else{
                        Frequent_Flyer_Information__c FFrecs = new Frequent_Flyer_Information__c();
                        FFrecs.id = ffmap.get(String.valueOf(data.get('key2')));
                        // Uncomment the statements if the below fields(retrieved from the API) needs to be editable
                        /*FFrecs.Case__c = caseId;
                        FFrecs.Account__c = accountId;
                        FFrecs.Name = String.valueOf(data.get('key1'));
                        FFrecs.Frequent_Flyer_Number__c = String.valueOf(data.get('key2'));
                        FFrecs.Frequent_Flyer_Email__c = String.valueOf(data.get('key3'));
                        FFrecs.Current_Tier__c = String.valueOf(data.get('key4'));
                        
                        String myDateStr = String.valueOf(data.get('key5'));
                        System.debug('$$$ mydateStr: '+ myDateStr);
                        List<String> myDateList = myDateStr.split('-');
                        Integer yearVal = Integer.valueOf(myDateList.get(2));
                        Integer monthVal = monthAndMonthNumberMap.get(myDateList.get(1));
                        Integer dayVal = Integer.valueOf(myDateList.get(0));
                        date mydate = date.newinstance(yearVal,monthVal,dayVal);
                        FFrecs.Freq_Flyer_Expiry_Date__c = mydate;  
                        System.debug('FerqFlyerExpiryDate'+FFrecs.Freq_Flyer_Expiry_Date__c);*/
                        FFrecs.Request_Type__c = String.valueOf(data.get('key6'));
                        FFrecs.Upgrade_Tier_Requested__c = String.valueOf(data.get('key7'));                       
                        lstFreqFlyersUpdate.add(FFrecs);                     
                    } 
                }
            }
            System.debug('lstFreqFlyers***'+lstFreqFlyers);
            System.debug('lstFreqFlyersUpdate***'+lstFreqFlyersUpdate);
            if(lstFreqFlyers!=null){
                insert lstFreqFlyers;  
            }
            if(lstFreqFlyersUpdate!= null){
                update lstFreqFlyersUpdate;
            }          
        }   catch(Exception ex){
            system.debug('ex###############'+ex);
        }
        
        String success = '';
        success = 'Frequent Flyer Record(s) has been created successfully';
        return success;
    }
}