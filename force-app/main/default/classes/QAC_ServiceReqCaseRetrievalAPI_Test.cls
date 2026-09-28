/* 
 * Created By : Ajay Bharathan | TCS | Cloud Developer 
 * Main Class : QAC_ServiceReqCaseRetrievalAPI
*/
@IsTest
public class QAC_ServiceReqCaseRetrievalAPI_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'\"caseRetrieval\" : {'+
		'\"sfCaseId\":[\"500p0000004m9X6AAI\",\"500p0000003rxMxAAI\"],'+
		'\"sfCaseNumber\":[\"0001423\",\"0001254\"]'+
		'}'+
		'}';
		QAC_ServiceReqCaseRetrievalAPI obj = QAC_ServiceReqCaseRetrievalAPI.parse(json);
		System.assert(obj != null);
	}
}