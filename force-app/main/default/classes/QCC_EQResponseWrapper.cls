public class QCC_EQResponseWrapper {
    public class P_CC_CLAIM_HEADER {
		public String UNIQUE_SOURCE_CALL_SEQ;
		public String EMAIL;
		public Integer PHONE_EXT;
		public Integer PREPARED_BY;
    }
	public P_CC_CLAIM_HEADER P_CC_CLAIM_HEADER;
    public P_CC_CLAIM_LINES P_CC_CLAIM_LINES;
    public OUT_RESULT OUT_RESULT;

	public class P_CC_CLAIM_LINES {
		public List<P_CC_CLAIM_LINES_ITEM> P_CC_CLAIM_LINES_ITEM;
    }

    public class P_CC_CLAIM_LINES_ITEM {
        public String TITLE;
		public String FIRST_NAME;
		public String LAST_NAME;
        public String CLAIM_NO;
        public String STATUS;
        public String ERROR_CODE; //type should be checked
        public String STATUS_MESSAGES;
    }

	public class OUT_RESULT {
        public String CC_BATCH_NAME;
		public String EXCEPTIONTYPE;
		public String ERRORMESSAGE;
    }

    public static QCC_EQResponseWrapper parse(String json) {
		return (QCC_EQResponseWrapper) System.JSON.deserialize(json, QCC_EQResponseWrapper.class);
	}
}