/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   QCC CAP System Request for Displaying Customer Details on the Service Console panel
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
01-Nov-2017      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_CAP_DetailController {
    /*--------------------------------------------------------------------------------------      
Method Name:        fetchAddress
Description:        Fetch Customer address Information from CAP system / Updated to Loyalty System Jira CRM-5595
Parameter:          ID
--------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static List<DisplayAddressWrapper> fetchAddress(Id recordId){
        try{
            Contact objcon = [select Id, FirstName, LastName, Email, Phone, Frequent_Flyer_Number__c,
                              CAP_ID__c, Preferred_Contact_Method__c 
                              from Contact where Id =: recordId];
            system.debug('objCon#######'+objcon);
            QCC_CustomerDetailsRequest requestBody = QCC_CAPRequest.createReqbodyForCAPDetail(objcon);
            //QCC_CustomerDetailsResponse.Response customerDetail = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
            //CRM-6427: CIP Decommissioning
            QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact loyaltyContactResponse = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI(objcon.Frequent_Flyer_Number__c);//Jira CRM 5595
            /*List<QCC_CustomerDetailsResponse.Phone> lstPhone = Null;
			List<QCC_CustomerDetailsResponse.Email> lstEmail = Null;
			List<QCC_CustomerDetailsResponse.Address> lstAddress = Null;
			String phone1 ='';*///CRM-5595
		    List<QCC_LoyaltyResponseWrapper.Phones> lstPhone = Null;
            List<QCC_LoyaltyResponseWrapper.Emails> lstEmail = Null;
            List<QCC_LoyaltyResponseWrapper.Addresses> lstAddress = Null;
            system.debug('loyaltyContactResponse$$$$$$'+loyaltyContactResponse); 
            /*if(customerDetail != Null && customerDetail.customers != Null && customerDetail.customers.size() == 1){
              lstPhone = customerDetail.customers[0].customer.phone;
              lstEmail = customerDetail.customers[0].customer.email;
			  lstAddress = customerDetail.customers[0].customer.address;
			}*/
            if(loyaltyContactResponse != Null){
                lstPhone = loyaltyContactResponse.phones;
                lstEmail = loyaltyContactResponse.emails;
                lstAddress = loyaltyContactResponse.addresses;
            }
            /* else if(customerDetail != Null && customerDetail.customers != Null && customerDetail.customers.size() > 1){
for(QCC_CustomerDetailsResponse.Customers customer: customerDetail.customers ){
QCC_CustomerDetailsResponse.Customer matchingCustomer = customer.customer;
if(matchingCustomer.qantasUniqueId == objCon.CAP_ID__c){
lstPhone   = matchingCustomer.phone;
lstEmail   = matchingCustomer.email;
lstAddress = matchingCustomer.address;
break;
}
}
}*/
            List<DisplayAddressWrapper> lstDispAddress = createAddresWrap(lstPhone, lstEmail, lstAddress, objCon.Preferred_Contact_Method__c);
            System.debug('lstDispAddress: '+lstDispAddress);
            return lstDispAddress;
        }
        catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_CAP_DetailController', 
                                    'fetchAddress', '', '', false,'', ex);
            
        }
        return null;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        updateSelected
Description:        Update Customer Details Selected
Parameter:          ID,List of Address
--------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static List<DisplayAddressWrapper> updateSelected(Id recordId, String lstDispWrap){
        try{
            List<DisplayAddressWrapper> lstDispWrapVal = (List<DisplayAddressWrapper>)JSON.deserialize(lstDispWrap,List<DisplayAddressWrapper>.class);
            system.debug('lstDispWrap######'+lstDispWrap);
            Contact objcon = [select Id, Preferred_Contact_Method__c  from Contact where Id =: recordId];
            for(DisplayAddressWrapper dispWrap: lstDispWrapVal){
                dispWrap.IsPreferred = false;
                if(objcon.Preferred_Contact_Method__c <> '' && objcon.Preferred_Contact_Method__c == 'Home' && dispWrap.TypeCode == 'H'){
                    dispWrap.IsPreferred = true;                        
                }else if(objcon.Preferred_Contact_Method__c <> '' && objcon.Preferred_Contact_Method__c == 'Business' && dispWrap.TypeCode == 'B'){
                    dispWrap.IsPreferred = true;    
                } else if(objcon.Preferred_Contact_Method__c <> '' && objcon.Preferred_Contact_Method__c == 'Other' && (dispWrap.TypeCode == 'O' || dispWrap.TypeCode == '')){
                    dispWrap.IsPreferred = true;    
                }
            }
            return lstDispWrapVal; 
        }
        catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_CAP_DetailController', 
                                    'updateSelected', '', '', false,'', ex);
            
        }
        return null;
    }
    /*--------------------------------------------------------------------------------------      
Method Name:        createAddresWrap
Description:        Address details Wrapper Information from CAP system/ Changed to Loyalty System Jira CRM-5595
Parameter:          ListPhone,ListEmail,ListAddress,StringPreferredMethod
--------------------------------------------------------------------------------------*/ 
    /*public static List<DisplayAddressWrapper> createAddresWrap( List<QCC_CustomerDetailsResponse.Phone> lstPhone, 
List<QCC_CustomerDetailsResponse.Email> lstEmail, 
List<QCC_CustomerDetailsResponse.Address> lstAddress, String preferredMthd)*/
    public static List<DisplayAddressWrapper> createAddresWrap( List<QCC_LoyaltyResponseWrapper.Phones> lstPhone, 
                                                               List<QCC_LoyaltyResponseWrapper.Emails> lstEmail, 
                                                               List<QCC_LoyaltyResponseWrapper.Addresses> lstAddress, String preferredMthd)
        
    { 
        List<DisplayAddressWrapper> lstDispAddress = new List<DisplayAddressWrapper>();
        Map<String, String> mapDispAdd = new Map<String, String>();
        Map<String, String> mapDispPhone = new Map<String, String>();
        Map<String, String> mapDispEmail = new Map<String, String>();
        
        if(lstAddress != Null){
            //for(QCC_CustomerDetailsResponse.Address address:  lstAddress){
            for(QCC_LoyaltyResponseWrapper.Addresses address:  lstAddress){ 
                String addr = address.lineOne +' '+address.lineTwo+' ';
                mapDispAdd.put(address.type_Z,addr);
                /*String addr = address.line1 +' '+address.line2+' '+address.line3+' '+address.line4;
addr += ', '+address.suburb+', '+address.state+', '+address.postCode+', '+address.countryName+'.';
mapDispAdd.put(address.typeCode, addr);*/
            }
        }
        
        if(lstPhone != Null){
            //for(QCC_CustomerDetailsResponse.Phone phone: lstPhone){
            for(QCC_LoyaltyResponseWrapper.Phones phone: lstPhone){
                String phoneNumber = phone.countryCode+' '+phone.areaCode+' '+phone.number_Z;
                mapDispPhone.put(phone.type_Z, phoneNumber);
                /*String phoneNumber =QCC_UtilityHelper.PhoneNumbertoE164(phone.phoneCountryCode,phone.phoneAreaCode,phone.phoneLineNumber);
mapDispPhone.put(phone.typeCode, phoneNumber);*/
            }
        }
        
        if(lstEmail != Null){
            /*for(QCC_CustomerDetailsResponse.Email email: lstEmail){
mapDispEmail.put(email.typeCode, email.emailId);*/
            for(QCC_LoyaltyResponseWrapper.Emails email: lstEmail){
                mapDispEmail.put(email.emailAddress,email.emailAddress);
            }
        }
        
        Set<String> setKey = new Set<String>();
        setKey.add('H');
        setKey.add('B');
        setKey.add('O');
        setKey.add('M');
        
        for(String key: setKey){
            if( (mapDispPhone != Null && mapDispPhone.containsKey(key)) ||
               (mapDispEmail != Null && mapDispEmail.containsKey(key)) ||
               (mapDispAdd != Null && mapDispAdd.containsKey(key)) )
            { 
                DisplayAddressWrapper dispAdd = new DisplayAddressWrapper();
                dispAdd.Phone = mapDispPhone != Null && mapDispPhone.containsKey(key)?mapDispPhone.get(key):'';
                dispAdd.Email = mapDispEmail != Null && mapDispEmail.containsKey(key)?mapDispEmail.get(key):'';
                dispAdd.Address = mapDispAdd != Null && mapDispAdd.containsKey(key)?mapDispAdd.get(key):'';
                dispAdd.TypeCode = key;
                dispAdd.IsPreferred = false;
                if(preferredMthd == 'Home' && key == 'H'){
                    dispAdd.IsPreferred = true;                     
                }else if(preferredMthd == 'Business' && key == 'B'){
                    dispAdd.IsPreferred = true; 
                } else if(preferredMthd == 'Other' && (key == 'O' ||key == '')){
                    dispAdd.IsPreferred = true; 
                }
                lstDispAddress.add(dispAdd);
            }
        }
        
        
        return lstDispAddress;
    }
    
    /*--------------------------------------------------------------------------------------      
Method Name:        DisplayAddressWrapper
Description:        Customer Details Information from CAP system
Parameter:          
--------------------------------------------------------------------------------------*/ 
    public class DisplayAddressWrapper{
        @AuraEnabled public String Phone;
        @AuraEnabled public String Email;
        @AuraEnabled public String Address;
        @AuraEnabled public String TypeCode;
        @AuraEnabled public Boolean IsPreferred;
    }
    
}