//Created for [QLSF-332] Loyalty: Change Close Date later so that field values can be updated before it is closed.
//Can be reused in future also to keep future methods.
public class futureMethodsClass {

    //[QLSF-332] Loyalty: Change Close Date later so that field values can be updated before it is closed.
    @future
    public static void closeOpp(Id oppId, Date closeDateValue){
        try{
            if (closeDateValue==null){
        update new Opportunity(Id=oppId,
                StageName='Closed Won');
        } else {
                update new Opportunity(Id=oppId,
                StageName='Closed Won',
                CloseDate=closeDateValue);
        }
        }catch(Exception e)
        {
            system.debug('Error Occurred '+e);
        }
        
    }
    


}