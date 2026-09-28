/*==============================================================================================================================
Author:         Rinaldo Clucher
Company:        Salesforce
Purpose:        Class to bring to gether disparate hotword checking code elements into a single class.
                This class is only a short term solution to enable hotword checking in flow. THe solution should be redeveloped completely
                to provide a service class which can be used by multiple clients including the trigger helper to check for hotword and assign
                a suitable queue. 
Date:           15/03/2021
==============================================================================================================================
History:
15-Mar-2021      RC               First Release.
==============================================================================================================================*/
public inherited sharing class QCC_CaseUtility {

    /*--------------------------------------------------------------------------------------      
    Contructor:        caseHotWords
    Description:       Creates a map of Queues from hotwords held in metadata.          
    --------------------------------------------------------------------------------------*/

    public static void createHotwordMap() {
        if(mapHotWordQueue == Null ){
            mapHotWordQueue = new Map<String, String>();
            for(QCC_HotWord__mdt qccHotWord: [Select DeveloperName, Hot_Word__c, Order__c from QCC_HotWord__mdt order by Order__c]){
                mapHotWordQueue.put(qccHotWord.DeveloperName, qccHotWord.Hot_Word__c);
                String allHotWord = mapHotWordQueue != Null && mapHotWordQueue.containsKey('All')? mapHotWordQueue.get('All')+','+qccHotWord.Hot_Word__c:qccHotWord.Hot_Word__c;
                mapHotWordQueue.put('All', allHotWord);
           }
        }
        system.debug('### Map of Hotwords : '+ mapHotWordQueue);

    }

    public static Map<String, String> mapHotWordQueue;// = new Map<Id, String>(); 

    /*--------------------------------------------------------------------------------------      
    Method Name:        caseHotWords
    Description:        Method to Create a map of Queue to avoid SOQL
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static void caseHotWords(){
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        metaDataHotwordCheck
    Description:        Method checks for hotwords using the metadata repository of Hotwords
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static Boolean metaDataHotwordCheck(String caseDescription){

        Boolean hasHotword = false;

        system.debug('caseDescription############'+ caseDescription);
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(caseDescription);
        String description = ' '+matcher.replaceAll(' ')+' ';

        createHotwordMap();
        for(String hotWordQueue: mapHotWordQueue.keyset()){
            if(hotWordQueue != 'All'){
                List<String> lstHotword = mapHotWordQueue.get(hotWordQueue).split(',');
                for(String hotWord: lstHotword){
                    String spaceHot = ' '+hotWord.trim()+' ';
                    //system.debug('description###########'+description);
                    //system.debug('(spaceHot).replace()###########'+(spaceHot).replace('"',''));
                    if(description.containsIgnoreCase((spaceHot).replace('"',''))){
                        hasHotword = true;
                        break;
                    }
                }
                if(hasHotword) {
                    break;
                }
            }
        }
        return hasHotword;
    }

/*----------------------------------------------------------------------------------------------      
Method Name:        isThereAHotwordInDescription
Description:        Return True if Description contains a hot words
Parameter:          String
----------------------------------------------------------------------------------------------*/ 
@InvocableMethod(label='Check Hotword Present' description='Return true if there is a hotword in the parameter')
public static List <Boolean> isThereAHotwordInDescription(list<String> descriptionList){
    //custom object which contains the hotwords, queuename and priority
    List<QCC_Hotword_Queue_Routing__c> QCCHotwordQueueRoutingList = [select id,Name,Hot_words__c,Priority__c,Queue_Name__c from QCC_Hotword_Queue_Routing__c where RecordType.DeveloperName='Customer_Connect'];

    List<Boolean> hasHotwordList = new List<Boolean>();
    List<String> hotWordList = new List<String>();
    Boolean hasHotword = false;
    
    if(QCCHotwordQueueRoutingList != null){         
        for(QCC_Hotword_Queue_Routing__c QHQ : QCCHotwordQueueRoutingList){
            String hotWord = QHQ.Hot_words__c;
            hotWordList = hotWord.split(',');   
            System.debug('Hotword List : '+hotWordList);
        }                      
    }
        
    //Checking if the case description contains the hotwords
    System.debug('@@@@@@hotWList ' + hotWordList);
    if (descriptionList.size() > 0){

        for(String descriptionItem : descriptionList){
            hasHotword = false;
            for(String hw : hotWordList){
            
                //Logic to find the hot words with a exact match from custom object to case description
                String spaceHot = ' '+hw.trim()+' ';
                String spaceHotword = ' '+hw.trim()+'.';
                String spaceHotword1 = ' '+hw.trim()+',';
                String spaceHotword2 = ' '+hw.trim()+';';
                String spaceHotword3 = ' '+hw.trim()+'?';
                String spaceHotword4 = ' '+hw.trim()+'!';
                String spaceHotword5 = ' '+hw.trim()+'$';
                String spaceHotword6 = ' '+hw.trim()+'(';
                String spaceHotword7 = ' '+hw.trim()+')';
                String spaceHotword8 = ' '+hw.trim()+'&';
                String spaceHotword9 = ' '+hw.trim()+'%';
                String spaceHotword10 = ' '+hw.trim()+'@';
                String spaceHotword11 = ' '+hw.trim()+'*';
    
    
                System.debug('@@@@@@spaceHot ' + spaceHot);
                System.debug('@@@@@@spaceHot ' + spaceHotword);
                Pattern nonAlphanumeric = Pattern.compile('^[a-zA-Z0-9!@#$&()\\-`+,/\"]*$');

                System.debug('@@@@@@Descriptionbefore ' + descriptionItem);    
                if(descriptionItem<>null){ 
                    System.debug('@@@@@@CaseDescriptionMiddle1 ' + descriptionItem);
                    Matcher matcher = nonAlphanumeric.matcher(descriptionItem);
                    System.debug('@@@@@@CaseDescriptionMiddle2 ' + descriptionItem);
                    String descriptionSpaced = ' '+matcher.replaceAll(' ')+' ';
                    System.debug('@@@@@@CaseDescriptionMiddle3 ' + descriptionSpaced);
                    descriptionItem =descriptionSpaced;
                    System.debug('@@@@@@CaseDescriptionMiddle4 ' + descriptionItem);
                }
                System.debug('>>>isThereAHotwordInDescription description: ' + descriptionItem);
                if(!String.isEmpty(descriptionItem)){
                    System.debug('@@@@@@ description is not empty ' + descriptionItem.containsIgnoreCase((spaceHot).replace('"','')));
                    System.debug('@@@@@@ with no quotes ' + descriptionItem.containsIgnoreCase((spaceHot)));
                    if( descriptionItem.containsIgnoreCase(spaceHot) ||
                        descriptionItem.containsIgnoreCase(spaceHotword) ||
                        descriptionItem.containsIgnoreCase(spaceHotword1)||
                        descriptionItem.containsIgnoreCase(spaceHotword2)||
                        descriptionItem.containsIgnoreCase(spaceHotword3)||
                        descriptionItem.containsIgnoreCase(spaceHotword4)||
                        descriptionItem.containsIgnoreCase(spaceHotword5)||
                        descriptionItem.containsIgnoreCase(spaceHotword6)||
                        descriptionItem.containsIgnoreCase(spaceHotword7)||
                        descriptionItem.containsIgnoreCase(spaceHotword8)||
                        descriptionItem.containsIgnoreCase(spaceHotword9)||
                        descriptionItem.containsIgnoreCase(spaceHotword10)||
                        descriptionItem.containsIgnoreCase(spaceHotword11)                        
                    ){
                        System.debug('##### HOT WORD MATCHED IN STRING');
                        hasHotword = true;
                    }
                }
                if(hasHotword)
                    break;
            }             
            if(!hasHotword){
                System.debug('##### NO MATCH with object hotword list, CHECKING FOR MATCHES IN METADATA hotwords');
                hasHotword = metaDataHotwordCheck(descriptionItem);
                System.debug('CHECK FOR MATCHES IN METADATA hotwords RESULT : ' + hasHotword);
            }
            hasHotwordList.add(hasHotword);
        }    
    }
    return hasHotwordList;
}
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        maskCreditCardAndUATPCardNumbersSeparatedBySpaces
    Description:        Jira CRM-5358- mask the UATP card numbers on case description and on 
                        email messagebody which are separated By Spaces.
    Parameter:          String
    --------------------------------------------------------------------------------------*/
    public static Map<String, String> maskCreditCardAndUATPCardNumbersSeparatedBySpaces(String originalDes)
    {
        Map<String, String> mapToReturn = new Map<String, String>();
        String updatedDescription = originalDes;
       	String firstSetChars;
        String firstSetCharsTrimmedVersion;
        String secondSetChars;
        String secondSetCharsTrimmedVersion;                   
        String thirdSetChars;
        String thirdSetCharsTrimmedVersion;
        String lastSetChars;
        String lastSetCharsTrimmedVersion;
        Boolean hasCreditCardInfo = false;
        Boolean hasUATPCardInfo = false;
        List<String> spiltStr = originalDes.split(' ');
        System.debug('spiltStr.size()==========> ' + spiltStr.size());
        for (integer strIndex = 0; strIndex < spiltStr.size(); strIndex++)
        {
            hasCreditCardInfo = false;
            hasUATPCardInfo = false;
            System.debug('strIndex value======> ' + strIndex);
            
            firstSetChars = spiltStr[strIndex];
            firstSetCharsTrimmedVersion = firstSetChars.replace('\n','');
            firstSetCharsTrimmedVersion = firstSetCharsTrimmedVersion.replace('\r','');
            firstSetCharsTrimmedVersion = firstSetCharsTrimmedVersion.trim();
            
            if (strIndex+1 < spiltStr.size())
            {
                secondSetChars = spiltStr[strIndex+1];
                secondSetCharsTrimmedVersion = secondSetChars.replace('\n','');
                secondSetCharsTrimmedVersion = secondSetCharsTrimmedVersion.replace('\r','');
                secondSetCharsTrimmedVersion = secondSetCharsTrimmedVersion.trim();
            }
            if (strIndex+2 < spiltStr.size())
            {
                thirdSetChars = spiltStr[strIndex+2];
                thirdSetCharsTrimmedVersion = thirdSetChars.replace('\n','');
                thirdSetCharsTrimmedVersion = thirdSetCharsTrimmedVersion.replace('\r','');
                thirdSetCharsTrimmedVersion = thirdSetCharsTrimmedVersion.trim();
            }                       
            if (strIndex+3 < spiltStr.size())
            {
                lastSetChars = spiltStr[strIndex+3];
                lastSetCharsTrimmedVersion = lastSetChars.replace('\n','');
                lastSetCharsTrimmedVersion = lastSetCharsTrimmedVersion.replace('\r','');
                lastSetCharsTrimmedVersion = lastSetCharsTrimmedVersion.trim();
            }            
            
            //Valid Credit Card Check, which are separated by Spaces
            if (firstSetCharsTrimmedVersion != null && (firstSetCharsTrimmedVersion.length() == 4) && 
                (firstSetCharsTrimmedVersion.length() == firstSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
                && secondSetCharsTrimmedVersion != null && (secondSetCharsTrimmedVersion.length() == 4) && 
                (secondSetCharsTrimmedVersion.length() == secondSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
                && thirdSetCharsTrimmedVersion != null && (thirdSetCharsTrimmedVersion.length() == 4) && 
                (thirdSetCharsTrimmedVersion.length() == thirdSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
                && lastSetCharsTrimmedVersion != null && (lastSetCharsTrimmedVersion.length() == 4) && 
                (lastSetCharsTrimmedVersion.length() == lastSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
               )
            {
                hasCreditCardInfo = true;
                String credCardNumber = firstSetChars + ' ' +  secondSetChars + ' ' + thirdSetChars +' ' + lastSetChars;
                integer credCardLength =credCardNumber.length();
                String s2 = credCardNumber.substring(2, credCardLength);
                System.debug('ss'+s2);
                String s3 = credCardNumber.replace(s2, '-XXXX-XXXX-XXXX');
                System.debug('ss2'+s3);
                String strChanged = updatedDescription.replace(credCardNumber, s3);
                mapToReturn.put(credCardNumber, s3);
            }
            //Valid UATP Card Check, which are separated by Spaces
            if (firstSetCharsTrimmedVersion != null && (firstSetCharsTrimmedVersion.length() == 4) && 
                (firstSetCharsTrimmedVersion.length() == firstSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
                && secondSetCharsTrimmedVersion != null && (secondSetCharsTrimmedVersion.length() == 5) && 
                (secondSetCharsTrimmedVersion.length() == secondSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())
                && thirdSetCharsTrimmedVersion != null && (thirdSetCharsTrimmedVersion.length() == 6) && 
                (thirdSetCharsTrimmedVersion.length() == thirdSetCharsTrimmedVersion.replaceAll('[^0-9]+', '').length())               
               )
            {
                hasUATPCardInfo = true;
                String credCardNumber = firstSetChars + ' ' +  secondSetChars + ' ' + thirdSetChars;
                integer credCardLength =credCardNumber.length();
                String s2 = credCardNumber.substring(2, credCardLength);
                System.debug('ss'+s2);
                String s3 = credCardNumber.replace(s2, '-XXXX-XXXX-XXXX');
                System.debug('ss2'+s3);
                String strChanged = updatedDescription.replace(credCardNumber, s3);
                mapToReturn.put(credCardNumber, s3);
            }
            //if credit card found, we skipped next 3 set of chars
            strIndex = hasCreditCardInfo ? strIndex + 3 : strIndex;
            //if uatp card found, we skipped next 2 set of chars
            strIndex = hasUATPCardInfo ? strIndex + 2 : strIndex;
        }
        return mapToReturn;
    }
    

}