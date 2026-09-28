/*

Modified Date   : 11/07/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-3804
Version         : V2.0 - Change channelEffectivedate to channelEffectiveDate on the PCC API
*/


global class QAC_TMCResponse {
    global list<TmcResponse> tmcResponses {get;set;}  
    public class TmcResponse
    {
        // for TMC Retrieval
        public String message;
        public String sfTMCid;
        public String recordType;
        public String statusCode;
        
        // for TMC Retrieval
        public String id;
        public String gdsCode;
        public String pseudoCityCode;
        public Boolean isActive;
        public String agencyProductFare;
        public String name;
        public String accountId;
        public DateTime lastInactiveDate;
        public String qacChannelStatus;
        //public Date channelEffectivedate;
        public Date channelEffectiveDate;
        public DateTime lastModifiedDate;   //CRM-9841
        
        // for TMC Retrieval
        public TmcResponse(Agency_Info__c tmcInfo, String qacChannelStatus){
            this.id = tmcInfo.Id;
            this.recordType = tmcInfo.recordType.Name;
            this.gdsCode = tmcInfo.Code__c;
            this.pseudoCityCode = tmcInfo.pcc__c;    
            this.isActive = tmcInfo.Active__c;  
            this.qacChannelStatus = qacChannelStatus;
            this.channelEffectiveDate=tmcInfo.Channel_Effective_Date__c;
            this.lastModifiedDate = tmcInfo.LastModifiedDate;   //CRM-9841
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
        public ExceptionResponse(String statusCode, String message, String errorcode, String sfErrorMessage){
            this.statusCode = statusCode;
            this.message = message;
            this.errorCode = errorcode;
            this.sfErrorMessage = sfErrorMessage;
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
    public class successResponse{
        public string statuscode;
        public string description;
        public successResponse(string statuscode,string description){
            this.statuscode = statuscode;
            this.description =description;
        }
    }
    public class success
    {
        public string statuscode;
        public string description;
        public string id;
        public string qacChannelStatus;
        public boolean isActive; 
        public String assetId;      //CRM-9841
        
        // for TMC Update
        public String recordType;
        public String pseudoCityCode;
        public String gdsCode;
        
        // TMC Creation Response
        public success(string statuscode,string description,String id,String qacChannelStatus,Boolean isActive){
            this.statuscode = statuscode;
            this.description =description;
            this.id=id;
            this.qacChannelStatus=qacChannelStatus;
            this.isActive = isActive;
        }
        
        public success(string statuscode, Agency_Info__c tmcInfo, String qacChannelStatus)
        {
            this.statuscode = statuscode;
            this.recordType = tmcInfo.RecordType.Name;
            this.id = tmcInfo.id;
            this.qacChannelStatus = qacChannelStatus;
            this.isActive = tmcInfo.Active__c;
            this.gdsCode = tmcInfo.Code__c;
            this.pseudoCityCode = tmcInfo.PCC__c;
        }
    }
}