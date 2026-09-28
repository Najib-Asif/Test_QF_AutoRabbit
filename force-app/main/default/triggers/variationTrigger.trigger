//Variation Trigger.. This

trigger variationTrigger on Variation__c (before insert, After insert) {

    if(trigger.isbefore)
    VariationTriggerHelper.updateVariationDetail(trigger.new);
    
    if(trigger.isAfter)
     VariationTriggerHelper.updateContractStatus(trigger.new);

}