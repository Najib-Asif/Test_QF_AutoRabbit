/*-----------------------------------------------------------------------------------------------------------------------------
Author:        
Company:       
Description:   
Test Class:   
*********************************************************************************************************************************
*********************************************************************************************************************************
History
Abhijeet P /Jayaraman J          For Freight to populate citycode in ACR record added few code    
Praveen S                        For QCC to create Account when new contact is created. Method: createAccount
Abbas S                          For Mapping AlternateEmail__c To Email And AlternatePhone__c to Phone 
Gnanavelu T                      Updated the class to work only for no Agency contacts Jira: CRM-4161
Vinothkumar Balasubramanian      Primary Contact on ACR should be checked during Account Registration JIRA : CRM-4188
********************************************************************************************************************************/

Public class accConRshipUpdateonContacts {
    
    public static void AccContactInsUpdate(list<Contact> listOfCon) {
        
        set<Id> ConIds = new set<Id>();
        map<Id, Contact> mapContact = new map<Id, Contact>();
        Set<String> accId = new Set<String>();
        list<AccountContactRelation> listOfAccConRel = new list<AccountContactRelation>();
        list<AccountContactRelation> listOfAccConRelUpd = new list<AccountContactRelation>();
        //Freight change Start
        set<Id> AirportcodeIds = new set<Id>();
        list<Airport_Code__c> listOfAirportcode = new list<Airport_Code__c>();
        map<Id, Airport_Code__c> mapAirportcode = new map<Id, Airport_Code__c>();
        //Freight change End
        Map<Id, Integer> AccountCount = new Map<Id, Integer>();
        //Changes start for CRM-4188
        Map<Id, Integer> Acrcount = new Map<Id, Integer>();
        //Changes end for CRM-4188
        Map<Id,Contact> mCon = new Map<Id,Contact>();
        List<AggregateResult> arList = new List<AggregateResult>();
        List<AggregateResult> acrList = new List<AggregateResult>();
        for(Contact Cont : listOfCon) {

            ConIds.add(Cont.Id);
            mapContact.put(Cont.Id, Cont);
            //ACR Primary
            if(Cont.QAC_Contact__c == 'Yes')
            accId.add(cont.accountid);
            //Freight change
            AirportcodeIds.add(Cont.Freight_Contact_City__c);
            
        }
        
        //Freight change Start
        /*listOfAirportcode =[Select Id,Name from Airport_Code__c where id In :AirportcodeIds ];

if(listOfAirportcode.size() > 0)
{
for(Airport_Code__c aico : listOfAirportcode) {
mapAirportcode.put(aico.id, aico);
}
}*/
        mapAirportcode = new Map<Id, Airport_Code__c>([Select Id,Name from Airport_Code__c where id In :AirportcodeIds ]);
        
        //Freight change End
        
        listOfAccConRel = [SELECT Function__c,Business_Type__c,Job_Role__c,ContactId,Contact.name,accountId,IsDirect, Freight_City__c, Key_Contact__c, Contact.QAC_Contact__c FROM AccountContactRelation WHERE ContactId IN : ConIds];
        system.debug('***SOQLUPDATEACR***'+ listOfAccConRel ); // City__c
        Set<ID> contactIDset = new Set<ID>();
        
        // for (AccountContactRelation acr:listOfAccConRel)
        //    contactIDset.add(acr.ContactId);
        //  listOfAccConRelcount = [SELECT id FROM AccountContactRelation WHERE ContactId IN : ConIds];
        List<AccountContactRelation > accList = new List<AccountContactRelation >();
        //  accList =[Select Id from Account WHERE ContactId IN : contactIDset];
        //commented below for loop as part of CRM-4188
        /*for (AccountContactRelation acr:listOfAccConRel )
            AccountCount.put(acr.ContactId,0);*/
        //Changes start for CRM-4188
        for (AccountContactRelation acr:listOfAccConRel)
            Acrcount.put(acr.accountId,0);
        //Changes end for CRM-4188
        //Commented below query to reduce soql during CRM-4188
        /*arList = [select ContactId conid, count(id)cnt from AccountContactRelation where ContactId in :AccountCount.keySet() group by ContactId];
        for (AggregateResult ar : arList) {
            AccountCount.put((Id)ar.get('conid'), (Integer)ar.get('cnt'));
        }*/
        //Changes start for CRM-4188
        for (AccountContactRelation ar : listOfAccConRel) {
            integer count=1;
            if(!AccountCount.containskey(ar.contactId)){
            AccountCount.put(ar.contactId,count);
            }else
            {
                AccountCount.put(ar.contactId,AccountCount.get(ar.contactId)+1);
            }
        }
        
        
        acrList=[select accountId accid, count(id)cnt from AccountContactRelation where accountId in :accid and primary_contact__c=true group by accountid];
        System.debug('Primary Acr List'+acrList);
        for (AggregateResult ar : acrList) {
            Acrcount.put((Id)ar.get('accid'), (Integer)ar.get('cnt'));
        }
        //Changes end for CRM-4188
        
        //  system.debug('***ACRCOUNT***'+ listOfAccConRelUpd );
        
        //for (Contact co:listOfCon)
        
        // {
        // if(AccountCount.get(co.Id) == 1){
        system.debug('***SizeofACR***'+ listOfAccConRel.size());
        
        for(AccountContactRelation accCon : listOfAccConRel) {
            if(AccountCount.get(accCon.ContactId) == 1){
                accCon.Function__c = mapContact.get(accCon.ContactId).Function__c;
                accCon.Business_Type__c = mapContact.get(accCon.ContactId).Business_Types__c;  
                accCon.Job_Role__c = mapContact.get(accCon.ContactId).Job_Role__c;
                system.debug('***ACR***'+ accCon.Job_Role__c);
                acccon.Job_Title__c = mapContact.get(accCon.ContactId).Job_Title__c;
                acccon.Related_Phone__c = mapContact.get(accCon.ContactId).Phone;
                //Freight change Start
                if(mapAirportcode.size() > 0)
                {
                    acccon.Freight_City__c = mapAirportcode.get(mapContact.get(accCon.ContactId).Freight_Contact_City__c).Name;
                }
                //Freight change End
                
                //Changes added JIRA:TS-3110
                if(mapContact.get(accCon.ContactId).Key_Contact__c == true)
                    acccon.Key_Contact__c = mapContact.get(accCon.ContactId).Key_Contact__c;
                //Changes End JIRA:TS-3110
                acccon.Related_Email__c = mapContact.get(accCon.ContactId).Email;
                //Changes start for CRM-4188
                if(AcrCount.get(accCon.accountId) == 0 && accCon.contact.name!='Store Email'){
                acccon.Primary_Contact__c=true;
                acccon.Related_Phone__c = mapContact.get(accCon.ContactId).MobilePhone;
                }
                else if (accCon.contact.QAC_Contact__c != 'Yes') {
                    acccon.Related_Phone__c = mapContact.get(accCon.ContactId).Phone;
                }
                    
                //Changes end for CRM-4188
                
                listOfAccConRelUpd .add(acccon);   
            }            
        }
        
        //   }
        // }
        if(listOfAccConRelUpd .size()>0)
            
            Database.update(listOfAccConRelUpd );
        system.debug('***UPDATEACR***'+ listOfAccConRelUpd );  
    }
    
    public static void AccContactUpdate(list<Contact> listOfCon) {
        
        set<Id> ConIds = new set<Id>();
        map<Id, Contact> mapContact = new map<Id, Contact>();
        list<AccountContactRelation> listOfAccConRel = new list<AccountContactRelation>();
        list<AccountContactRelation> listOfAccConRelUpd = new list<AccountContactRelation>();
        //Freight change Start
        set<Id> AirportcodeIds = new set<Id>();
        list<Airport_Code__c> listOfAirportcode = new list<Airport_Code__c>();
        map<Id, Airport_Code__c> mapAirportcode = new map<Id, Airport_Code__c>();
        //Freight change End
        Map<Id, Integer> AccountCount = new Map<Id, Integer>();
        Map<Id,Contact> mCon = new Map<Id,Contact>();
        List<AggregateResult> arList = new List<AggregateResult>();
        for(Contact Cont : listOfCon) {
      if(Cont.QAC_Contact__c != 'Yes')
      {
            ConIds.add(Cont.Id);
            mapContact.put(Cont.Id, Cont);
            //Freight change
            AirportcodeIds.add(Cont.Freight_Contact_City__c);
      }
            
        }
        
        //Freight change Start
        /*listOfAirportcode =[Select Id,Name from Airport_Code__c where id In :AirportcodeIds ];

if(listOfAirportcode.size() > 0)
{
for(Airport_Code__c aico : listOfAirportcode) {
mapAirportcode.put(aico.id, aico);
}
}*/
        mapAirportcode = new Map<Id, Airport_Code__c>([Select Id,Name from Airport_Code__c where id In :AirportcodeIds ]);
        
        //Freight change End
        
        listOfAccConRel = [SELECT Function__c,Business_Type__c,Job_Role__c,ContactId,IsDirect, Freight_City__c, Key_Contact__c FROM AccountContactRelation WHERE ContactId IN : ConIds];
        system.debug('***SOQLUPDATEACR***'+ listOfAccConRel ); // City__c
        Set<ID> contactIDset = new Set<ID>();
        
        // for (AccountContactRelation acr:listOfAccConRel)
        //    contactIDset.add(acr.ContactId);
        //  listOfAccConRelcount = [SELECT id FROM AccountContactRelation WHERE ContactId IN : ConIds];
        List<AccountContactRelation > accList = new List<AccountContactRelation >();
        //  accList =[Select Id from Account WHERE ContactId IN : contactIDset];
        for (AccountContactRelation acr:listOfAccConRel )
            AccountCount.put(acr.ContactId,0);
        arList = [select ContactId conid, count(id)cnt from AccountContactRelation where ContactId in :AccountCount.keySet() group by ContactId];
        for (AggregateResult ar : arList) {
            AccountCount.put((Id)ar.get('conid'), (Integer)ar.get('cnt'));
        }
        
        //  system.debug('***ACRCOUNT***'+ listOfAccConRelUpd );
        
        //for (Contact co:listOfCon)
        
        // {
        // if(AccountCount.get(co.Id) == 1){
        system.debug('***SizeofACR***'+ listOfAccConRel.size());
        
        for(AccountContactRelation accCon : listOfAccConRel) {
            if(AccountCount.get(accCon.ContactId) == 1){
                accCon.Function__c = mapContact.get(accCon.ContactId).Function__c;
                accCon.Business_Type__c = mapContact.get(accCon.ContactId).Business_Types__c;  
                accCon.Job_Role__c = mapContact.get(accCon.ContactId).Job_Role__c;
                system.debug('***ACR***'+ accCon.Job_Role__c);
                acccon.Job_Title__c = mapContact.get(accCon.ContactId).Job_Title__c;
                acccon.Related_Phone__c = mapContact.get(accCon.ContactId).Phone;
                //Freight change Start
                if(mapAirportcode.size() > 0)
                {
                    acccon.Freight_City__c = mapAirportcode.get(mapContact.get(accCon.ContactId).Freight_Contact_City__c).Name;
                }
                //Freight change End
                
                //Changes added JIRA:TS-3110
                if(mapContact.get(accCon.ContactId).Key_Contact__c == true)
                    acccon.Key_Contact__c = mapContact.get(accCon.ContactId).Key_Contact__c;
                //Changes End JIRA:TS-3110
                acccon.Related_Email__c = mapContact.get(accCon.ContactId).Email;     
                listOfAccConRelUpd .add(acccon);   
            }            
        }
        
        //   }
        // }
        if(listOfAccConRelUpd .size()>0)
            
            Database.update(listOfAccConRelUpd );
        system.debug('***UPDATEACR***'+ listOfAccConRelUpd );  
    }
    
    
    
    //public static void createAccount(List<Contact> lstCons){
    //    try{ 
    //        List<Account> lstAcc = new List<Account>();
    
    //        for(Contact objCon: lstCons){
    //            Account acc = new Account();
    //            acc.Name =objCon.firstName + ' ' +objCon.LastName+' [person]';
    //            String rectypeName = CustomSettingsUtilities.getConfigDataMap('Acc acrUpdateRecordType');
    //            acc.RecordTypeId = GenericUtils.getObjectRecordTypeId('Account', rectypeName);
    //            acc.Person_Account__c = true;
    //            objCon.PrimaryBusinessAccount__c = objCon.AccountId;
    //            lstAcc.add(acc);
    //        }
    //        if(lstAcc.size() > 0) {
    //            insert lstAcc;
    //        }
    
    //        for(Integer i = 0; i < lstAcc.size(); i++){
    //            lstCons[i].AccountId = lstAcc[i].Id;
    //        }
    //    }catch(Exception ex){
    //        CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Contact Trigger', 'accConRshipUpdateonContacts', 
    //                                'createAccount', String.valueOf(''), String.valueOf(''),false,'', ex);
    //    }
    //}
    public static void createAccount(List<Contact> lstCons){
        try{
            //GRAPHITE-1020: Because P1/CL/LTP contacts will be created via Event Stream when the contact does not exist yet,
            //the current logged-in user is the "Automated Process" which does not have a profile. Hence, the getCurrentUserProfileName() method throws an error.
            //Since the introduction of "Individual Contact", system does not need to check who is the logged-in user to decide whether to create Person Account or not.
            //The check can just be based on the Record Type = Individual Contact
            //string profileName = getCurrentUserProfileName();
            
            /*if(profileName =='Qantas CC Consultant'||
               profileName =='Qantas CC Team Lead'|| 
               profileName =='Qantas CC Operational Manager'||
               profileName == 'Qantas CC Journey Manager' ||
			profileName == 'System administrator'){*/
            Id individualContactRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
                   List<Account> lstAcc = new List<Account>();
                   
                   for(Contact objCon: lstCons){
                if(objCon.AccountId == Null && objCon.RecordTypeId == individualContactRecTypeId){
                           Account acc = new Account();
                           acc.Name =objCon.firstName + ' ' +objCon.LastName+' [person]';
                           String rectypeName = CustomSettingsUtilities.getConfigDataMap('Acc acrUpdateRecordType');
                           acc.RecordTypeId = GenericUtils.getObjectRecordTypeId('Account', rectypeName);
                           //acc.Person_Account__c = true;
                          // objCon.PrimaryBusinessAccount__c = objCon.AccountId;
                           lstAcc.add(acc);
                       }
                   }
            if (!lstAcc.isEmpty()) {
                   insert lstAcc;
            }
                   System.debug('Accounts ' + lstAcc);
                   System.debug('Contacts ' + lstCons);
                   
                   System.debug('Accounts size' + lstAcc.size());
                   System.debug('Contacts size' + lstCons.size());
                   for(Integer i = 0; i < lstAcc.size(); i++){
                       lstCons[i].AccountId = lstAcc[i].Id;
                   }
            // }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Contact Trigger', 'accConRshipUpdateonContacts', 
                                    'createAccount', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    public static void updateContact(List<Contact> lstCons, Map<Id, Contact> mapOldContact){
        for(Contact objCon: lstCons){

          Contact oldCon = mapOldContact != NUll? mapOldContact.get(objCon.Id): Null;
            if(oldCon == Null || oldCon.MailingCity != objCon.MailingCity ||
              oldCon.MailingState != objCon.MailingState || oldCon.MailingStateCode != objCon.MailingStateCode) {
                objCon.Profile_Homeport__c = objCon.MailingCity+', '+objCon.MailingStateCode;
            }

        }
    }

 /*   public static void createACRforPrimaryBusinessAcc(List<Contact> lstCons){
        string profileName = getCurrentUserProfileName();
        if(profileName =='Qantas CC Consultant'||
           profileName =='Qantas CC Team Lead'|| 
           profileName =='Qantas CC Operational Manager'){
               
               List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
               for(Contact objCon: lstCons){
                   if(objCon.PrimaryBusinessAccount__c != Null){
                       AccountContactRelation objACR = new AccountContactRelation();
                       objACR.ContactId = objCon.Id;
                       objACR.AccountId = objCon.PrimaryBusinessAccount__c;
                       objACR.Function__c = objCon.Function__c;
                       objACR.Business_Type__c = objCon.Business_Types__c;  
                       objACR.Job_Role__c = objCon.Job_Role__c;
                       objACR.Job_Title__c = objCon.Job_Title__c;
                       objACR.Related_Phone__c = objCon.Phone;
                       objACR.Related_Email__c = objCon.Email; 
                       objACR.PrimaryBusiness__c = true;   
                       lstACR.add(objACR);
                   }
               }
               insert lstACR;
           }
    } */
    
       public static void UpdateFrequentFlyerNumber(List<Contact> ConLst, Map<Id, Contact> ContactOldMap)
    {
        for(Contact ConObj : ConLst)
        {

            //Contact ContMap = ContactOldMap.get(ConObj.Id);
            //GRAPHITE - Add logic to check if the map contains key to prevent throwing an error "Attempt to dereference null object"
            Contact ContMap = (ContactOldMap != NULL) ? ContactOldMap.get(ConObj.Id) : null;
            if (ContMap != NULL) {
            if(ContactOldMap!=NULL && String.isNotBlank(ConObj.Frequent_Flyer_Number__c) && ContMap.Frequent_Flyer_Number__c != ConObj.Frequent_Flyer_Number__c)
            {
                ConObj.Frequent_Flyer_Number__c = String.valueOf(Integer.valueOf(ConObj.Frequent_Flyer_Number__c));
                system.debug('update ff'+ConObj.Frequent_Flyer_Number__c);
            }
            }
           else if(String.isNotBlank(ConObj.Frequent_Flyer_Number__c))
           {
               ConObj.Frequent_Flyer_Number__c = String.valueOf(Integer.valueOf(ConObj.Frequent_Flyer_Number__c));
               system.debug('insert ff'+ConObj.Frequent_Flyer_Number__c);
           }
            
        }
    } 
    public static void updateStandardEmailandPhone(List<Contact> lstCons){
        //GRAPHITE-1872: Because P1/CL/LTP contacts will be created via Event Stream when the contact does not exist yet,
        //the current logged-in user is the "Automated Process" which does not have a profile. Hence, the getCurrentUserProfileName() method throws an error.
        //Since the introduction of "Individual Contact", system does not need to check who is the logged-in user to decide whether to create Person Account or not.
        //The check can just be based on the Record Type = Individual Contact
        Id individualContactRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        /**
        string profileName = getCurrentUserProfileName();
        if(profileName =='Qantas CC Consultant'||
          profileName =='Qantas CC Team Lead'|| 
          profileName =='Qantas CC Operational Manager'){
        */
               for(Contact objCon: lstCons){
            if (objCon.RecordTypeId == individualContactRecTypeId) {
                   if(String.isBlank(objCon.Email) && String.isNotBlank(objCon.Alternate_Email__c)){
                       objCon.Email = objCon.Alternate_Email__c;
                   }
                   if(String.isBlank(objCon.Phone) && String.isNotBlank(objCon.Alternate_Phone__c)){
                       objCon.Phone = objCon.Alternate_Phone__c;
                   }
               }
           }
        //}
    }

    /*---------------------------------------------------------------------------------------------------      
    Method Name:        linkCaseToContact
    Description:        if Contact.caseId__c is not empty, find the case and attach it to the contact
    Parameter:          Case
    ---------------------------------------------------------------------------------------------------*/
    public static void linkCaseToContact(List<Contact> contacts , Map<Id, Contact> mapOldMap){
        try {
            Map<Id , Contact> casesId = new Map<Id , Contact>();
            for(Contact contact : contacts){
                if(String.isNotBlank(contact.caseId__c)){
                    casesId.put(contact.caseId__c , contact);
                }
            }

            if(casesId.size() > 0) {
                List<Case> cases = new List<Case>();
                for(Case caseObj : [select Id , contactId from Case where Id in :casesId.keySet()]){
                    caseObj.contactId = casesId.get(caseObj.Id).Id;
                    cases.add(caseObj);
                }

                if(cases.size() > 0) update cases;
            }
        } catch(Exception ex){
            system.debug('ex###############'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Contact Trigger Handler', 'ContactTriggerHelper', 
                                    'linkCaseToContact', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    
    public static string getCurrentUserProfileName(){
       String profileName = [SELECT Name FROM Profile where id = :Userinfo.getProfileId()].name;
        return profileName;
    }
}