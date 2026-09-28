/*----------------------------------------------------------------------------------------------------------------------
Author:        Cuong Ly
Company:       Capgemini
Description:   Wrapper Class uses for mapping data when invoke OPLA webservice
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
19-Jun-2018      Cuong Ly               Build Request and Response classes.

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_OPLALoungePassWrapper {
    public class Request{
        public String reference_no;
        public String frequent_flyer_no;
        public String expiry_period;
        public String title;
        public String first_name;
        public String last_name;
        public String email;
        public String issuer_code;
        public String pass_type;
        public String no_of_pass;
    }

    public class Response{
        public Boolean isSuccess;
        public String referenceNo;
        public String errorMessage;
    }
}