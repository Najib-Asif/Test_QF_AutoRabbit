Public class Proposalcreatecontract {

    public static void ProposalcreatecontractMethod(list<Proposal__C> listOfProp) {
    List <Contract__c   > contractToInsert = new List <Contract__c> ();
    Id recId1 = [select Id from RecordType where Name = 'Adhoc Charter' and SobjectType = 'Contract__c'].Id;
    Id recId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('Adhoc Charter').getRecordTypeId();
    for (Proposal__c o : listOfProp) {      
                     
        if (o.RecordTypeId == recId) {  
        Contract__c  v = new Contract__c ();  
        v.Account__c = o.Account__c;  
        v.Opportunity__c = o.Opportunity__c ; 
        v.Name=o.Name;
        v.Proposal__c   =o.Id;
        v.Contract_Start_Date__c=o.Proposal_Start_Date__c;
        v.Contract_End_Date__c  =o.Proposal_End_Date__c;
        v.Forecast_Charter_Spend__c =o.Forecast_Charter_Spend__c;
        v.Description__c=o.Description__c;
        v.Contact_Information__c=o.Contact_Information__c;
        v.Forecast_Charter_Spend__c =o.Forecast_Charter_Spend__c;
        v.RecordTypeId = recId1;
        contractToInsert.add(v);
        
        }
        
    }
    
    
    try {
       if(contractToInsert.size()>0)
        insert contractToInsert; 
    } catch (system.Dmlexception e) {
        system.debug (e);
    }
    }
    }