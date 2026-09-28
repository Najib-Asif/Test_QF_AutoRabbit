/**********************************************************************************************************************************
 
    Created Date: 10/04/2015
 
    Description: Extention controller to approve or reject a proposal
  
    Versión:
    V1.0 - 10/04/2015 - Initial version [FO]
 
**********************************************************************************************************************************/
public with sharing class ChangePropoalStatusExt {
  private String proposalId {get;set;}
  public String response{get;set;}
  
    /*
      Purpose:  Constructor to recieve proposal record.
      Parameters: ApexPages.StandardController.
      Return: none. 
    */
    public ChangePropoalStatusExt(ApexPages.StandardController stdController) {
        this.proposalId  = stdController.getRecord().id;
    }
  
    /*
      Purpose:  Method to generate radio button options.
      Parameters: none.
      Return: list of options. 
    */
    public List<SelectOption> getStatus() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Approve','Approve')); 
        options.add(new SelectOption('Reject','Reject')); 
        return options; 
    }
    
    /*
      Purpose:  Method to save proposal status.
      Parameters: none.
      Return: previous page. 
    */
    public pagereference saveStatus(){
    
        if(String.isBlank(response)){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select an option'));
             return null;
         }else {
            Proposal__c Prop = new Proposal__c();
            Prop.id = proposalId;
                if(response == 'Approve' ){
                    Prop.status__c = 'Approved- Customer';
                    try{
                        Database.update(Prop);
                    } catch(Exception e){
                        system.debug('EXCEPTION!!'+e.getStackTraceString());
                    }
                }else if(response == 'Reject' ){
                    Prop.status__c = 'Rejected- External';
                    try{
                        Database.update(Prop);
                    } catch(Exception e){
                        system.debug('EXCEPTION!!'+e.getStackTraceString());
                    }
               }
        }
        return new pagereference('/'+this.proposalId);
 
    }
    
     /*
      Purpose:  Method to cancel page.
      Parameters: none.
      Return: previous page. 
    */
     public pagereference cancelStatus(){
         return new pagereference('/'+this.proposalId);
     }
    
    
}