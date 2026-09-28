/*----------------------------------------------------------------------------------------------------------------------
Author:        Jamie Wang
Company:       Accenture
Description:   customer input pnr and lastname, get email and phone from CAP API
Inputs:
Test Class:     QCC_PNRContactInfoFlowControllerTest
************************************************************************************************
History
************************************************************************************************
18-Mar-2023      Jamie Wang                    Initial Design
29-Mar-2023      Jamie Wang                    Add passengerid to check nonFF email and phone
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class QCC_PNRContactInfoFlowController {
    
    public class Request {
        @InvocableVariable
        public String pnr;
        @InvocableVariable
        public String lastname;
        @InvocableVariable
        public String passengerId;
    }

    public class Response {
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String phone;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        getContactInfo
    Description:        Get email and phone from CAP API, using in QCC_Voice_Search_by_PNR_Subflow
    Parameter:          PNR and lastname passengerId
    Output:             email and phone
    Story:              ADT-181
    --------------------------------------------------------------------------------------*/ 
    
    @InvocableMethod(label='Get Contact Info From PNR' description='Returns email and phone from CAP')
    public static List<Response> getContactInfo(List<Request> requests) {
        String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
        Integer Phonecounter=0;
        List<QCC_PNRContactInfoWrapper.Phone> listPhones=new List<QCC_PNRContactInfoWrapper.Phone>();
        Request singleRequest = requests.get(0);
        QCC_PNRContactInfoWrapper pnrContact = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI(singleRequest.pnr, token, singleRequest.lastname);
        System.debug('pnrContact>>>>>>>>>>>' +pnrContact);
        System.debug('pnrContact>>>>>>>>>>>' +json.serialize(pnrContact));

        
        List<Response> listResponse = new List<Response>();
        Response res = new Response();
        if(pnrContact != Null && PnrContact.booking != Null){
            List<QCC_PNRContactInfoWrapper.Email> lstEmail = (pnrContact.booking.contacts != Null && pnrContact.booking.contacts.email != Null)? pnrContact.booking.contacts.email : Null;
            List<QCC_PNRContactInfoWrapper.Phone> lstPhone = (pnrContact.booking.contacts != Null && pnrContact.booking.contacts.phone != Null)? pnrContact.booking.contacts.phone : Null;
            
            if(lstEmail != Null){
    
                for(QCC_PNRContactInfoWrapper.Email emailInfo: lstEmail){
                    system.debug('emailInfo$$$$$'+emailInfo);
                    if (emailInfo.passengerIds.contains(singleRequest.passengerId)) {
                        res.email = emailInfo.emailText;
                        
                        //Check if valid email format using regex. Wrap break on if valid, then break. Otherwise, loop through the next email in case the next one has valid format.
                        if (QCC_VoiceUtils.checkIfValidEmail(emailInfo.emailText)) {
                            break;
                        }
                        
                    }
                }
                system.debug('email######'+res.email);
            }
            
            if(lstPhone != Null){
                string countAreacode;
                for(QCC_PNRContactInfoWrapper.Phone phoneInfo: lstPhone){
                    system.debug('lstPhone$$$$$'+lstPhone);
                    system.debug('phoneInfo$$$$$'+phoneInfo);
                    
                    system.debug('>>> the value of phoneInfo.passengerIds'+phoneInfo.passengerIds);
                    system.debug('>>> the value of singleRequest.passengerId'+singleRequest.passengerId);
                    if (phoneInfo.passengerIds.contains(singleRequest.passengerId)) 
                    {
                        system.debug('The value of phoneInfo.phoneNumber'+phoneInfo.phoneNumber);
                        if(phoneInfo.phoneNumber!=null && String.isNotBlank(phoneInfo.phoneNumber) && !phoneInfo.phoneNumber.contains('13 13 13'))
                        {
                            system.debug('inside the phone number check');
                            Phonecounter++;
                            listPhones.add(phoneInfo);
                            countAreacode=(String.isNotBlank(phoneInfo.countryCode) && phoneInfo.countryCode != null)?phoneInfo.countryCode:'';
                            countAreacode+=(String.isNotBlank(phoneInfo.areaCode) && phoneInfo.areaCode != null)?phoneInfo.areaCode:'';
                            res.phone = (String.isNotBlank(phoneInfo.countryCode) && phoneInfo.countryCode != null)?phoneInfo.countryCode:'';
                            res.phone += (String.isNotBlank(phoneInfo.areaCode) && phoneInfo.areaCode != null)?phoneInfo.areaCode:'';
                            res.phone += (String.isNotBlank(phoneInfo.phoneNumber) && phoneInfo.phoneNumber != null)?phoneInfo.phoneNumber:'';                     
                            break;
                        }   
                    }
                }
                system.debug('phone######'+res.phone);
                system.debug('Phonecounter######'+Phonecounter);
                system.debug('listPhones######'+listPhones);
                system.debug('countAreacode######'+countAreacode);
                
                //Check to correct the format of the phone number
                if(res.phone!=null && res.phone!= '')
                {
                    res.phone=QCC_VoiceUtils.checkIfValidPhone(res.phone);
                    
                }
                
            }
        }
        listResponse.add(res);

        return listResponse;


    }
}