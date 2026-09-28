public class QCC_FlightStatusAPIResponse{
	public List<flight> flights;
	public String lastUpdatedDateTime;	//2018-05-22T00:12:35.686Z
	public class flight {
		public List<flightNumbers> flightNumbers;
		public List<sector> sectors;
	}
	public class flightNumbers {
		public String airline;	//QF
		public Integer code;	//1
		public boolean primary;
		public String originDate;	//2018-05-22
		public String threeLetterAirline;	//QFA
		public String registrationNumber;	//VHOQD
	}
	public class sector {
		public String sectorId;	//QF1_SYD_SIN_22052018
		public String from_x;	//SYD
		public String to;	//SIN
		public departure departure;
		public arrival arrival;
		public String sectorDiversion;	//PLANNED
	}
	public class departure {
		public String estimated;	//2018-05-22T15:55:00+10:00
		public String actual;	//
		public String scheduled;	//2018-05-22T15:55:00+10:00
		public String status;	//Estimated
		public String terminal;	//T1
		public String gate;	//8
		public String boardingStatus;	//
		public boolean eligibleForSubscription;
	}
	public class arrival {
		public String estimated;	//2018-05-22T22:15:00+08:00
		public String actual;	//
		public String scheduled;	//2018-05-22T22:15:00+08:00
		public String status;	//Estimated
		public String terminal;	//
		public String gate;	//
		public boolean eligibleForSubscription;
	}
	public static QCC_FlightStatusAPIResponse parse(String json){
		return (QCC_FlightStatusAPIResponse) System.JSON.deserialize(json, QCC_FlightStatusAPIResponse.class);
	}
}