@IsTest
public class QAC_AgencyRetrievalAPI_Test {
    
    public static testMethod QAC_AgencyRetrievalAPI testParse() {
        String json = '{  '+
            '    \"agencyRetrieval\":'+
            '    {'+
            '       \"loginIATA\" : \"1010101\",'+
            '       \"bookingIATA\" : \"3000003\",'+
            '       \"pcc\" : \"xyz56\"'+
            '    }'+
            '}';
        QAC_AgencyRetrievalAPI obj = QAC_AgencyRetrievalAPI.parse(json);
        System.assert(obj != null);
        return obj;
    }
}