/***********************************************************************************************************************************

Description: Apex class for retrieving the account information. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Ajay Bharathan       		  Account record retrieval class                                T01
                                    
Created Date    : 16/02/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
public class QAC_AccountRetrievalAPI {

	public AccountRetrieval AccountRetrieval;
    public String source;                      //CIAM

	public class AccountRecords {
		public String agencyCode;
	}

	public class AccountRetrieval {
		public List<AccountRecords> AccountRecords;
	}
	
	public static QAC_AccountRetrievalAPI parse(String json) {
		return (QAC_AccountRetrievalAPI) System.JSON.deserialize(json, QAC_AccountRetrievalAPI.class);
	}
}