/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Customer Search using PNR
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Aug-2018      Praveen Sampath               Initial Design
28-Feb-2023      Jamie Wang                    invokePNRSearchWithoutLastName 
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_PNRSearchController {
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRSearch
    Description:        CAP PNR Search  
    Parameter:          PNR and Last Name
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String invokePNRSearch(String pnr, String lastName){
        QCC_PNRPassengerInfoWrapper response;
        try {
            pnr = QCC_GenericUtils.doTrim(pnr);
            lastName = QCC_GenericUtils.doTrim(lastName);
            lastName = EncodingUtil.urlEncode(lastName, 'UTF-8').replaceAll('\\+','%20'); 
            String passengers;
            
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            system.debug('token####'+token);
            response = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(pnr, token, lastName);
            
            //response = (QCC_PNRPassengerInfoWrapper)JSON.deserialize('{"booking":{"reloc":"5ZE8Z4","travelPlanId":"561451371617264","bookingId":"561451371617264","creationDate":"13/07/2023","groupName":null,"groupUnassignedPassengerQty":null,"currentPassengerQuantity":"1","lastUpdatedTimeStamp":"13/07/2023 23:13:00","passengers":[{"passengerId":"782655084027381","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"TEST","lastName":"XXXXXXXXXXUM","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"510692340001839A","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142208"}]}}', QCC_PNRPassengerInfoWrapper.class);
            system.debug('response###'+response);
            if(response != Null){
                QCC_PNRPassengerInfoWrapper.Booking booking = response.booking;
                if(booking != Null && booking.passengers != Null){
                    List<QCC_PNRPassengerInfoWrapper.Passengers> lstPas = new List<QCC_PNRPassengerInfoWrapper.Passengers>();
                    for(QCC_PNRPassengerInfoWrapper.Passengers pas: booking.passengers){
                        if(String.isBlank(pas.qantasFFNo )){
                            //pas.firstName = pas.firstName.substringBefore(' '); Commented to consider the middle names for existing contact search
                      
                            lstPas.add(pas);
                        }else{
                             lstPas.add(pas);
                        }
                    }
                    passengers = Json.serialize(lstPas);
                }
            }
            system.debug('passengers###'+passengers);
            if(String.isBlank(passengers) ){
                AuraHandledException ltEX = new AuraHandledException('');
                ltEX.setMessage(Label.QCC_NoValue);
                throw ltEX; 
            }
            
            return passengers;
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_PNRSearchController', 
                                    'invokePNRSearch', String.valueOf(response), String.valueOf(''), true,'', ex);
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;
        }   
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokePNRSearchWithoutLastName
    Description:        CAP PNR Search  
    Parameter:          PNR , creation Date
    Author:             Jamie Wang
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String invokePNRSearchWithoutLastName(String pnr , String creationDate, Boolean archivalData){
        QCC_PNRPassengerInfoWrapper response;
        try {
            pnr = QCC_GenericUtils.doTrim(pnr);
            // lastName = QCC_GenericUtils.doTrim(lastName);
            // lastName = EncodingUtil.urlEncode(lastName, 'UTF-8').replaceAll('\\+','%20'); 
            String passengers;
            String archival = String.valueOf(archivalData);
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            system.debug('token####'+token);
            response = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(pnr, creationDate, token, archival);
            system.debug('response###'+response);
            if(response != Null){
                QCC_PNRPassengerInfoWrapper.Booking booking = response.booking;
                if(booking != Null && booking.passengers != Null){
                    List<QCC_PNRPassengerInfoWrapper.Passengers> lstPas = new List<QCC_PNRPassengerInfoWrapper.Passengers>();
                    for(QCC_PNRPassengerInfoWrapper.Passengers pas: booking.passengers){
                        if(String.isBlank(pas.qantasFFNo )){
                            //pas.firstName = pas.firstName.substringBefore(' '); Commented to consider the middle names for existing contact search
                            lstPas.add(pas);
                        }else{
                             lstPas.add(pas);
                        }
                    }
                    passengers = Json.serialize(lstPas);
                }
            }
            system.debug('passengers###'+passengers);
            if(String.isBlank(passengers) ){
                AuraHandledException ltEX = new AuraHandledException('');
                ltEX.setMessage(Label.QCC_NoValue);
                throw ltEX; 
            }
            
            return passengers;
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_PNRSearchController', 
                                    'invokePNRSearch', String.valueOf(response), String.valueOf(''), true,'', ex);
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;
        }   
    }

    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeContactSearch
    Description:        CAP PNR Search  
    Parameter:          Pasenger Selected and PNR
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String invokeContactSearch(String passenger, String cusPNR, String recId){
        String resp;
        try{
            cusPNR = QCC_GenericUtils.doTrim(cusPNR);
            system.debug('passenger$$$'+passenger);
            system.debug('cusPNR$$$'+cusPNR);
            passenger = passenger.removeStart ('[');
            passenger = passenger.removeEnd(']');
            system.debug('objpassenger$$$'+passenger);
            QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = (QCC_PNRPassengerInfoWrapper.Passengers) Json.deserialize(passenger,  QCC_PNRPassengerInfoWrapper.Passengers.class);
            system.debug('passengerWrap$$$'+passengerWrap);
            
            
            if(String.isNotBlank(recId)){
                    Contact objcon;
                    if(passengerWrap.qantasFFNo != Null && String.isNotBlank(passengerWrap.qantasFFNo)){
                        resp = QCC_LookupFrequentFlyerController.lookupCustomer(passengerWrap.qantasFFNo, passengerWrap.lastName,'');
                        QCC_LookupFrequentFlyerController.CustomerWrapper respWrap = (QCC_LookupFrequentFlyerController.CustomerWrapper) Json.deserialize(resp, QCC_LookupFrequentFlyerController.CustomerWrapper.class);
                        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
                        conWrap.ffNumber = respWrap.ffNumber;
                        conWrap.lastName = respWrap.lastName;
                        conWrap.firstName = respWrap.firstName;
                        conWrap.ffTier = respWrap.ffTier;
                        conWrap.capId = respWrap.capId;
                        objcon = QCC_GenericUtils.fetchContactForFFCase(conWrap);
                    }else{
                        objcon = QCC_GenericUtils.fetchContactForNonFFCase();
                    }

                    if(objcon != Null){
                        Case objCase = [select id, (SELECT Id, Status__c FROM Recoveries_Case__r WHERE Status__c = 'Awaiting Approval') from case where Id =: recId];
                        if(objCase.Recoveries_Case__r == null || objCase.Recoveries_Case__r.size() == 0) {
                            objCase.ContactId = objcon.Id;
                            objCase.AccountId = objcon.AccountId;
                            update objCase;
                        }
                        else {
                            return 'Pending_Recoveries';
                        }
                    }else{
                        AuraHandledException ltEX = new AuraHandledException('');
                        ltEX.setMessage(Label.QCC_UnexpectedError);
                        throw ltEX; 
                    }
                    contactWrapper conInfo = new contactWrapper();
                    return 'success';

            }else if(passengerWrap.qantasFFNo != Null && String.isNotBlank(passengerWrap.qantasFFNo)){
                resp = QCC_LookupFrequentFlyerController.lookupCustomer(passengerWrap.qantasFFNo, passengerWrap.lastName,'');
                return resp;
            }else{
                contactWrapper conInfo = new contactWrapper();
                conInfo.fName = passengerWrap.firstName;
                conInfo.lName = passengerWrap.lastName;
                
                String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
                QCC_PNRContactInfoWrapper pnrContact = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI(cusPNR, token, passengerWrap.lastName);
                resp = json.serialize(pnrContact);
                if(pnrContact != Null && PnrContact.booking != Null){
                    List<QCC_PNRContactInfoWrapper.Email> lstEmail = (pnrContact.booking.contacts != Null && pnrContact.booking.contacts.email != Null)? pnrContact.booking.contacts.email : Null;
                    List<QCC_PNRContactInfoWrapper.Phone> lstPhone = (pnrContact.booking.contacts != Null && pnrContact.booking.contacts.phone != Null)? pnrContact.booking.contacts.phone : Null;
                    
                    if(lstEmail != Null){
                        //Jira CRM-6310: Look up PNR not populating email / phone number for non FF
                        for(QCC_PNRContactInfoWrapper.Email emailInfo: lstEmail) {
                            system.debug('emailInfo$$$$$'+emailInfo);
                            system.debug('emailInfo.passengerIds.size()$$$$$'+emailInfo.passengerIds.size());
                            if (emailInfo.passengerIds != Null && emailInfo.passengerIds.size() > 0 && emailInfo.passengerIds.contains(passengerWrap.passengerId)) {
                                conInfo.email = emailInfo.emailText;
                                break;
                            }
                        }
                        system.debug('conInfo######>'+conInfo);
                    }
                    
                    if(lstPhone != Null){
                        for(QCC_PNRContactInfoWrapper.Phone phoneInfo: lstPhone){
                            system.debug('phoneInfo$$$$$'+phoneInfo);
                            //Jira CRM-6310: Look up PNR not populating email / phone number for non FF
                            if (phoneInfo.passengerIds != Null && phoneInfo.passengerIds.size() > 0 && phoneInfo.passengerIds.contains(passengerWrap.passengerId)) {
                                        conInfo.phone = (String.isNotBlank(phoneInfo.countryCode) && phoneInfo.countryCode != null)?phoneInfo.countryCode:'';
                                    conInfo.phone += (String.isNotBlank(phoneInfo.areaCode) && phoneInfo.areaCode != null)?phoneInfo.areaCode:'';
                                    conInfo.phone += (String.isNotBlank(phoneInfo.phoneNumber) && phoneInfo.phoneNumber != null)?phoneInfo.phoneNumber:'';                     
                                    break;
                            }
                        }
                        
                    }
                }
                system.debug('conInfo######'+conInfo);
                 String strCon = Json.serialize(conInfo);

                /*contactWrapper cw = new contactWrapper();
                cw.email='test@testpnr.com';
                cw.ffNumber='';
                cw.fName='RT';
                cw.lName='PNR';
                cw.phone='452222222';
                String strCon = Json.serialize(cw);*/
                return strCon;
            }
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_PNRSearchController', 
                                    'invokeContactSearch', resp, String.valueOf(''), true,'', ex);
            system.debug('ex####'+ex);
            // Added by Purushotham for Remediation hotfix -- START
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ex.setMessage(ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').removeEnd(': []'));
            }
            // Added by Purushotham for Remediation hotfix -- END
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;  
        }
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeContactSearch
    Description:        CAP PNR Search  
    Parameter:          Pasenger Selected and PNR
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String invokeAssignContacttoCase(String contactInfo, String recId){
        String resp;
        try{
            system.debug('contactInfo###'+contactInfo);
            QCC_ContactWrapper conWrap = (QCC_ContactWrapper)Json.deserialize(contactInfo, QCC_ContactWrapper.class);
            Contact objcon = QCC_GenericUtils.fetchContactForFFCase(conWrap);
            if(objcon != Null){
                Case objCase = [select id, (SELECT Id, Status__c FROM Recoveries_Case__r WHERE Status__c = 'Awaiting Approval') from case where Id =: recId];
                if(objCase.Recoveries_Case__r == null || objCase.Recoveries_Case__r.size() == 0) {
                    objCase.ContactId = objcon.Id;
                    objCase.AccountId = objcon.AccountId;
                    //CRM-7179
                    objCase.First_Name__c = objcon.FirstName;
                    objCase.Last_Name__c = objcon.LastName;
                    //CRM-8061 commented the line below to keep the phone entact
                    //objCase.Contact_Phone__c = objCon.Phone;
                    objCase.Contact_Email__c = objcon.Email;
                    System.debug('objCase====> ' + objCase);
                    update objCase;
                }
                else {
                    return 'Pending_Recoveries';
                }
            }
            return objcon.Id;

        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_PNRSearchController', 
                                    'invokeAssignContacttoCase', resp, String.valueOf(''), true,'', ex);
            system.debug('ex####'+ex);
            // Added by Purushotham for Remediation hotfix -- START
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ex.setMessage(ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').removeEnd(': []'));
            }
            // Added by Purushotham for Remediation hotfix -- END
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;  
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetchColumn
    Description:        CAP Column
    Parameter:          Component Name
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String fetchColumn(String componentName){
        List<columns> lstColumns = new List<columns>();
        for(QCC_Data_Table__mdt column: [select ComponentName__c , Order__c, FieldAPI__c , FieldLabel__c, 
                                         Sortable__c , Type__c  from QCC_Data_Table__mdt where 
                                         ComponentName__c  =: componentName Order By Order__c])
        {
            Columns objCol =  new Columns();
            objCol.label = column.FieldLabel__c;
            objCol.fieldName = column.FieldAPI__c;
            objCol.type = column.Type__c;
            objCol.sortable = column.Sortable__c;
            lstColumns.add(objCol);
        }
        String columns = Json.serialize(lstColumns);
        return columns;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        assigntoGenericContact
    Description:        Assign Generic Contact
    Parameter:          caseID
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static String assigntoGenericContact(String caseId){
        try{
            Contact objcon = QCC_GenericUtils.fetchContactForNonFFCase();
            Case objCase = [select id, (SELECT Id, Status__c FROM Recoveries_Case__r WHERE Status__c = 'Awaiting Approval') from case where Id =: caseID];
            if(objCase.Recoveries_Case__r == null || objCase.Recoveries_Case__r.size() == 0) {
                objCase.ContactId = objcon.Id;
                objCase.AccountId = objcon.AccountId;
                update objCase;
                return 'success';
            }
            else {
                return 'Pending_Recoveries';
            }
            
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Customer Search', 'QCC_PNRSearchController', 
                                    'assigntoGenericContact', '', String.valueOf(''), true,'', ex);
            system.debug('ex####'+ex);
            // Added by Purushotham for Remediation hotfix -- START
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ex.setMessage(ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').removeEnd(': []'));
            }
            // Added by Purushotham for Remediation hotfix -- END
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;  
        }
    }
    
    public class Columns{
        public String label;
        public String fieldName ;
        public String type;
        public Boolean sortable;
    }
    
    public class contactWrapper{
        public String fName;
        public String lName;
        public String email;
        public String phone;
        public String ffNumber;
    }
}