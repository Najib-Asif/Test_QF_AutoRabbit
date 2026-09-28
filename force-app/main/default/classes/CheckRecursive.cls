/*****************************************************************************************************
ClassName   : CheckRecursive
CreatedBy   : Gourav Bhardwaj
Description : To Control the recursive running of Triggers.

Change History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Gourav Bhardwaj         1787        Stop Recursive running of AccountTeam Trigger               T01
Gourav Bhardwaj         1821        Stop Recursive running of ContractTrigger Trigger           T02
                                    
******************************************************************************************************/
public class CheckRecursive {
    
    // T01
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    // T01 Ends
    
    // T02
    private static boolean runContracts = true;
    public static boolean runOnceContracts(){
        if(runContracts){
            runContracts=false;
            return true;
        }else{
            return runContracts;
        }
    }
    // T02 Ends
    
}