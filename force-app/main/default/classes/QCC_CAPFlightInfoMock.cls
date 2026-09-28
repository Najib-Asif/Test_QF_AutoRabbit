@isTest
public class QCC_CAPFlightInfoMock implements HttpCalloutMock {

    protected list<mockRes> lstRes;
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public static integer i = 0;

    public QCC_CAPFlightInfoMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        lstRes = new List<mockRes>();
        lstRes.add(new mockRes(code, status, body, responseHeaders));
    }

    public QCC_CAPFlightInfoMock(List<MockRes> lstMock) {
        lstRes = lstMock;
    }

    public HTTPResponse respond(HTTPRequest req) {
        MockRes mock = lstRes[QCC_CAPFlightInfoMock.i];
        QCC_CAPFlightInfoMock.i++;

        HttpResponse res = new HttpResponse();
        for (String key : mock.responseHeaders.keySet()) {
            res.setHeader(key, mock.responseHeaders.get(key));
        }
        res.setBody(mock.body);
        res.setStatusCode(mock.code);
        res.setStatus(mock.status);
        return res;
    }

    public class MockRes{
        public Integer code;
        public String status;
        public String body;
        public Map<String, String> responseHeaders;
        public mockRes(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
        }
    }
}