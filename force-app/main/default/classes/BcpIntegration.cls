public with sharing class BcpIntegration implements Callable{
    public class InvalidActionCallableException extends Exception {}

    public Object call(String action, Map<String, Object> args) {
        system.debug('Print the arguments received'+args);
        switch on action {
          when 'createCase' {
            this.createCase((RestRequest)args.get('restRequest'), (RestResponse)args.get('restResponse'));
          }
          when else {
           throw new InvalidActionCallableException('Method not implemented');
          }
        }
        return null;
    }

    private void createCase(RestRequest req, RestResponse res) {
        SavePoint s = Database.setSavepoint();
        //res.responseBody = Blob.valueOf('In Create Case - ' + req.requestBody.toString());
        try {
            Map<String, Object> responseMap = new Map<String, Object>();
            Global_Properties__mdt metaRec = [select Static_Long_Values__c from Global_Properties__mdt where Label = 'BCP_CaseCreation' WITH SYSTEM_MODE limit 1];
            List<Object> fldMappings = (List<Object>)JSON.deserializeUntyped(metaRec.Static_Long_Values__c);
            Id accountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();

            Case newCase = new Case();
            String acctRef='';

            if (fldMappings == null ) {return;}
            Object payload = (Object)JSON.deserializeUntyped(req.requestBody.toString());
            for (Object fldMapping : fldMappings) {
                Map<String,Object> fldMappingEntry = (Map<String,Object>)fldMapping;
                
                Object value = String.isNotBlank((String)fldMappingEntry.get('RequestParam')) ? getAttributeValue((String)fldMappingEntry.get('RequestParam'), payload) : (String)fldMappingEntry.get('Value');
                if ((String)fldMappingEntry.get('type') == 'RecordTypeName') 
                {
                    value = Schema.SObjectType.Case.getRecordTypeInfosByName().get(String.valueOf(value)).getRecordTypeId();
                }
                value = typeCastData(value, (String)fldMappingEntry.get('type'));
                
                if (value != null) {
                    String externalObjectName = (String)fldMappingEntry.get('externalIdObject');
                    String externalObjectFldName = (String)fldMappingEntry.get('externalIdField');

                    if ( String.isNotBlank(externalObjectName) && String.isNotBlank(externalObjectFldName) ) {
                        sObject externalObject = (sObject)Type.forName(externalObjectName).newInstance();
                        externalObject.put(externalObjectFldName, value);
                        newCase.put((String)fldMappingEntry.get('FieldAPI'), externalObject);
                    } else {
                        newCase.put((String)fldMappingEntry.get('FieldAPI'), value);
                    }
                }
            }
            insert as user newcase;
            Case retCase = [select Id, CaseNumber,SuppliedCompany from Case where Id =:newCase.Id limit 1];

            if(retCase.SuppliedCompany!=null)
            {
                List<Account> relAccount =[select id from account where recordtypeid=: accountRecordTypeId and Qantas_Industry_Centre_ID__c=: retCase.SuppliedCompany limit 1];
                if(relAccount!=null && relAccount.size()>0)
                {
                    retCase.AccountId = relAccount.get(0).Id;
                } 
                
            }
            
            
            
            
            update retCase;

            List<ContentVersion> contentVersions = new List<ContentVersion>();
            system.debug('>>> blob content'+req.requestBody.toString().escapeXML());
            contentVersions.add(new ContentVersion( Title = 'QacRequestFile - ' + retCase.CaseNumber, PathOnClient = 'QacRequestFile.snote', 
            //req.requestBody.toString().escapeHTML4(); EncodingUtil.urlEncode(req.requestBody.toString(), 'UTF-8')
                                                    SharingOption = 'R', SharingPrivacy = 'P',
                                                    ReasonForChange = 'BCP Request Document', VersionData = Blob.valueOf(req.requestBody.toString().escapeXML()), IsMajorVersion = true, 
                                                    FirstPublishLocationId = newcase.Id ));
            createBackupData(payload);

            contentVersions.add( new ContentVersion( Title = 'QacBackupFile - ' + retCase.CaseNumber, PathOnClient = 'QacBackupFile.snote', 
            //req.requestBody.toString().escapeHTML4(); EncodingUtil.urlEncode(req.requestBody.toString(), 'UTF-8')
                                                    SharingOption = 'R', SharingPrivacy = 'P',
                                                    ReasonForChange = 'BCP Backup Document', VersionData = Blob.valueOf(JSON.serialize(payload).escapeXML()), IsMajorVersion = true, 
                                                    FirstPublishLocationId = newcase.Id ));
            insert contentVersions;
            
            

            responseMap.put('caseId', retCase.Id);
            responseMap.put('caseNumber', retCase.CaseNumber);
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;
        } catch(Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
            Database.rollback(s);
        }
    }
   
    /*--------------------------------------------------------------------------------------     
    Method Name:        createBackupData
    Description:        Method for Getting the attribute value from payload.  
    Parameter:          (Map<String,String>)payload
    --------------------------------------------------------------------------------------*/
    private static void createBackupData(Object payload){
        Map<String,Object> recPayload = (Map<String,Object>) payload;
        List<Object> specialRequirements = new List<Object>();
        if (recPayload.containsKey('serviceType')) recPayload.remove('serviceType');
        if (recPayload.containsKey('contactDetails')) recPayload.remove('contactDetails');

        if (recPayload.containsKey('bookingDetails')) {
            Map<String,Object> bookingDetails = (Map<String,Object>) recPayload.get('bookingDetails');
            if (bookingDetails.containsKey('flightDetails')) {
                Object flightDetails = bookingDetails.remove('flightDetails');
                bookingDetails.clear();
                bookingDetails.put('flightDetails', flightDetails);
            } else {
                recPayload.remove('bookingDetails');
            }
        }

        if (recPayload.containsKey('requestDetails')) {
            Map<String,Object> requestDetails = (Map<String,Object>) recPayload.get('requestDetails');
            if (requestDetails.containsKey('flightDetails')) {
                List<Object> flightDetails = (List<Object>) requestDetails.remove('flightDetails');
                requestDetails.clear();
                requestDetails.put('flightDetails', flightDetails);
                for (Object x : flightDetails) {
                    Map<String,Object> flightDetail = (Map<String,Object>) x;
                    if (flightDetail.containsKey('specialRequirements') && flightDetail.get('specialRequirements') != null) {
                        specialRequirements.addAll((List<Object>) flightDetail.get('specialRequirements'));
                    }
                }
            } else {
                recPayload.remove('requestDetails');
            }
        }

        for (Object x: specialRequirements) {
            Map<String,Object> specialRequirement = (Map<String,Object>) x;
            specialRequirement.remove('companionFirstName');
            specialRequirement.remove('companionMiddleName');
            specialRequirement.remove('companionSurName');
        }
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        getAttributeRec
    Description:        Method for Getting the attribute value from payload.  
    Parameter:          (String)attr, (Map<String,String>)payload
    --------------------------------------------------------------------------------------*/
    private static Object getAttributeRec(String attr, Object payload){
        if (String.isBlank(attr)) {return null;}
        system.debug(attr);
        List<String> a = attr.split('\\.');
        return getAttributeRec(a, payload);
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        getAttributeRec
    Description:        Method for Getting the attribute value from payload.  
    Parameter:          (List<String>)attr, (Map<String,String>)payload
    --------------------------------------------------------------------------------------*/
    private static Object getAttributeRec(List<String> attr, Object payload){
        if (attr == null || payload == null) {return null;}
        system.debug(attr);
        for (Integer i = 0; i<attr.size() ; i++) {
            if (payload != null) {payload = ((Map<String,Object>)payload).get(attr[i]);}
        }
        return payload;
    }

    /*--------------------------------------------------------------------------------------     
    Method Name:        getAttributeValue
    Description:        Method for Getting the attribute value from payload.  
    Parameter:          (String)attr, (Map<String,String>)payload
    --------------------------------------------------------------------------------------*/
    private static String getAttributeValue(String attr, Object payload){
        payload = getAttributeRec(attr, payload);
        return payload != null ? String.valueOf(payload) : null;
    }
    
    /*--------------------------------------------------------------------------------------     
    Method Name:        typeCastData
    Description:        Method for typecasting data as per the field type  
    Parameter:          (String)value, (String)valType
    --------------------------------------------------------------------------------------*/
    private static Object typeCastData(Object value, String valType){
        if (value == null || (value instanceOf String && String.isBlank((String)value))) {return null;}
        if (String.isBlank(valType)) {valType = 'String';}
        switch on valType.toLowerCase() {
            when 'integer' {
                return Integer.valueOf(value);
            }
            when 'decimal' {
                return Decimal.valueOf(String.valueOf(value));
            }
            when 'boolean' {
                return Boolean.valueOf(value);
            }
            when 'dategmt' {
                return Datetime.valueOfGmt((String)value).date();
            }
            when 'date' {
                return Date.valueOf((String)value);
            }
            when 'datetimegmt' {
                return Datetime.valueOfGmt((String)value);
            }
            when 'datetime' {
                return Datetime.valueOf((String)value);
            }
            when 'datejson' {
                return (Date)JSON.deserialize((String)value, Date.class);
            }
            when 'datetimejson' {
                return (Datetime)JSON.deserialize((String)value, Datetime.class);
            }
            when else {
                return value;
            }
        }
    }
      
}