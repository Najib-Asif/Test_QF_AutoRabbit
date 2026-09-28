/**
 * Jira: CRM-9902 
 * Last Modified By: Navpreet Kaur
 * Date modified: 18 June 2026
 * Description: To include the logic of Cabin Class Range for Suggested Recovery Points
 * Test Class: QCC_QantasPointsSuggestedValuesTest
 */
public with sharing class QCC_QantasPointsSuggestedValues {
    @AuraEnabled(cacheable=true)
    public static Map<String,Decimal> getSuggestedValues(String caseNumber, Id contactId) {
        Map<String,Decimal> suggestedValuesMap = new Map<String,Decimal>();
            try {
                System.debug('QCC_QantasPointsSuggestedValues getSuggestedValues caseNumber contactId:::'+caseNumber+':'+contactId);
                String recoveryType1 = CustomSettingsUtilities.getConfigDataMap('Case Recovery Type 1');
                String recoveryType2 = CustomSettingsUtilities.getConfigDataMap('Case Recovery Type 2');
                String nonTier = CustomSettingsUtilities.getConfigDataMap('Non-Tier FF');
                String bronzeTier = CustomSettingsUtilities.getConfigDataMap('Bronze FF');
                String silverTier = CustomSettingsUtilities.getConfigDataMap('Silver FF');
                String goldTier = CustomSettingsUtilities.getConfigDataMap('Gold FF');
                String platinumTier = CustomSettingsUtilities.getConfigDataMap('Platinum FF');
                String platinumOneTier = CustomSettingsUtilities.getConfigDataMap('Platinum One FF');
                String caseReopened = CustomSettingsUtilities.getConfigDataMap('CaseStatusReopened');
                String none = CustomSettingsUtilities.getConfigDataMap('None Value');
                String pointCalculationType1 = CustomSettingsUtilities.getConfigDataMap('Point Calculation Type 1');
                String pointCalculationType2 = CustomSettingsUtilities.getConfigDataMap('Point Calculation Type 2');
                String pointCalculationType3 = CustomSettingsUtilities.getConfigDataMap('Point Calculation Type 3');
                String durationRange1 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 1');
                String durationRange2 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 2');
                String durationRange3 = CustomSettingsUtilities.getConfigDataMap('Flight Duration Range 3');
                String qantasPoints = CustomSettingsUtilities.getConfigDataMap('Qantas Points Type');
                String finalised = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised');
                String key;
                List<QCC_Suggested_Recovery__mdt> suggestedRecoveryData = new List<QCC_Suggested_Recovery__mdt>();
                Map<String, QCC_Suggested_Recovery__mdt> metadataMap = new Map<String, QCC_Suggested_Recovery__mdt>();
                system.debug('Print the Point Calculation Type 3'+pointCalculationType3);
                suggestedRecoveryData = [SELECT Label,Type__c, Group__c, Category__c, Sub_Category__c, Point_Calculation__c,
                                         Tier__c, Flight_Duration__c, Classification__c,Cabin__c, Recovery_Type__c, Min_Value__c, Max_Value__c
                                         FROM QCC_Suggested_Recovery__mdt];
                for(QCC_Suggested_Recovery__mdt meta: suggestedRecoveryData) {
                    if(meta.Point_Calculation__c == pointCalculationType1){
                        key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c+''+meta.Tier__c+''+meta.Recovery_Type__c;
                    } else if(meta.Point_Calculation__c == pointCalculationType2) {
                        key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c+''+meta.Tier__c+''+meta.Recovery_Type__c+''+meta.Flight_Duration__c;
                    }else if(meta.Point_Calculation__c == pointCalculationType3){ //CRM-9902 to introduce Cabin and Flight Durations Points Ranges
                        system.debug('Enterred the Point Calculation Type 3'+meta.Point_Calculation__c);
                        key = meta.Group__c+''+meta.Category__c+''+meta.Flight_Duration__c+''+meta.Cabin__c;
                        system.debug('Print key for the Point Calculation Type 3'+key);
                    }else {
                        key = meta.Group__c+''+meta.Category__c+''+meta.Sub_Category__c+''+meta.Classification__c;
                    }
                    
                    key = key.toLowerCase();
                    //System.debug('Parent key = '+key);
                    metadataMap.put(key, meta);
                    system.debug('print the keyset'+metadataMap.keyset());
                }
                System.debug('Map Size ---> '+metadataMap.size());
                //System.debug('Recovery Id ' + recId);
                Set<Id> contactIds = new Set<Id>();
                Set<Id> caseIds = new Set<Id>();
                Set<Id> caseIdsWithCaseCategories = new Set<Id>();
                Map<Id, List<Case_Category__c>> caseCategoriesMap = new Map<Id, List<Case_Category__c>>();
                Map<Id, Contact> contactMap = new Map<Id, Contact>();
                Map<Id, Case> caseMap = new Map<Id, Case>();
                Map<Id, List<Case>> contactCasesMap = new Map<Id, List<Case>>();
                Map<Id, List<Case_Category__c>> contactCaseCategoriesMap = new Map<Id, List<Case_Category__c>>();
               
                    contactIds.add(contactId);
                    caseIds.add(caseNumber);
                
                for(Contact con: [SELECT Id, Name, Frequent_Flyer_Tier__c FROM Contact WHERE Id = :contactIds]){
                    contactMap.put(con.Id, con);
                }
                
                for(Case cs: [SELECT Id, Type, Group__c, Cabin_Class__c, Category__c, Sub_Category__c, Classification__c, ContactId, Status, Flight_Duration__c, Case_Category_Count__c, (SELECT Id, Amount__c, Status__c FROM Recoveries_Case__r WHERE Type__c =: qantasPoints AND Status__c =: finalised) FROM Case WHERE Id = :caseIds and (Origin!='Red App' and status!='Closed') limit 1000]) {
                    caseMap.put(cs.Id, cs);
                    if(cs.Case_Category_Count__c > 0) {
                        caseIdsWithCaseCategories.add(cs.Id);
                        system.debug('Case with category'+cs.Case_Category_Count__c);
                    }
                }
                
                if(caseIdsWithCaseCategories != null && caseIdsWithCaseCategories.size() > 0) {
                    for(Case_Category__c cs: [SELECT Group__c, Category__c, Sub_Category__c, Classification__c, Case__c FROM Case_Category__c WHERE Case__c = :caseIdsWithCaseCategories]) {
                        if(caseCategoriesMap.containsKey(cs.Case__c)){caseCategoriesMap.get(cs.Case__c).add(cs);
                        }
                        else {
                            List<Case_Category__c> c = new List<Case_Category__c>();
                            c.add(cs);
                            caseCategoriesMap.put(cs.Case__c, c);
                        }
                    }
                }
                
                //CRM-7851: Query update to avoid maximum execution time limit
                for(Case cs: [SELECT Type, Group__c, Cabin_Class__c, Category__c, Sub_Category__c, Classification__c, ContactId FROM Case WHERE ContactId = :contactIds AND Received_Date__c >= Last_N_Months:6 and (Origin!='Red App' and status!='Closed') limit 1000]) {
                    if(contactCasesMap.containsKey(cs.ContactId)){contactCasesMap.get(cs.ContactId).add(cs);
                    }
                    else {
                        List<Case> c = new List<Case>();
                        c.add(cs);
                        contactCasesMap.put(cs.ContactId, c);
                    }
                }
                
                //CRM-7851: Query update to avoid maximum execution time limit
                for(Case_Category__c cs: [SELECT Type__c, Group__c, Category__c, Sub_Category__c, Classification__c, Contact_Name__c FROM Case_Category__c WHERE Contact_Name__c = :contactIds AND CreatedDate >= Last_N_Months:6]) {
                    if(contactCaseCategoriesMap.containsKey(cs.Contact_Name__c)){ contactCaseCategoriesMap.get(cs.Contact_Name__c).add(cs);
                    }
                    else {
                        List<Case_Category__c> c = new List<Case_Category__c>(); c.add(cs);  contactCaseCategoriesMap.put(cs.Contact_Name__c, c);
                    }
                }
                

                    Decimal minValue = 0;
                    Decimal maxValue = 0;
                    Decimal sev1Count = 0;
                    Decimal sev2Count = 0;
                    String recoveryType;
                    Boolean SuggestedRecoveryEligible = false;
                    String durationRange;
                    String durationRangeCabins;
                    String cabinClass;
                    String tier;
                    String caseRecoveryType;
                    Decimal caseCountInPastSixMonths = 0;
                    Decimal suggestedMinValue = 0;
                    Decimal suggestedMaxValue = 0;
                    Case cs = caseMap != null ? caseMap.get(caseNumber) : null;
                    system.debug('===============caseMap' + caseMap);
                    if(cs != null) {
                        if(cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Baggage Type') || cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Insurance Letter Type') ||
                           cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Compliment Type') || cs.Type == CustomSettingsUtilities.getConfigDataMap('Case Query Type')) {
                               // Depreciation Value Process
                           }
                        else {
                            Contact con = contactMap.get(contactId);
                            if(con.Frequent_Flyer_Tier__c == null) {
                                tier = nonTier;
                            }
                            else {
                                tier = con.Frequent_Flyer_Tier__c;
                            }
                            
                            if(cs.Status == caseReopened) {caseRecoveryType = recoveryType2;
                            }
                            else if(caseRecoveryType == null){
                                if(contactCasesMap.containsKey(contactId)) {
                                    for(Case oldCs: contactCasesMap.get(contactId)) {
                                        if(oldCs.Type == cs.Type && oldCs.Group__c == cs.Group__c && oldCs.Category__c == cs.Category__c && oldCs.Sub_Category__c == cs.Sub_Category__c && oldCs.Classification__c == cs.Classification__c) {
                                            caseCountInPastSixMonths++;
                                        }
                                    }
                                }
                                
                                if(contactCaseCategoriesMap.containsKey(contactId) && !(caseCountInPastSixMonths > 1) ) {
                                    for(Case_Category__c oldCs: contactCaseCategoriesMap.get(contactId)) {
                                        if(oldCs.Type__c == cs.Type && oldCs.Group__c == cs.Group__c && oldCs.Category__c == cs.Category__c && oldCs.Sub_Category__c == cs.Sub_Category__c && oldCs.Classification__c == cs.Classification__c) {
                                            caseCountInPastSixMonths++;
                                        }
                                    }
                                }
                                
                                if(caseCountInPastSixMonths > 1) {caseRecoveryType = recoveryType2;
                                }
                                else {
                                    caseRecoveryType = recoveryType1;
                                }
                            }
                            
                            List<CaseCategories> caseValues = new List<CaseCategories>();
                            CaseCategories parentCase = new CaseCategories();
                            parentCase.caseGroup = cs.Group__c;
                            parentCase.category = cs.Category__c;
                            if(cs.Sub_Category__c == null) {parentCase.subCategory = none;
                            } else {
                                parentCase.subCategory = cs.Sub_Category__c;
                            }
                            if(cs.Classification__c == null) { parentCase.classification = none;
                            } else {
                                parentCase.classification = cs.Classification__c;
                            }
                            
                            caseValues.add(parentCase);
                            
                            if(cs.Case_Category_Count__c > 0) {
                                List<Case_Category__c> caseCategories = caseCategoriesMap.get(cs.Id);
                                for(Case_Category__c cc: caseCategories) {
                                    CaseCategories childCase = new CaseCategories();
                                    childCase.caseGroup = cc.Group__c;
                                    childCase.category = cc.Category__c;
                                    if(cc.Sub_Category__c == null){
                                        childCase.subCategory = none;
                                    } else {
                                        childCase.subCategory = cc.Sub_Category__c;
                                    }
                                    
                                    if(cc.Classification__c == null) {
                                        childCase.classification = none;
                                    } else {
                                        childCase.classification = cc.Classification__c;
                                    }
                                    
                                    caseValues.add(childCase);
                                }
                            }
                            
                            if(cs.Flight_Duration__c == null || (cs.Flight_Duration__c >= 0 && cs.Flight_Duration__c <= 4)) {
                                durationRange = '0-4';
                            } else if(cs.Flight_Duration__c > 4 && cs.Flight_Duration__c <= 10) { durationRange = '4-10';
                            } else {
                                durationRange = '10+';
                            }

                            //CRM-9902 Initialising Duration Ranges for the Cabin and Fligh Duration Calculation Type
                            if(cs.Flight_Duration__c == null || (cs.Flight_Duration__c >= 3 && cs.Flight_Duration__c <= 5)) { durationRangeCabins = '3-5';} 
							else if(cs.Flight_Duration__c > 4 && cs.Flight_Duration__c < 10) { durationRangeCabins = '5-9';} 
                            else { durationRangeCabins = '9+'; }

                            system.debug('value for durationRangeCabins'+durationRangeCabins);

                            //CRM-9902 Initialising Cabin Class to be included to the CabinKey
                            if(String.isNotEmpty(cs.Cabin_Class__c) ) 
                            {cabinClass = cs.Cabin_Class__c; }

                            system.debug('value for cabinClass'+cabinClass);
                            
                            for(CaseCategories c: caseValues){
                                System.debug('Group = '+c.caseGroup+' Cat = '+c.category+' Sub= '+c.subCategory+' Class='+c.classification);
                                Boolean isSev1 = false;
                                
                                QCC_Suggested_Recovery__mdt suggestedRec;
                                
                                String primaryKey = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification+''+tier+''+caseRecoveryType;
                                primaryKey = primaryKey.toLowerCase();
                                
                                String secondaryKey = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification+''+tier+''+caseRecoveryType+''+durationRange;
                                secondaryKey = secondaryKey.toLowerCase();
                                
                                String sev1Key = c.caseGroup+''+c.category+''+c.subCategory+''+c.classification;
                                sev1Key = sev1Key.toLowerCase();

                                String cabinKey=c.caseGroup+''+c.category+''+durationRangeCabins+''+cabinClass;
                                cabinKey=cabinKey.toLowerCase();
                                
                                //System.debug('Primary Key = '+primaryKey);
                                //System.debug('Secondary Key = '+secondaryKey);
                                //System.debug('Sev1 Key = '+sev1Key);
                                
                                if(metadataMap.containsKey(primaryKey)){
                                    suggestedRec = metadataMap.get(primaryKey);
                                    System.debug('Its a primaryKey');
                                } else if(metadataMap.containsKey(secondaryKey))
                                {suggestedRec = metadataMap.get(secondaryKey);
                                    System.debug('Its a secondaryKey');
                                } else if(metadataMap.containsKey(sev1Key)){
                                    suggestedRec = metadataMap.get(sev1Key);
                                    isSev1 = true;
                                    System.debug('Its a sev1Key');
                                }else if(metadataMap.containsKey(cabinKey))
                                {
                                    system.debug('enterred cabinKey'+cabinKey);
                                    suggestedRec = metadataMap.get(cabinKey);
                                    System.debug('Its a Cabin Key');
                                }
                                
                                if(suggestedRec != null) {
                                    if(!isSev1) {
                                        SuggestedRecoveryEligible = true;
                                        suggestedMinValue = suggestedRec.Min_Value__c;
                                        suggestedMaxValue = suggestedRec.Max_Value__c;
                                        if(cs.Case_Category_Count__c > 0) {
                                            sev2Count = sev2Count + 1;
                                        }
                                    } else if(isSev1 && cs.Case_Category_Count__c > 0) {
                                        sev1Count = sev1Count + 1;
                                        if(sev1Count > 1 && SuggestedRecoveryEligible == false) {
                                            SuggestedRecoveryEligible = true;
                                        }
                                    }
                                }
                                
                                if(suggestedMinValue > minValue) {
                                    minValue = suggestedMinValue;
                                }
                                if(suggestedMaxValue > maxValue) {
                                    maxValue = suggestedMaxValue;
                                }
                            }
                            
                            if((sev1Count + sev2Count)  > 1) {
                                //System.debug('sev1count = '+sev1Count+' sev2Count = '+sev2Count);
                                //System.debug('count = '+ (sev1Count + sev2Count));
                                Decimal extraPoints = 0;
                                if(tier == nonTier || tier == bronzeTier || tier == silverTier) {
                                    extraPoints = (sev2Count + 0.5 * (sev1Count)).round(System.RoundingMode.CEILING) * 1000;
                                    if(extraPoints > 3000) {
                                        extraPoints = 3000;
                                    }
                                    //System.debug('NBS');
                                }
                                if(tier == goldTier || tier == platinumTier || tier == platinumOneTier) {
                                    extraPoints = (sev1Count + sev2Count)*1000 + 1000;
                                    if(extraPoints > 4000) {
                                        extraPoints = 4000;
                                    }
                                }
                                //System.debug('maxVal = '+ maxValue+' extraPoints = '+extraPoints);
                                maxValue = maxValue + extraPoints;
                            }
                            
                            if(SuggestedRecoveryEligible) {
                                // DO NOT DELETE
                                Decimal pointsAlreadyGiven = 0;
                                if(cs.Recoveries_Case__r != null && cs.Recoveries_Case__r.size() > 0) {
                                    List<Recovery__c> otherRecoveries = cs.Recoveries_Case__r;
                                    for(Recovery__c r: otherRecoveries) {pointsAlreadyGiven += r.Amount__c;
                                 	}
                                    if(pointsAlreadyGiven < maxValue) {
                                        minValue = 0;
                                        maxValue = maxValue - pointsAlreadyGiven;
                                    }
                                    
                                    else if(pointsAlreadyGiven >= maxValue) {
                                        minValue = -1;
                                        maxValue = 0;//Changed from -1 to 0 as per CDP2-883 comments
                                    }
                                }
                                suggestedValuesMap.put('Suggested_Minimum__c', minValue);
                                suggestedValuesMap.put('Suggested_Maximum__c', maxValue);
                            }
                        }
                    }
                  
                
            } catch(Exception ex){
                System.debug('Exception: '+ex.getMessage());
                CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC_QantasPointsSuggestedValues', 'QCC_QantasPointsSuggestedValues', 'getSuggestedRange', String.valueOf(''), String.valueOf(''),false,'', ex);
            }
            System.debug('suggestedValuesMap::::'+suggestedValuesMap);
            return suggestedValuesMap;  
        }

        public class CaseCategories {
            String caseGroup;
            String category;
            String subCategory;
            String classification;
        }

    }