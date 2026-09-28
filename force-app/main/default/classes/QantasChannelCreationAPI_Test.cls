/*
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Purpose : API Class for receiving JSON from Channel Creation microservices
 * Related Class : QantasChannelCreation
 * Main Class : QantasChannelCreationAPI
*/
@IsTest
public class QantasChannelCreationAPI_Test {
	
    @isTest
	public static list<QantasChannelCreationAPI> testParse() {
		String json = '['+
		'	{'+
		'		\"gdsCode\" : \"Amadeus\",'+
		'		\"assetId\" : \"02ip0000000qGFG\",'+
		'		\"customerId\" : \"12345\",'+
		'		\"registrationType\" : \"independent\",'+
		'		\"registeredBy\" : \"0239206\"'+
		'	},'+
		'	{'+
		'		\"gdsCode\" : \"Sabre\",'+
		'		\"assetId\" : \"02ip0000000qGFG\",'+
		'		\"customerId\" : \"78901\",'+
		'		\"registrationType\" : \"independent\",'+
		'		\"registeredBy\" : \"0239206\"'+
		'	}'+
		']';
        
		List<QantasChannelCreationAPI> obj = QantasChannelCreationAPI.parse(json);
		System.assert(obj != null);
        return obj;
	}
}