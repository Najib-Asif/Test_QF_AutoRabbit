({
    //method to fetch the campaign records from apex controller
    getCampaigns : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.populateDateAndCampaigns");
        action.setParams({  
            "paramDate" : component.get("v.Month"),
            "view" : component.get("v.view"),
            "startDate" : component.get("v.StartDate"),
            "endDate" : component.get("v.EndDate"),
            "recordtypeName" : component.get("v.CampaignRecordType"),
            "recordToDisply" : component.get("v.recordToDisply"),
            "pageNumber" : component.get("v.page"),
            "recordView" : component.get("v.value"),
            "ownerId" : $A.get("$SObjectType.CurrentUser.Id"),
            "userIds" : component.get("v.userIds"),
            "typeofcampaigns" : component.get("v.TypeofcampaingsArraytemp"),
            "region" : component.get("v.RegionofcampaingsArraytemp") });
        
        action.setCallback(this, function(response) {
            component.set("v.Spinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var cmpTarget = component.find('Parentcmp');
                $A.util.removeClass(cmpTarget, 'HeightBlank');
                if(component.get("v.view") == "monthlyview"){
                    component.set("v.Campaigns",result[0].campaignsToShow);
                    component.set("v.SplitDates",result);
                    component.set("v.page",result[0].page);
                    component.set("v.total",result[0].total);
                    component.set("v.pages", Math.ceil(result[0].total / component.get("v.recordToDisply")));
                }
                else if(component.get("v.view") == "yearlyview"){
                    var values = {leftBtvalue: 'Go to the previous Year', 
                                  rightBtvalue: 'Go to the next Year', 
                                  currentBtvalue:'This FY',options:'yearlyview'};
                    component.set("v.buttonobj",values);
                    component.set("v.page",result[0].page);
                    component.set("v.total",result[0].total);
                    component.set("v.pages", Math.ceil(result[0].total / component.get("v.recordToDisply")));
                    var campyear = result[0].campaignsToShow;
                    var CampStartEnd = [];
                    
                    for(let i=0; i<campyear.length; i++)
                    {
                        var CampaignsStartEnd = {Id:'', Name:'', StartMonth : '',StartYear:'',EndMonth:'',EndYear:'',Status:'',Type:'',Region__c:''};
                        var dateStart = new Date(campyear[i].StartDate);
                        CampaignsStartEnd.StartMonth = new Date(campyear[i].StartDate).getMonth();
                        CampaignsStartEnd.StartYear = new Date(campyear[i].StartDate).getFullYear();
                        CampaignsStartEnd.EndMonth = new Date(campyear[i].EndDate).getMonth();
                        CampaignsStartEnd.EndYear = new Date(campyear[i].EndDate).getFullYear();
                        CampaignsStartEnd.Name = campyear[i].Name;
                        CampaignsStartEnd.Status = campyear[i].Status;
                        CampaignsStartEnd.Id = campyear[i].Id;
                        CampaignsStartEnd.Type = campyear[i].Type;
                        CampaignsStartEnd.Region__c = campyear[i].Region__c;
                        CampStartEnd.push(CampaignsStartEnd);
                    }
                    component.set("v.campaignFrYearlyview",CampStartEnd); 
                }
            }else if (state === "INCOMPLETE"){
                var values = {leftBtvalue: 'Go to the previous Year', 
                              rightBtvalue: 'Go to the next Year', 
                              currentBtvalue:'This Year',options:'yearlyview'};
                // do something
            }else if (state === "ERROR") {
                    var values = {leftBtvalue: 'Go to the previous Year', 
                                  rightBtvalue: 'Go to the next Year', 
                                  currentBtvalue:'This Year',options:'yearlyview'};
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
            }
        });
        $A.enqueueAction(action);	 
    },

    getListViews : function(component,event,helper){
        let action = component.get("c.getCampaignListViews");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                // Convert the response into the required format for the combobox
                let listViewOptions = response.getReturnValue().map(function(option) {
                    return { label: option.label, value: option.value };
                });
                component.set("v.listViewOptions", listViewOptions);
            }
        });
        $A.enqueueAction(action);
    },

    getRecordtypes : function(component,event,helper){
        component.set("v.Spinner",true);
        var action = component.get("c.getRecordCampaignRecordtypes");
        action.setParams({  "loginUserId" : $A.get("$SObjectType.CurrentUser.Id") });
        action.setCallback(this, function(response) {
            component.set("v.Spinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var recTypeUsers = response.getReturnValue();
                var options = recTypeUsers.recordTypes;
                var items = [];
                for(var i=0; i<options.length; i++){
                    var item = {
                        "label" : options[i].label,
                        "value" : options[i].value
                    };
                    items.push(item);
                }
                var userids = [];
                recTypeUsers.subordinateUsers.forEach(function(item){
                    userids.push(item.Id);
                });
                
                console.log("recordtypes "+JSON.stringify(items));
                console.log("logged in user"+$A.get("$SObjectType.CurrentUser.Id"));
                component.set("v.CampaignRecordtypes",items);
                component.set("v.userIds",userids);
                this.getLocalStoreageValues(component,event,helper);
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR"){
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                }else{ 
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);	
        
    },

    RecordTypeChanged : function(component,event,helper,fromEvent){
        var selectedRecordtype = component.get("v.SelectedCampaignRecordType");
        if(fromEvent){
            selectedRecordtype = event.getParam("value");
        }
        component.set("v.page", 1);
        component.set("v.CampaignRecordType",selectedRecordtype);
        localStorage.setItem( 'selectedCampaignRecordtype', selectedRecordtype );
        var campaigntype = component.get("v.CampaignRecordtypes");
        campaigntype.forEach(function(item){
            if(selectedRecordtype == item.value)
            {
                component.set("v.Typetemp",'All');
                component.set("v.Typeofcampaings",'All');
                component.set("v.Regiontemp",'All Regions');
                component.set("v.Regiontempplaceholder",'');
                component.set("v.Regionofcampaings",'All Regions');
                var emptyarray = [];
                component.set("v.TypeofcampaingsArraytemp",emptyarray);
                component.set("v.RegionofcampaingsArraytemp",emptyarray);
                var reinit = component.find('MultiSelectComponent');
                if(reinit != undefined)
                    reinit.reInit();
                component.set("v.CampaignType",item.label);
            }
        });
        if(selectedRecordtype == 'Business_and_Government')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Pending Reporting', value : 'PendingReporting'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            var type = [];
            var types =['All','ATL','Advertisement','Banner Ads','BTL','Conference','Corporate Communications','Corporate Marketing','Email','Event','Expo','Incentive','Marketing','Other','Partners','Product Promotion (QBR, AEQCC, QBD)','Public Relations','Referral Program'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Freight')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Pending Reporting', value : 'PendingReporting'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'},
                            {label:'Concept Phase', value : 'ConceptPhase'},
                            {label:'On hold', value : 'Onhold'},
                            {label:'Active', value : 'Active'},
                            {label:'Closed', value : 'Closed'}];
            
            var type = [];
            var types =['All','QBR Partnership','Shakedown'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['Africa','All','America','Asia','Australia','Europe','Global','JCA South East Asia','JCA UKEUMEA','Middle East','North America','North East Asia','Pacific / Niche','South America','South Pacific'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Learning_Development')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            
            var type = [];
            var types =['All','Other'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Loyalty_Commercial')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'Aborted', value : 'Aborted'},
                            {label:'Active', value : 'Active'},
                            {label:'Closed', value : 'Closed'}];
            
            var type = [];
            var types =['All','Advertisement','ATL','Banner Ads','BTL','Conference','Corporate Communications','Corporate Marketing','Email','Event','Expo','Incentive','Marketing','Other','Partners','Product Promotion (QBR, AEQCC, QBD)','Public Relations','Referral Program','STIPS'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['Africa','All','America','Asia','Australia','Europe','Global','JCA South East Asia','JCA UKEUMEA','Middle East','North America','North East Asia','Pacific / Niche','South America','South Pacific'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Marketing_Child')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Pending Reporting', value : 'PendingReporting'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            var type = [];
            var types =['All','Agency Tickets','ATL','BTL','Conference','Conference/Event','Entertainment/Sustenance','Event','Expo','Famil','Famil Incentive','Famil Trip','Gifts','Incentive Budget','Incentive/Famil','Market Support','Marketing','Marketing Activity','NATAS / TR','Networking','Other','Others','Pricing','Product Presentation','Promo Corp','Promo Trade','QTA','Roadshow','Sales Collateral','Sales Incentive','Sponsorship','Sponsorship/Prizes','STIPS','Supplier of the Month','Sustenance','Tickets','Training'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['Africa','All','Asia','Australia','Cambodia','Europe','Global','Indonesia','Korea','Malaysia','Middle East','North America','Papua New Guinea','Philippines','Singapore','Solomon Island','South America','South Pacific','Thailand','Vietnam'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Marketing_Parent')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Pending Reporting', value : 'PendingReporting'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            
            var type = [];
            var types =['All','ATL','BTL','Conference','Event','Expo','Incentive Budget','Market Support','Marketing','NATAS / TR','Networking','Other','Others','Pricing','Product Presentation','Promo Corp','Promo Trade','Roadshow','Sponsorship','STIPS','Supplier of the Month'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'SME_Campaigns')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Pending Reporting', value : 'PendingReporting'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'},
                            {label:'Concept Phase', value : 'ConceptPhase'},
                            {label:'On hold', value : 'Onhold'}];
            
            var type = [];
            var types =['All','Acquisition','Corporate Communications','Other','Product Promotion (QBR, AEQCC, QBD)','Retention'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Subscription')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            
            var type = [];
            var types =['All','Corporate Communications','Other'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }else if(selectedRecordtype == 'Travel_Fund')
        {
            var statuses = [{label:'Planned', value : 'Planned'},
                            {label:'InProgress', value : 'InProgress'},
                            {label:'Completed', value : 'Completed'},
                            {label:'Aborted', value : 'Aborted'}];
            
            var type = [];
            var types =['All'];
            types.forEach(function(item){
                type.push({value: item, label: item });
            });
            component.set("v.types",type);
            
            var region = [];
            var regions =['All'];
            regions.forEach(function(item){
                region.push({value: item, label: item });
            });
            component.set("v.regions",region);
            
            component.set("v.Statuses",statuses);
        }
        component.set("v.HideMonthBox",false);
        if(fromEvent)
            this.getCampaigns(component, event, helper);
    },

    handleChange : function(component,event,helper,fromEvent){
        var selectedOptionValue = component.get("v.selectedCalendarView");
        if(fromEvent) {
            selectedOptionValue = event.getParam("value");
        }
        localStorage.setItem( 'selectedCalendarView', selectedOptionValue );
        var cmpt = component.find('Stickydiv');
        $A.util.addClass(cmpt, 'Headerfixed');
        
        if(selectedOptionValue == "monthlyview"){
            var cmpTarget = component.find('Parentcmp');
            $A.util.addClass(cmpTarget, 'HeightBlank');
            var values = {leftBtvalue: 'Go to the previous month', 
                          rightBtvalue: 'Go to the next month', 
                          currentBtvalue:'This Month',options:'monthlyview'};
            
            component.set("v.buttonobj",values);
            var date = new Date();
            component.set("v.view",selectedOptionValue);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth(), 1), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth() + 1, 0), "YYYY-MM-DD"));
            component.set("v.recordToDisply", 50);
            component.set("v.page", 1);
            component.set("v.Month",$A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
        }else if(selectedOptionValue == "yearlyview"){
            var cmpTarget = component.find('Parentcmp');
            $A.util.addClass(cmpTarget, 'HeightBlank');
            var values = {leftBtvalue: 'Go to the previous Year', 
                          rightBtvalue: 'Go to the next Year', 
                          currentBtvalue:'This FY',options:''};
            component.set("v.buttonobj",values);
            
            var date = new Date();
            component.set("v.view",selectedOptionValue);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), 6), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear()+1, 5), "YYYY-MM-DD"));
            component.set("v.recordToDisply", 50);
            component.set("v.page", 1);
            component.set("v.Month",$A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
            component.set("v.Financialyear",date.getFullYear()+' - '+(date.getFullYear()+1).toString().substr(-2));
        }
        if(fromEvent)
            this.getCampaigns(component, event, helper);
    },

    RecordView : function(component,event,helper,fromEvent){   
        var SelectedRecordView = component.get("v.selectedRecordView");
        if(fromEvent) {
            SelectedRecordView = event.getParam("value");
        }
        localStorage.setItem('selectedRecordView', SelectedRecordView );
        console.log('SelectedRecordView----'+SelectedRecordView) ;
        component.set("v.value",SelectedRecordView);
        if(fromEvent)
            this.getCampaigns(component, event, helper);
    },

    ApplyTypefiltercondition : function(component, event, helper, fromEvent){
        console.log('Inside ApplyTypefiltercondition');
        if(fromEvent){
            component.set("v.Typetemp",component.get("v.Typeofcampaings"));
            component.set("v.open",false);
            component.set("v.opentypefilter",false);
            component.set("v.TypeofcampaingsArraytemp",component.get("v.TypeofcampaingsArray"));
            if(component.get("v.TypeofcampaingsArray").length == 0){
                component.set("v.Typeofcampaings",'All');
            }
            localStorage.setItem('selectedTypeList', JSON.stringify(component.get("v.TypeofcampaingsArraytemp"))); 
        }
        if(fromEvent)
            this.getCampaigns(component, event, helper);     
    },

    ApplyRegionfiltercondition : function(component, event, helper,fromEvent){
        console.log('Inside ApplyRegionfiltercondition');
        if(fromEvent){
            component.set("v.Regiontemp",component.get("v.Regionofcampaings"));
            component.set("v.Regiontempplaceholder",component.get("v.Regionofcampaings"));
            component.set("v.open",false);
            component.set("v.openregionfilter",false);
            component.set("v.RegionofcampaingsArraytemp",component.get("v.RegionofcampaingsArray"));
            if(component.get("v.RegionofcampaingsArray").length == 0){
                component.set("v.Regionofcampaings",'All');
            }
            localStorage.setItem('selectedRegionList', JSON.stringify(component.get("v.RegionofcampaingsArraytemp")));
        }
        if(fromEvent)
            this.getCampaigns(component, event, helper);
    },

    //Method to get the values from local storage and set into respective fields
    getLocalStoreageValues : function(component,event,helper){
        var recordType = localStorage.getItem('selectedCampaignRecordtype')
        if(recordType){
            component.set("v.HideMonthBox",false);
            component.set("v.SelectedCampaignRecordType",recordType);
            this.RecordTypeChanged(component,event,helper,false);
            component.set("v.selectedCalendarView",localStorage.getItem('selectedCalendarView'));
            this.handleChange(component,event,helper,false);
            component.set("v.selectedRecordView",localStorage.getItem('selectedRecordView'));
            this.RecordView(component,event,helper,false);
            var selectedRegionList = localStorage.getItem('selectedRegionList');
            if(selectedRegionList){
                selectedRegionList = JSON.parse(selectedRegionList);
                component.set("v.Regiontemp",selectedRegionList.toString());
                component.set("v.RegionofcampaingsArraytemp",selectedRegionList);
                component.set("v.RegionofcampaingsArray",selectedRegionList);
                component.set("v.Regionofcampaings",selectedRegionList.toString());
                this.ApplyRegionfiltercondition(component, event, helper,false);
/*
                component.set("v.RegionofcampaingsArraytemp",selectedRegion);
                component.set("v.Regiontempplaceholder",selectedRegion);
                component.set("v.Regionofcampaings",selectedRegion);
                component.set("v.Regiontemp",selectedRegion);
                */
                
            }
            var selectedTypeList = localStorage.getItem('selectedTypeList');
            if(selectedTypeList){
                selectedTypeList = JSON.parse(selectedTypeList);
                component.set("v.Typetemp",selectedTypeList.toString());
                component.set("v.TypeofcampaingsArraytemp",selectedTypeList);
                component.set("v.TypeofcampaingsArray",selectedTypeList);
                component.set("v.Typeofcampaings",selectedTypeList.toString());
                this.ApplyTypefiltercondition(component, event, helper,false);
            }
            this.getCampaigns(component, event, helper);
        }
    }
    
})