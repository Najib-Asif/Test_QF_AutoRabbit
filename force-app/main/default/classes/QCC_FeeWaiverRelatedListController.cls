/*********************************************************************************
Name         : QCC_FeeWaiverRelatedListController
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 25 October 2019
Usages       : This class is used to get all fee waiver from callout.
*********************************************************************************/
public without sharing class QCC_FeeWaiverRelatedListController {
    @AuraEnabled
    public static RelatedFeeWaiverWrapper getAllFeeWaiverData(Id contactId) {
        System.debug('QCC_FeeWaiverRelatedListController.getAllFeeWaiverData');
        
        //Generate the wrapper
        RelatedFeeWaiverWrapper myWrapper = new RelatedFeeWaiverWrapper();
        myWrapper.hasError = false;
        
        //Get the contact record
        Contact contactRecord;
        try {
            contactRecord = [SELECT Id, Frequent_Flyer_Number__c FROM Contact WHERE Id =: contactId];
        } catch(Exception ex) {
            contactRecord = null;
        }
        
        try {
            List<QCC_Fee_Waiver__c> feeWaiverList = new List<QCC_Fee_Waiver__c>();
            if (contactRecord != null) {
                //Trigger the callout until the last page
                Boolean hasNextPage = true;
                List<QCC_FeeWaiverWrapper.DetailWrapper> flightWrapperList = new List<QCC_FeeWaiverWrapper.DetailWrapper>();
                Integer pageNumber = 1;
                while(hasNextPage) {
                    QCC_FeeWaiverWrapper.FeeWaiverWrapper feeWaiverWrapper = QCC_InvokeCAPAPI.invokeFeeWaiverAPI(String.valueOf(pageNumber), contactRecord.Frequent_Flyer_Number__c);
                    System.debug('feeWaiverWrapper: ' + feeWaiverWrapper);
                    
                    if (feeWaiverWrapper.feeWaivers != null) {
                        flightWrapperList.addAll(feeWaiverWrapper.feeWaivers);
                    }
                    if (feeWaiverWrapper.nextPage == null) {
                        hasNextPage = false;
                    }
                    pageNumber++;
                }
                
                System.debug('flightWrapperList: ' + flightWrapperList);
                
                //Convert the response to Fee Waiver records as per GRAPHITE-1052
                for(QCC_FeeWaiverWrapper.DetailWrapper flightWrapper : flightWrapperList) {
                    QCC_Fee_Waiver__c feeWaiver = new QCC_Fee_Waiver__c();
                    feeWaiver.PNR__c = flightWrapper.reloc;
                    feeWaiver.Code__c = flightWrapper.otherTattoo;
                    feeWaiver.Category__c = flightWrapper.category;
                    feeWaiver.Subcategory__c = flightWrapper.subCategoryCode;
                    feeWaiver.Value__c = flightWrapper.amount;
                    feeWaiver.CurrencyIsoCode = flightWrapper.currencyCode;
                    feeWaiver.Waiver_Date__c = flightWrapper.feeWaiverCreationDate;
                    feeWaiverList.add(feeWaiver);
                }
                //Update the token once the callout is done.
                //QCC_GenericUtils.updateToken(token, 'QCC_CAPToken');
                
                myWrapper.feeWaiverRecords = feeWaiverList;
            }
        } catch(Exception ex) {
            myWrapper.hasError = true;
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Fee Waiver Related List', 'QCC_FeeWaiverRelatedListController', 'getAllFeeWaiverData', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
        
        System.debug('myWrapper: ' + myWrapper);
        
        return myWrapper;
    }
    
    public class RelatedFeeWaiverWrapper {
        @AuraEnabled public Boolean hasError {get;set;}
        @AuraEnabled public List<QCC_Fee_Waiver__c> feeWaiverRecords {get;set;}
    }
}