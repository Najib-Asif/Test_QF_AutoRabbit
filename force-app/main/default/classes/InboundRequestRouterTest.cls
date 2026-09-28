@isTest
public with sharing class InboundRequestRouterTest {
    
    @isTest
    public static void testHandlePost(){
        System.RestRequest newReq=new System.RestRequest();
        newReq.httpMethod='POST';
        newReq.requestBody=Blob.valueOf('Test');
        newReq.requestURI='/services/apexrest/customapi/v1/createcase';
        RestContext.request = newReq;
        RestContext.response = new System.RestResponse();
        try {
            InboundRequestRouter.handlePost();
        } catch (Exception e) {

        }
    }

    @isTest
    public static void testHandleGet(){
        System.RestRequest newReq=new System.RestRequest();
        newReq.httpMethod='Get';
        newReq.requestBody=Blob.valueOf('Test');
        newReq.requestURI='/services/apexrest/customapi/Qantas/v1/createcase';
        RestContext.request = newReq;
        RestContext.response = new System.RestResponse();
        try {
            InboundRequestRouter.handleGet();
        } catch (Exception e) {

        }
    }

    @isTest
    public static void testHandlePut(){
        try {
            InboundRequestRouter.handlePut();
        } catch (Exception e) {

        }
    }

    @isTest
    public static void testHandlePatch(){
        try {
            InboundRequestRouter.handlePatch();
        } catch (Exception e) {

        }
    }

    @isTest
    public static void testHandleDelete(){
        try {
            InboundRequestRouter.handleDelete();
        } catch (Exception e) {

        }
    }

    @isTest
    public static void testProcessRequest() {
        System.RestRequest newReq=new System.RestRequest();
        newReq.httpMethod='POST';
        newReq.requestBody=Blob.valueOf('Test');
        newReq.requestURI='/services/apexrest/customapi/Qantas/v1/createcase';
        RestContext.request = newReq;
        RestContext.response = new System.RestResponse();
        try {
            InboundRequestRouter.handlePost();
        } catch (Exception e) {

        }
    }
}