/*----------------------------------------------------------------------------------------------------------------------
Author:        Ajay
Company:       TCS
Description:   RestAPI Business Logic Class - QAC_AccountServicesProcess's test class
Test Class:    QAC_AccountServicesProcess_Test     
*********************************************************************************************************************************
History
10-Dec-2017    Ajay               Initial Design
********************************************************************************************************************************/
@isTest
public class QAC_AccountServicesProcess_Test{
    
    public static String[] getJSONStrings(){
        String[] myJson = new String[]{};
            
        String blankiataCodeJson = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"\",'+
        '         \"tidsCode\":\"\",'+
        '         \"agencyABN\":\"10001000100\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"state\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\"'+
        '        }'+
        '    }'+
        '}';

        String correctJson = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"3000000\",'+
        '         \"tidsCode\":\"\",'+
        '         \"agencyABN\":\"30003000300\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"stateCode\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+ 
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\",'+
        '            \"contactDetails\":[  '+
        '                {  '+
        '                    \"referenceID\":\"CON0000001\",'+
        '                    \"salutation\":\"Ms\",'+
        '                    \"firstName\":\"Caley\",'+
        '                    \"lastName\":\"Britto\",'+
        '                    \"preferredName\":\"caleyB\",'+
        '                    \"jobTitle\":\"Developer\",'+
        '                    \"jobFunction\":\"IT\",'+
        '                    \"frequentFlyerNumber\":\"JetAirways0456\",'+
        '                    \"jobRole\":\"Board member\",'+
        '                    \"email\":\"sample1@salesforce.com\",'+
        '                    \"phone\":\"+61-02-12345678\",'+
        '                    \"mobile\":\"+61-02-11222666\"'+
        '                },'+
        '                {  '+
        '                    \"referenceID\":\"CON0000002\",'+
        '                    \"salutation\":\"Mr\",'+
        '                    \"firstName\":\"John\",'+
        '                    \"lastName\":\"Smith\",'+
        '                    \"preferredName\":\"JohnnyS\",'+
        '                    \"jobTitle\":\"Executive\",'+
        '                    \"jobFunction\":\"HR\",'+
        '                    \"frequentFlyerNumber\":\"JetAirway10456\",'+
        '                    \"jobRole\":\"Director\",'+
        '                    \"email\":\"sample2@salesforce.com\",'+
        '                    \"phone\":\"+61-02-12346678\",'+
        '                    \"mobile\":\"+61-02-11222333\"'+
        '                }'+
        '            ],'+
        '            \"tmcDetails\":[  '+
        '                {  '+
        '                    \"referenceId\":\"TMC0000001\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Amadeus\",'+
        '                    \"pseudoCityCode\":\"2yu4\"'+
        '                },'+
        '                {  '+
        '                    \"referenceId\":\"TMC0000002\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Galileo\",'+
        '                    \"pseudoCityCode\":\"12mt\"'+
        '                }'+
        '            ],'+
        '            \"ticketingAuthorityDetails\":[  '+
        '                {  '+
        '                    \"iataCode\":\"2000000\",'+
        '                    \"iataName\":\"Qantas my Test 2\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1000000\",'+
        '                    \"iataName\":\"Qantas my Test 1\"'+
        '               },'+
        '                {  '+
        '                    \"iataCode\":\"1114702\",'+
        '                    \"iataName\":\"Qantas Test 1c\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1114703\",'+
        '                    \"iataName\":\"Qantas Test 1d\"'+
        '               }               '+
        '            ]          '+
        '        }'+
        '    }'+
        '}';

        String DupJsonforAccount = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"1000000\",'+
        '         \"tidsCode\":\"\",'+
        '         \"agencyABN\":\"10001000100\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"stateCode\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\"'+
        '        }'+
        '    }'+
        '}';

        String excepWithJson = '';
        
        String excepWithNull = null;

        String excepWithOther = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"1234599\",'+
        '         \"tidsCode\":\"1114000\",'+
        '         \"agencyABN\":\"84003237100\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"stateCode\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\",'+
        '            \"contactDetails\":[  '+
        '                {  '+
        '                    \"referenceID\":\"CON0000001\",'+
        '                    \"salutation\":\"Ms\",'+
        '                    \"firstName\":\"Caley\",'+
        '                    \"lastName\":\"\",'+
        '                    \"preferredName\":\"caleyB\",'+
        '                    \"jobTitle\":\"Developer\",'+
        '                    \"jobFunction\":\"IT\",'+
        '                    \"frequentFlyerNumber\":\"JetAirways0456\",'+
        '                    \"jobRole\":\"Board member\",'+
        '                    \"email\":\"sample1@salesforce.com\",'+
        '                    \"phone\":\"+61-02-12345678\",'+
        '                    \"mobile\":\"+61-02-11222666\"'+
        '                },'+
        '                {  '+
        '                    \"referenceID\":\"CON0000002\",'+
        '                    \"salutation\":\"Mr\",'+
        '                    \"firstName\":\"John\",'+
        '                    \"lastName\":\"Smith\",'+
        '                    \"preferredName\":\"JohnnyS\",'+
        '                    \"jobTitle\":\"Executive\",'+
        '                    \"jobFunction\":\"HR\",'+
        '                    \"frequentFlyerNumber\":\"JetAirway10456\",'+
        '                    \"jobRole\":\"Director\",'+
        '                    \"email\":\"sample2@salesforce.com\",'+
        '                    \"phone\":\"+61-02-12346678\",'+
        '                    \"mobile\":\"+61-02-11222333\"'+
        '                }'+
        '            ],'+
        '            \"tmcDetails\":[  '+
        '                {  '+
        '                    \"referenceId\":\"TMC0000001\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Amadeus\",'+
        '                    \"pseudoCityCode\":\"2yu4\"'+
        '                },'+
        '                {  '+
        '                    \"referenceId\":\"TMC0000002\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Galileo\",'+
        '                    \"pseudoCityCode\":\"12mt\"'+
        '                }'+
        '            ],'+
        '            \"ticketingAuthorityDetails\":[  '+
        '                {  '+
        '                    \"iataCode\":\"2000000\",'+
        '                    \"iataName\":\"Qantas my Test 2\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1000000\",'+
        '                    \"iataName\":\"Qantas my Test 1\"'+
        '               },'+
        '                {  '+
        '                    \"iataCode\":\"1114702\",'+
        '                    \"iataName\":\"Qantas Test 1c\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1114703\",'+
        '                    \"iataName\":\"Qantas Test 1d\"'+
        '               }               '+
        '            ]          '+
        '        }'+
        '    }'+
        '}';


        String inCorrectJson1 = '{  '+
        '    \"agencyRegistration\":null  '+
        '}';

        String inCorrectJson2 = '{  '+
        '    \"agencyRegistration\":{  '+
        '    }'+
        '}';

        String inCorrectJson3 = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"1234567\",'+
        '         \"tidsCode\":\"\",'+
        '         \"agencyABN\":\"84003237121\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"stateCode\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\",'+
        '            \"tmcDetails\":[  '+
        '                {  '+
        '                    \"referenceId\":\"TMC0000001\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Amadeus\",'+
        '                    \"pseudoCityCode\":\"2yu4\"'+
        '                },'+
        '                {  '+
        '                    \"referenceId\":\"TMC0000002\",'+
        '                    \"recordType\":\"GDS\",'+
        '                    \"gdsCode\":\"Galileo\",'+
        '                    \"pseudoCityCode\":\"12mt\"'+
        '                }'+
        '            ],'+
        '            \"ticketingAuthorityDetails\":[  '+
        '                {  '+
        '                    \"iataCode\":\"2000000\",'+
        '                    \"iataName\":\"Qantas my Test 2\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1000000\",'+
        '                    \"iataName\":\"Qantas my Test 1\"'+
        '               },'+
        '                {  '+
        '                    \"iataCode\":\"1114702\",'+
        '                    \"iataName\":\"Qantas Test 1c\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1114703\",'+
        '                    \"iataName\":\"Qantas Test 1d\"'+
        '               }               '+
        '            ]          '+
        '        }'+
        '    }'+
        '}';

        String inCorrectJson4 = '{  '+
        '    \"agencyRegistration\":{  '+
        '        \"accountDetail\":{  '+
        '         \"referenceID\":\"ACC0000001\",'+
        '         \"agencyName\":\"X Account Test 1\",'+
        '         \"legalName\":\"Flight Centre Travel Group Limited \",'+
        '         \"agencyChain\":\"Flight Centre Retail North\",'+
        '         \"agencySubChain\":\"Flight Centre Brand\",'+
        '         \"iataCode\":\"1234567\",'+
        '         \"tidsCode\":\"\",'+
        '         \"agencyABN\":\"84003237121\",'+
        '         \"qbrMembershipNumber\":\"11221122\",'+
        '         \"businessType\":\"Agency Prospect\",'+
        '         \"agencyAddressLine1\":\"abcd Street\",'+
        '         \"city\":\"Sydney\",'+
        '         \"stateCode\":\"NSW\",'+
        '         \"countryCode\":\"AU\",'+
        '         \"postalCode\":\"2135\",'+
        '         \"atolNumber\":\"\",'+
        '         \"abtaNumber\":\"\",'+
        '         \"bookingEngineAccess\":\"True\",'+
        '         \"dialCode\":\"+61\",'+
        '         \"phoneNumber\":\"-02-00500000\",'+
        '         \"faxNumber\":\"+61-02-00500001\",'+
        '         \"employees\":\"5000\",'+
        '         \"officeType\":\"Qantas Office\",'+
        '         \"website\":\"somesite.com\",'+
        '         \"accountEmail\":\"test@example.com\",'+
        '            \"contactDetails\":[  '+
        '                {  '+
        '                    \"referenceId\":\"CON0000001\",'+
        '                    \"salutation\":\"Ms\",'+
        '                    \"firstName\":\"Caley\",'+
        '                    \"lastName\":\"Britto\",'+
        '                    \"preferredName\":\"caleyB\",'+
        '                    \"jobTitle\":\"Developer\",'+
        '                    \"jobFunction\":\"IT\",'+
        '                    \"frequentFlyerNumber\":\"JetAirways0457\",'+
        '                    \"jobRole\":\"Board member\",'+
        '                    \"email\":\"sample1@salesforce.com\",'+
        '                    \"phone\":\"+61-(02)-12345678\",'+
        '                    \"mobile\":\"0111222666\"'+
        '                },'+
        '                {  '+
        '                    \"referenceId\":\"CON0000002\",'+
        '                    \"salutation\":\"Mr\",'+
        '                    \"firstName\":\"John\",'+
        '                    \"lastName\":\"Smith\",'+
        '                    \"preferredName\":\"JohnnyS\",'+
        '                    \"jobTitle\":\"Executive\",'+
        '                    \"jobFunction\":\"HR\",'+
        '                    \"frequentFlyerNumber\":\"JetAirway10457\",'+
        '                    \"jobRole\":\"Director\",'+
        '                    \"email\":\"sample2@salesforce.com\",'+
        '                    \"phone\":\"+61-(02)-12346678\",'+
        '                    \"mobile\":\"0111222333\"'+
        '                }'+
        '            ],'+
        '            \"ticketingAuthorityDetails\":[  '+
        '                {  '+
        '                    \"iataCode\":\"2000000\",'+
        '                    \"iataName\":\"Qantas my Test 2\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1000000\",'+
        '                    \"iataName\":\"Qantas my Test 1\"'+
        '               },'+
        '                {  '+
        '                    \"iataCode\":\"1114702\",'+
        '                    \"iataName\":\"Qantas Test 1c\"'+
        '                },'+
        '                {  '+
        '                    \"iataCode\":\"1114703\",'+
        '                    \"iataName\":\"Qantas Test 1d\"'+
        '               }               '+
        '            ]          '+
        '        }'+
        '    }'+
        '}';
        

        myJson.add(blankiataCodeJson);    //0th
        myJson.add(correctJson);          //1st
        myJson.add(DupJsonforAccount);    //2nd
        myJson.add(excepWithJson);        //3rd
        myJson.add(excepWithOther);       //4th
        myJson.add(inCorrectJson1);       //5th
        myJson.add(inCorrectJson2);       //6th
        myJson.add(inCorrectJson3);       //7th
        myJson.add(inCorrectJson4);       //8th

        return myJson;
    }
    
    @testSetup
    static void setup() {
    
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContentdocumentLinkTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();

        system.debug('inside test setup**');
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;

        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;

        Sales_Region__c sr1 = new Sales_Region__c(Name='Flight Centre Retail North',sales_h_eq_type__c='Industry',sales_h_start_date__c=Date.today());
        insert sr1;
        system.debug('sr act**'+sr1.active__c+' **date'+sr1.sales_h_end_date__c);       

        // Create All test accounts
        Account accWabnWqic = new Account(Name='Qantas my Test 1',Active__c = true,Type = 'Agency Account',RecordTypeId = accRTId,
                                     ABN_Tax_Reference__c = '10001001000',IATA_Number__c = '1000000');
        insert accWabnWqic;
        Account accWabnWqic2 = new Account(Name='Qantas my Test 2',Active__c = true,Type = 'Agency Account',RecordTypeId = accRTId,
                                     ABN_Tax_Reference__c = '20002002000',IATA_Number__c = '2000000');
        insert accWabnWqic2;

        Contact testcon1 = new Contact(FirstName='Bob',LastName='Test',AccountId=accWabnWqic.id,Function__c = 'IT',
                                      Business_Types__c = 'Agency',Email = 'sample1@salesforce.com',Frequent_Flyer_Number__c='JetAirways1456',MobilePhone='+61100000000');
        Contact testcon2 = new Contact(FirstName='Bob',LastName='Smith',AccountId=accWabnWqic.id,Function__c = 'IT',
                                      Business_Types__c = 'Agency',Email = 'sample2@salesforce.com',Frequent_Flyer_Number__c='JetAirways2456',MobilePhone='+61200000000');
        Contact testcon3 = new Contact(FirstName='Bob',LastName='Britto',AccountId=accWabnWqic.id,Function__c = 'IT',
                                      Business_Types__c = 'Agency',Email = 'sample3@salesforce.com',Frequent_Flyer_Number__c='JetAirways3456',MobilePhone='+61300000000');
        insert testcon1;
        insert testcon2;
        insert testcon3;
    }

    @isTest
    static void testwithCorrectJSON(){
        
        //QAC_AccountServicesAPI myApi = QAC_AccountServicesAPI_Test.testParse();
        
        String myCorrectJson = QAC_AccountServicesProcess_Test.getJSONStrings()[1];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myCorrectJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }
    
    @isTest
    static void testwithBlankIataCodeJSON(){
        
        String myBlankIataCodeJson = QAC_AccountServicesProcess_Test.getJSONStrings()[0];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myBlankIataCodeJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);
        
        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    @isTest
    static void testwithDupJSON(){
        
        String myDupJson = QAC_AccountServicesProcess_Test.getJSONStrings()[2];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myDupJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    @isTest
    static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            String myExcepJson = QAC_AccountServicesProcess_Test.getJSONStrings()[3];
            QAC_AccountServicesProcess_Test.restLogic(null,myExcepJson);
            
            Test.startTest();
                QAC_AccountServicesProcess.doAgencyRegistrationProcess();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }

    }

    @isTest
    static void testwithExcepOther()
    {
        try{
            system.debug('Inside Other Excep');
            
            String myExcepOther = QAC_AccountServicesProcess_Test.getJSONStrings()[4];
            QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myExcepOther);
            QAC_AccountServicesProcess_Test.restLogic(myApi,null);
                    
            Test.startTest();
                QAC_AccountServicesProcess.doAgencyRegistrationProcess();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test 2'+myException.getTypeName());
        }

    }


    @isTest
    static void testIncorrectJSON1(){
        
        String myIncorrectJson = QAC_AccountServicesProcess_Test.getJSONStrings()[5];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myIncorrectJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    @isTest
    static void testIncorrectJSON2(){
        
        String myIncorrectJson = QAC_AccountServicesProcess_Test.getJSONStrings()[6];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myIncorrectJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    @isTest
    static void testIncorrectJSON3(){
        
        String myIncorrectJson = QAC_AccountServicesProcess_Test.getJSONStrings()[7];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myIncorrectJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    @isTest
    static void testIncorrectJSON4(){
        
        String myIncorrectJson = QAC_AccountServicesProcess_Test.getJSONStrings()[8];
        QAC_AccountServicesAPI myApi = QAC_AccountServicesProcess_Test.parsingJSON(myIncorrectJson);
        QAC_AccountServicesProcess_Test.restLogic(myApi,null);

        Test.startTest();
            QAC_AccountServicesProcess.doAgencyRegistrationProcess();
        Test.stopTest();
    }

    public static QAC_AccountServicesAPI parsingJSON(String theJson){
        QAC_AccountServicesAPI obj = QAC_AccountServicesAPI.parse(theJson);
        system.debug('obj value**'+obj);
        return obj;
    }
    
    public static void restLogic(QAC_AccountServicesAPI theApi, String theExcepJson){
        RestRequest myReq = new RestRequest();
        RestResponse myRes = new RestResponse();

        myReq.requestURI = '/services/apexrest/QACAcctServices/';
        myReq.httpMethod = 'POST';
        myReq.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //myReq.requestBody = Blob.valueOf(JSON.serializePretty(theApi));
        
        RestContext.request = myReq;
        RestContext.response = myRes;
    }

}