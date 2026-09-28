/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose : API Class for receiving JSON from Channel Creation microservices
 * Related Class : QantasChannelCreation
*/
public class QantasChannelCreationAPI {

    // for POST
	public String gdsCode;
	public String customerId;
    public String registrationType;
    public String registeredBy;
    
    // for PATCH
	public String assetId;
    public Boolean qdpTermsAndConditions; //CRM 6829
    
	public static List<QantasChannelCreationAPI> parse(String json) {
		return (List<QantasChannelCreationAPI>) System.JSON.deserialize(json, List<QantasChannelCreationAPI>.class);
	}
    
}