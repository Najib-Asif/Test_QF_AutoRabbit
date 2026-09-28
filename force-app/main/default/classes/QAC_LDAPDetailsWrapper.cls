/*
 * Created By : Ajay | TCS | Cloud Developer 
 * Purpose : To get the API from LDAP System and merge it with SF
 * Main Class : QAC_SiteAdministrator_Controller
 =====================================================================
*/



public class QAC_LDAPDetailsWrapper 
{
    // LDAP Parameters on response
    public String username;
    public String agencyPasswordLastModifiedTimeStamp;
    public String managerPasswordLastModifiedTimeStamp;
    public Boolean managerAccountExists;
    public String errorCode;
    public String message;
    public String maskedEmailAddress;
    @AuraEnabled public String passwordSetUpLink;
    
    // SF Parameters for LEX 
    @AuraEnabled public Datetime agencyLastUpdated;
    @AuraEnabled public Datetime managerLastUpdated;
    @AuraEnabled public String agencyStatus;
    @AuraEnabled public String sfMessage;

    // SF Parameters for LDAP (Request Json)
    public String agencyCode;
    public String staffIdentifier;
    
    public static String convertToJsonString(QAC_LDAPDetailsWrapper m) {
        return JSON.serializePretty(m,true);
    }
    
    public static QAC_LDAPDetailsWrapper parse(String json) {
        return (QAC_LDAPDetailsWrapper) System.JSON.deserialize(json, QAC_LDAPDetailsWrapper.class);
    }
}