/***********************************************************************************************************************************

Description: Lightning component handler for the account snapshot search 

History:
======================================================================================================================
Name                    Jira        Description                                                 Tag
======================================================================================================================
Karpagam               CRM-3132   LEx-AccountSnapshot                T01

Created Date    : 25/05/18 (DD/MM/YYYY)

**********************************************************************************************************************************/
public  class QL_searchController{
    @AuraEnabled 
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val, String fld_API_Val1,String fld_API_Val2,String fld_API_Val3,String fld_API_Val4,String fld_API_Val5,String fld_API_Val6,String fld_API_Val7,String fld_API_Val8,String fld_API_Val9,String fld_API_Val10,String fld_API_Val11,String fld_API_Val12,String fld_API_Val13,String fld_API_Val14,String fld_API_Val15,String fld_API_Val16,
                                  Integer lim,String fld_API_Search,String searchText ){
                                      
                                      searchText='\'' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                      fld_API_Val9= '\'' +String.escapeSingleQuotes(fld_API_Val9.trim()) + '\'' ;
                                      String qryText ='Person Account';
                                      String selectFld = fld_API_Val + ','+fld_API_Val1 + ','+fld_API_Val2 + ','+fld_API_Val3+ ','+fld_API_Val4+ ','+fld_API_Val5+ ','+fld_API_Val6+ ','+fld_API_Val7+ ','+fld_API_Val8+ ','+fld_API_Val10+',Owner.Name' +','+fld_API_Val11+','+fld_API_Val12+','+fld_API_Val13+','+fld_API_Val14+','+fld_API_Val15+','+fld_API_Val16;
                                      
                                      String query = 'SELECT '+fld_API_Text+','+selectFld+
                                          ' FROM '+objectName+
                                          ' WHERE '+fld_API_Search+' LIKE '+searchText+ ' AND '  +  fld_API_val8+' = '+ fld_API_Val9+                          
                                          ' LIMIT '+lim;
                                      system.debug('query ************'+query );
                                      List<Account> sobjList = Database.query(query);
                                      System.debug('sobjList'+sobjList);
                                      List<ResultWrapper> lstRet = new List<ResultWrapper>();
                                      ID profID = userinfo.getProfileId();
                                      for(Account s : sobjList){
                                          //System.debug('OwnerName');
                                          System.debug('OwnerName'+s.Owner.Name);
                                          ResultWrapper obj = new ResultWrapper();
                                          ObjectDetails obj2 = new ObjectDetails();
                                          obj.objName = objectName;
                                          obj.text = String.valueOf(s.get(fld_API_Text)) ;
                                          obj.val = String.valueOf(s.get(fld_API_Val))  ;
                                          system.debug('fld_API_Val1*********'+fld_API_Val1);
                                          obj2.val1 = String.valueOf(s.get(fld_API_Val1))  ;
                                          system.debug(' obj2.val1**********'+ obj2.val1);
                                          obj2.val2 = String.valueOf(s.get(fld_API_Val2))  ;
                                          obj2.val3 = String.valueOf(s.get(fld_API_Val3))  ;
                                          obj2.val4 = String.valueOf(s.get(fld_API_Val4))  ;
                                          obj2.val5 = String.valueOf(s.get(fld_API_Val5))  ;
                                          obj2.val6 = String.valueOf(s.get(fld_API_Val6))  ;
                                          obj2.val7 = String.valueOf(s.get(fld_API_Val7))  ;
                                          obj2.val8 = String.valueOf(s.get(fld_API_Val8))  ;
                                          //obj2.val9 = String.valueOf(s.get(fld_API_Val9))  ;
                                          obj2.val10 = String.valueOf(s.get(fld_API_Val10))  ;
                                          obj2.name = String.valueOf(s.get(fld_API_Text));
                                          system.debug(' obj2.val6**********'+ obj2.val6);
                                          obj2.val11 = date.valueof(s.get(fld_API_Val11)); 
                                          obj2.val12 = date.valueof(s.get(fld_API_Val12))  ;
                                          obj2.val13 = String.valueOf(s.get(fld_API_Val13))  ;
                                          obj2.val14 = String.valueOf(s.get(fld_API_Val14))  ;
                                          obj2.val15 = String.valueOf(s.get(fld_API_Val15))  ;
                                          obj2.val16 = String.valueOf(s.get(fld_API_Val16))  ;                                        
                                          
                                          obj2.AccOwner = s.Owner.Name;
                                          
                                          obj.objDet = obj2;
                                          obj.objStrConv = JSON.serialize(obj2);
                                          // obj.objDet = new 
                                          lstRet.add(obj);
                                          
                                      }
                                      System.debug('######lstRet'+lstRet);
                                      if(profID != System.Label.QL_External_Profile)
                                      return JSON.serialize(lstRet) ;
                                      else
                                      return null;
                                  }
    
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
        
        public ObjectDetails objDet;
        public String  objStrConv;
    }
    
    public class ObjectDetails{
        public string name;
        public string AccOwner;
        public String val1{get;set;}
        public String val2{get;set;}
        public String val3{get;set;}
        public String val4{get;set;}
        public String val5{get;set;}
        public String val6{get;set;}
        public String val7{get;set;}
        public String val8{get;set;}
        public String val9{get;set;}
        public String val10{get;set;}
        public Date val11{get;set;}
        public Date val12{get;set;}
        public String val13{get;set;}
        public String val14{get;set;}
        public String val15{get;set;}
        public String val16{get;set;}
        
        
    }
    
}