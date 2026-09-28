public with sharing class QCC_TimeUtility {


/*----------------------------------------------------------------------------------------------
   Method Name:        timeInLocalStringFormat
   Description:        Return local time version of paratmer in utc time.
   Parameter:          String
   ----------------------------------------------------------------------------------------------*/
	@InvocableMethod(label='Return Local Time as String' description='Returns local time in string format')
	public static List <String> timeInLocalStringFormat(List<DateTime> utcTime){

		List <string> localTime = new List <string>();

		if (utcTime.size() > 0) {
			for(DateTime utcTimeItem : utcTime) {
				localTime.add( utcTimeItem.format('dd/MM/yyyy HH:mm:ss') );
			}
		}
		else {
			localTime.add( '' );
		}

		System.debug('#### Local time  : '+ localTime);

		return localTime;
	}


/*----------------------------------------------------------------------------------------------
   Method Name:        dateReformat
   Description:        Return local date based on date time in string format.
   Parameter:          String
   ----------------------------------------------------------------------------------------------*/
	public DateTime dateReformated;
	public String dateString {get; set;}

	public Void setDateTimeValue(String dateString){
		this.dateString = dateString;
		System.debug('#### setDateTimeValue - date time  : '+ this.dateString);
	}

	public DateTime getDateTimeValue(){

		// Set pattern to find string with format - dd/MM/yyyy HH:mm:ss
		Pattern dateTimePattern = Pattern.compile('(?i)(\\d{2})/(\\d{2})/(\\d{4})\\s*(\\d{2}):(\\d{2}):(\\d{2})');


		Matcher m = dateTimePattern.matcher(dateString);
		DateTime result;

		if(m.find()) {
			system.debug('### Day - ' + m.group(1));
			system.debug('### Month - ' + m.group(2));
			system.debug('### Year - ' + m.group(3));
			system.debug('### Hours - ' + m.group(4));
			system.debug('### Minutes - ' + m.group(5));
			system.debug('### Seconds - ' + m.group(6));
			result = DateTime.newInstanceGmt(
				Integer.valueOf(m.group(3)),
				Integer.valueOf(m.group(2)),
				Integer.valueOf(m.group(1)),
				Integer.valueOf(m.group(4)),
				Integer.valueOf(m.group(5)),
				Integer.valueOf(m.group(6))
				);
			dateReformated = result;
		}

		System.debug('#### setDateTimeValue - date time  : '+ dateReformated);

		return dateReformated;
	}

}