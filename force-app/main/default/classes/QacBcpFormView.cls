public without sharing class QacBcpFormView {
    @AuraEnabled(cacheable=true)
    public static Object getJsonData(Id recordId){
        Map<String, Object> returnData = new Map<String, Object>();
        List<ContentDocumentLink> records = [select id, ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData from ContentDocumentLink 
                                                where LinkedEntityId =:recordId and ContentDocument.LatestPublishedVersion.PathOnClient = 'QacRequestFile.snote' 
                                                WITH SYSTEM_MODE order by ContentDocument.CreatedDate desc limit 1];

        if (records.size() > 0) {
            returnData.put('fileData', records[0].ContentDocument.LatestPublishedVersion.VersionData.toString().unescapeXml());
            returnData.put('fileName', records[0].ContentDocument.Title);
            return returnData;
        }
        
        records = [select id, ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData from ContentDocumentLink 
                        where LinkedEntityId =:recordId and ContentDocument.LatestPublishedVersion.PathOnClient = 'QacBackupFile.snote' 
                        WITH SYSTEM_MODE order by ContentDocument.CreatedDate desc limit 1];

        if (records.size() > 0) {
            returnData.put('fileData', records[0].ContentDocument.LatestPublishedVersion.VersionData.toString().unescapeXml());
            returnData.put('fileName', records[0].ContentDocument.Title);
        }
        return returnData;
    }
}