/* 
* Created By : Ajay | TCS | Cloud Developer 
* Purpose : to convert the request JSON into APEX
* Test Class : QAC_AgencySecondaryParsing_Test
* Main Class : QAC_AgencySecondaryDetailsUpdate

Modified Date   : 23/08/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4725
Version         : V2.0 - Added new field "Maintenance Date"
*/

public class QAC_AgencySecondaryParsing 
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
    public String agencyWebSite;
    public string dialCode;
    public string phoneCountryCode;
    public Boolean tradesite;
	public Date maintenanceDate; //New Change JIRA:TS-4725 : Add Maintenance Date
    
    public QAC_AgencySecondaryParsing(Account theAccount)
    {
        primaryAgencyBusiness = theAccount.Business_Type__c;
        agencyAddressLine1 = theAccount.BillingStreet;
        city = theAccount.BillingCity;
        stateCode = theAccount.BillingState;
        countryCode = theAccount.BillingCountryCode;
        postalCode = theAccount.BillingPostalCode;
        tradesite = theAccount.Tradesite__c;
        maintenanceDate = theAccount.Maintenance_Date__c; //New Change JIRA:TS-4725 : Add Maintenance Date
		
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
        /*
        if((string.isNotBlank(dialingCode) || string.isNotEmpty(dialingCode)) && (string.isNotBlank(phone) || string.isNotEmpty(phone)))
        phoneNumber = '+' + dialingCode + phone;
        else if(string.isEmpty(dialingCode) && string.isNotEmpty(phone))
        phoneNumber = phone;
        */
        
        if(string.isNotBlank(dialingCode) && string.isNotEmpty(dialingCode))
            dialCode = '+' + dialingCode;
        if(string.isNotBlank(phone) && string.isNotEmpty(phone))
            phoneNumber = phone;

        employees = String.valueOf(theAccount.NumberOfEmployees);
        accountEmail = theAccount.Email__c;
        atasNumber = theAccount.ATAS__c;
        atolNumber = theAccount.ATOL_Number__c;
        abtaNumber = theAccount.ABTA_Number__c;
        agencyWebSite = theAccount.Website;
    }
    
    public static QAC_AgencySecondaryParsing parse(String json){
        return (QAC_AgencySecondaryParsing) System.JSON.deserialize(json, QAC_AgencySecondaryParsing.class);
    }
}