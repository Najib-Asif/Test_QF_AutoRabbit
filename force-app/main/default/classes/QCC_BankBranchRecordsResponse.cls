public class QCC_BankBranchRecordsResponse {
    public P_BANK_BRANCH_RECORDS P_BANK_BRANCH_RECORDS;
    public String P_OUT_RESULT;

    public class P_BANK_BRANCH_RECORDS {
        public List<P_BANK_BRANCH_RECORDS_ITEM> P_BANK_BRANCH_RECORDS_ITEM;
    }

    public class P_BANK_BRANCH_RECORDS_ITEM {
        public String CLAIM_NO;
        public String BANK_COUNTRY;
        public String BANK_NAME;
        public String BANK_BRANCH_NAME;
        public String BRANCH_NUMBER;
        public String EFT_SWIFT_CODE;
        public String BRANCH_ID;
        public String STATUS;
        public String ERROR_CODE;
        public String MESSAGE;
    }

    
    public static QCC_BankBranchRecordsResponse parseJSON(String jsonString) {
        return (QCC_BankBranchRecordsResponse)JSON.deserialize(jsonString, QCC_BankBranchRecordsResponse.class);
    }
    
}

// Example usage:
//String jsonString = '{ "P_BANK_BRANCH_RECORDS": { "P_BANK_BRANCH_RECORDS_ITEM": [ { "CLAIM_NO": "TEST_01", "BANK_COUNTRY": "India", "BANK_NAME": "Citibank NA", "BANK_BRANCH_NAME": "Chennai (600037002)", "BRANCH_NUMBER": "600037002", "EFT_SWIFT_CODE": "CITIINBXIBM", "BRANCH_ID": "26606454", "STATUS": "SUCCESS", "ERROR_CODE": null, "MESSAGE": null }, { "CLAIM_NO": "TEST_02", "BANK_COUNTRY": "India", "BANK_NAME": "State Bk of India", "BANK_BRANCH_NAME": "Delhi (110002012)", "BRANCH_NUMBER": "110002012", "EFT_SWIFT_CODE": "SBININBB521", "BRANCH_ID": "26432916", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_02", "BANK_COUNTRY": "India", "BANK_NAME": "State Bk of India", "BANK_BRANCH_NAME": "Delhi (110002013)", "BRANCH_NUMBER": "110002013", "EFT_SWIFT_CODE": "SBININBB521", "BRANCH_ID": "26432917", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_02", "BANK_COUNTRY": "India", "BANK_NAME": "State Bk of India", "BANK_BRANCH_NAME": "Delhi (110002014)", "BRANCH_NUMBER": "110002014", "EFT_SWIFT_CODE": "SBININBB521", "BRANCH_ID": "26432918", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_02", "BANK_COUNTRY": "India", "BANK_NAME": "State Bk of India", "BANK_BRANCH_NAME": "Delhi (110002016)", "BRANCH_NUMBER": "110002016", "EFT_SWIFT_CODE": "SBININBB521", "BRANCH_ID": "26432919", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_02", "BANK_COUNTRY": "India", "BANK_NAME": "State Bk of India", "BANK_BRANCH_NAME": "Delhi (110002017)", "BRANCH_NUMBER": "110002017", "EFT_SWIFT_CODE": "SBININBB373", "BRANCH_ID": "26432920", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_03", "BANK_COUNTRY": "Australia", "BANK_NAME": "NAB", "BANK_BRANCH_NAME": "Brisbane (084004)", "BRANCH_NUMBER": "084004", "EFT_SWIFT_CODE": "NATAAU3304B", "BRANCH_ID": "26226654", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_03", "BANK_COUNTRY": "Australia", "BANK_NAME": "Maquarie Bank", "BANK_BRANCH_NAME": "Queen Street (084004)", "BRANCH_NUMBER": "084004", "EFT_SWIFT_CODE": null, "BRANCH_ID": "30567804", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_03", "BANK_COUNTRY": "Australia", "BANK_NAME": "NAB", "BANK_BRANCH_NAME": "BRISBANE CITY (084004)", "BRANCH_NUMBER": "084004", "EFT_SWIFT_CODE": "NATAAU3302S", "BRANCH_ID": "30989661", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" }, { "CLAIM_NO": "TEST_03", "BANK_COUNTRY": "Australia", "BANK_NAME": "NATIONAL AUSTRALIA BANK", "BANK_BRANCH_NAME": "Capital Office", "BRANCH_NUMBER": "084004", "EFT_SWIFT_CODE": "NATAAU3303M", "BRANCH_ID": "31017066", "STATUS": "FAIL", "ERROR_CODE": "EC01", "MESSAGE": "Multiple matching records present" } ] }, "P_OUT_RESULT": "COMPLETED" }';
//BankBranchRecords bankBranchRecords = BankBranchRecords.parse(jsonString);
//bankBranchRecords.printData();