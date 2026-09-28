/**
* @File Name : QCC_CurrencyConversionCall.cls
* @Description : Invoked from Flow, calls the currency coversion API
* @Author : Sourabh Singh
* @Last Modified By :
* @Created On : August 19, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
* 1.1  9-Sep-2024 Sourabh Singh Updated code to fix bug CDP2-789
* 1.2  11-Sep-2024 Sourabh Singh Updated code to fix bug CDP2-802
*==============================================================================
* 1.0 | August 19, 2024 |   | Initial Version
**/

public without sharing class QCC_CurrencyConversionCall implements Queueable, Database.AllowsCallouts{
	
   public List<id> recordIds;
   public boolean isTestRun = true;
    public QCC_CurrencyConversionCall(List<Id> recordIds) {
        
        this.recordIds =  recordIds;
		isTestRun = true;//used for code coverage
    }
    public void execute(QueueableContext context) {
         
	if (!this.recordIds.isEmpty()) {
		List<Recovery__c> recList = [SELECT Id, Monetary_Value__c, Value__c, Currency_Conversion_Rate__c,Original_Currency_Acronym__c,Refund_POS_Country__c, Conversion_Date__c, Recovery_System_log__c, Process_Status__c, Automated_Currency_Conversion_Complete__c,Type__c FROM Recovery__c WHERE Id in :this.recordIds];
		List<Recovery__c> recListToUpdate = new List<Recovery__c>();

	if(QCC_Recoveries_Switch__mdt.getInstance('Master').Currency_Conversion_Switch__c && isTestRun)	//currency conversion flag is on
	{
		if(recList.Size() > 0) { // 1084 bug fix
			Date today = System.today();
			Date oneYearAgo = today.addYears(-1);//CDP2-1013 changes
         	String formattedDate = DateTime.now().format('ddMMyy', 'GMT'); 
			//Added for 1084 outer loop
			for(Recovery__c r:recList)
			{
				if(r.Original_Currency_Acronym__c != 'AUD')    
                {
                    if(r.Conversion_Date__c == null || (r.type__c == 'Ticket Refund EFT' && r.Conversion_Date__c >= oneYearAgo ) || r.type__c != 'Ticket Refund EFT'){//CDP2-1013 changes
                    //API callout for Non AUD
                        try{   
							Map<String, String> mapResponse = new Map<String,String>();           
                            //convert equivalent AUD amount to customer's bank currency and store in monetory value field
                            if(r.type__c == 'Ticket Refund EFT')
                            {
                                 mapResponse = QCCCurrencyConversionService.convertCurrency('BSR', r.conversion_date__c.format('ddMMyy', 'GMT'), r.Value__c, 'AUD', r.Original_Currency_Acronym__c);
                            }    
                            else{
                           mapResponse = QCCCurrencyConversionService.convertCurrency('BSR', formattedDate, r.Value__c, 'AUD', r.Original_Currency_Acronym__c);
                            } //1084 rec -> r
                            r.Currency_Conversion_Rate__c = Decimal.valueOf(mapResponse.get('ConversionRate'));
                            if(r.type__c != 'Ticket Refund EFT'){
                                r.Conversion_Date__c  = today;
                            }
                            r.Monetary_Value__c = QCCCurrencyConversionService.roundAmountBasedOnCurrency((r.value__c)*(Decimal.valueOf(mapResponse.get('ConversionRate'))),  r.Original_Currency_Acronym__c);  
                            r.Automated_Currency_Conversion_Complete__c = true;
                        }
						catch(Exception e){
							String responsebody =  '<span style="color: red;">FAIL</span> ' + e.getMessage();
							r.Recovery_System_log__c = r.Recovery_System_log__c == null ? '':r.Recovery_System_log__c ;           
							r.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds(UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (CURRENCY CONVERSION) ' +responsebody + '</li></ul>' + r.Recovery_System_log__c;
							r.Process_Status__c = 'Exception';
						}
					}//Changes for CDP2-1013
					else {
						if(r.type__c == 'Ticket Refund EFT' && r.Conversion_Date__c < oneYearAgo){
							String responseBody = '<span style="color: red;">FAIL</span> '+'Currency conversion failed due to conversion date >12 months ago';
							r.Recovery_System_log__c = r.Recovery_System_log__c == null ? '':r.Recovery_System_log__c ;           
							r.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds(UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (CURRENCY CONVERSION) ' +responsebody + '</li></ul>' + r.Recovery_System_log__c;
							r.Process_Status__c = 'Exception';
							r.Monetary_Value__c = null;
							r.Currency_Conversion_Rate__c = null;	
						}
					}
				}
				else //if AUD
				{
					r.Currency_Conversion_Rate__c = 1;
					r.Monetary_Value__c = r.Value__c;
					r.Conversion_Date__c  = today;
					r.Automated_Currency_Conversion_Complete__c = true;
				}
				recListToUpdate.add(r); //1084
			} 
			
			try{
				if(recListToUpdate.Size() > 0){
					update recListToUpdate;
				}
			}catch(Exception e){ 
                System.debug(e.getMessage());
				String responsebody =  '<span style="color: red;">FAIL</span> ' + e.getMessage();
				for(Recovery__c r:recList)
				 {
					recListToUpdate.clear();
                	r.Recovery_System_log__c = r.Recovery_System_log__c == null ? '':r.Recovery_System_log__c ;           
                	r.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds(UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (CURRENCY CONVERSION) ' +responsebody + '</li></ul>' + r.Recovery_System_log__c;
					r.Process_Status__c = 'Exception';
					r.Monetary_Value__c = null;
					r.Currency_Conversion_Rate__c = null;	
					recListToUpdate.add(r);				
				 }
               update recListToUpdate;
			}
		}
	}
	else 
	{
		String responsebody =  '<span style="color: red;">FAIL</span> Manual Currency Conversion Required. ';
		for(Recovery__c r:recList)
		 {
       		 r.Recovery_System_log__c = r.Recovery_System_log__c == null ? '':r.Recovery_System_log__c ;           
       		 r.Recovery_System_log__c = '<ul><li>'+ DateTime.Now().addSeconds(UserInfo.getTimezone().getOffset(DateTime.Now()) / 1000)+ ' (CURRENCY CONVERSION) ' +responsebody +  '</li></ul>'  + r.Recovery_System_log__c;
			 r.Process_Status__c = 'Exception';
			 recListToUpdate.add(r);	
		 }
		try{
			update recListToUpdate;
			}catch(Exception e){
                System.debug(e.getMessage());
			}	   
	}
	   //chain Bank search API call job
	   //removed Japan condition for CDP2-1037
	   if(!Test.isRunningTest())
           System.enqueueJob(new QCC_BankSearchCall(this.recordIds));
	}	
  }//end of execute method

}