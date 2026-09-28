import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { gql, graphql, refreshGraphQL } from "lightning/uiGraphQLApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * LWC to display Work Order Line Items related to a Case (Disruption Workflow)
 * @author Zain Seraj
 * @date   July 2025
 * @description Displays Work Order Line Items related to a Case, showing their status and approved amounts.
 */
export default class QccDisruptionWorkflow extends NavigationMixin(LightningElement) {
  @api recordId
  records;
  approvedTotal = 0;
  hasReviewLines = true;
  isLoading = true;
  casefields = ['Status', 'OwnerId', 'ContactId', 'Submit_to_Admin__c'];

  @wire(graphql, {
    query: gql`
      query WOLI_Info($recordId : ID) {
        uiapi {
          query {
            WorkOrderLineItem (where: { WorkOrder:{CaseId: { eq: $recordId } } }) {
              edges {
                node {
                  Id
                  WorkOrderId { 
                    value }
                  LineItemNumber { 
                    value 
                    displayValue }
                  Status { 
                    value 
                    displayValue }
                  Receipt_Date__c { 
                    value 
                    displayValue }
                  Receipt_Amount__c { 
                    value 
                    displayValue }
                  Total_Approved_Amount__c { 
                    value 
                    displayValue }
                  Original_Currency__c { 
                    value 
                    displayValue }
                  Original_Currency_Amount__c { 
                    value 
                    displayValue }
                  Expense_Category__c { 
                    value 
                    displayValue }
                }
              }
            }
          }
        }
      }`, variables: "$variables",
  })
  graphqlQueryResult(result) {
    this.graphqlWoliData = result;
    const { data, errors } = result;
    if (data) {
      this.approvedTotal = 0;
      this.hasReviewLines = false;
      this.records = data.uiapi.query.WorkOrderLineItem.edges.map((edge) => {
        let z = { ...edge.node }
        z.isApproved = false;
        if (z.Status.value === 'Approved') {
          this.approvedTotal += z.Total_Approved_Amount__c.value;
          z.isApproved = true;
        } else if (z.Status.value === 'Review') {
          this.hasReviewLines = true;
          z.Status = { ...z.Status, displayValue: 'Review Receipt(s)'};
        }
        return z;
      });
      this.isLoading = false;
    } else if (errors) {
      this.errors = errors;
      this.isLoading = false;
    }
  }

  get variables() {
    return {
      recordId: this.recordId,
    };
  }

  get hasRecords() {
    return this.records && this.records.length > 0;
  }

  get approvedTotalClass() {
    return this.approvedTotal > 0 ? 'Approved' : 'Rejected';
  }

  handleRefresh() {
    refreshGraphQL(this.graphqlWoliData);
  }

  showToast(title, variant, message) {
    const toastEvent = new ShowToastEvent({
        title: title,
        variant: variant,
        message: message,
      });
      this.dispatchEvent(toastEvent);
  }

  navigateToRecord(event) {
    const recordId = event.target.dataset.recordId;
    const pageReference = {
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        objectApiName: 'WorkOrderLineItem',
        actionName: 'view'
      }
    };

    this[NavigationMixin.Navigate](pageReference);
  }
}