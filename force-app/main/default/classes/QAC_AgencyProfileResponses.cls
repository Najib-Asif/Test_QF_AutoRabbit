/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose : to create responses for My Agency Profile Classes
*/

global class QAC_AgencyProfileResponses {

    global QACAgencySecondaryDetailsResponse qacAgencySecondaryDetailsResponse {get;set;}
    global QACAgencyPrimaryDetailsResponse qacAgencyPrimaryDetailsResponse {get;set;}
    global QACAgencyTARetrievalResponse qacAgencyTARetrievalResponse {get;set;}
    
    global ExceptionResponse exceptionResponse {get;set;}
    
    public class ExceptionResponse {
        public String statusCode;
        public String errorMessage;
        public list<FieldErrors> fieldErrors;
        public ExceptionResponse(String statusCode, String errorMessage, list<FieldErrors> fieldErrors){
            this.statusCode = statusCode;
            this.errorMessage = errorMessage;
            this.fieldErrors = fieldErrors;
        }
    }
    
    public Class FieldErrors{
        public String field;
        public String sfException;
        public FieldErrors(String field, String sfException){
            this.field = field;
            this.sfException = sfException;
        }
    }

    // QAC Agency Secondary Details Response
    public class QACAgencySecondaryDetailsResponse {

        public QAC_AgencySecondaryParsing agencySecondaryDetails;
        public QACAgencySecondaryDetailsResponse(Account theAccount)
        {
            this.agencySecondaryDetails = new QAC_AgencySecondaryParsing(theAccount);
        }
    }
    
    // QAC Primary Agency
    public class QACAgencyPrimaryDetailsResponse {

        // for Agency Primary Details Update
        public QAC_AgencyPrimaryDetailsResponse primaryInfo;
        public QACAgencyPrimaryDetailsResponse(String caseNumber,String message,String statusCode)
        {
            this.primaryInfo = new QAC_AgencyPrimaryDetailsResponse(caseNumber, message, statusCode);
        }
    }

    public class QACAgencyTARetrievalResponse 
    {
        public QAC_TaInfoWrapper taInfo;
        public QACAgencyTARetrievalResponse(Boolean Active,string Id, string QIC, string relAccountName)
        {
            this.taInfo = new QAC_TaInfoWrapper(Active, Id, QIC, relAccountName);
        }
    }
}