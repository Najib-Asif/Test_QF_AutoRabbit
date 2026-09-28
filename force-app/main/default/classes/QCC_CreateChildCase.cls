/*----------------------------------------------------------------------------------------------------------------------
Author:        Gandla Mallikarjuna
Company:       TCS
Description:   Jira:CRM-8706 Moved segregateEmailMsgBodyAndFooter method from CaseTriggerHelper
Test Class:
--------------------------------------------------------------------------------------------------------------------*/

public class QCC_CreateChildCase {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        segregateEmailMsgBodyAndFooter   
    Description:        it will seperate the email body and footer msg from email message. Jira: CRM-4843
    Parameter:          String emailMsg
    ----------------------------------------------------------------------------------------------*/
    @InvocableMethod(label='Segregate Email Message Body And Footer' description='')
    public static List<String> segregateEmailMsgBodyAndFooter(List<String> emailMsgs)
    {
        String emailMsg = emailMsgs[0];
        List<String> response = new List<String>();
        System.debug('emailMsg========> ' + emailMsg);
        
        //CRM-7348 101 SOQL limit Fix
        List<QCC_Email_Thread_Domain__mdt> emailThreadDomains = QCC_Email_Thread_Domain__mdt.getAll().Values();
        
        for (QCC_Email_Thread_Domain__mdt emailThreadDomain: emailThreadDomains)
        {
            if (emailMsg.stripHtmlTags().indexOf(emailThreadDomain.Mail_Thread_Starting_String__c) != -1)
            {
                emailMsg = emailMsg.substring(0, emailMsg.stripHtmlTags().indexOf(emailThreadDomain.Mail_Thread_Starting_String__c));
                break;
            }
        }
        if (String.isBlank(emailMsg))
        {
            emailMsg = System.Label.QCC_Case_Des_For_Empty_Email_Msg_Body;
        }
        response.add(emailMsg);
        System.debug('segregateEmailMsgBodyAndFooter response===========> ' + response);
        return response;
    }
}