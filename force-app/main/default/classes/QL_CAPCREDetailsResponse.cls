public class QL_CAPCREDetailsResponse {
  public class Others {
    public String companyName;
    public String comments;
  }

  public class Email {
    public String typeCode;
    public String emailId;
  }

  public class Response {
    public List<Customers> customers;
    public String totalMatchedRecords;
    public String nextPageNumber;
  }

  public class Address {
    public String typeCode;
    public String line1;
    public String line2;
    public String line3;
    public String line4;
    public String suburb;
    public String postCode;
    public String state;
    public String country;
    public String countryName;
  }

  public class Customer {
    public String qantasUniqueId;
    public String customerMatchScore;
    public Name name;
    public List<LoyaltyDetails> loyaltyDetails;
    public List<Address> address;
    public List<Phone> phone;
    public List<Email> email;
   // public List<TravelDoc> travelDoc;
    public Others others;
  }

  public class Customers {
    public Customer customer;
  }

  public class Phone {
    public String typeCode;
    public String phoneCountryCode;
    public String phoneAreaCode;
    public String phoneLineNumber;
    public String phoneExtension;
  }

  public class LoyaltyDetails {
    public String schemeOperatorCode;
    public String loyaltyId;
    public String airlineTierCode;
    public String startDate;
  }

 /* public class TravelDoc {
    public String typeCode;
    public String id;
    public String issueCountry;
  }*/

  public class Name {
    public String firstName;
    public String middleName;
    public String lastName;
    public String prefix;
    public String salutation;
    public String birthDate;
    public String genderCode;
  }
}