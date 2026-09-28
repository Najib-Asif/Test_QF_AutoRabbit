public class QCC_LoyaltyResponseWrapper {
    public String tierType;
    public String expiryDate; 
    public boolean tierOverridden;
    public String startDate; 
    public String previousTierCode;
    public String tierChangeReason;
    public String effectiveTier;
    public String tierCode;
    public String memberId; 
    public String firstName; 
    public String lastName; 
    public String mailingName; 
    public String salutation; 
    public String title; 
    public String dateOfJoining; 
    public String gender; 
    public String dateOfBirth; 
    public String email; 
    public String emailType; 
    public String countryOfResidency; 
    public String taxResidency; 
    public String membershipStatus; 
    public String preferredAddress; 
    public Integer pointBalance; 
    public Preferences preferences; 
    public StatusCredits statusCredits;
    public Boolean webLoginDisabled; 
    public Company company;
    public List<Programs> programs = new List<Programs>(); 
    Public QantasFrequentFlyerProfile qantasFrequentFlyerProfile;
    Public QantasFrequentFlyerContact qantasFrequentFlyerContact;
    public List<QantasFrequentFlyerTier> qantasFrequentFlyerTiers = new List<QantasFrequentFlyerTier>();
    public QantasFrequentFlyerAccount qantasFrequentFlyerAccount;
    
    public class Company {
        public String name; 
        public String positionInCompany; 
    }
    public class QantasFrequentFlyerAccount {
        public Integer pointBalance;
        public StatusCredits statusCredits;
    }
    
    public class Preferences {}
    public class StatusCredits {
        public String expiryDate; 
        public Integer lifetime; 
        public Integer total; 
        public Integer loyaltyBonus; 
    }
    public class Phones {
        public String countryCode; 
        public String areaCode; 
        public String type_Z; // in json: type
        public String number_Z; // in json: number 
        public Boolean preferred;//New for frequent flyer details
    }  
    public class Addresses {
        public String lineOne; 
        public String lineTwo;
        public String type_Z; // in json: type
        public Boolean preferred;//New for frequent flyer details
    }
    public class Emails {
        public String emailAddress;
        public Boolean preferred;//New for frequent flyer details
    }
    
    public class Programs {
        public String accountStatus;
        public Boolean suspended;
        public String enrolmentDate;
        public String programCode; 
        public String programName;
        public String expiryDate;
        public String ffExpireDate; // New Expiry Date Mapping
    }
    
    public class QantasFrequentFlyerProfile {
        public String memberId; 
        public String firstName; 
        public String lastName;
        public String title;
        public String dateOfBirth;
    }
    public class QantasFrequentFlyerContact {
        public List<Phones> phones;
        public List<Addresses> addresses; 
        public List<Emails> emails ;
    }
    
    public class QantasFrequentFlyerTier {
        public PointsClubTier pointsClubTier;
        public Tier qantasFrequentFlyerTier;
    }
    
    public class Tier {
        public String tierType;
        public String expiryDate; 
        public String previousTierCode;
        public boolean tierOverridden;
        public String tierCode;      
        public String tierChangeReason;
        public String effectiveTier;
        public String tierDescription;
        public String startDate; 
        public String lifetimeTier; //Jira: CRM-8740
        
    }
    
    public class PointsClubTier {
        public String level;
        public String levelDescription; // Jira: CRM-9670
        public String startDate;
    }
}
/* Commented below wrapper Structures as part new member API V2 Changes
public class ProgramDetails {
public String programCode; 
public String programName; 
public String enrollmentDate; 
public String accountStatus; 
public Boolean qcachSendMarketing; 
public String qcashProgramIdentifier; 
public String tierCode; 
public String tierFromDate;
public String tierToDate;
public String ffExpireDate; 
public String tierName; 

}


public class PhoneDetails {
public String type_Z; // in json: type
public String number_Z; // in json: number
public String areaCode; 
public String idd; 
public String status; 
}

public class Addresses {
public String type_Z; // in json: type
public String lineOne; 
public String lineTwo; 
public String suburb;
public String postCode; 
public String state; 
public String countryCode; 
public String status; 
}

public class Tier {
public String name; 
public String code; 
public String expiryDate; 
public String startDate; 
public String effectiveTier;
public String tierType;
public String tierCode;
}  */