/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay Bharathan
Company:       TCS
Description:   RestAPI JSON Response Class for QAC_ServiceReqCaseCreation,QAC_ServiceReqCaseRetrieval, QAC_ServiceReqCaseUpdationProcess. 
                This response is sent to Digital Team
Comments :     This class is refferd in QAC_ServiceReqCaseCreation and QAC_ServiceReqCaseRetrieval,this class following best practices ADDED COMMENTS due JIRA-5510 
Test Class:    QAC_ServiceReqCaseCreationProcess_Test, QAC_ServiceReqCaseRetrieval_Test, QAC_ServiceReqCaseUpdationProcess_Test
*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design
01-Jul-2019    Jay                Agency Credits related Changes.
13-Feb-2025    Gandla Mallikarjuna       CRM-9196 Included EMD Details for Seats And Baggage Service Request
********************************************************************************************************************************/

global class QAC_CaseResponses {

    global ExceptionResponse exceptionResponse {get;set;}
    
    // QAC Service Request Case Creation Responses
    global QACCaseCreationResponse serviceRequestCreateResponse {get;set;}
    global list<PassengerResponse> passengerResponses {get;set;}
    global list<FlightResponse> flightResponses {get;set;}
    global list<CaseCommentResponse> commentResponses {get;set;}
    global list<EMDDetailsResponse> emdDetailsResponses {get;set;} //Jira: CRM-9209
    global WorkOrderResponse workOrderResponse {get;set;}
    global WorkOrderLineItemResponse workOrderLineItemResponse {get;set;}
    global ServicePaymentResponse servicePaymentResponse {get;set;}
    
    // QAC Service Request Case Retrieval Responses
    global list<QACCaseRetrievalResponse> serviceRequests {get;set;}
    
    // QAC Service Request Case Updation Responses
    global list<QACCaseUpdationResponse> serviceRequestUpdateResponses {get;set;}
    //global CaseFulfilmentResponse caseFulfilmentResponse {get;set;}
    
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

    // QAC Service Request Case creation responses
    public class FlightResponse {

        // for Flight Creation
        public String message;
        public String statusCode;
        public String flightId;

        // for Flight Creation
        public FlightResponse(String statusCode, String message, String flightId){
            this.statusCode = statusCode;
            this.message = message;
            this.flightId = flightId;
        }

        // for Flight Retrieval
        public String flightNumber;
        public String cabinClass;
        public String flightDate;
        public String departurePort;
        public String arrivalPort;
        public String arrivalTime;
        public String departureTime;
        public String fareBasis;
        //public String requestId;
        public String newCabinClass;
        public String couponNumber;
        public String creationTimestamp;
        Public String lastModifiedTimestamp;
        
        
        // for Flight Retrieval
        public FlightResponse(Flight__c theFlight){
            this.flightNumber = theFlight.Flight_Number__c;
            this.cabinClass = theFlight.Cabin_Class__c;
            this.flightDate = String.valueOf(theFlight.Flight_Date__c);
            this.departurePort = theFlight.Departure_Airport__c;
            this.arrivalPort = theFlight.Arrival_Airport__c;
            this.arrivalTime = theFlight.Arrival_Time__c;
            this.departureTime = theFlight.Departure_Time__c;
            this.fareBasis = theFlight.Fare_Basis__c;
            //this.requestId = theFlight.Case__c;
            this.newCabinClass = theFlight.New_Cabin_Class__c;
            this.couponNumber = theFlight.Coupon_Number__c;
            this.flightId = theFlight.Id;   
            this.creationTimestamp = String.valueOf(theFlight.CreatedDate);
            this.lastModifiedTimestamp = String.valueOf(theFlight.LastModifiedDate);
        }
    }

    //Jira: CRM-9209
    public class EMDDetailsResponse {
        // for EMD Details Creation
        public String message;
        public String statusCode;
        public String emdId;

        // for EMD Details Creation
        public EMDDetailsResponse(String statusCode, String message, String emdId){
            this.statusCode = statusCode;
            this.message = message;
            this.emdId = emdId;
        }

        public String emdNum;
        public String emdType;

        public EMDDetailsResponse(EMD_Details__c theEMDDetail){
            this.emdNum = theEMDDetail.EMD_Number__c;
            this.emdType = theEMDDetail.EMD_Type__c;
           
        }

    }

    public class PassengerResponse {

        // for Passenger Creation
        public String message;
        public String statusCode;
        public String passengerId;

        // for Passenger Creation
        public PassengerResponse(String statusCode, String message, String passengerId){
            this.statusCode = statusCode;
            this.message = message;
            this.passengerId = passengerId;
        }
        
        // for Passenger Retrieval
        public String salutation;
        public String firstName;
        public String surname;
        public String passengerType;
        public String frequentFlyerNumber;
        public String flightNumber;
        public String oldTicketNumber;
        public String ticketNumber;
        public String dateOfBirth;
        public String newSalutation;
        public String newFirstName;
        public String newSurname;
        //public String requestId;
        public String creationTimestamp;
        Public String lastModifiedTimestamp;
        Public String passengerSequence;
        public String passengerTattoo;
        
        // for Passenger Retrieval
        public PassengerResponse(Affected_Passenger__c thePassenger){
            this.salutation = thePassenger.Salutation__c;
            this.firstName = thePassenger.FirstName__c;
            this.surname = thePassenger.LastName__c;
            this.passengerType = thePassenger.Passenger_Type__c;
            this.frequentFlyerNumber = thePassenger.FrequentFlyerNumber__c;
            this.flightNumber = thePassenger.QAC_Flight_Number__c;
            this.oldTicketNumber = thePassenger.Old_Ticket_Number__c;
            this.ticketNumber = thePassenger.Ticket_Number__c;
            this.dateOfBirth = String.valueOf(thePassenger.Date_of_Birth__c);
            this.newSalutation = thePassenger.New_Salutation__c;
            this.newFirstName = thePassenger.New_First_Name__c;
            this.newSurname = thePassenger.New_Last_Name__c;
            //this.requestId = thePassenger.Case__c;
            this.passengerId = thePassenger.QAC_Passenger_Id__c;
            this.creationTimestamp = String.valueOf(thePassenger.CreatedDate);
            this.lastModifiedTimestamp = String.valueOf(thePassenger.LastModifiedDate);
            this.passengerSequence = String.valueOf(thePassenger.Passenger_Sequence__c);
            this.passengerTattoo = String.valueOf(thePassenger.Passenger_Tattoo_Number__c);
        }
    }

    public class CaseCommentResponse {

        // for CaseComment Creation & Updation
        public String message;
        public String statusCode;
        
        // for CaseComment Creation & Updation
        public CaseCommentResponse(String statusCode, String message){
            this.statusCode = statusCode;
            this.message = message;
        }
        
        // for CaseComment Retrieval
        public String commentDescription;
        public String commentId;
        public String creationTimestamp;
        public String lastModifiedTimestamp;
        public String lastModifiedUser;
        
        // for CaseComment Retrieval
        public CaseCommentResponse(CaseComment theCC){
            this.commentDescription = theCC.CommentBody;
            this.commentId = theCC.Id;
            this.creationTimestamp = String.valueOf(theCC.CreatedDate);
            this.lastModifiedTimestamp = String.valueOf(theCC.LastModifiedDate);
            this.lastModifiedUser = theCC.LastModifiedBy.Name;
        }
    }

    public class WorkOrderResponse {

        // for Work Order Creation
        public String message;
        public String statusCode;
        public String workOrderId;
        
        // for Work Order Retrieval
        public String workOrderNumber;
        public String startDate;
        public String endDate;
        public String travelType;
        public String priceBookId;
        public String priceBookName;
        public String productCurrency;
        public Integer noOfLineItems;
        public Decimal subTotal;
        public Decimal gstAmount;
        public Decimal gstPercent;
        public Decimal grandTotal;
        public String status;
        public String creationTimestamp;
        public String lastModifiedTimestamp;
        public String lastModifiedUser; 
        public list<WorkOrderLineItemResponse> workOrderItems;
        public Decimal totalPayableCredits;
        
        // for Work Order Creation
        public WorkOrderResponse(String statusCode, String message, String WorkOrderId){
            this.statusCode = statusCode;
            this.message = message;
            this.workOrderId = WorkOrderId;
        }
        
        // for Work Order Retrieval
        public WorkOrderResponse(WorkOrder workOrder){
            this.workOrderItems = new list<WorkOrderLineItemResponse>();
            this.workOrderId = workOrder.Id;
            this.workOrderNumber = workOrder.WorkOrderNumber;
            this.startDate = String.ValueOf(workOrder.StartDate);
            this.endDate = String.ValueOf(workOrder.EndDate);
            this.travelType = workOrder.Travel_Type__c;
            this.priceBookId = workOrder.Pricebook2Id;
            this.priceBookName = workOrder.Pricebook2.Name;
            this.productCurrency = workOrder.CurrencyIsoCode;
            this.noOfLineItems = workOrder.LineItemCount;
            this.subTotal = workOrder.Sub_Total__c;
            this.gstAmount = workOrder.GST_Amount__c;
            this.gstPercent = workOrder.GST__c;
            this.grandTotal = workOrder.TotalPrice.setScale(2);
            this.creationTimestamp  = String.ValueOf(workOrder.CreatedDate);
            this.lastModifiedTimestamp  = String.ValueOf(workOrder.LastModifiedDate);
            this.lastModifiedUser   = workOrder.LastModifiedBy.Name;
            this.totalPayableCredits = workOrder.Total_Payable_Credits__c;

            // this.workOrderItems = workOrder.WorkOrderItem
            for(WorkOrderLineItem eachItem : workOrder.WorkOrderLineItems){
                this.workOrderItems.add(new WorkOrderLineItemResponse(eachItem));
            }
        }
    }

    public class WorkOrderLineItemResponse {

        // for Work Order Line Item Creation
        public String message;
        public String statusCode;
        public String workOrderLineItemId;
        
        // for Work Order Line Item Retrieval
        public String workOrderNumber;   
        public String productId;         
        public String productCode;       
        public String productName;       
        public Decimal quantity;          
        public Decimal unitPrice;         
        public Decimal subTotal;          
        public Decimal grandTotal;  
        public Decimal totalPayableCredits;
        public Decimal productCreditValue;
        
        // for Work Order Line Item Creation
        public WorkOrderLineItemResponse(String statusCode, String message, String WorkOrderLIId){
            this.statusCode = statusCode;
            this.message = message;
            this.workOrderLineItemId = WorkOrderLIId;
        }
        
        // for Work Order Line Item Retrieval
        public WorkOrderLineItemResponse(WorkOrderLineItem workOrderLineItem){
            this.workOrderLineItemId    = workOrderLineItem.Id;
            this.workOrderNumber        = workOrderLineItem.WorkOrder.WorkOrderNumber;
            this.productId              = workOrderLineItem.Product2Id;
            this.productCode            = workOrderLineItem.Product2.ProductCode;
            this.productName            = workOrderLineItem.Product2.Name;    
            this.quantity               = workOrderLineItem.Quantity;
            this.unitPrice              = workOrderLineItem.UnitPrice;
            this.subTotal               = workOrderLineItem.Subtotal;
            this.grandTotal             = workOrderLineItem.TotalPrice;
            this.totalPayableCredits    = workOrderLineItem.Total_Payable_credits__c;
            this.productCreditValue     = workOrderLineItem.Product_Credit_Value__c;
        }
    }

    public class ServicePaymentResponse {

        // for Service Payment Creation
        public String message;
        public String statusCode;
        public String paymentAmount;
        public String currencyCode;
        public String servicePaymentId;
        
        // for Service Payment Retrieval
        public String paymentId;
        public String workOrderId;
        public String workorderNumber;
        public String paymentType;
        public String paymentTimestamp;
        public String paymentDueDate;
        public String paymentCurrency;
        public Decimal totalAmount;
        public String paymentConfirmationNumber;
        public String paymentStatus;
        public String paymentRemarks;
        public String emdNumber;
        public String rficCode;
        public Date emdIssuedDate;
        public String emdIssuedIata;
        public String creationTimestamp;
        public String lastModifiedTimestamp;
        public String lastModifiedUser;
        public String receiptEmail;
        public String paymentNumber;
        public Decimal totalPayablecredits;

        // for Service Payment Creation
        public ServicePaymentResponse(String statusCode, String message, Service_Payment__c theSP){
            this.statusCode = statusCode;
            this.message = message;
            this.servicePaymentId = theSP.Id;
            this.currencyCode = theSP.Payment_Currency__c;
            this.paymentAmount = String.valueOf(theSP.Total_Amount__c);
        }
        
        // for Service Payment Retrieval
        public ServicePaymentResponse(Service_Payment__c theSP){
            this.paymentId          = theSP.Id;
            this.workOrderId        = theSP.Work_Order__c;
            this.workorderNumber    = theSP.Work_Order__r.WorkOrderNumber;
            this.paymentType        = theSP.Payment_Type__c;
            this.paymentTimestamp   = String.ValueOf(theSP.Payment_Timestamp__c);
            this.paymentDueDate     = String.ValueOf(theSP.Payment_Due_Date__c);
            this.paymentCurrency    = theSP.Payment_Currency__c;
            this.totalAmount        = theSP.Total_Amount__c;
            this.paymentConfirmationNumber = theSP.Payment_Confirmation_Number__c;
            this.paymentStatus      = theSP.Payment_Status__c;
            this.paymentRemarks     = theSP.Payment_Remarks__c;
            this.emdNumber          = theSP.EMD_Number__c;
            this.rficCode           = theSP.RFIC_code__c;
            this.emdIssuedDate      = theSP.EMD_Issued_Date__c;
            this.emdIssuedIata      = theSP.EMD_Issued_IATA__c;
            this.creationTimestamp  = String.ValueOf(theSP.CreatedDate);
            this.lastModifiedTimestamp = String.ValueOf(theSP.LastModifiedDate);
            this.lastModifiedUser   = theSP.LastModifiedBy.Name;
            /**JIRA:3769 this.receiptEmail      = theSP.QAC_Recipient_Email__c;**/
            this.paymentNumber      = theSP.Name;
            this.totalPayablecredits = theSP.Total_Payable_credits__c;
        }
    }

    public class FileResponse {
        
        public String fileName;
        public String fileUrl;
        public String documentId;
        
        public FileResponse(ContentVersion theCV){
            this.fileName = theCV.Title;            
            this.fileUrl = theCV.PathOnClient;
            this.documentId = theCV.ContentDocumentId;
        }
    }
    
    public class AgencyIdentification
    {
        public String agencyReference;
        public String agencyName;
        public String agentName;
        public String agentPhone;
        public String agentEmail;
        public String agencyId;
        public String agencyCountry;

        public AgencyIdentification(Case theCase){
            agencyCountry = theCase.Account.BillingCountryCode;
            agencyId = theCase.AccountId;
            agencyName = theCase.Account.Name;
            agencyReference = theCase.Account.Qantas_Industry_Centre_ID__c;
            agentName = theCase.Consultants_Name__c;
            agentPhone = theCase.Consultant_Phone__c;
            agentEmail = theCase.Consultant_Email__c;
        }
    }
    
    public class CaseFulfilmentResponse{
        public String message;
        public String statusCode;
        public String fulfillmentId;
        public CaseFulfilmentResponse(String statusCode, String message, Case_Fulfilment__c theCF){
            this.statusCode = statusCode;
            this.message = message;
            this.fulfillmentId = theCF.Id;
        }
    }

    // QAC Case Creation Response    
    public class QACCaseCreationResponse
    {
        // success scenarios for Case Creation - Service Request
        public String correlationId;
        public String caseNumber;
        public String requestId;
        public String authorityNumber;
        public String bookingReference;
        public String creationTimestamp;
        public String surname;
        public String message;
        public String statusCode;

        // Success Case Creation
        public QACCaseCreationResponse(String statusCode, String message, Case theCase){
            this.statusCode = statusCode;
            this.message = message;    
            this.correlationId = theCase.External_System_Reference_Id__c;
            this.caseNumber = theCase.CaseNumber;
            this.requestId = theCase.Id;
            this.authorityNumber = theCase.Authority_Number__c;
            this.bookingReference = theCase.PNR_number__c;
            this.creationTimestamp = String.valueOf(theCase.CreatedDate);
            this.surname = theCase.Passenger_Name__c;
        }
    }
    
    public class QACCaseUpdationResponse
    {
        // success scenarios for Case Updation - Service Request
        public String correlationId;
        public String requestNumber;
        public String requestId;
        public String caseStatus;
        public String message;
        public String statusCode;
        
        public list<CaseFulfilmentResponse> fulfilmentResponse;
        public ServicePaymentResponse servicePaymentResponse;

        // Success Case Updation
        public QACCaseUpdationResponse(String statusCode, String message, Case theCase, list<CaseFulfilmentResponse> CFResponse, ServicePaymentResponse SPResponse){
            this.statusCode = statusCode;
            this.message = message;    
            this.fulfilmentResponse = CFResponse;
            this.correlationId = theCase.External_System_Reference_Id__c;
            this.requestNumber = theCase.CaseNumber;
            this.requestId = theCase.Id;
            this.caseStatus = theCase.Status;
            this.servicePaymentResponse = SPResponse;
        }
        
        // Failure Case Updation
        public QACCaseUpdationResponse(String statusCode, String Message, String requestId){
            this.statusCode = statusCode;
            this.message = message;    
            this.requestId = requestId;    
        }
    }
    
    // QAC Case Retrieval Response  
    public class QACCaseRetrievalResponse {

        // case retrieval success scenario
        public list<FlightResponse> flights;
        public list<PassengerResponse> passengers;
        public list<CaseCommentResponse> comments;
        public list<FileResponse> files;
        public list<ServicePaymentResponse> servicePayment;
        public list<WorkOrderResponse> workOrder;

        public String correlationId;
        public String requestId;
        public String requestOwner;
        public String requestOrigin;
        public String requestNumber;
        public String creationTimestamp;
        public String lastModifiedTimestamp;
        public String expectedClosure;
        public String actualClosure;
        public String parentRequest;
        public String requestType;
        public String requestSubType1;
        public String requestSubType2;
        public String requestStatus;
        public String remarkCategory;
        public String subject;
        public String description;
        public String totalAttachments;
        public String requestReason;
        public String requestReasonSubType;
        public String otherReason;
        public String authorityNumber;
        public String additionalRequirements;
        public String requestCountryCode;
        public String authorityStatus;
        public String costOfSale;
        public String isoCurrency;

        public AgencyIdentification agencyIdentification;
        public QAC_ServiceReqCaseCreationAPI.FareDetails fare;
        public QAC_ServiceReqCaseCreationAPI.BookingDetails bookingDetails;

        // case retrieval failure scenario
        public String statusCode;
        public String message;
        
        // case retrieval success scenario
        public QACCaseRetrievalResponse(String statusCode, Case theCase, list<Flight__c> myFlightList, list<Affected_Passenger__c> myPassengerList, list<CaseComment> myCaseCommentList, list<ContentVersion> myFileResponseList, list<Service_Payment__c> myServicePaymentList, 
                                        list<WorkOrder> myWorkOrderList, list<EMD_Details__c> myEMDDetailsList) // Jira: CRM-9209
        {
            flights = new list<FlightResponse>();
            passengers = new list<PassengerResponse>();
            comments = new list<CaseCommentResponse>();
            files = new list<FileResponse>();
            servicePayment = new list<ServicePaymentResponse>();
            workOrder = new list<WorkOrderResponse>();
                
            this.statusCode = statusCode;
            correlationId = theCase.External_System_Reference_Id__c;
            requestId = theCase.Id;
            requestOwner = (String.valueOf(theCase.OwnerId).startsWith('005')) ? 'Consultant' : 
                            (String.valueOf(theCase.OwnerId).startsWith('00G')) ? 'Queue' : '';
            requestOrigin = theCase.Origin;
            requestNumber = theCase.CaseNumber;
            requestCountryCode = theCase.QAC_Request_Country__c;
            creationTimestamp = String.valueOf(theCase.CreatedDate);
            lastModifiedTimestamp = String.valueOf(theCase.LastModifiedDate);
            expectedClosure = String.valueOf(theCase.Expected_Closure_Date__c);
            actualClosure = ''; // Value yet to be mapped
            parentRequest = theCase.Parent.CaseNumber;
            requestType = theCase.Type;
            requestSubType1 = theCase.Problem_Type__c;
            requestSubType2 = theCase.Waiver_Sub_Type__c;
            requestStatus = theCase.Status;
            remarkCategory = theCase.Remark_Category__c;
            subject = theCase.Subject;
            description = theCase.Description;
            totalAttachments = String.valueOf(theCase.Total_Attachments__c);
            requestReason = theCase.Reason_for_Waiver__c;
            requestReasonSubType = theCase.Request_Reason_Sub_Type__c;
            otherReason = theCase.Request_Reason_Others__c;
            authorityNumber = theCase.Authority_Number__c;
            additionalRequirements = theCase.Additional_Requirements__c;
            authorityStatus = theCase.Authority_Status__c;
            costOfSale = String.valueOf(theCase.Cost_of_Sale__c);
            isoCurrency = theCase.CurrencyIsoCode;
            
            this.agencyIdentification = new QAC_CaseResponses.AgencyIdentification(theCase);
            this.fare = new QAC_ServiceReqCaseCreationAPI.FareDetails(theCase);
            this.bookingDetails = new QAC_ServiceReqCaseCreationAPI.BookingDetails(theCase, myEMDDetailsList);

            if(myFlightList != null){
                for(Flight__c eachFlight : myFlightList){
                    this.flights.add(new QAC_CaseResponses.FlightResponse(eachFlight));
                }
            }
            else{
                this.flights = null;
            }

            if(myPassengerList != null){
                for(Affected_Passenger__c eachPassenger : myPassengerList){
                    this.passengers.add(new QAC_CaseResponses.PassengerResponse(eachPassenger));
                }
            }
            else{
                this.passengers = null;
            }

            if(myCaseCommentList != null){
                for(CaseComment eachCC : myCaseCommentList){
                    this.comments.add(new QAC_CaseResponses.CaseCommentResponse(eachCC));
                }
            }
            else{
                this.comments = null;
            }
            
            if(myFileResponseList != null){
                for(ContentVersion eachVersion : myFileResponseList){
                    this.files.add(new QAC_CaseResponses.FileResponse(eachVersion));
                }
            }
            else{
                this.files = null;
            }
            
            // for Payments & Work Orders            
            if(myServicePaymentList != null){
                for(Service_Payment__c eachServicePayment : myServicePaymentList){
                    this.servicePayment.add(new QAC_CaseResponses.ServicePaymentResponse(eachServicePayment));
                }
            }
            else{
                this.servicePayment = null;
            }
            
            if(myWorkOrderList != null){
                for(WorkOrder eachOrder : myWorkOrderList){
                    this.workOrder.add(new QAC_CaseResponses.WorkOrderResponse(eachOrder));
                }
            }
            else{
                this.workOrder = null;
            }
        }

        // case retrieval failure scenario 
        public QACCaseRetrievalResponse(String statusCode, String message, String requestId){
            this.message = message;
            this.statusCode = statusCode;
            this.requestId = requestId;
        }       
    }
}