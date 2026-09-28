/* Created By : Ajay Bharathan | TCS | Cloud Developer */
public with sharing class QAC_LogoutController {

	@AuraEnabled
    public static String getSignOutURL()
    {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        list<Case> existingCases = QAC_CaseQueueAssignment.getUserCases();
        system.debug('cases owned by user'+existingCases);
        
        if (!Cache.Org.contains('output')) {
			Cache.Org.put('output', 'yes');
        }
        
        if(existingCases.isEmpty()){
            // no cases owned by the user
            return baseUrl;
        }
        return null;
    }
}