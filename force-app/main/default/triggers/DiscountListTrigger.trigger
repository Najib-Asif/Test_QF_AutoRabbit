trigger DiscountListTrigger on Discount_List__c (Before Insert, Before Update, After Insert, After Update) {
    
    try{
        Trigger_Status__c ts = Trigger_Status__c.getValues('DiscountListTrigger');
        if(ts.Active__c){
        
            if(Trigger.isBefore && Trigger.isUpdate){
            
               List<Discount_List__c> temp = DiscountListHandler.populateDiscountThreshold(Trigger.New);
            }
            /*if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                DiscountListHandler.updateProposal(Trigger.New);
            } */
            if(Trigger.isBefore && Trigger.isUpdate){
                DiscountListHandler.afterApprovalsDiscountChanged(Trigger.New, Trigger.OldMap);
            }
         }   
    }catch(Exception e){
        System.debug('Error Occured From Discount List Trigger: '+e.getMessage());
    }
}