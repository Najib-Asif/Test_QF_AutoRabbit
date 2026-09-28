/*----------------------------------------------------------------------------------------------------------------------
Author:        Van Cabezas
Company:       Accenture
Description:   Wrapper Class used as Apex-defined variable in the Screen Flow QCC Frequent Flyer Profile Details
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
09-Mar-2023      Van Cabezas                   ADT-92 Initial Creation
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_FrequentFlyerProfileDetailsWrapper {
    
    //FF Contact Details
    @InvocableVariable @AuraEnabled public Boolean withContactAPIException = false;
    @InvocableVariable @AuraEnabled public String contactAPIExceptionMsg;
    @InvocableVariable @AuraEnabled public String phoneNumber;
    @InvocableVariable @AuraEnabled public String email;
    @InvocableVariable @AuraEnabled public String suburb;
    @InvocableVariable @AuraEnabled public String state;
    @InvocableVariable @AuraEnabled public String postcode;
    @InvocableVariable @AuraEnabled public String countryName;
    @InvocableVariable @AuraEnabled public String street;
    
    //FF Profile Details
    @InvocableVariable @AuraEnabled public Boolean withProfileAPIException = false;
    @InvocableVariable @AuraEnabled public String profileAPIExceptionMsg;
    @InvocableVariable @AuraEnabled public String ffNumber;
	@InvocableVariable @AuraEnabled public String title;
    @InvocableVariable @AuraEnabled public String firstName;
    @InvocableVariable @AuraEnabled public String lastName;
    @InvocableVariable @AuraEnabled public String preferredName;
    @InvocableVariable @AuraEnabled public String dateOfBirth;
    
    //FF Tier
    @InvocableVariable @AuraEnabled public Boolean withTierAPIException = false;
    @InvocableVariable @AuraEnabled public String tierAPIExceptionMsg;
    @InvocableVariable @AuraEnabled public String qffTier;
    @InvocableVariable @AuraEnabled public String qffTierDisplay; //where is this used
    @InvocableVariable @AuraEnabled public Date tierAnniversaryDate;
    @InvocableVariable @AuraEnabled public String tierAnniversaryDateString;
    @InvocableVariable @AuraEnabled public String lifteTimeTier;//Jira: CRM-8740
    @InvocableVariable @AuraEnabled public String levelDescription;//Jira: CRM-9670
    
	//FF Program  
	@InvocableVariable @AuraEnabled public Boolean withProgramAPIException = false;
    @InvocableVariable @AuraEnabled public String programAPIExceptionMsg;  
    @InvocableVariable @AuraEnabled public Date joinDate;
    @InvocableVariable @AuraEnabled public String joinDateString;
    @InvocableVariable @AuraEnabled public Boolean memberSuspended;
    
    //FF Account
    @InvocableVariable @AuraEnabled public Boolean withAccountAPIException = false;
    @InvocableVariable @AuraEnabled public String accountAPIExceptionMsg;
    @InvocableVariable @AuraEnabled public Integer pointsBalanceInt;
    @InvocableVariable @AuraEnabled public String pointsBalance;
    @InvocableVariable @AuraEnabled public Integer statusLifeTimeInt;
    @InvocableVariable @AuraEnabled public String statusLifeTimeTotal;
    @InvocableVariable @AuraEnabled public Integer statusCreditsTillNextLevelInt;
    @InvocableVariable @AuraEnabled public String statusCreditsTillNextLevel;
    @InvocableVariable @AuraEnabled public Boolean webLoginEnabled;
    
    @InvocableVariable @AuraEnabled public Boolean isChanged;
}