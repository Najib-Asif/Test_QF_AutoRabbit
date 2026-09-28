/***********************************************************************************************************************************

Description: Apex class for retrieving the account information and TMC Information. 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Abhijeet P				      Account and TMC  record retrieval class                     T01

Created Date    : 03/05/18 (DD/MM/YYYY)

**********************************************************************************************************************************/

global class QAC_AgencyPrimaryParsing {

    global String agencyTradingName;	
    global String agencyCode;		
    global Boolean active;			
    global String agencyABN;			
    global String agencyChain;		
    global String agencySubChain;	
    global Boolean isManualRequestPending;
    global Id accountId;
    public String agencyLegalName;                             //CIAM
    
    // Changes added- by Ajay for Acc Retrieval using IATA
    //public Boolean hideTmcTa;
    global Boolean hideTa;
    
    public QAC_AgencyPrimaryParsing(Account theAccount){
        agencyTradingName = theAccount.Name;
        agencyCode = theAccount.Qantas_Industry_Centre_ID__c;
        active = theAccount.Active__c;
        agencyABN = theAccount.ABN_Tax_Reference__c;
        agencyChain = theAccount.Agency_Sales_Region__r.Name;
        agencySubChain = theAccount.Agency_Sub_Chain__c;
        isManualRequestPending = theAccount.QAC_Request_Pending__c;
        hideTa = theAccount.Agency_Sales_Region__r.Hide_TMCTA__c;
    }
    // Changes Ended

    public static QAC_AgencyPrimaryParsing parse(String json) {
		return (QAC_AgencyPrimaryParsing) System.JSON.deserialize(json, QAC_AgencyPrimaryParsing.class);
	}
	
}