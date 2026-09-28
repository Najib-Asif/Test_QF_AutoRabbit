/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   QCC CAP System Request for Displaying Customer Details on the Service Console panel
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Nov-2017      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CAPRequest {
     
    /*--------------------------------------------------------------------------------------      
    Method Name:        createReqbodyForCAPDetail
    Description:        Customer Details Information from CAP system
    Parameter:          Object Contact
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CustomerDetailsRequest createReqbodyForCAPDetail(contact objCon){
        QCC_CustomerDetailsRequest requestBody = new QCC_CustomerDetailsRequest();
        requestBody.firstName  = objCon.FirstName;
        requestBody.lastName  = objCon.LastName;
        if(objCon.CAP_ID__c != null){
            requestBody.qantasUniqueId  = objCon.CAP_ID__c;
        }else if(objCon.CAP_ID__c == null && objCon.Frequent_Flyer_Number__c != null){
            requestBody.qantasFFNo  = objCon.Frequent_Flyer_Number__c;
        }
        
        requestBody.system_z = 'CAPCRE_CC';
        return requestBody;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createBodyForBooking
    Description:        CAP Product Request Wrapper to create the Request Body
    Parameter:          Object Contact
    --------------------------------------------------------------------------------------*/ 
    public static QCC_CAPProductWrapper.CAPProdRequestWrap createBodyForBooking(Contact objCon){
        QCC_CAPProductWrapper.CAPProdRequestWrap qccCapProdreq = new QCC_CAPProductWrapper.CAPProdRequestWrap();
        qccCapProdreq.system_x = CustomSettingsUtilities.getConfigDataMap('QCC_DisplayBookingController System');
        qccCapProdreq.productsPerPage = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_DisplayBookingController Count'));  
        if(objCon.CAP_ID__c != Null){
            qccCapProdreq.customerId = objCon.CAP_ID__c;
        }else if(objCon.Frequent_Flyer_Number__c != Null){
            qccCapProdreq.ffNo = objCon.Frequent_Flyer_Number__c;
        }else{
            return null;
        }             
        return qccCapProdreq;
    }
    
}