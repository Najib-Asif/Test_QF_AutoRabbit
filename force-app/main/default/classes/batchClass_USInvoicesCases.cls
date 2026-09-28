/*Jira-> FCRM-854- US Invoicing - auto create invoice case
Description-> This batch will take the data from csv file and process the records to create cases 
Developer-> Navpreet Kaur
Creation Date-> Feb 2022
*/

global class batchClass_USInvoicesCases implements Database.Batchable<sObject>,Schedulable {
          
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       String query;
       String foldername='Freight_Invoicing_Process_US';
       query='select id,body, name, DeveloperName from document where Folder.DeveloperName=\''+foldername+'\'';
           
        return Database.getQueryLocator(query); 
    }
     global void execute(Database.BatchableContext bc, List<Document> scope) 
     {
         try
         {
         
         
        list<Case> listCases = new list<Case>();
        list<Case> listInsertCases = new list<Case>();
        List<Id> listAgencyInfoIds=new List<Id>();
        List<String> columnValues = new List<String>();
        list<String> filelines=new list<String>();
        set<String> portsList=new set<String>();
        set<String> accountsList=new set<String>(); 
        set<string> contactList=new set<String>();
        List<CASS_Billing__c> listInsertBillings=new List<CASS_Billing__c>();
        List<Id> createdCaseIds=new List<Id>();
        Map<string,Case> mapFromListCases=new Map<string,Case>() ;
        Map<string,CASS_Billing__c> mapBillings=new Map<string,CASS_Billing__c>();
        Set<CASS_Billing__c> updateBillings=new Set<CASS_Billing__c>(); 
        
        
        Id Accountid= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Freight Account').getRecordTypeId();
        Id Contactid= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Id FreightInvoicing=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Freight Invoicing').getRecordTypeId();
        Group grpId=[select id,DeveloperName from group where type='Queue' and DeveloperName='Freight_Invoices_US_Queue'];
            
         String latestDocName='FreightInvoicingUS_'+system.today().day()+'_'+system.today().month()+'_'+system.today().year();
    
        Document latestDoc=new Document();
       
         
         if(scope!=null && scope.size()>0)
         {
             for(document getDoc:scope)
             {
                 if(getDoc.DeveloperName.contains(latestDocName))
                 {
                     latestDoc=getDoc;
                 }
             }
         }  
     
         if(latestDoc!=null)
         {
             String stringBody = latestDoc.body.tostring();
          
             
                filelines = stringBody.split('\n');
               
                 for (Integer i=1;i<filelines.size();i++)
                 {
                      columnValues = filelines[i].split(',');
                      portsList.add(columnValues[0]);
                      accountsList.add(columnValues[2]);
                      contactList.add(columnValues[1]);
                
                 }
                Map<string,Airport_Code__c> fetchPortsMap=new Map<string,Airport_Code__c>();
                for(Airport_Code__c fetchPorts:[select id,name from Airport_Code__c where name IN :portsList])
                {
            
                    fetchPortsMap.put(fetchPorts.name,fetchPorts);
                }
                 
                Map<string,Account> fetchAccountsMap=new Map<string,Account>();
                for(Account accts:[select id,name,ownerid,Freight_Unique_Identifier__c,Freight_Customer_Code__c from Account where Freight_Unique_Identifier__c IN :accountsList and recordtypeid =:Accountid])
                {
                   
                    fetchAccountsMap.put(accts.Freight_Unique_Identifier__c,accts);
                }
               
                
                Map<string,Contact> fetchContactsMap=new Map<string,Contact>();
                for(Contact conts:[select id,name from Contact where Name IN :contactList and recordtypeid =:Contactid])
                {
                   
                    fetchContactsMap.put(conts.name,conts);
                }
               
                  for (Integer i=1;i<filelines.size();i++)
                     { 
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.EmailHeader.triggerAutoResponseEmail= true;
                        
                        columnValues = filelines[i].split(',');
                   
                            Case newRec=new Case();
                           
                            if(fetchAccountsMap.containskey(columnValues[2]) && fetchAccountsMap.get(columnValues[2]).id!=null )
                            newRec.Accountid=fetchAccountsMap.get(columnValues[2]).id;
                            
                            if(fetchContactsMap.containskey(columnValues[1]) && fetchContactsMap.get(columnValues[1]).id!=null)
                            newRec.contactid=fetchContactsMap.get(columnValues[1]).id;
                         

                            if(fetchPortsMap.containskey(columnValues[0]) && fetchPortsMap.get(columnValues[0]).id!=null)
                            newRec.Freight_Port__c=fetchPortsMap.get(columnValues[0]).id;

                            if(columnValues[7]!=null && columnValues[7]!='')
                            newRec.description=columnValues[7];
                            
                            if(columnValues[7]!=null && columnValues[7]!='')
                            newRec.Justification__c=columnValues[7];
                            
                            if(columnValues[3]!=null && columnValues[3]!=''&& columnValues[3].length()==11)
                            newRec.Subject='Freight Invoices US '+columnValues[3].left(3)+'-'+columnValues[3].right(8);
                            
                            if(columnValues[3]!=null && columnValues[3]!='' && columnValues[3].length()==11)
                            newRec.Freight_AWB_Number__c=columnValues[3].left(3)+'-'+columnValues[3].right(8);
                            
                            if(fetchAccountsMap.containskey(columnValues[2]) && fetchAccountsMap.get(columnValues[2]).ownerid!=null )
                            newRec.Account_Owner__c=fetchAccountsMap.get(columnValues[2]).ownerid;
                            
                            if(columnValues[10]!=null && columnValues[10]!='')
                            newRec.SuppliedEmail=columnValues[10];
                            
                            if(columnValues[9]!=null && columnValues[9]!='')
                            newRec.SuppliedPhone=columnValues[9];
                            
                            if(columnValues[8]!=null && columnValues[8]!='')
                            newRec.SuppliedName=columnValues[8];
                          
                            newRec.Ownerid=grpId.id;
                            newRec.status=System.Label.Case_status;
                            newRec.recordtypeid=FreightInvoicing;
                            newRec.Freight_Shipment__c=System.Label.Freight_Shipment;
                            newRec.Origin=System.Label.Case_Origin;
                            newRec.Priority=System.Label.Priority;
                            newRec.CurrencyIsoCode=System.Label.CurrencyIsoCode;
                            newRec.setOptions(dmo);
                            
                            
                            
                          listInsertCases.add(newRec);
             }
             
             
             if(listInsertCases!=null && listInsertCases.size()>0)
             {
                 Database.DMLOptions autoResponseOptions = new Database.DMLOptions(); 
                 autoResponseOptions.EmailHeader.triggerAutoResponseEmail = true; 
                     
 
                 Database.SaveResult[] srList = Database.insert(listInsertCases, false);
                    
                     
                 for(Case createdCases :listInsertCases)
                 {
                     Database.update(createdCases, autoResponseOptions); 
                        
                     if(createdCases.Freight_AWB_Number__c!=null && createdCases.Freight_AWB_Number__c!='')
                     {
                         mapFromListCases.put(createdCases.Freight_AWB_Number__c,createdCases);
                         createdCaseIds.add(createdCases.id);
                     }
                 }
                
               
             }
            List<CASS_Billing__c> listBillings=[select id,CASS_Request__c,CASS_Request__r.Freight_AWB_Number__c,CurrencyIsoCode,Freight_Amount__c from CASS_Billing__c where CASS_Request__c IN :createdCaseIds];
            if(listBillings!=null && listBillings.size()>0)
            {
                for(CASS_Billing__c billRecs: listBillings)
                {
                    mapBillings.put(billRecs.CASS_Request__r.Freight_AWB_Number__c,billRecs);
                }
            }
            
            
             //Insert the related CASS Billing Records for each Case?
             if(latestDoc!=null)
             {
                 String stringBody2 = latestDoc.body.tostring();

                 
                    filelines = stringBody.split('\n');

                     for (Integer i=1;i<filelines.size();i++)
                     {
                         columnValues = filelines[i].split(',');
                         
                         
                         if(columnValues[3]!=null && mapBillings.containskey(columnValues[3].left(3)+'-'+columnValues[3].right(8)))
                             {
                                 mapBillings.get(columnValues[3].left(3)+'-'+columnValues[3].right(8)).CurrencyIsoCode=System.Label.CurrencyIsoCode;
                                 if(columnValues[4]!=null && columnValues[4]!='')
                                 mapBillings.get(columnValues[3].left(3)+'-'+columnValues[3].right(8)).Freight_Amount__c=Decimal.valueof(columnValues[4]);
                                 updateBillings.add(mapBillings.get(columnValues[3].left(3)+'-'+columnValues[3].right(8)));
                             }
                         
                          
                          if(columnValues[3]!=null && columnValues[3]!='' && columnValues[3].length()==11)
                          {
                             String awbNum=columnValues[3].left(3)+'-'+columnValues[3].right(8);
                             if(mapFromListCases.containskey(awbNum))
                             {
                                    
                                    
                                    CASS_Billing__c recCass2=new CASS_Billing__c();
                                    recCass2.CurrencyIsoCode=System.Label.CurrencyIsoCode;
                                    recCass2.CASS_Request__c=mapFromListCases.get(awbNum).id;
                                    recCass2.Charges__c=System.Label.Charges_Amended;
                            
                                    if((columnValues[5]!=null && columnValues[5]!='') && (columnValues[6]!=null && columnValues[6]!=''))
                                    {
                                        if(Decimal.valueof(columnValues[5])>Decimal.valueof(columnValues[6]))
                                        {
                                           recCass2.Freight_Amount__c=Decimal.valueof(columnValues[5])-Decimal.valueof(columnValues[6]); 
                                        }
                                        else if(Decimal.valueof(columnValues[6])>Decimal.valueof(columnValues[5]))
                                        {
                                            recCass2.Freight_Amount__c=Decimal.valueof(columnValues[6])-Decimal.valueof(columnValues[5]);
                                        }
                                    }
                                    
                                   
                                  listInsertBillings.add(recCass2);
                          
                             }
                          }
                     }
                }
                if(updateBillings!=null && updateBillings.size()>0)
                {
                    List<CASS_Billing__c> updateBillingsListSet=new List<CASS_Billing__c>(updateBillings);
                    Database.SaveResult[] srList1 = Database.update(updateBillingsListSet, false);
                }
                if(listInsertBillings!=null && listInsertBillings.size()>0)
                {
                    Database.SaveResult[] srList1 = Database.insert(listInsertBillings, false);
                }
                
             
           }
           
         }
         catch(exception e)
         {
             system.debug('Exception Occurred'+e.getmessage());
         }
     }
     global void finish(Database.BatchableContext bc) {
       
        
    }
    global void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        batchClass_USInvoicesCases b = new batchClass_USInvoicesCases();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
    
 }