public class QAC_AgencyPrimaryDetailsResponse {
    
    public String caseNumber    {get;set;}
    public String message       {get;set;}
    public String statusCode    {get;set;}
    
    public QAC_AgencyPrimaryDetailsResponse(String caseNumber, String message, String statusCode){
        this.caseNumber     = caseNumber;
        this.message        = message;
        this.statusCode     = statusCode;
    }

}