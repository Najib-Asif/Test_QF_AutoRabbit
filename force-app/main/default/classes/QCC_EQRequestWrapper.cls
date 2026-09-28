public class QCC_EQRequestWrapper { 
	public InputParameters InputParameters;

	public class InputParameters {
		public P_CC_CLAIM_HEADER P_CC_CLAIM_HEADER;
		public P_CC_CLAIM_LINES P_CC_CLAIM_LINES;
    }

	public class P_CC_CLAIM_LINES {
        public List<P_CC_CLAIM_LINES_ITEM> P_CC_CLAIM_LINES_ITEM;
    }

	public class P_CC_CLAIM_HEADER { //Values in Custom metadata
		public String PREPARED_BY;
		public String ZIP_CODE;
		public String PHONE_EXT;
		public String STATE;
		public String EMAIL;
		public String SITE_NAME;
		public String CITY;
		public String COUNTRY;
		public String UNIQUE_SOURCE_CALL_SEQ;
		public String ADDRESS1;
		public String ADDRESS2;
		public String ADDRESS3;
	}

	public class P_CC_CLAIM_LINES_ITEM { //Recoveries 
		public Integer BRANCH_PARTY_ID; 
		public String ACCOUNT_TYPE;
		public String BANK_ACC_NUM;
		public String LAST_NAME;
		public String FIRST_NAME;
		public String BANK_COUNTRY;
		public String STATUS_MESSAGES;
		public String BANK_ACC_NAME;
		public String AMOUNT;
		public String SWIFT_CODE;
		public String CLAIM_NO;
		public String TAX_ID;
		public String EQCURRENCY;
		public String IBAN;
		public String INVOICE_DESCRIPTION;
		public String GL_ACCOUNT;
		public String GL_COST_CENTRE;
		public String TITLE;
		public String BRANCH_NAME;
		public String BANK_NAME;
		public String BRANCH_NUMBER;
	}
}