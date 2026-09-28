trigger QuoteTrigger on Quote (before insert, after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter) {
        try{
        QuoteTriggerHelper.quoteHandler(Trigger.new, Trigger.oldMap);
        }Catch(Exception e){
            if(e.getMessage().contains('Price Per Point is too low')){
                for(Quote quote:Trigger.new){
                    quote.addError('Price Per Point is too low');
                }
            }
        }
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {
        QuoteTriggerHelper.inActivateQuote(Trigger.new);
    }
    
}