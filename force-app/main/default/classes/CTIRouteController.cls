/*----------------------------------------------------------------------------------------------------------------------
    Author:        Ram Kolli
    Company:       TCS
    Description:   CTI-Salesforce contact routing. CTI sends a FF Number to Salesforce. We will route navigation to 
					related contact record. Ex. URL https://qantas.lightning.force.com/c/CTIRoutingApp.app?FFNumber=4179767
    Test Class:     CTIRouteControllerTest
	Date 	: 	   16-Mar-2021
-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class CTIRouteController {
    @AuraEnabled
    public static List<contact> getContact(string ffnumber){
            return [SELECT ID FROM CONTACT WHERE Frequent_Flyer_Number__c=:ffnumber];
    }
}