/***********************************************************************************************************************************
Author:          Jayaraman Jayaraj
Company:         TCS
Description:     Agency TA information Update.
Test Class Name:

History: 
======================================================================================================================
Date               Name                          Description                                                 
======================================================================================================================
14-Jun-2018        Jay                         Initial Design
**********************************************************************************************************************************/
global class QAC_AgencyTADetailsUpdateParsing {
    
    //Variable Declarations
    global Boolean isActive;
    global String id;
    
   /* public QAC_AgencyTADetailsUpdateParsing(Account_Relation__c taInfo){
        
        isActive = taInfo.Active__c;
            
    }*/
   
    
    //To Parse deserialize data
    public static QAC_AgencyTADetailsUpdateParsing parse(String json){
        return (QAC_AgencyTADetailsUpdateParsing) System.JSON.deserialize(json, QAC_AgencyTADetailsUpdateParsing.class);   
    }

}