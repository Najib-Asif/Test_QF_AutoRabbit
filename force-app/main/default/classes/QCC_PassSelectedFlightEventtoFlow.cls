/*========================================================================================================================
 * Created By   : Gnanavelu
 * Description  : Get the Selected flight events from Listviews 
 * JIRA         : CRM-3943
 * Test Class   : QCC_PassSelectedFlightEventtoFlowTest
==========================================================================================================================*/
public class QCC_PassSelectedFlightEventtoFlow {
    public List<Event__c> SelectedFlightEvents{get;set;}
    
    public QCC_PassSelectedFlightEventtoFlow(ApexPages.StandardSetController listcontroller){
            SelectedFlightEvents = new List<Event__c>();
        for(Event__c flightEvents : (Event__c[])listcontroller.getSelected()){
                SelectedFlightEvents.add(flightEvents);
            }
    }
}