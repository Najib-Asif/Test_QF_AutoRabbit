public with sharing class qccDateTimeOperations {
    @AuraEnabled(cacheable=true)
    public static Datetime getCurrentDateTime(){
        Datetime GMTDate; 
        try {
             //currentDateTime = System.now();
             Datetime currentDateTime=DateTime.now();
            GMTDate = Datetime.newInstanceGmt(currentDateTime.year(),currentDateTime.month(),currentDateTime.day(),currentDateTime.hour(),currentDateTime.minute(),currentDateTime.second());
             
             System.debug('>>>Print the date time'+GMTDate);
             return GMTDate;
        } catch (Exception e) {CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'qccDateTimeOperations', 'qccDateTimeOperations','getCurrentDateTime', String.valueOf(''), String.valueOf(''),false,'', e);
            throw new AuraHandledException(e.getMessage());
           }
        
    }
    @AuraEnabled
    public static Boolean compareDateTime(Id contactId){
        Datetime currentDateTime=DateTime.now();
        Datetime GMTDateNow=Datetime.newInstanceGmt(currentDateTime.year(),currentDateTime.month(),currentDateTime.day(),currentDateTime.hour(),currentDateTime.minute(),currentDateTime.second()); 
        Boolean hideSensitiveMessage=false;
        DateTime contactSelectedDateTime;
        DateTime contactSelectedDateTimeInGMT;
        
        Contact updateCont=new Contact();

        System.debug('Here is the GMT date and Time Now'+GMTDateNow);
        try {
             List<Contact> contactList=[SELECT Schedule_Sensitive_Message__c,Sensitive_Contact__c FROM Contact WHERE Id=:contactId LIMIT 1];
             if(contactList!=null && contactList.size()>0)
             {
                updateCont=contactList.get(0);
                System.debug('Previous Time'+updateCont.Sensitive_Contact__c);
                contactSelectedDateTime=contactList.get(0).Schedule_Sensitive_Message__c;
                System.debug('SOQL returned datetime from field'+ contactSelectedDateTime);
                if(contactSelectedDateTime!=null)
                contactSelectedDateTimeInGMT=Datetime.newInstanceGmt(contactSelectedDateTime.year(),contactSelectedDateTime.month(),contactSelectedDateTime.day(),contactSelectedDateTime.hour(),contactSelectedDateTime.minute(),contactSelectedDateTime.second());

                System.debug('Here is the GMT date and Time Previously set'+contactSelectedDateTimeInGMT);

                
                if(contactSelectedDateTimeInGMT!=null && contactSelectedDateTimeInGMT<=GMTDateNow)
                {
                    hideSensitiveMessage=true;
                    
                }
             
                if(hideSensitiveMessage && updateCont.Sensitive_Contact__c==true)
                {
                    system.debug('Inside the hide sensitive message and contact checkbox');
                    updateCont.Sensitive_Contact__c=false;
                    update updateCont;
                }
                 System.debug('>>>Print the comparison result'+hideSensitiveMessage);
             }
             

             
             return hideSensitiveMessage;
        } catch (Exception e) {CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'qccDateTimeOperations', 'qccDateTimeOperations','compareDateTime', String.valueOf(''), String.valueOf(''),false,'', e);
            throw new AuraHandledException(e.getMessage());
           
        }
        
    }
    @AuraEnabled(cacheable=true)
    public static Boolean compareSelectedDateTime(DateTime selectedDateTime)
    {
        Datetime GMTDateNow; 
        Datetime selectedDateTimeInGMT;
        Boolean showDateValidationMsg=false;
        try {
             //currentDateTime = System.now();
             Datetime currentDateTime=DateTime.now();
             GMTDateNow = Datetime.newInstanceGmt(currentDateTime.year(),currentDateTime.month(),currentDateTime.day(),currentDateTime.hour(),currentDateTime.minute(),currentDateTime.second());
             selectedDateTimeInGMT=Datetime.newInstanceGmt(selectedDateTime.year(),selectedDateTime.month(),selectedDateTime.day(),selectedDateTime.hour(),selectedDateTime.minute(),selectedDateTime.second());
             System.debug('>>>Print the date time of now'+GMTDateNow);
             System.debug('>>>Print the date time selected one'+selectedDateTimeInGMT);

             if(selectedDateTimeInGMT<GMTDateNow)
             {
                showDateValidationMsg=true;
             }
             return showDateValidationMsg;
        } catch (Exception e) {
           
            system.debug('ex######'+e);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'qccDateTimeOperations', 'qccDateTimeOperations',
                                    'compareSelectedDateTime', String.valueOf(''), String.valueOf(''),false,'', e);
            
            throw new AuraHandledException(e.getMessage());
           
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static DateTime convertInGMT(DateTime selectedDateTime)
    {
        Datetime selectedDateTimeInGMT;
        
        try {
             
             selectedDateTimeInGMT=Datetime.newInstanceGmt(selectedDateTime.year(),selectedDateTime.month(),selectedDateTime.day(),selectedDateTime.hour(),selectedDateTime.minute(),selectedDateTime.second());
             
             System.debug('>>>Print the selected date time in convertInGMT'+selectedDateTimeInGMT);
             
             return selectedDateTimeInGMT;
        } catch (Exception e) {CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'qccDateTimeOperations', 'qccDateTimeOperations',
                                    'convertInGMT', String.valueOf(''), String.valueOf(''),false,'', e);
            throw new AuraHandledException(e.getMessage());
           
        }
    }
   
}