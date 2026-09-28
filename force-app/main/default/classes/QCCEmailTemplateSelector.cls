public class QCCEmailTemplateSelector {
    @InvocableMethod(label='Get relevant Email Templates' description='Returns the list of email templates applicable to this case type,group,categor.' category='Case')
    public static List<List<EmailTemplate>> getEmailTemplates(List<Id> caseIds) {
        System.debug('====getEmailTemplates() caseIds====' + caseIds);
        List<List<EmailTemplate>> thelist = new List<List<EmailTemplate>>();
        //query case record - type,group,category
        List<Case> theCase = [SELECT Id, CaseNumber, Type, Group__c, Category__c, RecordType.DeveloperName 
                              	FROM Case WHERE Id IN :caseIds LIMIT 1];
        if(theCase.isEmpty())
        	return thelist;

        //read the metadata maping and determine which templates are applicable to the case based on type and group 
        List<QCC_Email_Template_Folder_Mapping__mdt> mappings = [SELECT Id, Label, DeveloperName, Folder_Id__c, Type__c, Group__c 
               												FROM QCC_Email_Template_Folder_Mapping__mdt
                                                         	WHERE Type__c =: theCase[0].Type AND Group__c =: theCase[0].Group__c];
        System.debug('====getEmailTemplates() mappings====' + mappings.size());
        Set<String> folderIds = new Set<String>();

        //iterate through the retrieved metadata and filter out the list that is applicable to case.category
        //if Case does not have a category, we just need to show all templates applicable to case.type and case.group combination
        for(QCC_Email_Template_Folder_Mapping__mdt mapping : mappings) {
            folderIds.add(mapping.Folder_Id__c);
        }
        System.debug('====getEmailTemplates() folderIds.size====' + folderIds.size());

        if(folderIds.isEmpty())
        	return thelist;
        
        //populate a list of templates to be shown, order alphabetically
        thelist.add([SELECT Id, Name, Body,FolderName, FolderId FROM EmailTemplate 
                     WHERE (FolderId IN: folderIds OR Folder.Name='QCC Common') AND Folder.Type = 'EmailTemplate' 					 
                     ORDER BY Name]);
        System.debug('====getEmailTemplates() thelist====' + thelist);
        
        return thelist;        
    }
    
}