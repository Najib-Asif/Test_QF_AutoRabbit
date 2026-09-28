/*----------------------------------------------------------------------------------------------------------------------
Author:        Gandla Mallikarjuna
Company:       TCS
Description:   CRM-8421: Format the Request Tracker Platform Event Payload to JSON
Test Class:    QantasMObileAppAPIJSONFormatterTest
-----------------------------------------------------------------------------------------------------------------------*/
public class QantasMObileAppAPIJSONFormatter {
    
    
    public class QansMobileAppPayload {
        @InvocableVariable(label='status' required=false)
        public String status;

        @InvocableVariable(label='oldStatus' required=false)
        public String oldStatus;
        
        @InvocableVariable(label='contactId' required=false)
        public String contactId;
        
        @InvocableVariable(label='originalCaseNumber' required=false)
        public String originalCaseNumber;

        @InvocableVariable(label='caseNumber' required=false)
        public String caseNumber;

        
        @InvocableVariable(label='caseType' required=false)
        public String caseType;

        
        @InvocableVariable(label='caseGroup' required=false)
        public String caseGroup;

        
        @InvocableVariable(label='caseCategory' required=false)
        public String caseCategory;

        
        @InvocableVariable(label='caseSubcategory' required=false)
        public String caseSubcategory;

        
        @InvocableVariable(label='caseClassification' required=false)
        public String caseClassification;

        @InvocableVariable(label='caseOrigin' required=false)
        public String caseOrigin;

        @InvocableVariable(label='caseReceiveddDate' required=false)
        public DateTime caseReceiveddDate;
        
        @InvocableVariable(label='isresponseRequired' required=false)
        public String isresponseRequired;
        
        //@InvocableVariable(label='previousStatus' required=true)
        //public String previousStatus;
        
        @InvocableVariable(label='caseRecType' required=false)
        public String caseRecType;

        @InvocableVariable(label='recoveryNumber' required=false)
        public String recoveryNumber;
        
        @InvocableVariable(label='recProcessStatus' required=false)
        public String recProcessStatus;

        @InvocableVariable(label='recType' required=false)
        public String recType;

        @InvocableVariable(label='recCreatedDate' required=false)
        public DateTime recCreatedDate;

        @InvocableVariable(label='methodName' required=true)
        public String methodName;
    }
    

    @InvocableMethod(label='parsePayload' description='Returns the JSON Payload for request tracker platform event' category='Case And Recovery')
    public static List<String> parsePayload(List<QansMobileAppPayload> payloads) {

		List<String> jsonPayloads = new List<String>();        
        try{

            for (QansMobileAppPayload payload: payloads) {
                if (payload.methodName.equals('parseCasePayload')) {
                    jsonPayloads.add(parseCasePayload(payload));
                } else if (payload.methodName.equals('parseRecoveryPayload')) {
                    jsonPayloads.add(parseRecoveryPayload(payload));
                }
            }
            
        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'QantasMObileAppAPIJSONFormatter', 
                'parsePayload', String.valueOf(''), String.valueOf(''), false, '', ex);
            
        }
        return jsonPayloads;
        
    }

    public static String parseCasePayload(QansMobileAppPayload payload) {
        String jsonPayload;
        try{
            CasePayload csPayload = new CasePayload();

            csPayload.status = payload.status;
            csPayload.oldStatus = payload.oldStatus;
            csPayload.originalCaseNumber = payload.originalCaseNumber;
            System.debug('payload.contactId========> ' + payload.contactId);
            csPayload.contactFFNumber = payload.contactId;
            csPayload.caseNumber = payload.caseNumber;
            csPayload.caseOrigin = payload.caseOrigin;
            csPayload.caseReceiveddDate = payload.caseReceiveddDate;
            csPayload.isresponseRequired = payload.isresponseRequired;
            csPayload.caseRecType = payload.caseRecType;
            csPayload.caseType = payload.caseType;
            csPayload.caseGroup = payload.caseGroup;
            csPayload.caseCategory = payload.caseCategory;
            csPayload.caseSubcategory = payload.caseSubcategory;
            csPayload.caseClassification = payload.caseClassification;

            jsonPayload = JSON.serialize(csPayload);
            System.debug('jsonPayload======> ' + jsonPayload);

        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'QantasMObileAppAPIJSONFormatter', 
                'parseCasePayload', String.valueOf(''), String.valueOf(''), false, '', ex);
        }
        return jsonPayload;
    }

    
    public static String parseRecoveryPayload(QansMobileAppPayload payload) {
        String jsonPayload;
        try{
            RecoveryPayload recPayload = new RecoveryPayload();
            recPayload.originalCaseNumber = payload.originalCaseNumber;
            System.debug('payload.contactId=======> ' + payload.contactId);
            recPayload.contactFFNumber = payload.contactId;
            recPayload.isresponseRequired = payload.isresponseRequired;
            recPayload.recoveryNumber = payload.recoveryNumber;
            recPayload.recProcessStatus = payload.recProcessStatus;
            recPayload.recType = payload.recType;
            recPayload.recCreatedDate = payload.recCreatedDate;

            jsonPayload = JSON.serialize(recPayload);
            System.debug('jsonPayload======> ' + jsonPayload);

        } catch(Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC', 'QantasMObileAppAPIJSONFormatter', 
                'parseRecoveryPayload', String.valueOf(''), String.valueOf(''), false, '', ex);

        }
        return jsonPayload;
    }

    public class CasePayload {
        public String status;
        public String oldStatus;
        public String originalCaseNumber;
        public String caseOrigin;
        public String contactFFNumber;
        public String caseNumber;
        public DateTime caseReceiveddDate;
        public String isresponseRequired;
        public String caseRecType;
        public String caseType;
        public String caseGroup;
        public String caseCategory;
        public String caseSubcategory;
        public String caseClassification;
    }

    public class RecoveryPayload {
        public String originalCaseNumber;
        public String contactFFNumber;
        public String isresponseRequired;
        public String recoveryNumber;
        public String recProcessStatus;
        public String recType;
        public DateTime recCreatedDate;

    }

}