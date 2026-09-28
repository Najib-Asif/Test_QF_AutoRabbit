public class LoyaltyRequestWrapper {

	public Member member;
	public String partnerIndicator;
	public String validationLevel;
	public String partnerID;
	public String productName;
	public String activityDate;
	public Payment payment;
	public class Payment {
		public String transactionReference;
		public String basePointsSign;
		public Integer numberOfBasePoints;
		public String bonusPointsSign;
		public Integer numberOfBonusPoints;
		public String totalPointsSign;
		public Integer numberOfTotalPoints;
		public String statementText;
	}

	public class Member {
		public String surname;
		public String firstInitial;
		public String externalMemID;
	}

}