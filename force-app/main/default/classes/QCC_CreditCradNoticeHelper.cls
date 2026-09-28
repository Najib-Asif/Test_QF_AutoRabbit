/*----------------------------------------------------------------------------------------------------------------------
Author:        Bharathkumar
Company:       Tata Consultancy services
Description:   QCC CreditCardNoticeHelper
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
20-July-2018      Bharathkumar               Initial Design
22-November-2019     	Accenture 		Rafael Escuadra			    GRAPHITE-909 Add case recordtypes "Assistance" and "Specific Needs" for CreditcardMasking

-----------------------------------------------------------------------------------------------------------------------*/
public with sharing  class QCC_CreditCradNoticeHelper {

    @AuraEnabled
    public static Boolean hasCreditCard(Id caseId){
        Boolean hasCardInfo;
        Case c = [select id,HasCreditCard__c,type,Description,Origin, recordTypeId from Case where id = :caseId Limit 1];
        Boolean isUpdate = false;
        //Pre-Travel GRAPHITE-909 Mask Credit Card Details for Pre-Travel Email-to-Case
        String caseRecordTypeName = '';
        if(!string.isEmpty(c.recordTypeId)){
            caseRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordTypeId).getName();
        }
        List<string> recordTypesList  =Label.QCC_MaskCardNumberForRecordTypes.split(';');
        //end GRAPHITE-909

        if(c != null){
          if(c.Origin!=null && c.Description != null
             && (( c.Origin!='Auto Email' && (c.type=='Baggage' || c.type=='Insurance Letter' || c.type=='Complaint' || c.type=='Compliment' || c.type=='Further Action Required'|| c.type=='Medical-Patient' || c.type=='Medical-Assistance Provided' || c.type=='On the Spot Recovery' || c.type=='Query' ))
                 || recordTypesList.contains(caseRecordTypeName))){  //GRAPHITE-909 Mask card details if  recordtype is Assistance
              if(c.HasCreditCard__c){
                  return true;
              }
               String str = c.Description;
              str= str.replace('\n',' ');
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
                    if(s.contains('http')) {    //skip the masking logic for urls
                        continue;
                    }
                    s = s.replaceAll('\\D','');
                    Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11}|(?:2131|1800|35*\\d{3})*\\d{15})$');
                    Matcher m = p.matcher(s);
                    System.debug('m.matches():'+m.matches());
                    if(m.matches()){

                        //String mcard1='5555555555554444';
                        integer i =s.length();
                        String s2 = s.substring(2, i);
                        String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                        String strChanged = str.replace(s1, s3);
                        c.Description = strChanged;
                        isUpdate= true;
                        if(isUpdate){
                              c.HasCreditCard__c = true;
                              update c;
                          }
                        return true;

                    }
                }
               // hasCardInfo = c.HasCreditCard__c;

            }
        }
        return false;
    }

    //for masking
    public static void maskCreditCard(List<Case> clist){
        Boolean hasCardInfo;
       // Case c = [select id,HasCreditCard__c,Description,Origin from Case where id = :caseId Limit 1];
        Boolean isUpdate = false;
        List<string> recordTypesList  =Label.QCC_MaskCardNumberForRecordTypes.split(';');
        for(Case c :clist){
            hasCardInfo = false;
        if(c != null){
                //Pre-Travel GRAPHITE-909 Mask Credit Card Details for Pre-Travel Email-to-Case
                String caseRecordTypeName = '';
                if(!string.isEmpty(c.recordTypeId)){
                    caseRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordTypeId).getName();
                }
                //end GRAPHITE-909

                if(c.Origin!=null && c.Description != null
                 	&& (( c.Origin!='Auto Email' && (c.type=='Baggage' || c.type=='Insurance Letter' || c.type=='Complaint' || c.type=='Compliment' || c.type=='Further Action Required'|| c.type=='Medical-Patient' || c.type=='Medical-Assistance Provided' || c.type=='On the Spot Recovery' || c.type=='Query' ))
                  	|| recordTypesList.contains(caseRecordTypeName))){  //GRAPHITE-909 Mask card details if  recordtype is Assistance
               String str = c.Description;
              str= str.replace('\n',' ');
                      if( c.Description.contains('-XXXX-XXXX-XXXX')){
                          hasCardInfo = true;
                      }
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
                    if(s.contains('http')) {    //skip the masking logic for urls
                        continue;
                    }
                    s = s.replaceAll('\\D','');
                    Pattern p=Pattern.compile('^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35*\\d{3})*\\d{11}|(?:2131|1800|35*\\d{3})*\\d{15})$');
                    Matcher m = p.matcher(s);
                    if(m.matches()){
                              hasCardInfo = true;
                        //String mcard1='5555555555554444';
                        integer i =s.length();
                        String s2 = s.substring(2, i);
                        String s3 = s.replace(s2, '-XXXX-XXXX-XXXX');
                        String strChanged = str.replace(s1, s3);
                        c.Description = strChanged;
                        isUpdate= true;
                        if(isUpdate){
                              c.HasCreditCard__c = true;
                          }
                    }
                }
                //Jira CRM-5358 Mask Credit Card number with spaces
                Map<String, String> maskedStrMap = QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(str);
                String originalDes = c.Description;
                for (String mskdStr : maskedStrMap.keySet())
                {
                    originalDes = originalDes.replace(mskdStr, maskedStrMap.get(mskdStr));
                    hasCardInfo = true;
                }
                c.Description = hasCardInfo ? originalDes : c.Description;
               // hasCardInfo = c.HasCreditCard__c;

            }
        }
            c.HasCreditCard__c = hasCardInfo;
        }
               
    }
}