public class QAC_ServiceReqCaseRetrievalAPI {

	public class CaseRetrieval {
		public List<String> sfCaseId;
		public List<String> sfCaseNumber;
	}

	public CaseRetrieval caseRetrieval;

	public static QAC_ServiceReqCaseRetrievalAPI parse(String json) {
		return (QAC_ServiceReqCaseRetrievalAPI) System.JSON.deserialize(json, QAC_ServiceReqCaseRetrievalAPI.class);
	}
}