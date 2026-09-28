public with sharing class AgencyInvitationController {
    
    @AuraEnabled
    public static Object getAllocations(List<String> agencyBrand, List<String> agencyGroup, List<String> agencyIATA, List<String> agencyIATACodes, Id selectedOfferId){
        try {
            if ( String.isBlank(selectedOfferId) ) return null;
            if ( agencyIATA == null || agencyBrand == null || agencyGroup == null || agencyIATACodes == null) return null;
            if ( agencyIATA.isEmpty() && agencyBrand.isEmpty() && agencyGroup.isEmpty() && agencyIATACodes.isEmpty()) return null;

            String[] eligibleStatus = new String[] {'Active'};
            // Fetching excluded accreditation statuses and GDS from labels
            String[] excludedGDS = Label.PNDC_Excluded_Aggregators.split(';');
            Map<String, Object> returnData = new Map<String, Object>();
            Set<Id> acntIds = new Set<Id>();
            /*for (String status : eligibleStatus) {
                Map<Id, Account> accs = new Map<Id, Account> ([select Id, Name, Active__c,  Qantas_Industry_Centre_ID__c, Agency_Sales_Region__r.Email__c, Agency_Sales_Region__r.name, 
                                            BillingCountryCode, 
                                            (select id, Status__c from Offer_Allocations__r where Offer_Catalogue__c = :selectedOfferId limit 1 ) from Account where 
                                            Id in 
                        (select AccountId from Asset where RecordType.DeveloperName = 'Agency_Channel' and Active__c = true and 
                        Account.RecordType.DeveloperName = 'Agency_Account' and Account.Active__c = true and 
                            Account.Agency_Sales_Region__r.Active__c = true and 
                            GDS_Name__c not in :excludedGDS and 
                            (AccountId in :agencyIATA or Account.Agency_Sales_Region__r.Name like :agencyGroup or Account.Agency_Sales_Region__c in :agencyBrand OR 
                            Account.Qantas_Industry_Centre_ID__c in :agencyIATACodes)
                         and Premium_Channel_Status__c = :status and AccountId not in :acntIds
                        ) with USER_MODE order by Qantas_Industry_Centre_ID__c Nulls Last]);
                if(!accs.isEmpty()) {
                    acntIds.addAll(accs.keySet());
                    returnData.put(status, accs.values());
                }
            }*/

            return [select Id, Name, Active__c,  Qantas_Industry_Centre_ID__c, Agency_Sales_Region__r.Email__c, Agency_Sales_Region__r.name, BillingCountryCode, 
                (select id, Status__c from Offer_Allocations__r where Offer_Catalogue__c = :selectedOfferId limit 1 ), 
                (select id, Premium_Channel_Status__c from Assets 
                            where RecordType.DeveloperName = 'Agency_Channel' and Active__c = true and GDS_Name__c not in :excludedGDS and Premium_Channel_Status__c in :eligibleStatus 
                            order by Premium_Channel_Status__c desc limit 1)
                from Account 
                where RecordType.DeveloperName = 'Agency_Account' and Active__c = true and Agency_Sales_Region__r.Active__c = true and 
                        (Id in :agencyIATA 
                        OR Agency_Sales_Region__r.Name like :agencyGroup 
                        OR Agency_Sales_Region__c in :agencyBrand 
                        OR Qantas_Industry_Centre_ID__c in :agencyIATACodes) with USER_MODE order by Qantas_Industry_Centre_ID__c Nulls Last];
            /*String queryString = 'select Id, Name, Active__c,  Qantas_Industry_Centre_ID__c, Agency_Sales_Region__r.Email__c, Agency_Sales_Region__r.name, '
                + '(select id from Offer_Allocations__r where Offer_Catalogue__c = :selectedOffer limit 1 ) from Account where Id in '
                    + '(select AccountId from Asset where Active__c = true and Account.Active__c = true and Account.Agency_Sales_Region__r.Active__c = true and '
                    + ' (AccountId in :agencyIATA or Account.Agency_Sales_Region__r.Name like :agencyGroup or Account.Agency_Sales_Region__c in :agencyBrand)'
                    + ' and Premium_Channel_Status__c in :eligibleStatus' 
                    + ')';*/

            //return returnData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<sObject> getAgencyInvitations(List<String> agencyBrand, List<String> agencyGroup, List<String> agencyIATA, List<String> agencyIATACodes){
        try {
            if ( agencyIATA == null || agencyBrand == null || agencyGroup == null || agencyIATACodes == null ) return null;
            if(agencyIATA.isEmpty() && agencyBrand.isEmpty() && agencyGroup.isEmpty() && agencyIATACodes.isEmpty()) return null;

            String[] excludedGDS = Label.PNDC_Excluded_Aggregators.split(';');

            return [select id, GDS_Name__c, Agency_Identifier__c, Invitation_Date__c, Invitation_Expiry_Date__c, EffectiveDate__c, Premium_Channel_Status__c,
                    Account.Name, Account.Agency_Sales_Region__r.Name, Account.Agency_Sales_Region__r.Email__c, Account.Email__c, Account.AccreditationType__c,
                    Account.AccreditationStatus__c, Account.SecondaryEmail__c, AccountId
                    from Asset where RecordType.DeveloperName = 'Agency_Channel' and Active__c = true and 
                        Account.RecordType.DeveloperName = 'Agency_Account' and Account.Active__c = true and Account.Agency_Sales_Region__r.Active__c = true and 
                        GDS_Name__c not in :excludedGDS and 
                        ( AccountId in :agencyIATA or Account.Agency_Sales_Region__r.Name like :agencyGroup or 
                        Account.Agency_Sales_Region__c in :agencyBrand or Account.Qantas_Industry_Centre_ID__c in :agencyIATACodes) 
                        with USER_MODE order by Agency_Identifier__c Nulls Last];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendInvitations(List<String> managerEmails, String invitationType){
        try {
            String metadataName;
            if (invitationType == 'Commercial Agreement') {
                metadataName = 'Agency_Invitation_Email_Template';
            }else if(invitationType == 'EOI'){
                metadataName = 'Agency_Invitation_EOI_Email_Template';
            }else if(invitationType == 'PNDC Email'){
                metadataName = 'Agency_Invitation_PNDC_Email_Template';
            }else{
                throw new AuraHandledException('Invalid Invitation Type');
            }
            Global_Properties__mdt agencyInviteTemplate = Global_Properties__mdt.getInstance(metadataName);
            EmailTemplate et = [select id from EmailTemplate where DeveloperName =: agencyInviteTemplate.Static_Values__c limit 1];
            String orgWideId = [select id, address from orgwideemailaddress where displayname='No-Response'].id;
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(String email : managerEmails) {
                if (String.isBlank(email)) continue;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setOrgWideEmailAddressId(orgWideId);
                message.setToAddresses(new List<String>{email});
                message.setTemplateId(et.Id);
                message.setTargetObjectId(UserInfo.getUserId());
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(true);
                messages.add(message);
            }
            Messaging.sendEmail(messages);
                //message.setSenderDisplayName('QC-Lounge');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<sObject> getAgencyNamesFromIATAs(List<String> agencyIATA){
        try {
            if (agencyIATA == null || agencyIATA.isEmpty()) return null;

            return [select id, Name
                    from Account where Active__c = true and Agency_Sales_Region__r.Active__c = true and 
                    RecordType.DeveloperName = 'Agency_Account' and Qantas_Industry_Centre_ID__c in :agencyIATA with USER_MODE];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*@AuraEnabled
    public static Object performDml(Object records, String action){
        List<sObject> sObjectRecs;
        sObjectRecs = (List<sObject>)Json.deserializeStrict(Json.serialize(records), List<sObject>.class); 
        if (sObjectRecs == null || sObjectRecs.isEmpty()) {throw new AuraHandledException('No data to perform DML');}
        if (String.isBlank(action)) {throw new AuraHandledException('Invalid action');}
        switch on action.toLowerCase() {
            when 'insert' {
                Database.insert(sObjectRecs, AccessLevel.USER_MODE);
            } when 'update' {
                Database.update(sObjectRecs, AccessLevel.USER_MODE);
            }when 'upsert' {
                Database.upsert(sObjectRecs, AccessLevel.USER_MODE);
            }when 'delete' {
                Database.delete(sObjectRecs, AccessLevel.USER_MODE);
            }when else {
                throw new AuraHandledException('Invalid action');
            }
        }
        return sObjectRecs;
    }*/
}