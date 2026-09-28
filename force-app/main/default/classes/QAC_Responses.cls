/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Bharathan
Company:       TCS
Description:   RestAPI JSON Response Class for QAC_AccountServicesProcess Main Class. This response is sent to Digital Team
Test Class:    QAC_AccountServicesProcess_Test,QAC_AccountRetrieval_Test,QAC_AgencyRetrieval_Test     
*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design
10-May-2019    Ajay               Account PNR Validation API Response
30-Mar-2026    Zain S                CIAM-1896: Fix for Null Pointer Exception in Account Retrieval Response when Billing Address is null
30-Mar-2026    Zain S                CIAM-1881: Added new fields in Account Retrieval Response for CIAM integration
********************************************************************************************************************************/
global class QAC_Responses {
    
    global CaseResponse caseResponse {get;set;}
    global list<TmcResponse> tmcResponses {get;set;}
    global list<TaResponse> ticketingAuthorityResponses {get;set;}
    global AccountResponse accountResponse {get;set;}
    global list<ContactResponse> contactResponses {get;set;}
    global list<AcrResponse> acrResponses {get;set;}
    global ExceptionResponse exceptionResponse {get;set;}
    
    global list<QACAccountRetrievalResponse> QACAccountRetrievalResponse {get;set;}

    // for Account Validation PNR Response
    global QAC_AgencyValidationResponse agencyValidationResponse {get;set;}
    
    public class AccountResponse
    {
        public String statusCode;
        public String digitalReferenceId;
        public String sfAccountId;
        public String IATA;
        //public String TIDS;
        public String ABN;
        public String message;
        public Boolean qacSiteAccess;
        public Boolean accountActive;
        
        // account Responses for Success / error 
        public AccountResponse(String statusCode, String refId, String accId, String iata, Boolean qacSiteAccess, Boolean accountActive, String abn){
            this.statusCode = statusCode;
            DigitalReferenceId = refId;
            SFAccountId = accId;
            this.IATA = iata;
            //this.TIDS = tids;
            this.ABN = abn;
            this.message = (String.isBlank(accId)) ? 'Account is not Created, Duplicate Account Found' : 'Account Created Successfully';
            this.qacSiteAccess = qacSiteAccess;
            this.accountActive = accountActive;
        }
        
        // account Responses for IATA / TIDS value blank
        public AccountResponse(String statusCode, String Message){
            this.statusCode = statusCode;
            this.message = message;    
            DigitalReferenceId = '';
            SFAccountId = '';
            this.IATA = '';
            this.ABN = '';
        }
    }
    
    public class CaseResponse{
        public String statusCode;
        public String message;
        public String sfCaseNumber;
        public String caseRecType;
        public String accountStatus;
        public CaseResponse(String statusCode, String message, String sfCaseNumber, String caseRecType, String accountStatus){
            this.statusCode = statusCode;
            this.message = message;  
            this.sfCaseNumber = sfCaseNumber;
            this.caseRecType = caseRecType; 
            this.accountStatus = accountStatus;
        }
    }
    
    public class TmcResponse{
        
        // for Agency Registration
        public String message;
        public String sfTMCid;
        public String recordType;
        public String statusCode;
        
        // for Agency Retrieval
        public String gdsCode;
        public String pseudoCityCode;
        public Boolean active;
        public String agencyProductFare;
        public String name;
        public String accountId;
        public DateTime lastInactiveDate;
        
        // for Agency Registration
        public TmcResponse(String statusCode,String message, String sfTMCid, String recordType){
            this.statusCode = statusCode;
            this.message = message;  
            this.sfTMCid = sfTMCid;
            this.recordType = recordType;    
        }
        
        // for Agency Retrieval
        public TmcResponse(String accountId, String name, String gdsCode, String pseudoCityCode, String agencyProductFare, Boolean active,DateTime lastInactiveDate){
            this.accountId = accountId;
            this.name = name;  
            this.gdsCode = gdsCode;
            this.pseudoCityCode = pseudoCityCode;    
            this.agencyProductFare = agencyProductFare;
            this.active = active;  
            this.lastInactiveDate = lastInactiveDate;
        }
    }
    
    public class TaResponse{
        
        // for Agency Registration
        public String statusCode;
        public String message;
        public String sfTAid;
        public String primaryIATACode;
        public String primaryAccountName;
        public String relatedIATACode;
        public String relatedAccountName;
        
        // for Agency Retrieval
        public String relatedAccountID;
        public String primaryAccountID;
        public String relationship;
        public String name;
        public Boolean active;
        public Date startDate;
        public DateTime lastInactiveDate;
        
        public String replaceAgencyName(String AgencyName){
            return (String.isBlank(AgencyName)) ? null : AgencyName.replaceAll('\\[(.*?)\\]','').trim();
        }
        
        // for Agency Registration
        public TaResponse(String statusCode, String message, String sfTAid, String primaryIATACode, String primaryAccountName, String relatedIATACode,String relatedAccountName){
            this.statusCode = statusCode;
            this.message = message;  
            this.sfTAid = sfTAid;
            this.primaryIATACode = primaryIATACode;    
            //this.primaryAccountName = primaryAccountName;
            this.primaryAccountName = this.replaceAgencyName(primaryAccountName);
            this.relatedIATACode = relatedIATACode;    
            //this.relatedAccountName = relatedAccountName;    
            this.relatedAccountName = this.replaceAgencyName(relatedAccountName);
        }
        
        // for Agency Retrieval
        public TaResponse(String name, String sfTAid, String primaryAccountID, String primaryAccountName, String primaryIATACode, String relationship, String relatedAccountID, String relatedAccountName, String relatedIATACode, Date startDate, Boolean active, DateTime lastInactiveDate){
            this.name = name;  
            this.sfTAid = sfTAid;
            this.primaryAccountID = primaryAccountID;    
            this.primaryIATACode = primaryIATACode;
            //this.primaryAccountName = primaryAccountName;  
            this.primaryAccountName = this.replaceAgencyName(primaryAccountName);
            
            this.relationship = relationship;
            this.relatedIATACode = relatedIATACode;    
            this.relatedAccountID = relatedAccountID;
            //this.relatedAccountName = relatedAccountName;  
            this.relatedAccountName = this.replaceAgencyName(relatedAccountName);
            
            this.startDate = startDate;
            this.active = active;  
            this.lastInactiveDate = lastInactiveDate;
        }
    }
    
    public class ContactResponse{
        public String statusCode;
        public String message;
        public String sfContactid;
        public String email;
        public String lastName;
        public String phone;
        public String verificationNumber;
        public ContactResponse(String statusCode,String message, String sfContactid, String email, String lastName, String phone, String verificationNumber){
            this.statusCode = statusCode;
            this.message = Message;  
            this.sfContactid = sfContactid;
            this.email = email;   
            this.phone = phone;
            this.lastName = lastName; 
            this.verificationNumber=verificationNumber;
        }
    }
    
    public class AcrResponse{
        public String message;
        public String accName;
        public String contactName;
        public String statusCode;
        public AcrResponse(String statusCode,String message, String contactName, String accName){
            this.statusCode = statusCode;
            this.message = Message;  
            this.accName = accName;
            this.contactName = contactName;    
        }
    }
    
    public class ExceptionResponse {
        public String message;
        public String errorCode;
        public String sfErrorMessage;
        public String statusCode;
        public ExceptionResponse(String statusCode, String message, String errorcode, String sfErrorMessage){
            this.statusCode = statusCode;
            this.message = message;
            this.errorCode = errorcode;
            this.sfErrorMessage = sfErrorMessage;
        }
    }

    // Agency Retrieval Response
    // For Account PNR Validation API
    public class QAC_AgencyValidationResponse
    {
        public String statusCode;
        public String message;
        
        public QAC_AgencyValidationResponse(String statusCode, String message){
            this.message = message;
            this.statusCode = statusCode;
        }       
    }
    
    //Account TMC Response
    public class QACAccountRetrievalResponse
    {
        //public Account accountDetail;
        public list<TmcResponse> agencyTMCList;
        public list<TaResponse> agencyTAList;
        
        // success scenarios for Account Retrieval
        public String agencyName;
        public String agencyABN;
        public String website;
        public String faxCountryCode;
        public String faxAreaCode;
        public String faxNumber;
        public String accountEmail;
        public String referenceId;
        public String agencyId;                            //CIAM
        public String primaryAgencyBusiness;
        
        public BillingAddress billingAddress;
        
        //public Address billingAddress;
        public Boolean bookingEngineAccess;
        public String agencyChain;
        public String agencyBrandCode;
        public String agencySubChain;
        public String phoneCountryCode;
        public String phoneAreaCode;
        public String phoneNumber;
        public Boolean active;
        Public String customerCategory;
        public String agencyType;
        public String officeType;
        public String legalName;
        public String iataCode;
        public String tidsCode;
        public Integer employees;
        public String ownerName;
        public String qbrMembershipNumber;
        public String industry;
        public Boolean tradesite;
        public Date iataExpiryDate;
        public Boolean isManualRequestPending;                       //CIAM
        public String accreditationType;                            //CIAM-1881
        
        // failure scenarios for Account Retrieval
        public String statusCode;
        public String qicCode;
        public String message;
        
        //account tmc response for Success
        public QACAccountRetrievalResponse(String statusCode, Account acc, list<Agency_Info__c> myTmcList, list<Account_Relation__c> myTaList){
            //this.accountDetail = acc;
            agencyTMCList = new list<TmcResponse>();
            agencyTAList = new list<TaResponse>();
            
            this.statusCode = statusCode;

            // to remove characters inside square brackets
            this.agencyName = acc.Name.replaceAll('\\[(.*?)\\]','').trim(); 

            this.agencyABN = acc.ABN_Tax_Reference__c;
            this.qicCode = acc.Qantas_Industry_Centre_ID__c;
            this.website = acc.Website;
            this.faxCountryCode = acc.Fax_Country__c;
            this.faxAreaCode = acc.Fax_Area__c;
            this.faxNumber = acc.Fax_Number__c;
            this.accountEmail = acc.Email__c;
            this.referenceId = acc.External_Reference_ID__c;
            this.primaryAgencyBusiness = acc.Business_Type__c;

            //this.billingAddress = acc.BillingAddress;
            this.billingAddress = new QAC_Responses.BillingAddress(acc.BillingAddress);

            this.bookingEngineAccess = acc.RCTI__c;
            if(acc.Agency_Sales_Region__c != null){
                this.agencyChain = acc.Agency_Sales_Region__r.Name;
                
                if (this.billingAddress.countryCode == 'AU')
                    this.agencyBrandCode = acc.Agency_Sales_Region__r.Brand_Code__c;
                else
                    this.agencyBrandCode = this.billingAddress.countryCode;
            }
            else
                this.agencyBrandCode = this.billingAddress.countryCode;
            
            this.agencySubChain = acc.Agency_Sub_Chain__c;
            this.phoneCountryCode = acc.Phone_Country_Code__c;
            this.phoneAreaCode = acc.Phone_Area__c;
            this.phoneNumber = acc.Phone_Number__c;
            this.active = acc.Active__c;
            this.customerCategory = acc.Customer_Category__c;
            this.agencyType = acc.Agency_Type__c;
            this.legalName = acc.Legal_Name__c;
            this.iataCode = acc.IATA_Number__c;
            this.tidsCode = acc.Agency_TIDS_Number__c;
            this.employees = acc.NumberOfEmployees;
            this.ownerName = acc.Owner.Name;
            this.qbrMembershipNumber = acc.Aquire_Membership_Number__c;
            this.industry = acc.Industry;
            this.tradesite = acc.Tradesite__c;
            this.accreditationType = acc?.AccreditationType__c;                       //CIAM-1881
            this.iataExpiryDate = acc.IATA_Expiry_Date__c;
            this.officeType = acc.Office_Type__c;
            this.isManualRequestPending = acc.QAC_Request_Pending__c;                       //CIAM
            this.agencyId = acc.Id;                       //CIAM
            
            system.debug('tmc list**'+myTmcList);
            system.debug('ta list**'+myTaList);
            
            if(myTmcList != null){
                for(Agency_Info__c eachTMC : myTmcList){
                    this.agencyTMCList.add(new QAC_Responses.TmcResponse(eachTMC.Account__c,
                                                                         eachTMC.Name,
                                                                         eachTMC.Code__c,
                                                                         eachTMC.PCC__c,
                                                                         eachTMC.Agency_Product_Fares__c,
                                                                         eachTMC.Active__c,
                                                                         eachTMC.Last_Inactive_Date__c));
                }
            }
            
            if(myTaList != null){
                for(Account_Relation__c eachTA : myTaList){
                    
                    this.agencyTAList.add(new QAC_Responses.TaResponse(eachTA.name,
                                                                       eachTA.Id,
                                                                       eachTA.Primary_Account__c,
                                                                       eachTA.Primary_Account_f__c,
                                                                       eachTA.Primary_Account__r.Qantas_Industry_Centre_ID__c,
                                                                       eachTA.Relationship__c,
                                                                       eachTA.Related_Account__c,
                                                                       eachTA.Related_Account_f__c,
                                                                       eachTA.Related_Account__r.Qantas_Industry_Centre_ID__c,
                                                                       eachTA.Start_Date__c,
                                                                       eachTA.Active__c,
                                                                       eachTA.Last_Inactive_Date__c));
                }
            }
            else{
                this.agencyTAList = null;
            }
        }
        
        // account tmc response for failure
        public QACAccountRetrievalResponse(String statusCode, String message, String qicCode){
            this.message = message;
            this.statusCode = statusCode;
            this.qicCode = qicCode;
        }       
    }
    
    public class BillingAddress {
        public String city;
        public String country;
        public String countryCode;
        public String geocodeAccuracy;
        public Double latitude;
        public Double longitude;
        public String postalCode;
        public String state;
        public String stateCode;
        public String street;
        
        public BillingAddress(Address billingAddress)
        {
            if (billingAddress != null) {               //CIAM-1896: Fix for Null Pointer Exception in Account Retrieval Response when Billing Address is null
                city = billingAddress.getCity();
                country = billingAddress.getCountry();
                countryCode = billingAddress.getCountryCode();
                geocodeAccuracy = billingAddress.getGeocodeAccuracy();
                latitude = billingAddress.getLatitude();
                longitude = billingAddress.getLongitude();
                postalCode = billingAddress.getPostalCode();
                state = billingAddress.getState();
                stateCode = billingAddress.getStateCode();
                if(String.isNotBlank(billingAddress.getStreet()))
                    street = billingAddress.getStreet().replaceAll('(\r\n|\n\r|\r|\n)', ','); 
            }
        }
    }    
}