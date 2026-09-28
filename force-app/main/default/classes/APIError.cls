/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir
Company:       Capgemini
Description:   APIError Class to capture the Dynamic Error Response on(Real Time Syncing from ifly)
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
09-Nov-2017    Praveen Sampath               Initial Design
10-Nov-2017    Benazir Amir                  STME-3704
15-Nov-2017    Benazir Amir                  STME-3740
28-Nov-2017    Benazir Amir                  STME-3741
05-Dec-2017    Benazir Amir                  STME-3796
05-Dec-2017    Benazir Amir                  STME-3839
-----------------------------------------------------------------------------------------------------------------------*/
public class APIError{
    public string message {get;set;}
    public string errorCode {get;set;}
    public APIError(string msg, string code){
        this.message = msg;
        this.errorCode = code;
    }
}