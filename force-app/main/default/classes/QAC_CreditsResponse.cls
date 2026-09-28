/************************************************************************************************************************
 * Description: Test Class for QAC_Credits RestAPI, Created as part of QAC Credits Project
 * Author: Sobhan - TCS
 ************************************************************************************************************************/
global class QAC_CreditsResponse {
global list<balanceResponse> creditResponse {get;set;}
global ExceptionResponse exceptionResponse {get;set;}
    global QACCreditResponse QACCreditResponse{get;set;} 
    global List<LedgerResponse> Statement {get;set;}
    
    public class balanceResponse{
        //Asset Retrieval for balance
        public String message;
        public String recordType;
        public String statusCode;
           
        public String agencyIdentifier;
        public Decimal creditYear;
        public Decimal totalAcquiredCredits;
        public Decimal totalConsumedCredits;
        public Decimal totalOutstandingCredits;
        
        
        // for Credits balance Retrieval from asset
        public balanceResponse(List<Asset> aInfo){
            this.agencyIdentifier = aInfo[0].Agency_Identifier__c;
            this.creditYear = aInfo[0].Asset_Year__c;
            this.totalAcquiredCredits = aInfo[0].Total_Acquired_Credits__c;    
            this.totalConsumedCredits = aInfo[0].Total_Consumed_Credits__c;  
            this.totalOutstandingCredits = aInfo[0].Total_Outstanding_Credits__c;
        }
    }
    
    public class LedgerResponse{
        public String caseNumber;
        public String subType1;
        public String transactionType;
        public String transactionFrequency;
        public Date   transactionDate;
        public String reason;
        public Decimal creditValue;
        
        public LedgerResponse(String caseNumber, String subType1, String transactionType, String transactionFrequency,Date transactionDate,String reason,decimal creditValue){
        
            this.caseNumber = caseNumber;
            this.subType1 = subType1;
            this.transactionType = transactionType;
            this.transactionFrequency=transactionFrequency;
            this.transactionDate=transactionDate;
            this.reason=reason;
            this.creditValue=creditValue;
                    
        }
    }
    public class QACCreditResponse{
        public Decimal totalAcquiredCredits;
        public Decimal totalConsumedCredits;
        public Decimal totalOutstandingCredits;
        public String statusCode;
        public List<LedgerResponse> Statement;
        public QACCreditResponse(String statusCode,List<Asset> asstObj, List<Ledger__c> listLedgerObj){
            
            this.statusCode=statusCode;
            
            this.totalAcquiredCredits = asstObj[0].Total_Acquired_Credits__c;    
            this.totalConsumedCredits = asstObj[0].Total_Consumed_Credits__c;  
            this.totalOutstandingCredits = asstObj[0].Total_Outstanding_Credits__c; 
            
            Statement = new List<LedgerResponse>();
            
            if(listLedgerObj!=null){
                for(Ledger__c ledgerObj : listLedgerObj){
                    this.Statement.add(new QAC_CreditsResponse.LedgerResponse(ledgerObj.case__r.CaseNumber,
                                                                               ledgerObj.case__r.Sub_Type_1__c,
                                                                               ledgerObj.Transaction_Type__c,
                                                                               ledgerObj.Transaction_Frequency__c,
                                                                               ledgerObj.Transaction_date__c,
                                                                               ledgerObj.Reason__c,
                                                                               ledgerObj.Total_Credit_value__c));
                }
            }
            
        }
        
    }
    
    public class ExceptionResponse {
        public String message;
        public String errorCode;
        public String sfErrorMessage;
        public String statusCode;
        public list<FieldErrors> fieldErrors;
        public ExceptionResponse(String statusCode, String message, list<FieldErrors> fieldErrors){
            this.statusCode = statusCode;
            this.message = message;
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
              
}