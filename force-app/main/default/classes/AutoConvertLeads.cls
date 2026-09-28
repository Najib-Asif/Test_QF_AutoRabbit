/*******************************************************************************************************************************
Description: This apex is invoked by a process builder which will convert lead into Account and Contact in 
case of no duplicates exist. Update account type accordingly.
Created Date: 10-04-2017
JIRA: CRM-2545 
Modified Date: 15-06-2017
Modified By : Freight Team as part of Freight release 2 changes.

JIRA: CRM-3040

Modified Date: 05-May-2018
Modified By : DPP Lead changes, auto opportunity creation

JIRA: CRM-10363

Modified Date: 18-Dec-2025
Modified By : Capgemini - Code Security Remediation


******************************************************************************************************************************** */

Public without sharing class AutoConvertLeads { //CRM-10363 added without sharing for Code Security Remediation
    
    @InvocableMethod
    public static void LeadAssign(List < Id > LeadIds) {
        try {
            system.debug('insidetry');
            Map < List<String>,Contact > conMap = new Map < List<String>,Contact > ();
            Contact[] consToUpdate = new List < Contact > ();
            String msg = '';
            String ErrorMessageRecipient = '';
            Set < String > emailSet = new Set < String > ();
            Set < String > lName = new Set < String > ();
            List < Lead > newList = new List < Lead > ();
            //Freight Start
            Map <Id,Id> LeadWithParAccMap = new Map<Id,Id> ();
            Map <Id,Id> newAccIdWithParAccMap = new Map<Id,Id> ();
            Map<ID,AccountContactRelation> parAccIdWithAcrObjMap = new Map<ID,AccountContactRelation> ();
            //CRM-8332 Change Start
            Map <String,Account> frtParentAccMap = new Map<String,Account> ();
            Map <String,Account> frtParentAccCreateMap = new Map<String,Account> ();
            Set < String > frtCorpIdentSet = new Set < String > ();
            Set < String > countryCodeSet = new Set < String > ();
            //CRM-8332 Change End
            //Freight End
            Id accountId;
            Id contactId;
            Id leadId;
            system.debug(LeadIds);
            //CRM-8332 Change Start
            //newList = [Select Email,Parent_Account__c,LastName,Auto_Create_Opportunity__c,Opportunity_Type__c from Lead where Id IN: LeadIds];
            newList = [Select Email,Parent_Account__c,LastName,Auto_Create_Opportunity__c,Opportunity_Type__c, Freight_Corporate_Identifier__c, New_Account_Type__c, 
                        Freight_Station_Code__r.Name, Legal_Name__c, Company, Street, City, State, Country, CountryCode, PostalCode, ABN_Tax_Reference__c, 
                        Freight_Customer_Code__c,Business_Type__c,Freight_Business_Sub_Type__c,Freight_Revenue_Stream__c,Freight_Account_Business_Type__c,
                        SC_ID__c,CreatedDate,Freight_Origin__c,Freight_Destination__c,Target_Volume_kg__c, Description,Proposed_Revenue_Amount__c,Freight_Shipping__c  
                        from Lead where Id IN: LeadIds WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
            Id frtRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Freight_Account').getRecordTypeId();
            //CRM-8332 Change End
            system.debug(newList);
            //Get email addresses.
            for (Lead l: newList) {
                system.debug(l);
                emailSet.add(l.Email);
                //Freight Start
                if (l.Parent_Account__c!=null){ 
                    LeadWithParAccMap.put(l.Id,l.Parent_Account__c); 
                }

                //CRM-8332 Change Start
                if (l.New_Account_Type__c == 'Freight-Branch' && l.Parent_Account__c == null && String.isNotBlank(l.Freight_Corporate_Identifier__c) && String.isNotBlank(l.CountryCode)){ 
                    Account newAcc = new Account();
                    newAcc.Name = l.Company + ' [FREIGHT-'+l.Freight_Corporate_Identifier__c+'-'+l.CountryCode+']';
                    newAcc.Type = 'Freight-Country';
                    newAcc.Freight_Corporate_Identifier__c = l.Freight_Corporate_Identifier__c;
                    newAcc.BillingStreet=l.Street;
                    newAcc.BillingCity=l.City;
                    newAcc.BillingState=l.State;
                    newAcc.BillingCountry=l.Country;
                    newAcc.BillingCountryCode=l.CountryCode;
                    newAcc.BillingPostalCode=l.PostalCode;
                    newAcc.Active__c = true;
                    newAcc.ABN_Tax_Reference__c = l.ABN_Tax_Reference__c;
                    newAcc.Freight_Customer_Code__c = l.Freight_Customer_Code__c;
                    newAcc.recordtypeid = frtRecordTypeId;
                    newAcc.Freight_Unique_Identifier__c = l.Freight_Corporate_Identifier__c+'-'+l.CountryCode;//l.Freight_Customer_Code__c;//CRM-9235
                    newAcc.Legal_Name__c = l.Legal_Name__c;//CRM-9235
                    //INC2797644 - Start
                    newAcc.Business_Type__c = l.Freight_Account_Business_Type__c;
                    newAcc.Business_Sub_Type__c = l.Freight_Business_Sub_Type__c;
                    newAcc.Freight_Revenue_Stream__c  = l.Freight_Revenue_Stream__c;
                    //INC2797644 - End
                    frtParentAccCreateMap.put(l.CountryCode+l.Freight_Corporate_Identifier__c,newAcc);
                    frtCorpIdentSet.add(l.Freight_Corporate_Identifier__c);
                    countryCodeSet.add(l.CountryCode);
                }
                //CRM-8332 Change End
                //Freight End
            }
            //CRM-8332 Change Start
            if (!frtCorpIdentSet.isEmpty()){
                for (Account acc: [select Id, Freight_Corporate_Identifier__c, BillingCountryCode from Account where RecordType.DeveloperName = 'Freight_Account' and Type = 'Freight-Country' 
                                    AND Freight_Corporate_Identifier__c IN :frtCorpIdentSet and BillingCountryCode in :countryCodeSet WITH USER_MODE]) { //CRM-10363 added WITH USER_MODE for Code Security Remediation
                    String key = acc.BillingCountryCode+acc.Freight_Corporate_Identifier__c;
                    frtParentAccMap.put(key,acc);
                    frtParentAccCreateMap.remove(key);
                }
                if (!frtParentAccCreateMap.isEmpty()) insert frtParentAccCreateMap.values();
                frtParentAccMap.putAll(frtParentAccCreateMap);
            }
            //CRM-8332 Change End

            List<string> str = new List<string>();
            //Get existing contacts.        
            for (Contact con: [select Email,LastName from Contact where email in :emailSet AND LastName IN:lName WITH USER_MODE]) { //CRM-10363 added WITH USER_MODE for Code Security Remediation
                str.add(con.Email +','+con.LastName);
                conMap.put(str, con);
                system.debug('Existcontact'+con);
            }
            LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true  WITH USER_MODE Limit 1]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
            List < Database.LeadConvert > MassLeadconvert = new List < Database.LeadConvert > ();
            List < String > convertMsgs = new List < String > (); // List of Strings containing status messages about each conversion operation
            for (Lead l: newList) {
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                Leadconvert.setLeadId(l.id);
                Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
                //SC condition
                if(l.SC_ID__c != null && l.Parent_Account__c == null){
                    l.Auto_Create_Opportunity__c =true;
                    l.Opportunity_Type__c='Freight';
                    UPDATE as user l; //CRM-10363 CRUD check before DML
                    system.debug('Auto_Create_Opportunity__c'+l.Auto_Create_Opportunity__c);
                    System.debug('Opportunity_Type__c '+l.Opportunity_Type__c);
                }
                //end
                if(l.Auto_Create_Opportunity__c== TRUE)
                    Leadconvert.setDoNotCreateOpportunity(False); //Remove this line if you want to create an opportunity from Lead Conversion 
                else
                    Leadconvert.setDoNotCreateOpportunity(TRUE);
                Leadconvert.setSendNotificationEmail(TRUE);
                system.debug('Existcontactmap'+conMap);
                List<string> EmailLname = new List<string>();
                EmailLname.add(l.Email+','+l.LastName);
                if (conMap.keySet().contains(EmailLname)) {
                    Leadconvert.setContactId(conMap.get(EmailLname).Id);
                }
                MassLeadconvert.add(Leadconvert);
            }
            
            if (!MassLeadconvert.isEmpty()) {
                List < Database.LeadConvertResult > lcr = Database.convertLead(MassLeadconvert, false);
                
                for (Database.LeadConvertResult lcrList: lcr) {
                    system.debug('LeadConvertResult**********' + lcrList);
                    //Capture failed conversions for the email message.
                    //Freight Start
                    newAccIdWithParAccMap.put(lcrList.getAccountId(), LeadWithParAccMap.get(lcrList.getLeadId()));
                    //Freight End
                    Lead le =[SELECT  Name,Parent_Account__r.Name,OwnerId,Auto_Lead_Convert__c,Opportunity_Type__c,Parent_Account__c, Auto_Create_Opportunity__c,Freight_Shipping__c,  
                    Freight_Account_Business_Type__c, SC_ID__c, CreatedDate,Freight_Origin__c,Freight_Destination__c,Target_Volume_kg__c,Description,Proposed_Revenue_Amount__c,Shipment_Type__c,CurrencyIsoCode from Lead WHERE ID = :lcrList.getLeadId() WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                    
                    system.debug('leadconvertBoolean**********' + lcrList.isSuccess());
                    if (lcrList.isSuccess()) {
                        accountId = lcrList.getAccountId();
                        contactId = lcrList.getContactId();
                        leadId = lcrList.getLeadId();
                        Account acc = [SELECT Name From Account WHERE ID = :accountId WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        Contact con = [SELECT Name From Contact WHERE ID = :contactId WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        system.debug('leadId**********' + leadId);
                        system.debug('accountId**********' + accountId);
                        //String convertMsg='CONVERSION SUCCEEDED: Converted Lead: ' + le.Name + ' into Account: ' + acc.Name + ' and Contact: ' + con.Name + '\n';
                        String convertMsg = 'Account:' + ' <' + acc.Name + '>' + ' and Contact:' + ' <' + con.Name + '>' + ' created from your Lead. Thank you.';
                        
                        convertMsgs.add(convertMsg);
                        //CRM-8332 Change Start
                        if (!Test.isRunningTest()) addChatterFeed(convertMsg, le.OwnerId, accountId);
                        /*ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        
                        messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                        
                        mentionSegmentInput.id = le.OwnerId;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        textSegmentInput.text = ' ' + convertMsg;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = accountId;
                        
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);*/
                        //CRM-8332 Change End
                    }
                    else {
                        system.debug('inside lead error part*************');
                        le.Auto_Lead_Convert__c=False;
                        UPDATE as System le; //CRM-10363 CRUD check before DML
                        Database.Error[] errors = lcrlist.getErrors();
                        String convertMsg = 'Case has been created for the System Administrator to action. Thank you.';
                        for (Database.Error err: errors) {
                            //  convertMsg += '\tERROR: ' + err.getMessage() + '\n';
                            system.debug('convertMsg ############' + convertMsg);
                            convertMsgs.add(convertMsg);
                            //ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), le.Id, ConnectApi.FeedElementType.FeedItem, 'Hi'+convertMsgs);
                            //CRM-8332 Change Start               
                            if (!Test.isRunningTest()) addChatterFeed(convertMsg, le.OwnerId, le.Id);
                            /*ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                            
                            messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                            
                            mentionSegmentInput.id = le.OwnerId;
                            messageBodyInput.messageSegments.add(mentionSegmentInput);
                            
                            textSegmentInput.text = ' ' + convertMsg;
                            messageBodyInput.messageSegments.add(textSegmentInput);
                            
                            feedItemInput.body = messageBodyInput;
                            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                            feedItemInput.subjectId = le.Id;
                            
                            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);*/
                            //CRM-8332 Change End
                        }
                        
                    }
                    if (accountId != null) {
                        system.debug('accountId************' + accountId);
                        List < account > accToUpdate = new List < account > ();
                        Map < String,
                            ID > RecordTypeMAP = new Map < String,
                            Id > ();
                        for (RecordType RecType: [Select Id, DeveloperName from RecordType where sObjectType = 'account' WITH SYSTEM_MODE]) { //CRM-10363 added WITH SYSTEM_MODE for Code Security Remediation
                            RecordTypeMAP.put(RecType.DeveloperName, RecType.id);
                        }
                        
                        
                        List < Account > aclist = [SELECT Id, Name, New_Account_Type__c, Type, IATA_Number__c, RecordTypeID, BillingCountry, BillingCountryCode, BillingState, Parentid, Freight_Corporate_Identifier__c, Freight_Station_Code__r.Name, Freight_Unique_Identifier__c, Freight_Customer_Code__c FROM Account WHERE Id = :accountId WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        For(account accRec: aclist) {
                            system.debug('accRec.BillingCountry########' + accRec.BillingCountry);
                            system.debug('accRec.BillingCountryCode########' + accRec.BillingCountryCode);
                            system.debug('accRec.BillingState########' + accRec.BillingState);
                            if (accRec.New_Account_Type__c == 'Agency') {
                                system.debug('accRec*************' + accRec);
                                accRec.Type = 'Agency Account';
                                accRec.Qantas_Industry_Centre_ID__c = accRec.IATA_Number__c;
                                accRec.RecordTypeID = RecordTypeMAP.get('Agency_Account');
                                accRec.Industry = 'Travel';
                                accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);
                                if (accRec.BillingCountry == 'AU') {
                                    system.debug('accRec.BillingState**********' + accRec.BillingState);
                                    String myString1 = accRec.Name;
                                    system.debug('myString1%%%%%%' + myString1);
                                    String myString2 = accRec.BillingState;
                                    system.debug('myString2 $$$$$$$' + myString2);
                                    Boolean result = myString1.contains(myString2);
                                    system.debug('result ^^^^^^^^^' + result);
                                    if (result == false) accRec.Name = accRec.Name + ' [' + accRec.BillingState + ']';
                                }
                                else {
                                    system.debug('accRec.BillingCountryCode**********' + accRec.BillingCountryCode);
                                    String myString1 = accRec.Name;
                                    system.debug('myString1%%%%%%' + myString1);
                                    String myString2 = accRec.BillingCountryCode;
                                    system.debug('myString2 $$$$$$$' + myString2);
                                    Boolean result = myString1.contains(myString2);
                                    system.debug('result ^^^^^^^^^' + result);
                                    if (result == false) accRec.Name = accRec.Name + ' [' + accRec.BillingCountryCode + ']';
                                }
                                accToUpdate.add(accRec);
                            }
                            else if (accRec.New_Account_Type__c == 'Prospect') {
                                accRec.Type = 'Prospect Account';
                                accRec.RecordTypeid = RecordTypeMAP.get('Prospect_Account');
                                accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);
                                accToUpdate.add(accRec);
                            }
                            
                            else if (accRec.New_Account_Type__c == 'Customer') {
                                accRec.Type = 'Customer Account';
                                accRec.RecordTypeid = RecordTypeMAP.get('Customer_Account');
                                accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);
                                accToUpdate.add(accRec);
                            }
                            
                            else if (accRec.New_Account_Type__c == 'Charter') {
                                accRec.Type = 'Charter Account';
                                accRec.RecordTypeid = RecordTypeMAP.get('Charter_Account');
                                accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);
                                accToUpdate.add(accRec);
                            }
                            else if (accRec.New_Account_Type__c == 'Other') {
                                accRec.Type = 'Other Account';
                                accRec.RecordTypeid = RecordTypeMAP.get('Other_Account');
                                accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);
                                accToUpdate.add(accRec);
                            }
                            //Freight Start
                            else if (accRec.New_Account_Type__c == 'Freight-Branch') {
                                if(accRec.ParentId == null){
                                    accRec.ParentId = newAccIdWithParAccMap.get(accRec.Id);    
                                }  
                                //CRM-8332 Change Start
                                if(accRec.ParentId == null && frtParentAccMap.containsKey(accRec.BillingCountryCode+accRec.Freight_Corporate_Identifier__c)){
                                    accRec.ParentId = frtParentAccMap.get(accRec.BillingCountrycode+accRec.Freight_Corporate_Identifier__c).Id;  
                                    newAccIdWithParAccMap.put(accRec.Id, accRec.ParentId);
                                }   
                                //CRM-8332 Change End
                                   
                                /*INC2797644 - Start
                                if(accRec.Freight_Customer_Code__c != ''){
                   accRec.Freight_Unique_Identifier__c = accRec.Freight_Customer_Code__c;
                                }
                INC2797644 - End*/
                                accRec.Type = accRec.New_Account_Type__c;
                                accRec.RecordTypeid = RecordTypeMAP.get('Freight_Account');
                                accRec.Freight_Unique_Identifier__c = accRec.Freight_Corporate_Identifier__c+'-'+accRec.BillingCountryCode;
                                accRec.Name += ' '+'[FREIGHT-'+accRec.Freight_Corporate_Identifier__c+'-'+accRec.BillingCountrycode+'-'+accRec.Freight_Station_Code__r.Name+']';
                                accToUpdate.add(accRec); 
                                system.debug('insideacc***'+accToUpdate);
                               
                                
                            }
                            //Freight Start
                            
                        }
                        if (accToUpdate.size() > 0) UPDATE as user accToUpdate; //CRM-10363 CRUD check before DML
                    }
                    if(lcrList.getOpportunityId()!= null){
                        List<Opportunity> optyToUpd = new List<Opportunity>();
                        Map < String,ID > OptyRecordTypeMAP = new Map < String,Id > ();
                        for (RecordType RecType: [Select Id, DeveloperName from RecordType where sObjectType = 'opportunity' WITH SYSTEM_MODE]) { //CRM-10363 added WITH SYSTEM_MODE for Code Security Remediation
                            OptyRecordTypeMAP.put(RecType.DeveloperName, RecType.id);
                        }
                        Opportunity opp = [SELECT Name,RecordTypeId,Account.Name,Freight_Frequency__c From Opportunity WHERE ID = :lcrList.getOpportunityId() WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        Account ACCID = [SELECT Id, Name,ParentId FROM Account WHERE Id = :lcrList.getAccountId() WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        system.debug('ACCID***'+ACCID);
                        if(le.Opportunity_Type__c=='Agency Partnerships')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('Agency_Partnerships');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='Business and Government')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('Business_and_Government');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='Charters')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('Scheduled_Charters');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='GSA')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('GSA');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='SME Product')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('SME_Product');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='Sales Development')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('Sales_Development');
                            optyToUpd . add(opp);
                        }
                        else if(le.Opportunity_Type__c=='DPP Onboarding')
                        {
                            opp.RecordTypeid = OptyRecordTypeMAP.get('DPP_Onboarding_Partners');
                            optyToUpd . add(opp);
                        }
                         else if(le.Opportunity_Type__c=='Freight'){//salescockpit oppty mapping
                            opp.Type =le.Opportunity_Type__c;
                            opp.RecordTypeid = OptyRecordTypeMAP.get('Freight');
                            Opp.CloseDate = le.CreatedDate.addDays(30).date();
                            opp.StageName = 'Identify';
                            opp.Category__c = 'RB - Spot Rates';
                            opp.Freight_Frequency__c = 'Seasonal';
                            opp.Freight_Aircraft_Type__c ='Passenger QF';
                            opp.Name ='ZZ'+' '+ le.Freight_Origin__c +' '+le.Freight_Destination__c +' '+opp.Account.Name;
                            opp.OwnerId = le.OwnerId;
                            opp.AccountId = ACCID.ParentId;
                            opp.Contact__c = lcrList.getContactId();
                            opp.Origin_Destination__c = le.Freight_Origin__c+'-'+le.Freight_Destination__c;
                            opp.Target_Volume_in_kg__c =le.Target_Volume_kg__c;
                            opp.Shipment_Type__c = le.Shipment_Type__c;
                            opp.Freight_Shipping__c  =le.Freight_Shipping__c;
                            opp.Description = le.Description;
                            opp.Amount = le.Proposed_Revenue_Amount__c;
                            opp.CurrencyIsoCode = le.CurrencyIsoCode;
                            opp.SC_ID__c = le.SC_ID__c;
                            optyToUpd . add(opp);
                            System.debug('optyToUpd'+opp);
                        }
                        if(optyToUpd.size()>0)
                            UPDATE as user optyToUpd; //CRM-10363 CRUD check before DML
                    }
                    //Freight Start
                    if (contactId != null) {
                        List < Contact > conToUpdate = new List < Contact > ();
                        
                        List < Contact > conlist = [SELECT Id, Name, Business_Types__c, Accountid FROM Contact WHERE Id = :contactId AND Business_Types__c = 'Freight' WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                        For(Contact conRec: conlist) {
                            if(conRec.Business_Types__c == 'Freight')
                            {
                                if(conRec.Accountid != null){
                                    conRec.Accountid = newAccIdWithParAccMap.get(conRec.Accountid);
                                    conToUpdate.add(conRec);
                                }
                            }
                            
                        }
                        if (conToUpdate.size() > 0) UPDATE as user conToUpdate; //CRM-10363 CRUD check before DML
                    }  
                    //Freight End                  
                }
                //Freight ACR Part Start
                if (accountId != null && contactId != null)
                {
                    
                    List < AccountContactRelation > acrToupdateList = new List < AccountContactRelation > ();
                    
                    List < AccountContactRelation > acrlist = [SELECT Id, Accountid, Contactid, Job_Role__c, Business_Type__c, Related_Phone__c, Related_Email__c, Job_Title__c, Function__c, Freight_City__c FROM AccountContactRelation WHERE Contactid = :contactId AND Accountid = : accountId  AND Business_Type__c = 'Freight' WITH USER_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                    For(AccountContactRelation acrRec: acrlist) {            
                        
                        parAccIdWithAcrObjMap.put(newAccIdWithParAccMap.get(acrRec.Accountid), acrRec);                    
                    } 
                    
                    
                    List < AccountContactRelation > acrupdatelist = [SELECT Id, Accountid, Contactid, Job_Role__c, Business_Type__c, Related_Phone__c, Related_Email__c, Job_Title__c, Function__c, Freight_City__c FROM AccountContactRelation WHERE Contactid = :contactId AND Accountid = : newAccIdWithParAccMap.get(accountId)  WITH SYSTEM_MODE]; //CRM-10363 added WITH USER_MODE for Code Security Remediation
                    For(AccountContactRelation acrupdateRec: acrupdatelist) {            
                        
                        
                        acrupdateRec.Job_Role__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Job_Role__c;
                        acrupdateRec.Related_Email__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Related_Email__c;
                        acrupdateRec.Job_Title__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Job_Title__c;
                        acrupdateRec.Function__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Function__c; 
                        if (parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Business_Type__c != null){
                            acrupdateRec.Business_Type__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Business_Type__c;
                        }
                        if (parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Related_Phone__c != null){
                            acrupdateRec.Related_Phone__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Related_Phone__c;
                        }
                        if (parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Freight_City__c != null){
                            acrupdateRec.Freight_City__c = parAccIdWithAcrObjMap.get(acrupdateRec.Accountid).Freight_City__c;
                        }
                        
                        
                        acrToupdateList.add(acrupdateRec); 
                    } 
                    if (acrToupdateList.size() > 0) UPDATE as System acrToupdateList; //CRM-10363 CRUD check before DML
                    
                }
                //Freight ACR Part End
            }
            //Send email with failed conversions.
            /*  if(msg != '') {
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[]{ErrorMessageRecipient,'karpagam.swaminathan@tcs.com'};

mail.setToAddresses(toAddresses);
mail.setSubject('Lead conversion errors');
mail.setPlainTextBody(msg);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
}*/
            // Send notification email
            String msgBody = 'Automatic Lead conversion results:\n';
            for (String convertMsg: convertMsgs) {
                msgBody += convertMsg;
            }
            // sendEmail(UserInfo.getUserId(), UserInfo.getName(), 'Automatic Lead Conversion', msgBody, null);
        } catch (QueryException e) { //CRM-10363 added Catch for Code Security Remediation
            Map<String, Set<String>> inaccessibleFields = e.getInaccessibleFields();
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'AutoConvertLeads', 'AutoConvertLeads', 
                                    'LeadAssign', inaccessibleFields.toString(), String.valueOf(''),false,'', e);
        } catch(Exception ex) {
            // sendEmail(UserInfo.getUserId(), UserInfo.getName(), 'Automatic Lead Conversion Failed', ex.getMessage(), null);
            throw ex;
            //system.debug('insidecatch');
            //system.debug('insidecatch'+ ex);
        }
        
    }
    //CRM-8332 Change Start
    public static void addChatterFeed(String convertMsg, Id ownerId, Id subjectId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        
                        messageBodyInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                        
                        mentionSegmentInput.id = ownerId;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                        
                        textSegmentInput.text = ' ' + convertMsg;
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = subjectId;
                        
                        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    //CRM-8332 Change End
    /* public static Boolean sendEmail(Id targetId, String senderDisplayName, 
String subject, String textBody, Messaging.EmailFileAttachment[] attachments) {

// Create and send a single email message to the targetId      
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

// Use the specified template
email.setTargetObjectId(targetId);
email.setSubject(subject);
email.setPlainTextBody(textBody);
email.setSenderDisplayName(senderDisplayName);
email.setSaveAsActivity(false);
if (attachments != null) {
email.setFileAttachments(attachments);
}
Messaging.SendEmailResult[] results = 
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
return results[0].isSuccess();        
} */
}