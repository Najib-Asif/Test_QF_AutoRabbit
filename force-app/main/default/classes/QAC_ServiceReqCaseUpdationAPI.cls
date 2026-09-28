/* Created By : Ajay Bharathan | TCS | Cloud Developer */
public class QAC_ServiceReqCaseUpdationAPI {

	public class ServicePayment {
		public String paymentId;
		public String workOrderId;
		public String paymentType;
		public String paymentStatus;
		public String paymentRemarks;
		public String paymentReferenceNumber;
		public String emdNumber;
		public Date emdIssueDate;
		public String emdIssueIata;
		public String receiptEmail;
		public String paymentNumber;
		public String paymentTimestamp;
	}

	public class ServiceRequestUpdate {
		public String requestId;
		public String requestNumber;
		public String correlationId;
		public String requestStatus;
		public String authorityStatus;
		public AgencyIdentification agencyIdentification;
		public List<FulfillmentStatus> fulfillmentStatus;
		public ServicePayment servicePayment;
		public List<Comments> comments;
	}

	public class AgencyIdentification {
		public String agentName;
		public String agentPhone;
		public String agentEmail;
	}

	public class FulfillmentStatus {
		public String fulfillCategory;
		public String fulfillTimestamp;
		public String fulfillStatus;
		public String fulfillMessage;
	}

	public List<ServiceRequestUpdate> serviceRequestUpdate;

	public class Comments {
		public String commentDescription;
		public String creationTimestamp;
	}
    
    public static QAC_ServiceReqCaseUpdationAPI parse(String json) {
        return (QAC_ServiceReqCaseUpdationAPI) System.JSON.deserialize(json, QAC_ServiceReqCaseUpdationAPI.class);
    }
}