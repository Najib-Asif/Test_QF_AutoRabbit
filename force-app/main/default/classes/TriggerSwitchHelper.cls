public class TriggerSwitchHelper {
    public static Boolean caseTriggerRunFlag = true;
    
    public static Boolean canCaseTriggerExecute(){
        return caseTriggerRunFlag; 
    }
    
    public static void stopCaseTrigger(){
        caseTriggerRunFlag = false;
    }
    
    public static void allowCaseTrigger(){
        caseTriggerRunFlag = true;
    }

}