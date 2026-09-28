/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose : to create responses for Qantas Channel Classes
 
  Modified Date   : 10/07/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : CRM-3802
  Version         : V2.0 - If the Asset status is Accepted and the effective date is <= today, 
                    the Channel status returned by the asset retrieval API should be "Active".
                    Otherwise, return the Channel status as it appears in Salesforce.
          
  Modified Date   : 30/09/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4824
  Version         : Include Registration Type
*/

global class QantasChannelResponses {

    global list<QantasChannelCreationResponse> channelCreationResponse {get;set;}
    global QantasChannelRetrievalResponse channelRetrievalResponse {get;set;}
    global list<QantasChannelUpdationResponse> channelUpdationResponse {get;set;}
    
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

    // Qantas Channel Creation Response
    public class QantasChannelCreationResponse{

        public String statusCode;
        public String sfAssetId;
        public String sfAccountId;
        public String agencyCode;
        public String gdsCode;
        public String message;
        
        // Channel Responses for Success
        public QantasChannelCreationResponse(String statusCode, String sfAssetId, String sfAccountId, 
                                             String agencyCode, String gdsCode,String msg){
            this.statusCode = statusCode;
            this.sfAssetId = sfAssetId;
            this.sfAccountId = sfAccountId;
            this.agencyCode = agencyCode;
            this.gdsCode = gdsCode;
            this.message = msg;
        }
    }
    
    // Qantas Channel Creation Response
    public class QantasChannelUpdationResponse{

        public String statusCode;
        public String assetId;
        public String status;
        public String gdsCode;
        public String message;
        
        // Channel Responses for Success
        public QantasChannelUpdationResponse(String statusCode, String assetId, String status, String gdsCode,String msg){
            this.statusCode = statusCode;
            this.assetId = assetId;
            this.status = status;
            this.gdsCode = gdsCode;
            this.message = msg;
        }
    }
    
    // Qantas Channel Retrieval Response
    public class QantasChannelRetrievalResponse {

        public Boolean isMember;
        public list<AssetRetrievalResponse> assetsRetrievedList;
        public QantasChannelRetrievalResponse(Boolean isMember, list<Asset> assetsList)
        {
            this.isMember = isMember;
            assetsRetrievedList = new list<AssetRetrievalResponse>();
            
      if(assetsList != null){
                for(Asset eachAsset : assetsList){
                    this.assetsRetrievedList.add(new QantasChannelResponses.AssetRetrievalResponse(eachAsset));
                }
            }
            else{
                this.assetsRetrievedList = null;
            }
        }
    }

    public class AssetRetrievalResponse {
        public String gdsCode;
        public String customerId;
        public String status;
        public String effectiveDate;
        public String assetId;
    //Changes added by Vinoth for TS-4824
    public String registrationType;
    //Changes ends for TS-4824
        public AssetRetrievalResponse(Asset theAsset){
            this.gdsCode = theAsset.GDS__r.Name;
            this.customerId = theAsset.Customer_ID__c;
            //this.status = theAsset.Status;
            this.assetId = theAsset.Id;
            this.effectiveDate = String.valueOf(theAsset.Channel_Effective_Date__c);
            if(theAsset.Channel_Effective_Date__c <= system.today() && theAsset.Status == 'Accepted'){
                this.status = 'Active';
            }
            else{
                this.status = theAsset.Status;
            }
      //Changes added by Vinoth for TS-4824
      if(string.isblank(theAsset.Registration_Type__c)){
        this.registrationType = '';
      }
      else{
        this.registrationType = theAsset.Registration_Type__c;
      }
            //Changes ends for TS-4824
        }
    }
}