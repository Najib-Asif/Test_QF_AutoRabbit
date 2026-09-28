/*==============================================================================================================================
Author:         Rinaldo Clucher
Company:        Salesforce
Purpose:        This Class will be used to load files.
. 
Date:           29/03/2021
==============================================================================================================================
History:
29-Mar-2021      RC               First Release.
==============================================================================================================================*/
public with sharing class QCC_LoadFileController {


    /**
    * @author       Rinaldo Clucher
    * @date         29-03-2021 
    * @description  getAllUploadedFiles :  This method will fetch all Content doc related to Case record
    * @param        String caseRecordId - Case Record Id
    * @return       List<ContentDocument> - List of Content doc, which will be displayed in Component (File Component)
    */
	@AuraEnabled
	public static List<ContentDocument> getAllUploadedFiles(String caseRecordId){
		Set<Id> recordIds = new Set<Id> {caseRecordId};
		List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds ];
		Set<Id> documentIds = new Set<Id>();
		for(ContentDocumentLink cdl:cdlList) {
			documentIds.add(cdl.ContentDocumentId);
		}
		return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN : documentIds];
	}

        /**
    * @author       Rinaldo Clucher
    * @date         29-03-2021 
    * @description  createCaseCommentRecord :  This method will create Case Comments for Case Record for specific File Name
    * @param        String caseRecordId - Case Record Id
    * @param        String fileNames - File Names attached to Case
    * @return       CaseResponseWrapper - This a wrapper Object
    */
	@AuraEnabled
	public static CaseResponseWrapper createCaseCommentRecord(String caseRecordId,String fileNames){
		List<String> errorMessageList = new List<String>();
		try {
			CaseComment initialCaseComment = new CaseComment();
			initialCaseComment.CommentBody = fileNames + ' uploaded by ' + UserInfo.getName();
			initialCaseComment.IsPublished = true;
			initialCaseComment.ParentId = caseRecordId;
			insert initialCaseComment;
		}catch (System.DmlException dml) {
			for (Integer i=0; i < dml.getNumDml(); i++) {errorMessageList.add(dml.getDmlMessage(i));}
		} catch (Exception e) {errorMessageList.add(e.getMessage());}
		CaseResponseWrapper caseResponseWrapper =new CaseResponseWrapper(caseRecordId,errorMessageList,null);
		return caseResponseWrapper;
	}

    /***
	 * Wrapper for Response, which will be used to containt the record Id of casex
	 * and Error message in case if any exist.
	 */
	public class CaseResponseWrapper {
		@AuraEnabled
		public String recordId;
		@AuraEnabled
		public String caseNumber;
		@AuraEnabled
		public List<String> errorMessageList;

		public CaseResponseWrapper(String recordId,List<String> errorMessageList,String caseNumber){
			this.recordId=recordId;
			if(caseNumber!=null) {
				this.caseNumber=caseNumber;
			}
			this.errorMessageList=errorMessageList;
		}
	}


}