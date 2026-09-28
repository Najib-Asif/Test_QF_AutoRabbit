/*
Purpose : Response class for Account Primary & Secondary Retrieval to My Agency Profile
Developed By : 
Yuvraj :        For My Agency profile response
Ajay :          For including channel response for Channel Retrieval
Main Class :    QAC_AcctRetrievalUsingIATA

Modified Date   : 23/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"

Modified Date   : 18/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4810
Version         : V3.0 - Add agencyBrandCode

*/

global class QAC_AgencyAccountRetrieval 
{
    global AgencyPrimaryDetails agencyPrimaryDetails;
    global AgencySecondaryDetails agencySecondaryDetails;
    
    public class AgencyPrimaryDetails 
    {
        public String agencyTradingName;
        public String agencyCode;
        public String agencyABN;
        public String agencyChain;
        public String agencySubChain;
        public Boolean isManualRequestPending;
        public Boolean active;
        public Boolean hideTa;
        //New Changes JIRA:TS-4810
        public String agencyBrandCode;
        //Changes ends JIRA:TS-4810
        public AgencyPrimaryDetails(Account theAccount)
        {
            agencyTradingName = theAccount.Name;
            agencyCode = theAccount.Qantas_Industry_Centre_ID__c;
            agencyABN = theAccount.ABN_Tax_Reference__c;
            agencyChain = theAccount.Agency_Sales_Region__r.Name;
            agencySubChain = theAccount.Agency_Sub_Chain__c;
            isManualRequestPending = theAccount.QAC_Request_Pending__c;
            active = theAccount.Active__c;
            hideTa = theAccount.Agency_Sales_Region__r.Hide_TMCTA__c;
            //New Changes JIRA:TS-4810
            if(theAccount.Agency_Sales_Region__c != null){
                
                if (theAccount.BillingCountryCode == 'AU')
                    agencyBrandCode = theAccount.Agency_Sales_Region__r.Brand_Code__c;
                else
                    agencyBrandCode = theAccount.BillingCountryCode;
            }
            else
                agencyBrandCode = theAccount.BillingCountryCode;
            //Changes ends JIRA:TS-4810
        }
    }
    
    public class AgencySecondaryDetails 
    {
        public String primaryAgencyBusiness;
        public String agencyAddressLine1;
        public String city;
        public String stateCode;
        public String countryCode;
        public String postalCode;
        public String phoneNumber;
        public String employees;
        public String accountEmail;
        public String atasNumber;
        public String abtaNumber;
        public String atolNumber;
        public String agencyWebsite;
        public string dialCode;
        public date maintenanceDate;  //New Change JIRA:TS-4725 : Add Maintenance Date
        
        // included for Channel Retrieval new fields 
        // JIRA: TS - 4223 
        public Boolean tradesite;
        public Boolean channelStatus;
        public Set<String> associatedGdsList;
        
        public AgencySecondaryDetails(Account theAccount, Set<String> gdsValues)
        {
            associatedGdsList = gdsValues;
            channelStatus = theAccount.Channel_Member__c;
            tradesite = theAccount.Tradesite__c;
            String regExp = '[\\-\\+\\.\\^:\\(\\),]';
            String replaceExp = '';
            String dialingCode;
            string phone;
            
            if(string.isNotBlank(theAccount.Phone_Country_Code__c))
            {
                dialingCode = theAccount.Phone_Country_Code__c.replaceall(regExp,replaceExp);
                dialingCode = dialingCode.replace(' ', replaceExp); 
            }
            
            if(string.isNotBlank(theAccount.Phone_Number__c))
            {
                phone = theAccount.Phone_Number__c.replaceall(regExp,replaceExp);
                phone = phone.replace(' ', replaceExp); 
            }
            
            //Uncomment the below code in order to revert
            /**if((string.isNotBlank(dialingCode) || string.isNotEmpty(dialingCode)) && (string.isNotBlank(phone) || string.isNotEmpty(phone)))
{
phoneNumber = '+' + dialingCode + phone;
}
else if(string.isEmpty(dialingCode) && string.isNotEmpty(phone))
{
phoneNumber = phone;
}**/
            
            if(string.isNotBlank(dialingCode) && string.isNotEmpty(dialingCode))
                dialCode = '+' + dialingCode;
            if(string.isNotBlank(phone) && string.isNotEmpty(phone))
                phoneNumber = phone;
            
            primaryAgencyBusiness = theAccount.Business_Type__c;
            agencyAddressLine1 = theAccount.BillingStreet;
            city = theAccount.BillingCity;
            stateCode = theAccount.BillingState;
            countryCode = theAccount.BillingCountryCode;
            postalCode = theAccount.BillingPostalCode;
            employees = String.valueOf(theAccount.NumberOfEmployees);
            accountEmail = theAccount.Email__c;
            atasNumber = theAccount.ATAS__c;
            atolNumber = theAccount.ATOL_Number__c;
            abtaNumber = theAccount.ABTA_Number__c;
            agencyWebSite = theAccount.Website;
            maintenanceDate = theAccount.Maintenance_Date__c; //New Change JIRA:TS-4725 : Add Maintenance Date
            
        }
    }
}