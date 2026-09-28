/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Wrapper Class Simulates  QBR Request received from QCP
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
24-APR-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
global class QBRProductRegWrapper {

    public String amexProductId;
    public String enrolmentStatusCode;
    public String enrolmentStatusDescription;
    public QBRProduct qbrinfo;

    public class QBRProduct{
    	public String membershipNumber;
	    public String membershipStatus;
	    public Date membershipStartDate;
	    public Date membershipEndDate;
	    public String companyIndustry;
	    public String companyAirlineLevel;
	    public String companyGSTRegistered;
	    public String companyEntityType;
    }
}