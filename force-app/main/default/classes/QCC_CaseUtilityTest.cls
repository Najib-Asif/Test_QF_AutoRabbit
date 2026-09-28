@isTest
public inherited sharing class QCC_CaseUtilityTest {
    public QCC_CaseUtilityTest() {

    }

    @testSetup 
    static void setup() {
    
        QCC_Hotword_Queue_Routing__c QCCHotword = new QCC_Hotword_Queue_Routing__c(     Hot_words__c = 'Usquadriplegic,assistance dog,disability,disabled,dog,media ,Multiple Sclerosis,paraplegic,repatriation,special needs,Terminally ill,wheel chair,wheelchair,deaf,guide dog,blind,bomb,quadraplegicer1', 
                                                                                        Priority__c = 'CCC Critical Queue', 
                                                                                        Queue_Name__c = 'CCC Critical Queue'
                                                                                    );
        insert QCCHotword;


        }


    /*----------------------------------------------------------------------------------------------      
    Method Name:        updateCaseHotwordQueueRouting    
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      

    static testMethod void testIsThereAMetadataHotwordInDescription() {
            
    
        list<String> descriptionTextList = new List<String>();
        list<Boolean> HotwordMachtedResults;
        descriptionTextList.add('I have a Quadraplegic machine');

        Test.startTest();
        System.debug('### Starting Test testIsThereAMetadataHotwordInDescription');
        HotwordMachtedResults = QCC_CaseUtility.isThereAHotwordInDescription(descriptionTextList);
        System.debug('### Has IsThereAHotwordInDescription Hotword : ' + HotwordMachtedResults);
        System.debug('### Finished Test testIsThereAMetadataHotwordInDescription');
        System.assert(HotwordMachtedResults[0], true);

        Test.stopTest();
    }

        /*----------------------------------------------------------------------------------------------      
    Method Name:        updateCaseHotwordQueueRouting    
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      

    static testMethod void testIsThereARecordHotwordInDescription() {
            
    
        list<String> descriptionTextList = new List<String>();
        list<Boolean> HotwordMachtedResults;
        descriptionTextList.add('Where my honey nuts at?? \n bomb.');

        Test.startTest();
        System.debug('### Starting Test testIsThereARecordHotwordInDescription');
        HotwordMachtedResults = QCC_CaseUtility.isThereAHotwordInDescription(descriptionTextList);
        System.debug('### Has IsThereAHotwordInDescription Hotword : ' + HotwordMachtedResults);
        System.debug('### Finished Test testIsThereARecordHotwordInDescription');
        System.assert(HotwordMachtedResults[0], true);

        Test.stopTest();
    }
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        testMaskCreditCardAndUATPCardNumbersSeparatedBySpaces  
	Description:        Jira CRM-5358- mask the UATP card numbers on case description and on 
                        email messagebody which are separated By Spaces.
    Parameter:          
    ----------------------------------------------------------------------------------------------*/      

    static testMethod void testMaskCreditCardAndUATPCardNumbersSeparatedBySpaces()
    {        
        list<String> descriptionTextList = new List<String>();
        descriptionTextList.add('4322 5567 8890 9900 test credit card.');
        System.debug('### Starting Test v');
        QCC_CaseUtility.maskCreditCardAndUATPCardNumbersSeparatedBySpaces(descriptionTextList[0]);
    }

}