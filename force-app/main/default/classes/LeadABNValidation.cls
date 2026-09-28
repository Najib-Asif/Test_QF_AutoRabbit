/*****************************************************************************************************
Created By      : Priyadharshini Vellingiri
Class Name      : LeadABNValidation
Mock Class      : LeadValidateABNMock
Test Class Name : LeadABNValidationTest
VF Page         : LeadABNValidation
Created Date    : 02/09/17 (DD/MM/YYYY)
Description     : Auto Populate the ABN related information to the Lead's ABN Source Information section upon Button(Validate ABN) click
JIRA            : CRM-2667
Version         : V1.0 - 02/08/17 - Initial version

******************************************************************************************************/

global Class LeadABNValidation{
 
    public Lead controllerLead { get; set; }
    
    Lead leadRecord = new Lead();
    
    public LeadABNValidation(ApexPages.StandardController stdController) {
        // Map to store response Key-Value pair 
        // map<string, string> mapResponseKeyToValue = new map<string, string>();
        leadRecord = (Lead)stdcontroller.getRecord();
        leadRecord = [SELECT Id, ABN_Tax_Reference__c, ABN_Current_Status__c,PostalCode, Legal_Name__c FROM Lead WHERE Id =: leadRecord.Id];
    }
    
      public PageReference validateABN(){
      
        system.debug(' @@ leadRecord after Select @@ ' + leadRecord);
        HttpRequest request     = new HttpRequest();
        HttpResponse response   = new HttpResponse();   
        Http http               = new Http();
        Boolean setExpMsg=False;
       
    
        string url = 'https://abr.business.gov.au/abrxmlsearch/AbrXmlSearch.asmx/ABRSearchByABN?searchString=' + leadRecord.ABN_Tax_Reference__c +
                        '&includeHistoricalDetails=N&authenticationGuid=2b7c5a3f-eaff-407d-bb29-f86c435e3a28';
        
        // Setting Required parameters
        request.setEndpoint( url );
        request.setMethod('GET');   
        
        // try {  
            response = http.send(request); 
            system.debug(' @@ Response @@ ' + response.getBody());
            
            DOM.Document xmlDOC = new DOM.Document();
            xmlDOC.load(response.getBody());
            // DOM.XMLNode rootElement = xmlDOC.getRootElement();
           
            for(Dom.XmlNode node :xmlDOC.getRootElement().getChildElements()){
                if(node.getName() == 'response') {
                    for(Dom.XmlNode node1 :node.getChildElements()){
                        if(node1.getName() == 'businessEntity'){                        
                            for(Dom.XmlNode node2 :node1.getChildElements()){                                        
                                if(node2.getName() == 'mainName'){
                                   system.debug(' @@ Mainname @@ ' + node2.getName());     
                                    for(Dom.XmlNode node3 :node2.getChildElements()){                                                                           
                                        if(node3.getName() == 'organisationName'){
                                            leadrecord.Legal_Name__c = node3.getText();
                                            system.debug(' @@ OrganisationName @@  ' + node3.getText());                                            
                                        }
                                      }
                                    }
                                 else if(node2.getName() == 'mainBusinessPhysicalAddress'){
                                    for(Dom.XmlNode node3 :node2.getChildElements()){
                                        if(node3.getName() == 'postcode'){
                                            leadrecord.PostalCode = node3.getText();
                                            system.debug(' @@ PostalCode @@  ' + node3.getText()); 
                                        }
                                    }
                                } else if(node2.getName() == 'entityStatus'){
                                    for(Dom.XmlNode node3 :node2.getChildElements()){
                                        if(node3.getName() == 'entityStatusCode'){
                                            leadrecord.ABN_Current_Status__c = node3.getText();
                                            system.debug(' @@ StatusCode @@  ' + node3.getText());
                                        }
                                    }
                                } else if(node2.getName() == 'entityType'){
                                    for(Dom.XmlNode node3 :node2.getChildElements()){
                                        if(node3.getName() == 'entityDescription'){
                                            leadrecord.ABN_Description__c = node3.getText();
                                            system.debug(' @@ Description @@  ' + node3.getText());
                                        }
                                    }
                                } 
                            }
                        } else if(node1.getName() == 'exception')
                            {
                            setExpMsg = TRUE;
                        } 
                    }
                }
            }

            system.debug(' @@ leadRecord after parsing Response@@  ' + leadRecord);
            if(setExpMsg==TRUE) {
                //leadRecord.addError('Exception Occured');
                leadRecord.ShowError__c=TRUE;
                leadrecord.Legal_Name__c = '';
                leadrecord.PostalCode ='';
                leadrecord.ABN_Description__c ='';
                leadrecord.ABN_Current_Status__c='';
                system.debug('@@Error@@ ' + leadRecord.ShowError__c);                
             } else{
                 leadRecord.ShowError__c=False;
              }
            update leadRecord;
            
            PageReference pageRef = new PageReference('/'+leadRecord.Id);
            return pageRef;
 }

        // } catch( System.Exception e) {
        //    System.debug('ERROR: '+ e);
        // }       
}