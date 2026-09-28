/*
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Purpose : API Class for validating PNR using Agency Retrieval and its child records
* Main Class : QAC_AgencyRetrieval
*/
public class QAC_AgencyRetrievalAPI {

    public class AgencyRetrieval {
        public String loginIATA;
        public String bookingIATA;
        public String pcc;
    }

    public AgencyRetrieval agencyRetrieval;

    public static QAC_AgencyRetrievalAPI parse(String json) {
        return (QAC_AgencyRetrievalAPI) System.JSON.deserialize(json, QAC_AgencyRetrievalAPI.class);
    }
}