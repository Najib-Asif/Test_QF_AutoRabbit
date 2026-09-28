@isTest
Public class LeadABNValidationTest {

     @isTest static void ABNtestCallout() {
                       
           Lead leadRecord = new Lead( Company='Google',
                                        New_Account_Type__c='Customer',
                                        Status='Open',
                                        LastName='Michael',
                                        ABN_Tax_Reference__c ='77134330420',
                                        ABN_Current_Status__c ='Active',
                                        PostalCode = '3000',
                                        Legal_Name__c ='Victaulic Australia Pty Ltd');
                                        
            insert leadRecord ; 
         }
      @isTest   
        static void validateABNTest() {                                   
       
           Lead ld = new Lead( Company='Dell',
                                        New_Account_Type__c='Customer',
                                        Status='Open',
                                        LastName='Leo',
                                        ABN_Tax_Reference__c ='50081143786',
                                        ABN_Current_Status__c ='Active',
                                        PostalCode = '6000',
                                        Legal_Name__c ='Australia Pty Ltd');
                                        
           insert ld;
           Test.startTest();
           
           Test.setMock(HttpCalloutMock.class, new LeadValidateABNMock());
           HttpRequest  req = new HttpRequest(); 
           Http http   = new Http();
           
           Boolean setExpMsg=False;
           
           req.setEndpoint('https://abr.business.gov.au/abrxmlsearch/AbrXmlSearch.asmx/ABRSearchByABN?searchString='+
                        '&includeHistoricalDetails=N&authenticationGuid=2b7c5a3f-eaff-407d-bb29-f86c435e3a28');                 

           system.debug('******requestreceived ******'+req);
           req.setMethod('GET'); 
        
           HttpResponse response;
           system.debug('******requestreceivedafterGET ******'+req);       

           response = http.send(req);
           DOM.Document xmlDOC = new DOM.Document();
           xmlDOC.load(response.getBody());
           system.debug('******response******'+response.getBody()); 
           ApexPages.currentPage().getParameters().put('id', ld.id);//Pass Id to page
           ApexPages.StandardController sc = new ApexPages.StandardController(ld);
           LeadABNValidation apextestclass=new LeadABNValidation(sc);
           apextestclass.validateABN();
           PageReference pageRef = new PageReference('/' + ld.Id);        
           
        Test.stopTest();        
    }
}