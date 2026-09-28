public class QLCalendarViewController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCalendarRecords(
        String objectApiName,
        List<String> fields,
        String startDateField,
        String endDateField,
        Map<String, Object> filters,
        Date startDate,
        Date endDate
    ) {       
        String soql =
                'SELECT ' + String.join(fields, ',') +
                ' FROM ' + objectApiName +
                ' WHERE ' + startDateField + ' <= :endDate'+
                ' AND '+endDateField + ' >= :startDate'+
            	' AND '+startDateField + ' != null AND '+endDateField+ ' != null';
            // Add optional filters
		if (filters != null && !filters.isEmpty()) {
            for (String fieldName : filters.keySet()) {
                Object value = filters.get(fieldName);
                soql += ' AND ' + fieldName + ' = \'' + String.escapeSingleQuotes((String)value) + '\'';
            }
    	}

        List<SObject> records = Database.query(soql);
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (SObject rec : records) {
            Map<String, Object> row = new Map<String, Object>();
    
            for (String field : fields) {
                Object val = rec.get(field);
    
                // Convert DateTime fields to user timezone string
                if (val instanceof Datetime) {
                    Datetime dt = (Datetime) val;
                    row.put(field, dt.format('yyyy-MM-dd'));
                } else {
                    row.put(field, val);
                }
            }
    
            result.add(row);
        }
        System.debug('records---'+records);
        return result;
    }

}