/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Bharathan
Company:       TCS
Description:   RestAPI JSON Parsing Class converted from Received JSON from Digital team into Salesforce
Test Class:    QAC_AccountServicesAPI_Test     
*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design

Modified Date   : 17/09/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : TS-4805
Version         : V2.0 - Added new field for Tradesite and Contract Group
********************************************************************************************************************************/
public class QAC_AccountServicesAPI {

    public AgencyRegistration agencyRegistration;
    
    public class AgencyRegistration {
        public AccountDetail accountDetail;
    }

    public class TmcDetails {
        public String referenceID;
        public String recordType;
        public String gdsCode;
        public String pseudoCityCode;
    }

    public class TicketingAuthorityDetails {
        public String iataCode;
        public String iataName;
    }

    public class ContactDetails {
        public String referenceID;
        public String salutation;
        public String firstName;
        public String lastName;
        public String preferredName;
        public String jobTitle;
        public String jobFunction;
        public String frequentFlyerNumber;
        public String jobRole;
        public String email;
        public String phone;
        public String mobile;
        public boolean keyContact;
        public String verificationNumber;
        
    }

    public class AccountDetail {
        public String referenceID;
        public String agencyName;
        public String legalName;
        public String agencyChain;
        public String agencySubChain;
        public String primaryAgencyBusiness;
        public String bookingEngineAccess;
        public String iataCode;
        public String tidsCode;
        public String agencyABN;
        public String qbrMembershipNumber;
        public String agencyAddressLine1;
        public String city;
        public String stateCode;
        public String countryCode;
        public String postalCode;
        public String phoneNumber;
        public String faxNumber;
        public String employees;
        public String officeType;
        public String website;
        public String accountEmail;
        //New Changes JIRA:TS-3110
        public String dialCode;
        public String siteRegion;
        //changes ends JIRA:TS-3110
        //New Changes JIRA:TS-3287
        public string atolNumber;
        public string abtaNumber;
        //changes ends JIRA:TS-3287
        //New Changes JIRA:TS-4805
        public boolean tradesiteFlag;
        public String contractGroup;
        //Changes ends JIRA:TS-4805
        public List<ContactDetails> contactDetails;
        public List<TmcDetails> tmcDetails;
        public List<TicketingAuthorityDetails> ticketingAuthorityDetails;
    }

    public static QAC_AccountServicesAPI parse(String json) {
        return (QAC_AccountServicesAPI) System.JSON.deserialize(json, QAC_AccountServicesAPI.class);
    }
}