public class QCC_CaseRelationshipsController {
    @AuraEnabled
    public static List<CaseRelationshipWrapper> fetchCaseRelationshipsByCaseId(String caseId) {
        List<CaseRelationshipWrapper> listCaseRelationships = new List<CaseRelationshipWrapper>();
        List<Case_Relationships__c> listCase1;
        List<Case_Relationships__c> listCase2;

        listCase1 = [SELECT Case_2__r.Id, Case_2__r.CaseNumber, createdDate, Case_2__r.Contact_Fullname__c,Description__c FROM Case_Relationships__c WHERE Case_1__r.Id =: caseId];
        for(Case_Relationships__c obj : listCase1){
            listCaseRelationships.add(new CaseRelationshipWrapper(obj.Case_2__r.Id, obj.Case_2__r.CaseNumber, obj.Case_2__r.Contact_Fullname__c, obj.createdDate,obj.Description__c));
        }

        listCase2 = [SELECT Case_1__r.Id, Case_1__r.CaseNumber, createdDate, Case_1__r.Contact_Fullname__c,Description__c FROM Case_Relationships__c WHERE Case_2__r.Id =: caseId];
        for(Case_Relationships__c obj : listCase2){
            listCaseRelationships.add(new CaseRelationshipWrapper(obj.Case_1__r.Id, obj.Case_1__r.CaseNumber, obj.Case_1__r.Contact_Fullname__c, obj.createdDate,obj.Description__c));
        }
        return listCaseRelationships;
    }

    public class CaseRelationshipWrapper{
        @AuraEnabled public String caseId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String contactName;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String description;//CRM-8956-Added Decription 

        public CaseRelationshipWrapper(String caseId, String caseNumber, String contactName, Datetime createdDate,String description){
            this.caseId = caseId;
            this.caseNumber = caseNumber;
            this.contactName = contactName;
            this.createdDate = createdDate;
            this.description  = description;
        }
    }
}