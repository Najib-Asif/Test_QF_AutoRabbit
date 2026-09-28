/*********************************************************************************
Name         : QCC_CustomerHistorySearchController
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 August 2019
Usages       : This class is used as the backend controller for the qCC_CustomerHistorySearch component
*********************************************************************************/
public with sharing class QCC_CustomerHistorySearchController {
    //@Purpose: This method is used to generate the wrapper record for the initial search once the user press enter.
    //@input parameters:
    //	1. searchKey - The text inputted by the user in the search field in front end.
    //	2. recordId - The contact record id in the record page.
    //@return type: Wrapper list that will be generated as data table in front end
    @AuraEnabled(cacheable=true)
    public static List<DataTableWrapper> generateCustomerHistoryTables(String searchKey, String recordId) {
        List<DataTableWrapper> wrapperList = new List<DataTableWrapper>();
        try {
            Integer pageNumber = 1;

            List<QCC_SearchRecord__mdt> metadataRecords = [
                SELECT MasterLabel, DeveloperName, Columns__c, Icon__c, Priority__c, Returning_Clause__c, Object_Name__c, Initial_Page_Limit__c, Load_More_Page_Limit__c
                FROM QCC_SearchRecord__mdt WHERE Active__c = true ORDER BY Priority__c
            ];

            SearchRecordWrapper searchWrapper = new SearchRecordWrapper();
            if (!String.isBlank(searchKey)) {
                searchWrapper = getAllSearchRecords(metadataRecords, pageNumber, recordId, searchKey);
            }
            wrapperList = generateDataTables(metadataRecords, searchWrapper, pageNumber);
        } catch(Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Customer History Search', 'QCC_CustomerHistorySearchController', 'generateCustomerHistoryTables', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }

        return wrapperList;
    }
    
    //@Purpose: This method is used to get a new batch of records once load more has been triggered in each data table.
    //@input parameters:
    //	1. searchKey - The text inputted by the user in the search field in front end.
    //	2. recordId - The contact record id in the record page.
    //	3. pageNumber - The page number that will determine the offset of the SOSL.
    //	4. tableName - The table name which the load more has been triggered.
    //@return type: List of records for a specific object that match the searchKey
    @AuraEnabled(cacheable=true)
    public static List<sObject> generateCustomerHistoryPerPage(String searchKey, String recordId, Integer pageNumber, String tableName) {
        List<sObject> resultList = new List<sObject>();

        try {
            List<QCC_SearchRecord__mdt> metadataRecords = [
                SELECT MasterLabel, DeveloperName, Columns__c, Icon__c, Priority__c, Returning_Clause__c, Object_Name__c, Initial_Page_Limit__c, Load_More_Page_Limit__c
                FROM QCC_SearchRecord__mdt WHERE Active__c = true AND DeveloperName =: tableName
            ];

            if (!metadataRecords.isEmpty()){
                SearchRecordWrapper searchResultWrapper = getAllSearchRecords(metadataRecords, pageNumber, recordId, searchKey);
                List<List<sObject>> currentRecords = searchResultWrapper.currentRecords;
                List<List<sObject>> allRecords = searchResultWrapper.allRecords;
                for(List<sObject> currentObjectRecord : currentRecords) {
                    resultList = currentObjectRecord;
                }

                for(List<sObject> allRecord : allRecords) {
                    System.debug('allRecord: ' + allRecord.size());
                }
            }
        } catch(Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Customer History Search', 'QCC_CustomerHistorySearchController', 'generateCustomerHistoryTables', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }

        return resultList;
    }
    
    //@Purpose: This method is used to generate the SOSL query that will determine the records for each data table.
    //@input parameters:
    //	1. metadataRecords - The metadata record that is currently active.
    //	2. pageNumber - The page number that will determine the offset of the SOSL.
    //	3. recordId - The contact record id in the record page.
    //	4. searchKey - The text inputted by the user in the search field in front end.
    //@return type: Wrapper that holds the current batch of records and the total record count.
    public static SearchRecordWrapper getAllSearchRecords(List<QCC_SearchRecord__mdt> metadataRecords, Integer pageNumber, String recordId, String searchKey) {
        //Escape single quote from the front end variables
        recordId = String.escapeSingleQuotes(recordId);
        searchKey = String.escapeSingleQuotes(searchKey);

        SearchRecordWrapper wrapper = new SearchRecordWrapper();
        List<List<sObject>> objectRecords = new List<List<sObject>>();

        //Get all ContentDocument Ids from ContentDocumentLink
        List<ContentDocumentLink> contentDocumentLinkRecords = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        List<Id> contentDocumentIds = new List<Id>();
        for(ContentDocumentLink contentDocumentLinkRecord : contentDocumentLinkRecords) {
            contentDocumentIds.add(contentDocumentLinkRecord.ContentDocumentId);
        }

        //Get all EmailMessage Ids from EmailMessageRelation
        List<EmailMessageRelation> emailMessageRelationRecords = [SELECT Id, EmailMessageId FROM EmailMessageRelation WHERE RelationId =: recordId];
        List<Id> emailMessageIds = new List<Id>();
        for(EmailMessageRelation emailMessageRelationRecord : emailMessageRelationRecords) {
            emailMessageIds.add(emailMessageRelationRecord.EmailMessageId);
        }

        //Generate the string query for SOSL
        String returningClauseForCurrentRecords = 'RETURNING ';
        String returningClauseForAllRecords = 'RETURNING ';
        for(QCC_SearchRecord__mdt metadataRecord : metadataRecords){
            //Generate the pageLimit, initialOffset and pageOffset used to limit the record display
            Integer pageLimit = pageNumber == 1 ? Integer.valueOf(metadataRecord.Initial_Page_Limit__c) : Integer.valueOf(metadataRecord.Load_More_Page_Limit__c);
            Integer initialOffset = pageNumber == 1 ? 0 : Integer.valueOf(metadataRecord.Initial_Page_Limit__c);
            Integer pageOffset = pageNumber == 1 ? 0 : ((pageNumber - 2) * pageLimit) + initialOffset;

            //Concatenate the records from metadata to generate the string SOSL query
            returningClauseForCurrentRecords = returningClauseForCurrentRecords + metadataRecord.Object_Name__c + metadataRecord.Returning_Clause__c + ',';

            //Substitute the value
            returningClauseForCurrentRecords = returningClauseForCurrentRecords.replace(':pageLimit', String.valueOf(pageLimit));
            returningClauseForCurrentRecords = returningClauseForCurrentRecords.replace(':pageOffset', String.valueOf(pageOffset));
            returningClauseForCurrentRecords = returningClauseForCurrentRecords.replace(': recordId', '\'' + recordId + '\'');

            //Generate the string SOSL query to get the record count
            returningClauseForAllRecords = returningClauseForAllRecords + metadataRecord.Object_Name__c + metadataRecord.Returning_Clause__c + ',';
            returningClauseForAllRecords = returningClauseForAllRecords.replace(': recordId', '\'' + recordId + '\'');
            returningClauseForAllRecords = returningClauseForAllRecords.remove(' LIMIT :pageLimit OFFSET :pageOffset');
        }

        //Remove the last comma instead of including an if condition on above code
        returningClauseForCurrentRecords = returningClauseForCurrentRecords.removeEnd(',');
        returningClauseForAllRecords = returningClauseForAllRecords.removeEnd(',');

        //Finalize the string SOSL query
        searchKey = '\'*' + searchKey + '*\'';
        String searchQueryForCurrentRecords = 'FIND ' + searchKey + ' IN ALL FIELDS ' + returningClauseForCurrentRecords;
        String searchQueryForAllRecords = 'FIND ' + searchKey + ' IN ALL FIELDS ' + returningClauseForAllRecords;

        System.debug('searchQueryForCurrentRecords: ' + searchQueryForCurrentRecords);
        System.debug('searchQueryForAllRecords: ' + searchQueryForAllRecords);

        //Execute the string SOSL qury
        wrapper.currentRecords = System.search.query(searchQueryForCurrentRecords);
        wrapper.allRecords = System.search.query(searchQueryForAllRecords);

        return wrapper;
    }

    public class SearchRecordWrapper{
        @AuraEnabled public List<List<sObject>> currentRecords {get;set;}
        @AuraEnabled public List<List<sObject>> allRecords {get;set;}
    }

    //@Purpose: This method is used to generate the wrapper record for each metadata record.
    //@input parameters:
    //	1. metadataRecords - The metadata record that is currently active.
    //	2. searchWrapper - The wrapper that holds the current batch of records and the total record count.
    //	3. pageNumber - The page number that will determine the offset of the SOSL.
    //@return type: Wrapper list that will be generated as data table in front end
    public static List<DataTableWrapper> generateDataTables(List<QCC_SearchRecord__mdt> metadataRecords, SearchRecordWrapper searchWrapper, Integer pageNumber) {
        List<DataTableWrapper> wrapperList = new List<DataTableWrapper>();
        Integer wrapperIndex = 0;

        //Generate the wrapper list to generate the datatable later in front end
        for(QCC_SearchRecord__mdt metadataRecord : metadataRecords) {
            DataTableWrapper wrapperItem = new DataTableWrapper();
            List<ColumnWrapper> columnList = new List<ColumnWrapper>();
            List<TypeAttributeWrapper> typeAttributeList = new List<TypeAttributeWrapper>();
            Integer stringIndex = 0;

            //Split the value in Columns__c field in the metadata to generate the columns for the datatable
            for(String fieldStrings : metadataRecord.Columns__c.split('~')){
                ColumnWrapper columnItem = new ColumnWrapper();
                TypeAttributeWrapper typeAttribute = new TypeAttributeWrapper();
                for(String fieldString:fieldStrings.split(',')){
                    switch on stringIndex++ {
                        when  0{
                            columnItem.label = fieldString;
                        }
                        when  1{
                            columnItem.fieldName = fieldString;
                        }
                        when  2{
                            columnItem.type = fieldString;
                        }
                        when  3{
                            if (columnItem.type == 'url') {
                                typeAttribute.fieldName = fieldString;
                            }
                        }
                        when  4{
                            if (columnItem.type == 'url') {
                                typeAttribute.urlFieldNameSource = fieldString;
                            }
                        }
                        when  5{
                            if (columnItem.type == 'url') {
                                typeAttribute.fieldNameSource = fieldString;
                            }
                        }
                    }
                    if (columnItem.type == 'url') {
                        typeAttribute.urlFieldName = columnItem.fieldName;
                    	columnItem.typeAttributes = typeAttribute;
                    }
                }
                stringIndex = 0;
                columnList.add(columnItem);
                if (columnItem.type == 'url') {
                    typeAttributeList.add(typeAttribute);
                }
            }

            //Prepare the values to generate the datatable
            if (searchWrapper.currentRecords != null) {
                wrapperItem.tableData = searchWrapper.currentRecords[wrapperIndex];
            } else {
                wrapperItem.tableData = new List<sObject>();
            }
            wrapperItem.tableColumns = columnList;
            wrapperItem.tableTypeAttributes = typeAttributeList;
            wrapperItem.pageNumber = pageNumber;
            if (searchWrapper.currentRecords != null) {
                wrapperItem.totalRecordCount = searchWrapper.allRecords[wrapperIndex].size();
                System.debug('searchWrapper.allRecords[wrapperIndex].size(): ' + searchWrapper.allRecords[wrapperIndex].size());
            } else {
                wrapperItem.totalRecordCount = 0;
            }
            wrapperItem.loadMoreStatusMessage = '';
            wrapperItem.tableIcon = metadataRecord.Icon__c;
            wrapperItem.tableName = metadataRecord.MasterLabel;
            wrapperItem.tableId = metadataRecord.Object_Name__c;
            wrapperItem.tableVisibility = wrapperItem.tableData.size() != 0;
            wrapperIndex++;
            System.debug('wrapperItem: ' + wrapperItem);
            wrapperList.add(wrapperItem);
        }
        
        System.debug('wrapperList: ' + wrapperList);
        
        return wrapperList;
    }
    
    public class DataTableWrapper {
        @AuraEnabled public String tableId {get;set;}
        @AuraEnabled public String tableName {get;set;}
        @AuraEnabled public Integer pageNumber {get;set;}
        @AuraEnabled public Integer totalRecordCount {get;set;}
        @AuraEnabled public String loadMoreStatusMessage {get;set;}
        @AuraEnabled public List<SObject> tableData {get;set;}
        @AuraEnabled public List<ColumnWrapper> tableColumns {get;set;}
        @AuraEnabled public List<TypeAttributeWrapper> tableTypeAttributes {get;set;}
        @AuraEnabled public String tableIcon {get;set;}
        @AuraEnabled public Boolean tableVisibility {get;set;}
    }
    
    public class ColumnWrapper{
        @AuraEnabled public String label {get;set;} // Label name of the field
        @AuraEnabled public String fieldName {get;set;}  // API Name of the field
        @AuraEnabled public String type {get;set;}  // Type of the field
        @AuraEnabled public TypeAttributeWrapper typeAttributes {get;set;}
    }
    
    private class TypeAttributeWrapper{
        @AuraEnabled public String urlFieldName {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String urlFieldNameSource {get;set;}
        @AuraEnabled public String fieldNameSource {get;set;}
    }
}