global class QAC_TAInsertionResponse 
{
    
    
    global list<TaResponse> ticketingAuthorityResponses {get;set;}
    global List<ExceptionResponse> exceptionResponses {get;set;}
    
    public class TaResponse
    {
        public String primaryIATA;
        public String relatedIATA;
        public String relationship;
        
        public TaResponse(String primaryIATA, String relatedIATA, String relationship)
        {
            this.primaryIATA 				= primaryIATA;
            this.relatedIATA 				= relatedIATA;  
            //this.relationship 				= relationship;
        }
    }
    
    public class ExceptionResponse 
    {
        public String message;
        public String errorCode;
        public String ErrorMessage;
        public String statusCode;
        public ExceptionResponse(String statusCode, String message, String errorcode, String ErrorMessage)
        {
            this.statusCode = statusCode;
            this.message = message;
            this.errorCode = errorcode;
            this.ErrorMessage = ErrorMessage;
        }
    }
    
    

}