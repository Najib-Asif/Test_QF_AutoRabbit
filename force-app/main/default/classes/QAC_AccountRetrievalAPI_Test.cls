/***********************************************************************************************************************************

Description: Apex Test class for QAC_AccountRetrievalAPI Class 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Ajay Bharathan                Test class for account retrieval class                      T01
                                    
Created Date    : 16/02/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
@IsTest
public class QAC_AccountRetrievalAPI_Test {
    
    @isTest
    public static QAC_AccountRetrievalAPI testParse() {
        String json = '{'+
        '   \"AccountRetrieval\" :'+
        '   {'+
        '       \"AccountRecords\" : '+
        '       ['+
        '       {'+
        '           \"agencyCode\" : \"4364557\"'+
        '       },'+
        '       {'+
        '           \"agencyCode\" : \"1000000\"'+
        '       },'+
        '       {'+
        '           \"agencyCode\" : \"1114000\"'+
        '       }'+
        '       ]'+
        '   }'+
        '}';
        
        QAC_AccountRetrievalAPI obj = QAC_AccountRetrievalAPI.parse(json);
        System.assert(obj != null);
        return obj;
    }
}