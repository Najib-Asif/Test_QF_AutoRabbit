({   doInit : function(component, event, helper) {
    	//var url = $A.get('$Resource.RecoveryChartBackGroundImage');
        //component.set('v.backgroundImageURL', url);
    	helper.getMemberList(component,helper,event);
        helper.getReccoveryTypeList(component,helper,event);
    	//helper.getChart(component, event, helper); 
        helper.getAverageMonetaryValue(component,helper,event);
    	helper.getMemberDataFilterByStatus(component,event,helper);
        helper.getAveragevalue(component,helper,event);
        helper.getAverageQuantity(component,helper,event); 
    	helper.getAverageGoodwillMonetaryValue(component,helper,event);         	
        //helper.numberOfDays(component,helper,event);
	},
    setup : function(component, event, helper) {              
        helper.getChart(component, event, helper);     
        helper.getPieChart(component, event, helper);     
    },
  navigateToRecord : function(component, event, helper){
  		var target = event.target;
        var selectedItem = event.currentTarget;
          var recId = selectedItem.dataset.record;
      console.log('recId id:::::'+recId);
			var recordId = target.getAttribute("data-attribute");
			console.log('Record id:::::'+recordId);
			var urlEvent = $A.get("e.force:navigateToURL");
      		var urlValue  = String($A.get("$Label.c.Recovery_base_URL"));
       			//urlValue =  urlValue+recordId+'/view';
       			//https://qantas--lightning.lightning.force.com/lightning/r/Recovery__c/a1o0k000001UZRFAA4/viewa1o0k000001UZRFAA4/view/
      //https://qantas--lightning.lightning.force.com/lightning/r/Recovery__c/		
      console.log('Record id::::22554:'+urlValue);
console.log('Record id::::2255899:'+urlValue);       
			urlEvent.setParams({
			"url": urlValue+recordId+'/view'
            });
      console.log('Record id::::225588:'+urlValue); 
			urlEvent.fire();
     },
    
     getTeamMemberData : function(component,event, helper){
        
        helper.getChart(component,event,helper); 
        helper.getAveragevalue(component,event,helper);
        helper.getAverageMonetaryValue(component,event,helper);
        helper.getAverageQuantity(component,event,helper);
         
         
          
    },
   getRecoveryTypeData : function(component,event, helper){
        
        helper.getPieChart(component,event,helper); 
        helper.getAveragevalue(component,event,helper);
        helper.getAverageMonetaryValue(component,event,helper);
        helper.getAverageQuantity(component,event,helper);                            
    },
    
   searchSelectedDateDate : function(component,event,helper){
        var FromDate = component.find("Fromdate").get("v.value"); 
        console.log('FromDate',FromDate);
        
        var ToDate = component.find("Todate").get("v.value"); 
        console.log('ToDate',ToDate);
       helper.SearchDatarange(component,event,helper,FromDate,ToDate);
       helper.getAveragevalueByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageMonetaryValueByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageQuantityByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageGoodwillMonetaryValueDate(component,event,helper,FromDate,ToDate);
       
   }, 
  
   searchSelectedDateDateType : function(component,event,helper){
        var FromDate = component.find("TypeFromdate").get("v.value"); 
        console.log('FromDate',FromDate);
        
        var ToDate = component.find("TypeTodate").get("v.value"); 
        console.log('ToDate',ToDate);
       helper.SearchTypeDatarange(component,event,helper,FromDate,ToDate);
      /* helper.getAveragevalueByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageMonetaryValueByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageQuantityByDate(component,event,helper,FromDate,ToDate);
       helper.getAverageGoodwillMonetaryValueDate(component,event,helper,FromDate,ToDate);*/
       
   }, 
  getMemberDataFilter : function(component,event,helper){
      helper.getMemberDataFilterByStatus(component,event,helper);
  },
  
  /* Component controller */

 downloadDocument : function(component, event, helper){

     console.log('starting');
  var sendDataProc = component.get("v.sendData");
     console.log('start 2');
  var dataToSend = {
       "label" : "This is test"
   //"AverageQuantity" : component.get("v.AverageQuantity")
  }; //this is data you want to send for PDF generation
  console.log('start 2');
  //invoke vf page js method
  sendDataProc(component.get("v.AverageQuantity"), function(){
              //handle callback
  });
 },
  
   downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.recoveries");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
  
  hideaverage : function(component,event,helper){
      helper.showHideHelper('BodyAverageInfo');
  },
  
  hidegraph : function(component,event,helper){
      helper.showHideHelper('BodyGraph');
  },
  
  hidedata : function(component,event,helper){
      helper.showHideHelper('BodyData');
  },
})