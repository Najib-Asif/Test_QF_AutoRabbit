/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Search for the Cases and Contact
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
01-Aug-2018             Purushotham B          	Initial Design 
23-Mar-2023				Leslie Padilla			ADT-140: Updating current case creation logic across channels to ensure that "not null" Contact is attached 
												if 4pt ID is provided (FirstName, LastName, Email, Phone)
												Updated method getContactId to include phone and email as input parameters
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_SearchContactInfoController {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    search
    Description:    Search for the Cases 
    Parameter:      String, String, String, String, String    
    Return:         List<Case>    
    ----------------------------------------------------------------------------------------------*/
	@AuraEnabled
    public static List<Case> search(String firstName, String lastName, String email, String phone, String ffNumber, String component, String caseId) {
        try {
            String emptyString = '';
            //Jira CRM-6471: SOQL Performance
            String child = '';
            firstName = QCC_GenericUtils.doTrim(firstName);
            lastName = QCC_GenericUtils.doTrim(lastName);
            email = QCC_GenericUtils.doTrim(email);
            phone = QCC_GenericUtils.doTrim(phone);
            ffNumber = QCC_GenericUtils.doTrim(ffNumber);
            
            system.debug('First Name:'+firstName + 'lastName:'+lastName+ 'Email:' +email+ 'phone :'+phone + 'ffNumber:'+ffNumber);
            List<Case> cases = new List<Case>();
            //Jira:CRM-8706
            //Set<Id> qccCaseIds = CaseTriggerHelper.qccCaseRecordTypeIds();
            Set<Id> qccCaseIds = CaseUtility.qccCaseRecordTypeIds();
            Map<Id, Contact> contactMap;
            
            //FIX for ADT Hypercare Issue 86
            Id qccCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Voice').getRecordTypeId();
            qccCaseIds.add(qccCaseRecordTypeId);
            
            List<String> queryFields = new List<String>();
            
            //Fields that needs to be displayed on the Search Result lightning component should be queried
            for(QCC_Data_Table__mdt dataTable: [SELECT ComponentName__c, Order__c, FieldAPI__c, FieldLabel__c, Sortable__c, Type__c FROM QCC_Data_Table__mdt
                                            WHERE ComponentName__c  = :component Order By Order__c]) {
                
                if(dataTable.Type__c.equalsIgnoreCase('Datetime')) {
                    String field = 'format('+dataTable.FieldAPI__c+')';
					system.debug('field value'+field);
                    queryFields.add(field);
                } else {
                    queryFields.add(dataTable.FieldAPI__c);
                }
            }
            
            if(!queryFields.contains('Description')) {
                queryFields.add('Description');
				system.debug('Description If');
            }
            
            if(!queryFields.contains('Status')) {
                queryFields.add('Status');
				system.debug('Status If');
            }
            
            if(!queryFields.contains('Frequent_Flyer_Tier__c')) {
                queryFields.add('Frequent_Flyer_Tier__c');
				system.debug('Freq Flyer If');
            }
            
            if(!queryFields.contains('Sub_Category__c')) {
                queryFields.add('Sub_Category__c');
				system.debug('Sub Category If');
            }
            
            String theQuery;
            if(String.isNotBlank(ffNumber)) {
                String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+','');
                System.debug('ffNumWithOutLeadingZeros#### '+ffNumWithOutLeadingZeros);
                String ffNumWithLeadingZeros = '0%'+ffNumWithOutLeadingZeros;
                System.debug('ffNumWithOutLeadingZeros#### '+ffNumWithLeadingZeros);
                contactMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c =: ffNumWithOutLeadingZeros OR Frequent_Flyer_Number__c like :ffNumWithLeadingZeros ORDER BY CAP_ID__c NULLS LAST LIMIT 1]);
				system.debug('Contact Map####' +contactMap);
                Set<Id> contactIds = contactMap.keySet();
				system.debug('Contact Ids####'+ contactIds);
				system.debug('Case Ids####'+ qccCaseIds);
				system.debug('Case Ids Binding variable####'+ caseId);
                //Jira: CRM-4956
                //Jira CRM-6471: SOQL Performance
                theQuery = 'SELECT Id, '+ String.join(queryFields, ',') + ' FROM Case WHERE RecordTypeId IN :qccCaseIds AND ContactId IN :contactIds AND Id != :caseId AND CCC_And_B_Case_Type__c != :child ORDER BY CreatedDate DESC';
				system.debug('1 - theQuery####'+theQuery);
            } else {
                Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE FirstName =: firstName AND LastName =: lastName AND Frequent_Flyer_Number__c != null]);
				system.debug('Map Contacts***'+contacts);
                Set<Id> conIds = contacts.keySet();
				system.debug('Contact id***'+conIds);
                //if(conIds != null && conIds.size() == 1) {
                //    System.debug('Only one FF contact found');
                //    theQuery = 'SELECT Id, Contact.Frequent_Flyer_Number__c, '+ String.join(queryFields, ',') + ' FROM Case WHERE RecordTypeId IN :qccCaseIds AND ContactId IN :conIds AND Id != :caseId ORDER BY CreatedDate DESC';
                //} else {
                    if(conIds != null && conIds.size() > 0) {

                        System.debug('Multiple contacts with same First name and Last name+++');
                        Id placeholderRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC_PlaceHolderAccRectype'));
						system.debug('RecordtypeID+++'+placeholderRecTypeId);
                        //Jira CRM-6471: SOQL Performance
                        theQuery = 'SELECT Id, Contact.Frequent_Flyer_Number__c, '+ String.join(queryFields, ',') + ' FROM Case WHERE RecordTypeId IN :qccCaseIds AND (ContactId IN :conIds OR Contact.RecordTypeId =: placeholderRecTypeId) AND First_Name__c =: firstName AND Last_Name__c =: lastName AND CCC_And_B_Case_Type__c != :child';
                    } else {
                        //Jira: CRM-4958
                        //Jira CRM-6471: SOQL Performance
                        theQuery = 'SELECT Id, '+ String.join(queryFields, ',') + ' FROM Case WHERE RecordTypeId IN :qccCaseIds AND First_Name__c =: firstName AND Last_Name__c =: lastName AND CCC_And_B_Case_Type__c != :child';
                    }
                    if(String.isNotBlank(email)) {
                        theQuery = theQuery + ' AND Contact_Email__c =: email';
                    }
                    if(String.isNotBlank(phone)) {
                        theQuery = theQuery + ' AND Contact_Phone__c =: phone';
                    }
                    if(String.isNotBlank(caseId)) {
                        theQuery = theQuery + ' AND Id != :caseId';
                    }
                    theQuery = theQuery + ' ORDER BY CreatedDate DESC';
                //}
            }
            System.debug('theQueryFinal'+theQuery);
            //Jira CRM-6471: SOQL Performance
			//System.debug('theDBQueryResults'+Database.query(theQuery));
			
            cases = (List<Case>)Database.query(theQuery);
			System.debug('Case values*****'+cases);
            for(Case cs: cases) {
				system.debug('Case Inside Iteration :'+cs);
                // Just for displaying purpose on hovering over Case Number, did the below line and it is not committed to the database
                // It is just a workaround.
                String hoverMsg = 'Status: ' + cs.Status;
                hoverMsg = hoverMsg + '\n\nTier: ' + (String.isNotBlank(cs.Frequent_Flyer_Tier__c) ? cs.Frequent_Flyer_Tier__c : '');
                hoverMsg = hoverMsg + '\n\nSub Category: ' + (String.isNotBlank(cs.Sub_Category__c) ? cs.Sub_Category__c : '');
                hoverMsg = hoverMsg + '\n\nDescription: '+ (String.isNotBlank(cs.Description) ? cs.Description : '');
                cs.Description = hoverMsg;
                //System.debug(cs.CreatedDate);
            }
            return cases;
			
        } catch(Exception ex) {
			system.debug('inside catch');
            System.debug(ex.getStackTraceString());
            system.debug('Exception###'+ex.getMessage()); 
            system.debug('Exception###'+ex.getLineNumber()); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Search Contact Info', 'QCC_SearchContactInfoController', 
                                    'search', '', '', false,'', ex);
        }
        return null;
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    getContactId
    Description:    Search for the Contact and return the Contact Id
    Parameter:      String, String, String, String, String        
    Return:         String <ContactId>_<noreplyEmail>   
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String getContactId(String firstName, String lastName, String capId, String ffTier, String ffNumber, String email, String phone) {
        try {
            firstName = QCC_GenericUtils.doTrim(firstName);
            lastName = QCC_GenericUtils.doTrim(lastName);
            ffNumber = QCC_GenericUtils.doTrim(ffNumber);
            email = (String.isNotBlank(email)) ? QCC_GenericUtils.doTrim(email) : '';
            phone = (String.isNotBlank(phone)) ? QCC_GenericUtils.doTrim(phone) : '';
            List<Contact> contacts = new List<Contact>();
            Contact con;
            
            //Crete wrapper
            QCC_ContactWrapper contactWrapper = new QCC_ContactWrapper();
            contactWrapper.firstName = firstName;
            contactWrapper.lastName = lastName;
            contactWrapper.capId = capId;
            contactWrapper.ffTier = ffTier;
            contactWrapper.ffNumber = ffNumber;
            contactWrapper.email = email;
            contactWrapper.phone = phone;
            
            if(String.isNotBlank(ffNumber)) {
                con = QCC_GenericUtils.fetchContactForFFCase(contactWrapper);
            } else {
                //ADT-140: Create Non FF contact
                List<String> contactDetails = new List<String>();
                contactDetails.add(JSON.serialize(contactWrapper));
                String contactMappingSource = 'ContactWrapper_Field__c';
                Map<String,Contact> allContactsMap = QCC_GenericUtils.getNonFFContactForCase(contactDetails, contactMappingSource);
                //If all fields required to create a non ff contact are defined then non ff contact (RecordType = Individual) will return
                if (!allContactsMap.isEmpty()) {
                    con = allContactsMap.values().get(0);
                } else {//Otherwise, NULL contact (RecordType = Placeholder) will be created
                    con = QCC_GenericUtils.fetchContactForNonFFCase();
                }
            }
           //insert con;
            String noReply = CustomSettingsUtilities.getConfigDataMap('QCC_ContactEmail');
            return con.Id+'_'+noReply;
        } catch(Exception ex) {
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Search Contact Info', 'QCC_SearchContactInfoController', 
                                    'getContactId', '', '', false,'', ex);
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    createCase
    Description:    create case on lightning out
    Parameter:      String, String, String, String, String        
    Return:         case id.
    ----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String createCase(String contactId, String email, String phone, String firstName, String lastName,
        String street, String suburb, String postCode, String stateCode, String country, String recordTypeId) 
    {
        try {
            Case objCase = new Case();
            objCase.ContactId = contactId;
            objCase.Contact_Email__c = email;
            objCase.Contact_Phone__c =  phone;
            objCase.First_Name__c = firstName;
            objCase.Last_Name__c = lastName;
            objCase.Street__c  = street;
            objCase.Suburb__c = suburb;
            objCase.Post_Code__c = postCode;
            objCase.State__c = stateCode;
            objCase.Country__c = country;
            objCase.Status = 'Received';
            objCase.Origin = 'Webchat';
            objCase.Is_Response_Requested__c = 'No';
            objCase.recordTypeId = recordTypeId;
            insert objCase;
            Case newCase  = [select Id, CaseNumber, ContactId, Contact_Email__c, Contact_Phone__c,
                             Last_Name__c, Street__c, Suburb__c, Post_Code__c, State__c, Country__c,
                             Status, Origin, Is_Response_Requested__c, First_Name__c from Case 
                             where Id =: objCase.Id];
            String strCase = JSON.serialize(newCase);
            return strCase;
        }catch(Exception ex) {
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Search Contact Info', 'QCC_SearchContactInfoController', 
                                    'createCase', '', '', false,'', ex);
        }
        return null;
    }

}