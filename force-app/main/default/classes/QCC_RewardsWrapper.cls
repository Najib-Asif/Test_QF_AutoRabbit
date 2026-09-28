public class QCC_RewardsWrapper {
    public class BonusRewards {
		@AuraEnabled public List<String> rewardOptions;
		@AuraEnabled public Integer activeOfferCount;
		@AuraEnabled public String expiryDate;
		@AuraEnabled public String offer;
		@AuraEnabled public List<String> rewards;
		@AuraEnabled public String voucherCode;
		@AuraEnabled public String selectedReward;
		@AuraEnabled public String selectedDate;
	}

	@AuraEnabled public List<BonusRewards> bonusRewards;

	public class PromoRewards {
		@AuraEnabled public String promoCode;
		@AuraEnabled public String promoType;
		@AuraEnabled public String promoExpiryDate;
	}
	
	public static QCC_RewardsWrapper parse(String json) {
		return (QCC_RewardsWrapper) System.JSON.deserialize(json, QCC_RewardsWrapper.class);
	}
}