/**********************************************************************************************************************************
 
    Created Date: 13/04/2015
 
    Description: Extention controller to chnages the contracts legal status
  
    Versión:
    V1.0 - 13/04/2015 - Initial version [FO]
 
**********************************************************************************************************************************/
public with sharing class ChangeContractStatusExt {
  public Contract__c contractObj {get;set;}
  public String response{get;set;}
  
    /*
      Purpose:  Constructor to recieve Contract record.
      Parameters: ApexPages.StandardController.
      Return: none. 
    */
    public ChangeContractStatusExt (ApexPages.StandardController stdController) {
        contractObj   = new Contract__c ();
        contractObj.id   = stdController.getRecord().id;
    }
    
    /*
      Purpose:  Method to generate radio button options.
      Parameters: none.
      Return: list of options. 
    */
    public List<SelectOption> getCustomerResponse() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Signed','Signed')); 
        options.add(new SelectOption('Rejected','Rejected')); 
        return options; 
    }
    
        
    /*
      Purpose:  Method to save contract customer reponse.
      Parameters: none.
      Return: previous page. 
    */
    public pagereference saveCustomerResponse(){
         if(String.isBlank(response)){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select an option'));
             return null;
         }else {
         
            if(response == 'Signed' ){
                contractObj.status__c = 'Signed by Customer';
                try{
                    Database.update(contractObj);
                } catch(Exception e){
                    system.debug('EXCEPTION!!'+e.getStackTraceString());
                }
            }else if(response == 'Rejected' ){
                contractObj.status__c = 'Rejected - Customer';
                try{
                    Database.update(contractObj);
                } catch(Exception e){
                    system.debug('EXCEPTION!!'+e.getStackTraceString());
                }
           }
        }
        return new pagereference('/'+contractObj.id);
 
    }
    
     /*
      Purpose:  Method to cancel page.
      Parameters: none.
      Return: previous page. 
    */
     public pagereference cancelStatus(){
         return new pagereference('/'+contractObj.id);
     }
}