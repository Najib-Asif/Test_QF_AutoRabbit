/*****************************************************************************************
* Created By        Leslie Padilla | ACN | Developer 
* Purpose           This apex includes helper methods for QCC Voice Call Handling Component Screen flow and its subflows
* REST API          No Rest API Needed 
* Modified Date     27/01/23 (DD/MM/YYYY)
* Modified By       
* JIRA              ADT-189 - Ability to Verify caller
* Version           1.1 Initial Development
******************************************************************************************/
public class QCC_CallHandlingFlowHelper {
    @InvocableMethod(label='QCC Call Handling Flow Helper')
    public static List<FlowOutputs> invokeThisMethod(List<FlowInputs> request) {
        List<FlowOutputs> results;
        if (request[0].methodName == 'createAnonymisedContact') {
            results = createAnonymisedContact(request);
        }        
        if (request[0].methodName == 'getContactBasedOnFF') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = getContactBasedOnFF(request);
        }
        if (request[0].methodName == 'removeSpace') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = removeSpace(request);
        }
        if (request[0].methodName == 'validateEmail') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = validateEmail(request);
        }
        if (request[0].methodName == 'validatePhone') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = validatePhone(request);
        }
        if (request[0].methodName == 'createNewFFContact') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = createNewFFContact(request);
        }
        if (request[0].methodName == 'createNewNonFFContact') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = createNewNonFFContact(request);
        }
        if (request[0].methodName == 'getExistingNonFFCont') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = getExistingNonFFCont(request);
        }
        if (request[0].methodName == 'getFourParamsFromTheCase') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = getFourParamsFromTheCase(request);
        }
        if (request[0].methodName == 'searchAllContacts') {
            system.debug('Flow Helper +++' + request[0].methodName);
            results = searchAllContacts(request);
        }
        return results;
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public String methodName;
        
        @InvocableVariable
        public String firstName;
        
        @InvocableVariable
        public String lastName;
        
        @InvocableVariable
        public String ffNumber;
         
        @InvocableVariable
        public String RecordTypeId;
        
        @InvocableVariable
        public String pnr;
        
        @InvocableVariable
        public String emailInput;
        
        @InvocableVariable
        public contact contactRecInput;
        
        @InvocableVariable
        public String phoneInput;
        
        @InvocableVariable
        public String caseID;
    }
    
    //output details which goes from apex to flow
    public class FlowOutputs{
        @InvocableVariable
        public String contactId;
        
        @InvocableVariable
        public Contact contact;
        
        @InvocableVariable
        public Contact contactRecord;
        
        @InvocableVariable
        public String pnr;
        
        @InvocableVariable
        public Boolean isEmailValid;
        
        @InvocableVariable
        public String validPhone;
        
        @InvocableVariable
        public Case CaseRecord;
        
        @InvocableVariable
        public List<Contact> contactsList;
    }
    
    //Purpose: If caller's enquiry is not PNR-related, then a NULL/Anonymous contact will be created
    public static List<FlowOutputs> createAnonymisedContact(List<FlowInputs> requests) {
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowInputs request = requests[0];
        FlowOutputs result = new FlowOutputs();
        
        Contact objCon = QCC_GenericUtils.fetchContactForNonFFCase();
        result.contactId = objCon.Id;
        result.contact = objCon;
        
        results.add(result); 
        
        system.debug('results ===== ' + results);
        return results;
        
    }
    
    public static List<FlowOutputs> getContactBasedOnFF(List <FlowInputs> request){
        System.debug('@@@@ getContactBasedOnFF');
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        String ffNumber = request[0].ffNumber;
        System.debug('@@@@ ffNumber' + ffNumber);
        String ffNumWithOutLeadingZeros = ffNumber.replaceFirst('^0+', '');
        System.debug('@@@@ ffNumWithOutLeadingZeros > '+ ffNumWithOutLeadingZeros);
        List<Contact> ffContact = [SELECT ID, LastName, FirstName, Email, Frequent_Flyer_Number__c, RecordTypeId FROM Contact WHERE Frequent_Flyer_Number__c =:  ffNumWithOutLeadingZeros AND RecordTypeId =: request[0].RecordTypeId LIMIT 1];
            if(!ffContact.isEmpty()){
                result.contactRecord = ffContact[0];
                System.debug('@@@@ getContactBasedOnFF result > '+ result);
                results.add(result);
            }
        
        return results;
    }
    public static List<FlowOutputs> getExistingNonFFCont(List <FlowInputs> request){
        System.debug('@@@@ getExistingNonFFCont');
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        String firstName;
        
        if(request[0].firstName.contains(' '))
        {
            firstName = request[0].firstName.substringbefore(' ');
        }
        else
        {
            firstName = request[0].firstName;
        }
        String lastName = request[0].lastName;
        String phone = request[0].phoneInput;
        String email = request[0].emailInput;
        
        System.debug('@@@@ firstName' + firstName);
        System.debug('@@@@ lastName' + lastName);
        System.debug('@@@@ phoneInput' + phone);
        System.debug('@@@@ emailInput' + email);
        System.debug('@@@@ request[0].RecordTypeId' + request[0].RecordTypeId);
        
        phone='%'+phone.right(9);
          
        System.debug('@@@@ phoneInput last 9 digits' + phone);
        
        List<Contact> nonFfContact = [SELECT ID, Phone,email, LastName, FirstName, Frequent_Flyer_Number__c, RecordTypeId FROM Contact WHERE 
            (firstname =: firstName OR firstname =: request[0].firstName) AND
            lastName =: lastName AND
            phone like: phone AND
            email =: email AND                          
            RecordTypeId =: request[0].RecordTypeId LIMIT 1];
        
            System.debug('@@@@ nonFfContact result > '+ nonFfContact);
        
            if(!nonFfContact.isEmpty())
            {
                
                result.contactRecord = nonFfContact[0];
                System.debug('@@@@ getExistingNonFFCont result > '+ result);
                results.add(result);
            }
             
        return results;
    }

    public static List<FlowOutputs> removeSpace(List <FlowInputs> request){
        System.debug('@@@@ removeSpace');
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        String pnr = request[0].pnr;
        System.debug('@@@@ request > '+ request);
        String pnrNoSpace = QCC_GenericUtils.doTrim(pnr);
        result.pnr = pnrNoSpace;
        System.debug('@@@@ removeSpace result > '+ result);
        results.add(result);
        return results;
    }
    
    public static List<FlowOutputs> validateEmail(List <FlowInputs> request){
        System.debug('@@@@ validateEmail');
        List<FlowOutputs> results = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();
        String email = request[0].emailInput;
        
        result.isEmailValid = QCC_VoiceUtils.checkIfValidEmail(email);
        System.debug('@@@@ request > '+ request + 'result > ' + result.isEmailValid);

        results.add(result);
        return results;
    }
    //Added the method for CRM-6319
    public static List<FlowOutputs> createNewFFContact(List <FlowInputs> request)
    {
         System.debug('@@@@ createNewFFContact');
         List<FlowOutputs> results = new List<FlowOutputs>();
         List<FlowOutputs> outputFromGetFFContact = new List<FlowOutputs>();
         FlowOutputs result = new FlowOutputs();
         Contact newCont=request[0].contactRecInput;
         outputFromGetFFContact=getContactBasedOnFF(request);
         
        try{
            system.debug('@@@ outputFromGetFFContact'+outputFromGetFFContact);
             if(outputFromGetFFContact==null ||  outputFromGetFFContact.isEmpty())
             {
                 insert newCont;
                result.contactRecord=newCont;
                results.add(result);
                system.debug('@@@ Contact Inserted'+result.contactRecord);
             } 
        }catch(Exception e){
            QCC_VoiceUtils.insertLogRec('Log Exception Logs Rec Type', 'QCC_CallHandlingFlowHelper', 'QCC_CallHandlingFlowHelper',
                                'createNewFFContact', '', '', false,'', e.getMessage());
        }
         return results;
    }
    //Added the method for CRM-6320
    public static List<FlowOutputs> createNewNonFFContact(List <FlowInputs> request)
    {
         System.debug('@@@@ createNewNonFFContact');
         List<FlowOutputs> results = new List<FlowOutputs>();
         List<FlowOutputs> outputFromGetFFContact = new List<FlowOutputs>();
         FlowOutputs result = new FlowOutputs();
         System.debug('@@@@ contact record'+request[0].contactRecInput);
         Contact newCont=request[0].contactRecInput;
         System.debug('@@@@ result of newCont'+newCont); 
    
         
         Boolean validated=QCC_VoiceUtils.checkIfValidEmail(newCont.email);
         system.debug('@@@ email valid?'+validated);
         system.debug('@@@ phone valid?'+newCont.Phone);
         newCont.Phone=QCC_VoiceUtils.checkIfValidPhone(newCont.Phone);
          system.debug('@@@ phone valid after validation?'+newCont.Phone);
        
        try{
            if(validated && newCont.FirstName!=null && newCont.FirstName!='' && newCont.LastName!=null && newCont.LastName!='' && newCont.Phone!=null && newCont.Phone!='')
            {
                System.debug('@@@@ inside the newNonFFContact');
                
                insert newCont;
                result.contact=newCont;
            }
            results.add(result);
             System.debug('@@@@ new contact newCont'+newCont);
        }catch(Exception e){
            QCC_VoiceUtils.insertLogRec('Log Exception Logs Rec Type', 'QCC_CallHandlingFlowHelper', 'QCC_CallHandlingFlowHelper',
                                'createNewNonFFContact', '', '', false,'', e.getMessage());
        }
        
         return results;
    }
    //Validate the phone format enterred for Non FF Contact
      public static List<FlowOutputs> validatePhone(List <FlowInputs> request){
          
          List<FlowOutputs> results = new List<FlowOutputs>();
          try
          {
              System.debug('@@@@ validatePhone');
              if(request[0].phoneInput!=null)
              {
                  
                    FlowOutputs result = new FlowOutputs();
                    String phone = request[0].phoneInput;
                    
                    result.validPhone=QCC_VoiceUtils.checkIfValidPhone(phone);
                    System.debug('@@@@ request > '+ request + 'result > ' + result.validPhone);
        
                results.add(result);
              }
               
                
          }
          catch(exception e)
          {
              system.debug('Exception has occurred'+e.getmessage());
          }
        return results;
    }
     //Validate if four Params exist on the case ID passed CRM-6909
      public static List<FlowOutputs> getFourParamsFromTheCase(List <FlowInputs> request)
      {
            System.debug('@@@@ getFourParamsFromTheCase');
            List<FlowOutputs> results = new List<FlowOutputs>();
            try{
                FlowOutputs result = new FlowOutputs();
                Id caseId = request[0].caseID;
                
                List<Case> getCase=[select id,First_Name__c,Last_Name__c,Contact_Email__c,Contact_Phone__c from case where id=:request[0].caseID];
                result.CaseRecord=getCase[0];
                System.debug('@@@@ request > '+ request + 'result > ' + result.CaseRecord);

                results.add(result);
                }
          catch(Exception e)
          {
              system.debug('Exception has occurred'+e.getmessage());
            }
        return results;
    }
     //Search FF and NON-FF contacts in SF CRM-6909
      public static List<FlowOutputs> searchAllContacts(List <FlowInputs> request)
      {
          System.debug('@@@@ searchAllContacts');
          List<FlowOutputs> results = new List<FlowOutputs>();
          try
          {
              
                FlowOutputs result = new FlowOutputs();
                Id contRecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
                String firstname=request[0].firstName ;
                String lastname=request[0].lastName ;
                String email;
                List<FlowOutputs> getValidPhone=validatePhone(request) ; 
                FlowOutputs validPhone=getValidPhone[0];
                String phone=validPhone.validPhone;
                contact getReturnCont;
                
                List<FlowOutputs> getValidEmail=validateEmail(request) ;
                FlowOutputs validEmail=getValidEmail[0];
                if(validEmail.isEmailValid)
                {
                    email=request[0].emailInput ; 
                }
                
                  if(request[0].firstName.contains(' '))
                    {
                        firstname = request[0].firstName.substringbefore(' ');
                    }
                    else
                    {
                        firstname = request[0].firstName;
                    }
                phone='%'+phone.right(9);
                if(email!=null && email!='')
                {
                    List<contact> getContacts=[select id,firstname,lastname,email,phone,Frequent_Flyer_Number__c,createddate from contact where 
                    recordtypeid=:contRecordTypeId AND
                    (firstname =: firstname OR firstname =: request[0].firstName) AND
                    lastName =: lastname AND
                    phone like: phone AND
                    email =: email AND
                    Active__c = true order by createddate asc];
                    
                    system.debug('@@@ value of getContacts'+getContacts);
                    
                    if(getContacts!=null && getContacts.size()>0)
                    {
                        system.debug('@@@ inside the if check for not null contact');
                        for(Contact getCon: getContacts)
                        {
                            if(getCon.Frequent_Flyer_Number__c!=null && getCon.Frequent_Flyer_Number__c!='')
                            {
                                getReturnCont=getCon;
                                break;
                            }
                            
                        }
                        if(getReturnCont==null){
                            getReturnCont=getContacts[0];
                        }
                        result.contactRecord=getReturnCont;
                    }
                }  
                System.debug('@@@@ request > '+ request + 'result > ' + result.contactRecord);
                results.add(result);
            }
          catch(Exception e)
          {
            system.debug('Exception has occurred'+e.getmessage());
        }
        return results;
    }
}