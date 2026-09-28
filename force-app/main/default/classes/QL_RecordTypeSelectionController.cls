public with sharing class QL_RecordTypeSelectionController {
    
    @AuraEnabled public Account MyAccObj{get;set;}  
    @AuraEnabled public boolean isSuccess{get;set;}
    @AuraEnabled public String Message{get;set;}
    @AuraEnabled public String fld_val1{get;set;}
    @AuraEnabled public String fld_val2{get;set;}
    @AuraEnabled public String fld_val3{get;set;}
    @AuraEnabled
    public static string findRecordTypes(string objName){        
        string returnString='';
        List<RecordTypeWrapper> wrapperList=new List<RecordTypeWrapper>();
        if(objName == 'Case'){
            for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() == true && info.isMaster() == False)
                {
                    system.debug('available record type @@@@'+info);
                    RecordTypeWrapper rw=new RecordTypeWrapper();
                    rw.recordTypeLabel=info.getName();
                    rw.recordTypeId=info.recordtypeid;
                    wrapperList.add(rw);
                }
            }
        }
        
           else if(objName == 'Opportunity'){
            for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() == true && info.isMaster() == False)
                {                    
                    RecordTypeWrapper rw=new RecordTypeWrapper();
                    rw.recordTypeLabel=info.getName();
                    rw.recordTypeId=info.recordtypeid;
                    wrapperList.add(rw);
                }
            }
        }
        returnString= JSON.serialize(wrapperList);
        system.debug('*****'+returnString);
        return returnString;
    }
    public class RecordTypeWrapper{
        public string recordTypeLabel{get;set;}
        public string recordTypeId{get;set;}
    }
    
    @AuraEnabled
    public static String fetchOpportunityfields(String AccId)
    {
        system.debug('Accid*************'+Accid);
        List<ObjectDetails> lstRet = new List<ObjectDetails>();
        Account Accobj = [Select Id, Type, Estimated_Total_Annual_Revenue__c, Total_QF_Revenue_TY__c, Estimated_MCA_Revenue__c, Estimated_QF_Dom_Market_Share__c,
                          QF_Domestic_Market_Share__c, Estimated_Int_Market_Share__c, QF_International_Market_Share__c, Estimated_Int_MCA_Market_Share__c,
                          QF_International_MCA_Market_Share__c from Account WHERE ID =: AccId];
        system.debug(Accobj);
        ObjectDetails obj2 = new ObjectDetails();
        system.debug('newvalue '+Accobj.Estimated_QF_Dom_Market_Share__c);
        if((Accobj.Type=='Customer Account' || Accobj.Type=='Prospect Account' || Accobj.Type=='Agency Account') && Accobj!=null)
        {
            if(Accobj.Estimated_Total_Annual_Revenue__c!=null && Accobj.Estimated_Total_Annual_Revenue__c!=0)
                obj2.val1 = String.valueof(Accobj.Estimated_Total_Annual_Revenue__c);
           //else if(Accobj.Estimated_Total_Annual_Revenue__c!=null)
                //obj2.val1 = String.valueof(Accobj.Total_QF_Revenue_TY__c);
            else  
                obj2.val1 = String.valueof(Accobj.Total_QF_Revenue_TY__c);
            
            if(Accobj.Estimated_MCA_Revenue__c!=null)
                obj2.val2 = String.valueof(Accobj.Estimated_MCA_Revenue__c);
            else 
                obj2.val2 = '0.00';
            
            if(Accobj.Estimated_QF_Dom_Market_Share__c!=null && Accobj.Estimated_QF_Dom_Market_Share__c!=0)
                obj2.val3 = String.valueof(Accobj.Estimated_QF_Dom_Market_Share__c);
            //else if(Accobj.Estimated_QF_Dom_Market_Share__c!=null)
                //obj2.val3= String.valueof(Accobj.QF_Domestic_Market_Share__c);
            else 
                obj2.val3= String.valueof(Accobj.QF_Domestic_Market_Share__c);
            
            
            if(Accobj.Estimated_Int_Market_Share__c!=null && Accobj.Estimated_Int_Market_Share__c!=0)
                obj2.val4 = String.valueof(Accobj.Estimated_Int_Market_Share__c);
            else
                obj2.val4= String.valueof(Accobj.QF_International_Market_Share__c);
            
            if(Accobj.Estimated_Int_MCA_Market_Share__c!=null && Accobj.Estimated_Int_MCA_Market_Share__c!=0)
                obj2.val5= String.valueof(Accobj.Estimated_Int_MCA_Market_Share__c);
            //else if(Accobj.Estimated_Int_MCA_Market_Share__c!=null)
                //obj2.val5 = String.valueof(Accobj.QF_International_MCA_Market_Share__c);
            else 
                obj2.val5 = String.valueof(Accobj.QF_International_MCA_Market_Share__c);
            
            lstRet.add(obj2);
            system.debug('lstRet:'+lstRet);
        }
        return JSON.serialize(lstRet) ;
        
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel,String obj){
        Id recid;
        //Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();  
        if(obj!= null && recordTypeLabel!= null)
        {
            system.debug('obj************'+obj);
            // recid =Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();    
            recid = recordTypeLabel;
            system.debug('recid************'+recid);
        }
        return recid;
    }    
    
    @AuraEnabled
    public static String fetchFFCasefields(String CaseId)
    {
        system.debug('Accid*************'+CaseId);
        List<ObjectDetails> lstRet = new List<ObjectDetails>();
        Id FFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Frequent Flyer Request').getRecordTypeId();
        Id SORecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Offers Request').getRecordTypeId();
        //Case Caseobj = [Select Id, AccountId,Type from Case WHERE Id=: CaseId AND Type = 'Frequent Flyer Information'];
        Case Caseobj = [Select Id, AccountId,Type from Case WHERE Id=: CaseId AND (RecordTypeId=:FFRecordTypeId OR RecordTypeId=:SORecordTypeId )];
        system.debug(Caseobj );
        ObjectDetails obj2 = new ObjectDetails(); 
        Obj2.val1 = String.valueof(Caseobj.AccountId);
        lstRet.add(obj2);
        system.debug('lstRet**********'+lstRet);
        return String.valueof(Caseobj.AccountId);
    }
      @AuraEnabled(cacheable = true)
    public static String fetchDSCasefields(String contId)
    {
        system.debug('ContId*************'+contId);
        List<ObjectDetails> lstRet = new List<ObjectDetails>();
        Contract__c Contobj = [Select Id,Account__c FROM Contract__c WHERE Id=: contId];
        system.debug(Contobj );
        ObjectDetails obj2 = new ObjectDetails(); 
        Obj2.val1 = String.valueof(Contobj.Account__c);
        lstRet.add(obj2);
        system.debug('lstRet**********'+lstRet);
        // return JSON.serialize(lstRet) ;
        return String.valueof(Contobj.Account__c);
    }
    @AuraEnabled (cacheable=true)
    public static QL_RecordTypeSelectionController fetchSAPfields(String AccId)
    {
        QL_RecordTypeSelectionController obj= new QL_RecordTypeSelectionController();
        system.debug('AccId*************'+AccId);
        Account Accobj = [Select Id,Ownerid,Description FROM Account WHERE Id=: AccId];
        system.debug(Accobj);
        obj.fld_val1 = String.valueof(Accobj.Id);
        Obj.fld_val2 = String.valueof(Accobj.Ownerid);
        Obj.fld_val3 = String.valueof(Accobj.Description);
        return Obj;
    }
    
    @AuraEnabled
    public static String fetchRelationshipfields(String ConId)
    {
        system.debug('Accid*************'+ConId);
        Id recid = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Non_Agency_Contact').getRecordTypeId();
        List<ObjectDetails> lstRet = new List<ObjectDetails>();
        Contact Contobj = [Select Id from Contact WHERE Id=:ConId and RecordTypeId =: recid];
        system.debug(Contobj);
        ObjectDetails obj2 = new ObjectDetails(); 
        Obj2.val1 = String.valueof(Contobj.Id);
        lstRet.add(obj2);
        system.debug('lstRet**********'+lstRet);
        return String.valueof(Contobj.Id);
    }
    
    
    public class ObjectDetails{
        public string name;
        
        
        public String val1{get;set;}
        public String val2{get;set;}
        public String val3{get;set;}
        public String val4{get;set;}
        public String val5{get;set;}
        
        
    }
    
}