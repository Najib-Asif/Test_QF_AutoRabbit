@isTest
public class testEmailHandlerdummy {
   public static testMethod void testEmailHandler () {
        //set up                
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.Subject = '______________________';
        email.plainTextBody = null;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        myHandler mailer = new myHandler(); 
                
        //run test
        Test.startTest();
            mailer.handleInboundEmail(email, envelope);
        Test.stopTest();
    }   
}