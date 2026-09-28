public with sharing class QCC_StringToDateTimeUtility {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:        timeInLocalStringFormat
    Description:        Return DateTime from string in format DD/MM/YYYY hh:mm:ss 
    Parameter:          String
    ----------------------------------------------------------------------------------------------*/ 
    @InvocableMethod(label='Return DateTime from String' description='Returns time in DateTime format from string format of DD/MM/YYYY hh:mm:ss')
    public static List <DateTime> timeinDateTimeFormat(List<String > stringTime){
        
       List <DateTime> localTime = new List <DateTime>();

       // Set pattern to find string with format - dd/MM/yyyy HH:mm:ss 
       Pattern dateTimePattern = Pattern.compile('(?i)(\\d{2})/(\\d{2})/(\\d{4})\\s*(\\d{2}):(\\d{2}):(\\d{2})');
        
        if (stringTime.size() > 0){
            for(String stringTimeItem : stringTime){
 
                Matcher m = dateTimePattern.matcher(stringTimeItem);
                DateTime result;

                if(m.find()) {
                    system.debug('### Day - ' + m.group(1));
                    system.debug('### Month - ' + m.group(2));
                    system.debug('### Year - ' + m.group(3));
                    system.debug('### Hours - ' + m.group(4));
                    system.debug('### Minutes - ' + m.group(5));
                    system.debug('### Seconds - ' + m.group(6));
                    result = DateTime.newInstance(
                        Integer.valueOf(m.group(3)),
                        Integer.valueOf(m.group(2)),
                        Integer.valueOf(m.group(1)),
                        Integer.valueOf(m.group(4)),
                        Integer.valueOf(m.group(5)),
                        Integer.valueOf(m.group(6))        
                    );
                }
                localTime.add( result );
            }
        }
    
        System.debug('#### timeinDateTimeFormat - date time  : '+ localTime);
     
        return localTime;
    }
    
}