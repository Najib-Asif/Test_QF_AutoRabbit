/*********************************************************************************
Name         : QCC_DisplaySpecificNeedsController
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 2020-01-13
Usages       : This will handle the backend logic needed for QCC_DisplaySpecificNeedsRelatedToCase
*********************************************************************************/
public class QCC_DisplaySpecificNeedsController {
    //@Purpose: This method updates the QCC_Specific_Needs__c record based on the selected checkbox in the lightning component.
    //@input paremeters:
    //	-caseRecordId - The record id of the case which the specific need record is related.
    //	-specificNeedRecord - The object record containing all the updated field.
    //	-isNew - The flag to determine whether the case record should be updated or not.
    //@return type: List of sObject including fields with null values
    @AuraEnabled  
    public static void updateSpecificNeedRecord(String caseRecordId, String specificNeedRecord, Boolean isNew){
        system.debug('@@@SN: ' + specificNeedRecord);
        QCC_Specific_Needs__c specificNeedRecordToUpdate = (QCC_Specific_Needs__c)JSON.deserialize(specificNeedRecord, QCC_Specific_Needs__c.class);
        
        if (isNew) {
            Case caseRecord = [SELECT Id, QCC_Specific_Needs__c, ContactId FROM Case WHERE Id =: caseRecordId];
            caseRecord.QCC_Specific_Needs__c = specificNeedRecordToUpdate.Id;
            specificNeedRecordToUpdate.QCC_Contact__c = caseRecord.ContactId;
            specificNeedRecordToUpdate.QCC_Case__c = caseRecord.Id;
            
            update caseRecord;  
        }
        
        update specificNeedRecordToUpdate;
    }
    
    @AuraEnabled
    public static RequestTypeWrapper retrieveCheckboxValues(Id RecId){
        //List<String> ListValue = new List<String>();        
        system.debug('@@@DOINITrecord Id'+RecId);
        case cs = [
            SELECT Id, QCC_Specific_Needs__r.Update_PNR_WC__c,QCC_Specific_Needs__r.Confirm_Outcome_to_Customer__c, QCC_Specific_Needs__r.QCC_PNR_Updated_SD__c, 
            QCC_Specific_Needs__r.QCC_Dog_Traveled_and_Previously_Approved__c, QCC_Specific_Needs__r.QCC_Outcome_Confirmation_Sent_to_Cst_SD__c, 
            QCC_Specific_Needs__r.QCC_Compliance_Approval_Request_Sent_SD__c, QCC_Specific_Needs__r.QCC_Compliance_Outcome_Received_SD__c,
            QCC_Specific_Needs__r.QCC_Update_PNR_MC__c, QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Customer_MC__c,
            QCC_Specific_Needs__r.QCC_Update_PNR_MCST__c, QCC_Specific_Needs__r.QCC_Update_Intelex__c, QCC_Specific_Needs__r.QCC_MEDA_Clearance_Confirmed__c, 
            QCC_Specific_Needs__r.QCC_Payment_Received__c, QCC_Specific_Needs__r.QCC_Booking_Created__c, QCC_Specific_Needs__r.QCC_Quote_Provided_to_Requester_MCST__c, 
            QCC_Specific_Needs__r.QCC_Final_Confirmation_Sent_to_Requester__c,  QCC_Specific_Needs__r.QCC_PNR_Updated_MCOD__c, QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved__c, QCC_Specific_Needs__r.QCC_Quote_Provided_to_Customer_MCOD__c,
            QCC_Specific_Needs__r.QCC_Customer_has_accepted_Quote_MCOD__c, QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCOD__c, QCC_Specific_Needs__r.QCC_PNR_Updated_MCOQS__c,
            QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved_MCQS__c, QCC_Specific_Needs__r.QCC_Quote_Provided_to_Customer_MCOQS__c,
            QCC_Specific_Needs__r.QCC_Customer_has_accepted_Quote_MCOQS__c, QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCOQS__c,
            QCC_Specific_Needs__r.QCC_PNR_Updated_MCIT__c, QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved_MCIT__c, QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCIT__c,
            QCC_Specific_Needs__r.QCC_Update_PNR_CBBG__c, QCC_Specific_Needs__r.QCC_Seating_Allocated_for_Customer_CBBG__c, QCC_Specific_Needs__r.QCC_Update_PNR_MBW__c,
            QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Requestor_MBW__c, QCC_Specific_Needs__r.QCC_Notify_Cabin_Crew_CJMs_SD__c, QCC_Specific_Needs__r.QCC_Notify_Departure_Airport_3_Days_PAP__c,
            QCC_Specific_Needs__r.QCC_Notify_Departure_Airport_3_Days_ST__c, QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_OD__c,
            QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_QS__c, QCC_Specific_Needs__r.QCC_Oxygen_Ordered__c, QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_IT__c,
            QCC_Specific_Needs__r.QCC_Notify_Airport_and_Crew_1_Day__c, QCC_Specific_Needs__r.QCC_Updating_Service_Dog_Register__c,
            QCC_Specific_Needs__r.QCC_Update_PNR_MCNE__c, QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Customer_MCNE__c, QCC_Specific_Needs__r.QCC_Send_Notification_to_Airline_MCNE__c
            FROM Case 
            WHERE  id=:RecId
        ];
        RequestTypeWrapper requestTypeList = new RequestTypeWrapper();        
        List<String> listWC = new List<String>();
        List<String> listNE = new List<String>();
        List<String> listCBAP = new List<String>();
        List<String> listOD = new List<String>();
        List<String> listIQ = new List<String>();
        List<String> listIT = new List<String>();
        List<String> listST = new List<String>();
        List<String> listSD = new List<String>();
        List<String> listCBBG = new List<String>();
        List<String> listMBW = new List<String>();
        
        //Wheelchair
        if(cs.QCC_Specific_Needs__r.Update_PNR_WC__c == true){
            listWC.add('Update_PNR_WC__c');
        }
        if(cs.QCC_Specific_Needs__r.Confirm_Outcome_to_Customer__c == true){
            listWC.add('Confirm_Outcome_to_Customer__c');
        }
        
        //Medical Clearance - No Equipment
        if(cs.QCC_Specific_Needs__r.QCC_Update_PNR_MCNE__c == true){
            listNE.add('QCC_Update_PNR_MCNE__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Customer_MCNE__c == true){
            listNE.add('QCC_Confirmation_Sent_to_Customer_MCNE__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Send_Notification_to_Airline_MCNE__c == true){
            listNE.add('QCC_Send_Notification_to_Airline_MCNE__c');
        } 
        
        //CBAP
        if(cs.QCC_Specific_Needs__r.QCC_Update_PNR_MC__c == true){
            listCBAP.add('QCC_Update_PNR_MC__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Customer_MC__c == true){
            listCBAP.add('QCC_Confirmation_Sent_to_Customer_MC__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Departure_Airport_3_Days_PAP__c == true){
            listCBAP.add('QCC_Notify_Departure_Airport_3_Days_PAP__c');
        }

        //Medical Clearance - Oxygen Domestic
        if(cs.QCC_Specific_Needs__r.QCC_PNR_Updated_MCOD__c == true){
            listOD.add('QCC_PNR_Updated_MCOD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved__c == true){
            listOD.add('QCC_MEDA_Completed_Approved__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Quote_Provided_to_Customer_MCOD__c == true){
            listOD.add('QCC_Quote_Provided_to_Customer_MCOD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Customer_has_accepted_Quote_MCOD__c == true){
            listOD.add('QCC_Customer_has_accepted_Quote_MCOD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCOD__c == true){
            listOD.add('QCC_Confirmation_sent_to_Customer_MCOD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_OD__c == true){
            listOD.add('QCC_Notify_Eng_Airport_Crew_2_days_OD__c');
        }
        
        //Medical Clearance - International Qantas Supplied
        if(cs.QCC_Specific_Needs__r.QCC_PNR_Updated_MCOQS__c == true){
            listIQ.add('QCC_PNR_Updated_MCOQS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved_MCQS__c == true){
            listIQ.add('QCC_MEDA_Completed_Approved_MCQS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Quote_Provided_to_Customer_MCOQS__c == true){
            listIQ.add('QCC_Quote_Provided_to_Customer_MCOQS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Customer_has_accepted_Quote_MCOQS__c == true){
            listIQ.add('QCC_Customer_has_accepted_Quote_MCOQS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCOQS__c == true){
            listIQ.add('QCC_Confirmation_sent_to_Customer_MCOQS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_QS__c == true){
            listIQ.add('QCC_Notify_Eng_Airport_Crew_2_days_QS__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Oxygen_Ordered__c == true){
            listIQ.add('QCC_Oxygen_Ordered__c');
        }
        
        //International Travel
        if(cs.QCC_Specific_Needs__r.QCC_PNR_Updated_MCIT__c == true){
            listIT.add('QCC_PNR_Updated_MCIT__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_MEDA_Completed_Approved_MCIT__c == true){
            listIT.add('QCC_MEDA_Completed_Approved_MCIT__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_sent_to_Customer_MCIT__c == true){
            listIT.add('QCC_Confirmation_sent_to_Customer_MCIT__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Eng_Airport_Crew_2_days_IT__c == true){
            listIT.add('QCC_Notify_Eng_Airport_Crew_2_days_IT__c');
        }
        
        //Stretcher
        if(cs.QCC_Specific_Needs__r.QCC_Update_PNR_MCST__c == true){
            listST.add('QCC_Update_PNR_MCST__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Update_Intelex__c == true){
            listST.add('QCC_Update_Intelex__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Booking_Created__c == true){
            listST.add('QCC_Booking_Created__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Payment_Received__c == true){
            listST.add('QCC_Payment_Received__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_MEDA_Clearance_Confirmed__c == true){
            listST.add('QCC_MEDA_Clearance_Confirmed__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Final_Confirmation_Sent_to_Requester__c == true){
            listST.add('QCC_Final_Confirmation_Sent_to_Requester__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Quote_Provided_to_Requester_MCST__c == true){
            listST.add('QCC_Quote_Provided_to_Requester_MCST__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Departure_Airport_3_Days_ST__c == true){
            listST.add('QCC_Notify_Departure_Airport_3_Days_ST__c');
        }

        //ServiceDog
        if(cs.QCC_Specific_Needs__r.QCC_Compliance_Outcome_Received_SD__c == true){
            listSD.add('QCC_Compliance_Outcome_Received_SD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Updating_Service_Dog_Register__c == true){
            listSD.add('QCC_Updating_Service_Dog_Register__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_PNR_Updated_SD__c == true){
            listSD.add('QCC_PNR_Updated_SD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Cabin_Crew_CJMs_SD__c == true){
            listSD.add('QCC_Notify_Cabin_Crew_CJMs_SD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Outcome_Confirmation_Sent_to_Cst_SD__c == true){
            listSD.add('QCC_Outcome_Confirmation_Sent_to_Cst_SD__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Compliance_Approval_Request_Sent_SD__c == true){
            listSD.add('QCC_Compliance_Approval_Request_Sent_SD__c');
        }

        //Baggage CBBG
        if(cs.QCC_Specific_Needs__r.QCC_Update_PNR_CBBG__c == true){
            listCBBG.add('QCC_Update_PNR_CBBG__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Seating_Allocated_for_Customer_CBBG__c == true){
            listCBBG.add('QCC_Seating_Allocated_for_Customer_CBBG__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Notify_Airport_and_Crew_1_Day__c == true){
            listCBBG.add('QCC_Notify_Airport_and_Crew_1_Day__c');
        }
        
        //Baggage MBW
        if(cs.QCC_Specific_Needs__r.QCC_Update_PNR_MBW__c == true){
            listMBW.add('QCC_Update_PNR_MBW__c');
        }
        if(cs.QCC_Specific_Needs__r.QCC_Confirmation_Sent_to_Requestor_MBW__c == true){
            listMBW.add('QCC_Confirmation_Sent_to_Requestor_MBW__c');
        }
        
        requestTypeList.strWheelChair = listWC;
        requestTypeList.strNoEquipment = listNE;
        requestTypeList.strCBAP = listCBAP;
        requestTypeList.strOxygenDomestic = listOD;
        requestTypeList.strIntQantas = listIQ;
        requestTypeList.strIntTravel = listIT;
        requestTypeList.strMCStretcher = listST;
        requestTypeList.strServiceDog = listSD;
        requestTypeList.strBaggageCBBG = listCBBG;
        requestTypeList.strBaggageMBW = listMBW;
        
        return requestTypeList;
        
    }
    public class RequestTypeWrapper{
        @AuraEnabled public List<String> strWheelChair {get; set;}
        @AuraEnabled public List<String> strNoEquipment {get; set;}
        @AuraEnabled public List<String> strCBAP{get; set;}
        @AuraEnabled public List<String> strOxygenDomestic {get; set;}
        @AuraEnabled public List<String> strIntQantas {get; set;}        
        @AuraEnabled public List<String> strIntTravel {get; set;}        
        @AuraEnabled public List<String> strMCStretcher {get; set;}
        @AuraEnabled public List<String> strServiceDog {get; set;}
        @AuraEnabled public List<String> strBaggageCBBG {get; set;}
        @AuraEnabled public List<String> strBaggageMBW {get; set;} 
        
    }
    @AuraEnabled
    public static List<metaDataWrapper> getMetadataFields(){
        
        List<metaDataWrapper> wrapperFieldsList = new List<metaDataWrapper>();
        
        List<QCC_Specific_Needs_Fields__mdt> sectionFields = [SELECT Id, label, Record_Form_Fields__c 
                                                              FROM QCC_Specific_Needs_Fields__mdt
                                                             ];
        for(QCC_Specific_Needs_Fields__mdt fieldsLoop : sectionFields){
            metaDataWrapper wrapperFields = new metaDataWrapper();
            List<String> fields = fieldsLoop.Record_Form_Fields__c.split(',');
            List<String> newStringList = new List<String>();
            for(String mdFields: fields){
                newStringList.add(mdFields.trim());
            }
            wrapperFields.fields = newStringList;
            wrapperFields.sectionName = fieldsLoop.label;
            wrapperFieldsList.add(wrapperFields);
        }
        
        return wrapperFieldsList;
    }
    
    public class metaDataWrapper{
        @AuraEnabled public List<String> fields {get; set;}
        @AuraEnabled public String sectionName {get; set;}
    }
}