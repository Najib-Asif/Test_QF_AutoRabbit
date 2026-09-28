public class QCC_CAPTransactionWrapper {
    public class CAPTransactionRequest{
        public String system_x; //The calling system identifier (mandatory)
        public String firstName;    //max 60 chars, mandatory
        public String middleName;   //max 60 chars, requires firstName if present
        public String surName;  //max 60 chars, mandatory
        public String prefix;   //max 12 chars
        public String salutation;   //max 60 chars
        public String qantasUniqueID;   //max 24 chars, decimal digits only
        public String qantasFFNo;   //max 24 chars, decimal only, will internally left pad with zeros to 10 total digits if less than 10, allowing for the old 7 digit format in queries of the underlying data
        public String birthDate;    //dd/mm/yyyy format
        public String genderCode;   //max 4 chars
        public String addressLine1; //max 50 chars
        public String addressLine2; //max 50 chars
        public String addressLine3; //max 50 chars
        public String addressLine4; //max 50 chars
        public String suburb;   //max 40 chars
        public String postCode; //max 8 chars
        public String state;    //max 8 chars
        public String country;  //max 2 chars, e.g. AU, upper case alphabetic chars and spaces only
        public String countryName;  //max 30 chars, must match A-Z or space or &'(),- or 0-9
        public String phoneCountryCode; //max 4 chars, requires phoneAreaCode & phoneLineNumber also if present, must match 0-9
        public String phoneAreaCode;    //max 5 chars, requires phoneLineNumber & phoneCountryCode also if present, must match 0-9
        public String phoneLineNumber;  //max 25 chars, requires phoneCountryCode & phoneAreaCode also if present, must match 0-9
        public String phoneExtension;   //max 25 chars, requires phoneLineNumber also if present, must match 0-9
        public String emailAddr;    //addr@domain format, max 101 chars
        public String travelDocTypeCode;    //max 4 chars, must match A-Z or 0-9 or space
        public String travelDocId;  //max 16 chars, requires travelDocIssueCountry also if present, must match A-Z or 0-9
        public String travelDocIssueCountry;    //max 4 chars, must match A-Z or 0-9 or space
        public String version;  //1.0 (mandatory)
    }

    public class CAPTransactionResponse{
        public String airlineCustomerValue;
        public Integer otherAirlineSchemeCount;
        public String qantasFFNo;
        public String qfMemberTierClubCode;
        public Integer complaintCount;
        public Integer serviceFailureCount;
        public Integer surpriseDelightCount;
        public Integer mishandledBagCount;
        public Integer flightCancellationCount;
        public Integer flightDelayDomesticCount;
        public Integer flightDelayInternationalCount;
        public Integer flightUpgradeDomesticCount;
        public Integer flightUpgradeInternationalCount;
        public Integer flightDowngradeDomesticCount;
        public Integer flightDowngradeInternationalCount;
        public Integer flightSegmentCount;
        public String qantasUniqueID;
        public String majorityQCI;
        public String majorCorpCountryCode;
        public String majorCorpBCI;
        public String majorCorpACI;
        public String majorCorpOCI;
        public String majorCorpName;
        public String majorCorpAltName;
    }
    
}