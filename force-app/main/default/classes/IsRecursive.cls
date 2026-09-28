public Class IsRecursive{
    public static boolean run = true;
    public static boolean runOnce(){
        if(run) {
            run=false;
            return true;
        } else {
            return run;
        }
    }
    public static boolean runCasebeforeupdate = true;
    public static boolean runOnceCasebeforeupdate(){
        if(runCasebeforeupdate) {
            runCasebeforeupdate=false;
            return true;
        } else {
            return runCasebeforeupdate;
        }
    }
    public static boolean runAccountafterUpdate = true;
    public static boolean runAccountafterUpdate(){
        if(runAccountafterUpdate) {
            runAccountafterUpdate=false;
            return true;
        } else {
            return runAccountafterUpdate;
        }
    }
    public static boolean runCaseafterinsert = true;
    public static boolean runOnceCaseafterinsert(){
        if(runCaseafterinsert) {
            runCaseafterinsert=false;
            return true;
        } else {
            return runCaseafterinsert;
        }
    }
    public static boolean runCaseafterupdate = true;
    public static boolean runOnceCaseafterupdate(){
        if(runCaseafterupdate) {
            runCaseafterupdate=false;
            return true;
        } else {
            return runCaseafterupdate;
        }
    }
}