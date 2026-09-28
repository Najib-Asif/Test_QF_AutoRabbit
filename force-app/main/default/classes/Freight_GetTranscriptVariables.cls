/*
 *********************************************************************************
 * History:
 * Version     Author           Date            Description
 * 2.0         Sruthi Anil     04-06-2026      CRM 12989 -Code Security Remediation
 *********************************************************************************
 */

public with sharing class Freight_GetTranscriptVariables {

  public class TranscriptInput {
    @InvocableVariable(required=true)
    public ID routableID;
  }
  
  public class VisitorNameOutput {
    @InvocableVariable(required=true)
    public String sFirstName;
  }

  @InvocableMethod(label='Get User Name')
  public static List<VisitorNameOutput> getUserName(List<TranscriptInput> transcripts) {
      
      

    List<VisitorNameOutput> names = new List<VisitorNameOutput>();
    try{
        for (TranscriptInput transcript : transcripts) {
        System.debug('Inside getChatTopic'+transcript.routableID);
          // Query for the transcript record based on the ID
          LiveChatTranscript transcriptRecord = [SELECT Name, Freight_Chat_Topic__c
                                                FROM LiveChatTranscript 
                                                WHERE Id = :transcript.routableID with USER_MODE LIMIT 1]; //CRM 12989 - Code Security Remediation
          
          // Store the first name in an output variable
          VisitorNameOutput nameData = new VisitorNameOutput();
          nameData.sFirstName = transcriptRecord.Freight_Chat_Topic__c;
          
          // Add the name to the list of outputs
          names.add(nameData);
    }   
    return names;
    } catch (QueryException ex) { //CRM-12989 added Catch for Code Security Remediation
	
	        Map<String, Set<String>> inaccessibleFields = ex.getInaccessibleFields();
	            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Freight_GetTranscriptVariables', 'Freight_GetTranscriptVariables','getUserName', inaccessibleFields.toString(), String.valueOf(''),false,'', ex);
	          return null;  
            }
  }
}