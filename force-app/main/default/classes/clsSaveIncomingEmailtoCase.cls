global class clsSaveIncomingEmailtoCase implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try{
            Messaging.InboundEmail incEmail = email;
            createCaseFromEmail(incEmail);
        }catch(exception e){
            System.debug(e);
        }
        return null;
    }

    private static  void createCaseFromEmail(Messaging.InboundEmail incEmail){
        try{
            Case emailCase = new Case();
            insert emailCase;
            createEmailMessage(emailCase.Id,incEmail);
        } catch (System.DmlException e){
            System.debug(e);
        }

    }

    private static void createEmailMessage(Id caseId, Messaging.InboundEmail email) {
        try{
            String emailIds;
            EmailMessage incEmail = new EmailMessage();
            incEmail.ParentId = caseId;
            incEmail.Incoming = true;
            incEmail.Subject = email.Subject;
            incEmail.MessageDate = datetime.now();
            incEmail.HtmlBody = email.htmlBody;  
            incEmail.TextBody = email.plainTextBody;
            incEmail.FromName = email.fromName;
            incEmail.FromAddress = email.fromAddress;
            incEmail.headers = parseHeaders(email.headers);
            incEmail.Status = '0'; 
            insert incEmail;
        }catch(Exception e){
            system.debug(e);
        }
    }

    private static string parseHeaders(List<Messaging.InboundEmail.Header> headers) {
        String h = '';
        try{
            for(Messaging.InboundEmail.Header hdr : headers){
                h += hdr.Name +':'+ hdr.Value +'\n';
            }
        }catch(Exception e){
            system.debug(e);
        }
        return h;
    }    
}