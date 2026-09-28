/*----------------------------------------------------------------------------------------------------------------------
Author:        Bharathkumar
Company:       Tata Consultancy services
Description:   QCC EmailMessageCreditCardNoticeHelper
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
20-August-2018      Bharathkumar               Initial Design
22-November-2019     	Accenture 		Rafael Escuadra			    GRAPHITE-909 Add case recordtypes "Assistance" and "Specific Needs" for CreditcardMasking

-----------------------------------------------------------------------------------------------------------------------*/

public with sharing  class QCC_EmailMessageCreditCradNoticeHelper {


    //for masking
    public static void maskCreditCard(List<EmailMessage> EmailMessageList){
        Boolean textBodyHasCardInfo = false;
        Boolean htmlBodyHasasCardInfo = false;
       // EmailMessage c = [select id,HasCreditCard__c,Description,Origin from EmailMessage where id = :EmailMessageId Limit 1];
        Boolean isUpdate = false;
        String emailHtmlBody;
        String emailTextBody;
        Set<id> caseIdSet = new Set<id>();
        for(EmailMessage emailMessage : EmailMessageList){
            System.debug('emailMessage.ParentId'+emailMessage.ParentId);
            if(emailMessage.ParentId != null && string.valueOf(emailMessage.ParentId).startsWith('500')){ //check if parent is case // Null check - CRM 5762 
                caseIdSet.add(emailMessage.ParentId);
            }
        }

        Map<id,String> caseRecordTypeMap = new Map<id,String> ();
        if(!caseIdSet.isEmpty()){
            for(Case caseRecord : [SELECT id, recordtype.Name FROM Case WHERE Id IN :caseIdSet AND recordTypeId  != null]){
                caseRecordTypeMap.put(caseRecord.id, caseRecord.recordtype.Name);
            }
        }
        List<string> recordTypesList  = Label.QCC_MaskCardNumberForRecordTypes.split(';');


        for(EmailMessage em :EmailMessageList){
                        System.debug('em#####'+em);

            //Pre-Travel GRAPHITE-909 Mask Credit Card Details for Pre-Travel Email-to-Case
            String caseRecordTypeName = '';
            if(!string.isEmpty(em.parentId)){
                caseRecordTypeName = caseRecordTypeMap.containsKey(em.parentId) ? caseRecordTypeMap.get(em.parentId) : '';
            }
            if(em != null && em.subject.contains('Qantas Customer Care') || recordTypesList.contains(caseRecordTypeName) ){ //GRAPHITE-909 Mask card details if  recordtype is Assistance
          if(em.TextBody != null){
               String str = em.TextBody;
              emailTextBody = em.TextBody;
              str= str.replace('\n',' ');
              str= str.replace(';',' ');
                List<String> spiltStr = str.split(' ');
                for(String s : spiltStr){
                    String s1 = s;
                    s= s.replace('\n','');
                    s=s.replace('\r','');
                    s =  s.trim(); 
                    Boolean isAusPhoneNumberWithplus = s.startsWith('+61')||s.startsWith('0')||s.startsWith('61')||s.startsWith('+');                    
                    Boolean isPhoneNumber;
                    if(isAusPhoneNumberWithplus){
                        isPhoneNumber =  true;
                        continue;
                    }                   
                    s = s.replaceAll('\\D','');
                    Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11})$');
                    Matcher m = p.matcher(s);
                    if(m.matches()){                        
                        
                        //String mcard1='5555555555554444';
                        textBodyHasCardInfo = true;
                        integer i =s.length();
                        String s2 = s.substring(2, i);
                        String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                        String strChanged = str.replace(s1, s3);
                        str = str.replace(s1, s3);
                       // emailTextBody= strChanged;
                        //em.TextBody = strChanged;
                        em.TextBody = str;    
                    }                    
                }
                //Jira CRM-5358
                Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
              	for (String mskdStr : maskedStrMap.keySet())
              	{
                    em.TextBody = em.TextBody.replace(mskdStr, maskedStrMap.get(mskdStr));
                  	textBodyHasCardInfo = true;
              	}
              
               // hasCardInfo = c.HasCreditCard__c;

            }   
            if(em.HtmlBody != null){
               String str = em.HtmlBody;
                str = str.replaceAll('\\<.*?\\>', ' ');
                emailHtmlBody = em.HtmlBody;
              str= str.replace('\n',' ');
                str= str.replace('&nbsp;',' ');
                List<String> spiltStr = str.split(' ');
                for(String s : spiltStr){
                    String s1 = s;
                    s= s.replace('\n','');                    
                    s=s.replace('\r','');
                    s =  s.trim(); 
                    Boolean isAusPhoneNumberWithplus = s.startsWith('+61')||s.startsWith('0')||s.startsWith('61')||s.startsWith('+');                    
                    Boolean isPhoneNumber;
                    if(isAusPhoneNumberWithplus){
                        isPhoneNumber =  true;
                        continue;
                    }                   
                    s = s.replaceAll('\\D','');
                    Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11})$');
                    Matcher m = p.matcher(s);
                    if(m.matches()){                        
                        
                        //String mcard1='5555555555554444';
                        htmlBodyHasasCardInfo = true;
                        integer i =s.length();
                        //if(i>21){
                        //    i=17;
                       // }
                        String s2 = s.substring(2, i);
                        String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                        String strChanged = str.replace(s1, s3);
                       str =  str.replace(s1, s3);
                        //emailHtmlBody = strChanged;
                        //em.HtmlBody = strChanged;
                        //em.HtmlBody = str;
                        em.HtmlBody = em.HtmlBody.replace(s1, s3);
                    }                    
                }
                //Jira CRM-5358
                Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
                for (String mskdStr : maskedStrMap.keySet())
                {
                    em.HtmlBody = em.HtmlBody.replace(mskdStr, maskedStrMap.get(mskdStr));
                    htmlBodyHasasCardInfo = true;
                }
               // hasCardInfo = c.HasCreditCard__c;

            } 
           // em.TextBody = emailTextBody;
          ////  em.HtmlBody = emailHtmlBody;
        } 
        
        }
               
    }
}