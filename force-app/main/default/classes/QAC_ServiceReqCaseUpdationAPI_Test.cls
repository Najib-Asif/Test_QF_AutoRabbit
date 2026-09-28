/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QAC_ServiceReqCaseUpdationAPI
*/
@IsTest
public class QAC_ServiceReqCaseUpdationAPI_Test {
    
    @IsTest
    public static void testParse() {
        
        String json = '{'+
            '   \"serviceRequestUpdate\":['+
            '      {'+
            '         \"requestId\":\"5005D000002wKWDQA2\",'+
            '         \"requestNumber\":\"02090170\",'+
            '         \"correlationId\":\"C-001001001003\",'+
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Arun Rajendran\",'+
            '            \"agentPhone\":\"+61-423559795\",'+
            '            \"agentEmail\":\"arunrajendran@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"servicePayment\":{'+
            '            \"paymentId\":\"a28p00000003zxzAAA\",'+
            '            \"workOrderId\":\"0WOp00000004a3ZGAQ\",'+
            '            \"paymentType\":\"Card\",'+
            '            \"paymentStatus\":\"Paid\",'+
            '            \"paymentRemarks\":\"Payment Done successfully\",'+
            '            \"paymentReferenceNumber\":\"\",'+
            '            \"emdNumber\":\"0818209981826\",'+
            '            \"emdIssueDate\":\"2018-09-12\",'+
            '            \"emdIssueIata\":\"0239498\",'+
            '            \"receiptEmail\":\"rana.dhiraj@qantas.com.au\",'+
            '            \"paymentNumber\":\"INV-00000476\",'+
            '            \"paymentTimestamp\":\"2018-10-23 12:28:51\"'+
            '         },'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      },'+
            '      {'+
            '         \"requestId\":\"5005D000002wEKUQA2\",'+
            '         \"requestNumber\":\"02090169\",'+
            '         \"correlationId\":\"C-001001001002\",'+
            '         \"requestStatus\":\"In Progress\",'+
            '         \"authorityStatus\":\"Approved\",'+
            '         \"agencyIdentification\":{'+
            '            \"agentName\":\"Ajay Bharathan\",'+
            '            \"agentPhone\":\"+61-469017227\",'+
            '            \"agentEmail\":\"ajay.bharathan@qantas.com.au\"'+
            '         },'+
            '         \"fulfillmentStatus\":['+
            '            {'+
            '               \"fulfillCategory\":\"Payment\",'+
            '               \"fulfillTimestamp\":\"2018-10-23 12:28:51\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Payment Done successfully\"'+
            '            },'+
            '            {'+
            '               \"fulfillCategory\":\"Remark\",'+
            '               \"fulfillTimestamp\":\"2018-05-22 15:00:00\",'+
            '               \"fulfillStatus\":\"Success\",'+
            '               \"fulfillMessage\":\"Please update the request case\"'+
            '            }'+
            '         ],'+
            '         \"servicePayment\":{'+
            '            \"paymentId\":\"a28p00000003zxzAAB\",'+
            '            \"workOrderId\":\"0WOp00000004a3ZGAP\",'+
            '            \"paymentType\":\"Card\",'+
            '            \"paymentStatus\":\"Paid\",'+
            '            \"paymentRemarks\":\"Payment Done successfully\",'+
            '            \"paymentReferenceNumber\":\"\",'+
            '            \"emdNumber\":\"0818209981826\",'+
            '            \"emdIssueDate\":\"2018-09-12\",'+
            '            \"emdIssueIata\":\"0239498\",'+
            '            \"receiptEmail\":\"rana.dhiraj@qantas.com.au\",'+
            '            \"paymentNumber\":\"INV-00000476\",'+
            '            \"paymentTimestamp\":\"2018-10-23 12:28:51\"'+
            '         },'+
            '         \"comments\":['+
            '            {'+
            '               \"commentDescription\":\"insert new comment 1\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:01:00\"'+
            '            },'+
            '            {'+
            '               \"commentDescription\":\"insert new comment 2\",'+
            '               \"creationTimestamp\":\"2018-05-22 15:02:00\"'+
            '            }'+
            '         ]'+
            '      }'+
            '   ]'+
            '}';        
        
        QAC_ServiceReqCaseUpdationAPI obj = QAC_ServiceReqCaseUpdationAPI.parse(json);
        System.assert(obj != null);
        //return obj;
    }
}