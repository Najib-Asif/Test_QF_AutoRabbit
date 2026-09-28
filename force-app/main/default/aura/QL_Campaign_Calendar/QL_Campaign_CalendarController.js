({
    Initialize : function(component, event, helper) {
        var cmpTarget = component.find('Parentcmp');
        $A.util.addClass(cmpTarget, 'HeightBlank');
        helper.getListViews(component,event,helper);
        helper.getRecordtypes(component,event,helper);
        
    },
    
    RecordTypeChanged : function(component,event,helper){
        helper.RecordTypeChanged(component,event,helper,true);
    },
    SetTheMonthYear : function(component,event,helper)
    {
        component.set("v.recordToDisply",event.getParam("recordToDisply"));
        component.set("v.page",event.getParam("page"));
        helper.getCampaigns(component,event,helper);
    },
    
    RecordView : function(component,event,helper){
        helper.RecordView(component,event,helper,true);
    },

    handleChange : function(component,event,helper){
        helper.handleChange(component,event,helper,true);
    },
    
    Previousperiod : function(component,event,helper)
    {
        
        if(component.get("v.buttonobj") != null)
        {
            if(component.get("v.buttonobj").options == 'monthlyview')
            {
                //var MonthView = component.find('CampaignCalendarMonth');
                //MonthView.GetDates("previousmonth");
                var splitDate = component.get("v.SplitDates");
                
                var date = new Date(splitDate[0].dateCams[0].sDate);
                date.setMonth(date.getMonth()-1);
                component.set("v.page",1);
                component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth(), 1), "YYYY-MM-DD"));
                component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth() + 1, 0), "YYYY-MM-DD"));
                component.set("v.Month",$A.localizationService.formatDate(date, "YYYY-MM-DD"));
                helper.getCampaigns(component,event,helper);
            }
            else if(component.get("v.buttonobj").options == 'yearlyview')
            {
                //var MonthView = component.find('CampaignCalendarYear');
                //MonthView.GetMonths("previousyear");
                var date = new Date(component.get("v.Month"));
                date.setFullYear(date.getFullYear()-1);
                component.set("v.page",1);
                component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), 6), "YYYY-MM-DD"));
                component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear()+1, 5), "YYYY-MM-DD"));
                component.set("v.Month",$A.localizationService.formatDate(date, "YYYY-MM-DD"));
                component.set("v.Financialyear",date.getFullYear()+' - '+(date.getFullYear()+1).toString().substr(-2));
                helper.getCampaigns(component,event,helper);
            }
        }
    },
    
    NextPeriod : function(component,event,helper)
    {
        
        
        if(component.get("v.buttonobj").options == 'monthlyview')
        {
            //var MonthView = component.find('CampaignCalendarMonth');
            //MonthView.GetDates("nextmonth");
            var splitDate = component.get("v.SplitDates");
            
            var date = new Date(splitDate[0].dateCams[0].sDate);
            date.setMonth(date.getMonth()+1);
            component.set("v.page",1);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth(), 1), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth() + 1, 0), "YYYY-MM-DD"));
            component.set("v.Month",$A.localizationService.formatDate(date, "YYYY-MM-DD"));
            helper.getCampaigns(component,event,helper);
            
        }else if(component.get("v.buttonobj").options == 'yearlyview')
        {
            //var MonthView = component.find('CampaignCalendarYear');
            //MonthView.GetMonths("nextyear");
            var date = new Date(component.get("v.Month"));
            date.setFullYear(date.getFullYear()+1);
            component.set("v.page",1);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), 6), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear()+1, 5), "YYYY-MM-DD"));
            component.set("v.Month",$A.localizationService.formatDate(date, "YYYY-MM-DD"));
            component.set("v.Financialyear",date.getFullYear()+' - '+(date.getFullYear()+1).toString().substr(-2));
            helper.getCampaigns(component,event,helper);
        }
    },
    
    Currentperiod : function(component, event, helper){
        if(component.get("v.buttonobj").options == 'monthlyview')
        {
            //var MonthView = component.find('CampaignCalendarMonth');
            //MonthView.GetDates('');            
            var date = new Date();
            component.set("v.page",1);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth(), 1), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear(), date.getMonth() + 1, 0), "YYYY-MM-DD"));
            component.set("v.Month",$A.localizationService.formatDate(date, "YYYY-MM-DD"));
            helper.getCampaigns(component,event,helper);
            
        }else if(component.get("v.buttonobj").options == 'yearlyview')
        {
            //var MonthView = component.find('CampaignCalendarYear');
            //MonthView.GetMonths('');reInit
            var date = new Date();
            component.set("v.page",1);
            component.set("v.StartDate",$A.localizationService.formatDate(new Date(date.getFullYear(), 6), "YYYY-MM-DD"));
            component.set("v.EndDate",$A.localizationService.formatDate(new Date(date.getFullYear()+1, 5), "YYYY-MM-DD"));
            component.set("v.Month",$A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
            component.set("v.Financialyear",date.getFullYear()+' - '+(date.getFullYear()+1).toString().substr(-2));
            helper.getCampaigns(component,event,helper);
        }
    },
    CollapsePane : function(component, event, helper) {
        if(component.get("v.open")== false)
        {
            var filterpanel = component.find('FilterPanel');
            $A.util.toggleClass(filterpanel, 'slds-is-open');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.toggleClass(filterpanel, 'slds-hide');
                }),200
            );
        }else
        {
            var filterpanel = component.find('FilterPanel');
            $A.util.toggleClass(filterpanel, 'slds-is-open');
            
            component.set("v.Typeofcampaings",component.get("v.Typetemp"));
            component.set("v.Regionofcampaings",component.get("v.Regiontemp"));
            
            var reinit = component.find('MultiSelectComponent');
            if(reinit != undefined)
                reinit.reInit();
            
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.toggleClass(filterpanel, 'slds-hide');
                    component.set("v.open",false);
                    component.set("v.opentypefilter",false);
                    component.set("v.openregionfilter",false);
                }),200
            );
        }
        
    },

    GetSelectedRegions : function(component, event, helper) {
        var selectedregion = event.getParam("value");
        if(selectedregion != null)
        {
            component.set("v.RegionofcampaingsArray",selectedregion);
            component.set("v.Regionofcampaings",selectedregion);
        }else{
            var SelectedRegions = event.getParam("values");
            var Selectedtypeslabel = event.getParam("labels");
            component.set("v.TypeofcampaingsArray",Selectedtypeslabel);
            var types ='';
            for(var i=0; i<Selectedtypeslabel.length; i++)
            {
                if(Selectedtypes.length == 1)
                    types = Selectedtypeslabel[i];
                else
                {
                    if(Selectedtypeslabel[i] != 'All')
                    {
                        if(i< Selectedtypes.length-1)
                            types += Selectedtypeslabel[i] + ", ";
                        else
                            types += Selectedtypeslabel[i];
                    }
                }
            }
            component.set("v.Typeofcampaings",types);
        }
    },
    
    GetSelectedValues : function(component, event, helper) {

        var sourceComponent = event.getSource();
        var typeComponent = component.find("MultiSelectComponent");
        var regionComponent = component.find("MultiSelectComponentRegion");
        if (sourceComponent === typeComponent) {
            var Selectedtypes = event.getParam("values");
            var Selectedtypeslabel = event.getParam("labels");
            component.set("v.TypeofcampaingsArray",Selectedtypeslabel);
            var types ='';
            for(var i=0; i<Selectedtypeslabel.length; i++)
            {
                if(Selectedtypes.length == 1)
                    types = Selectedtypeslabel[i];
                else
                {
                    if(Selectedtypeslabel[i] != 'All')
                    {
                        if(i< Selectedtypes.length-1)
                            types += Selectedtypeslabel[i] + ", ";
                        else
                            types += Selectedtypeslabel[i];
                    }
                }
            }
            component.set("v.Typeofcampaings",types);
        } else if (sourceComponent === regionComponent) {
            var SelectedRegions = event.getParam("values");
            var SelectedRegionslabel = event.getParam("labels");
            component.set("v.RegionofcampaingsArray",SelectedRegionslabel);
            var regions ='';
            for(var i=0; i<SelectedRegionslabel.length; i++)
            {
                if(SelectedRegions.length == 1)
                regions = SelectedRegionslabel[i];
                else
                {
                    if(SelectedRegionslabel[i] != 'All')
                    {
                        if(i< SelectedRegions.length-1)
                        regions += SelectedRegionslabel[i] + ", ";
                        else
                        regions += SelectedRegionslabel[i];
                    }
                }
            }
            component.set("v.Regionofcampaings",regions);
        }
    },
    
    ShowHidefilter : function(component, event, helper){
        console.log('Type filter---'+component.get("v.opentypefilter"));
        console.log('Region filter---'+component.get("v.openregionfilter"));
        console.log('Inside ShowHidefilter method');
        if(component.get("v.types").length > 0 && component.get("v.buttonobj") != null)
        {
            var buttonid = event.currentTarget.id;
            console.log('Button Id'+buttonid);
            if(buttonid == 'Filterfieldtype')
            {
                if(component.get("v.opentypefilter") == false && component.get("v.open") == false)
                {
                    component.set("v.open",true);
                    component.set("v.opentypefilter",true);
                    component.set("v.openregionfilter",false);
                }
                else
                {
                    component.set("v.open",false);
                    component.set("v.openregionfilter",false);
                    component.set("v.opentypefilter",false);
                }
                
            }else if(buttonid == 'Filterfieldregion')
            {
                if(component.get("v.openregionfilter") ==  false)
                {
                    component.set("v.open",true);
                    component.set("v.openregionfilter",true);
                    component.set("v.opentypefilter",false);
                }
                else
                {
                    component.set("v.open",false);
                    component.set("v.openregionfilter",false);
                    component.set("v.opentypefilter",false);
                }
            }
            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "warning",
                "message": "Please Select the Campaign Type & View"
            });
            toastEvent.fire();
        }
    },
    CloseFilter : function(component, event, helper){
        var Filterreset = event.currentTarget.id;
        var empty = [];        
        if(Filterreset == 'Filtertypereset')
        {
            component.set("v.open",false);
            component.set("v.opentypefilter",false);
            component.set("v.Typetemp",'All');
            component.set("v.Typeofcampaings",'All');
            component.set("v.TypeofcampaingsArraytemp", empty);
            var reinit = component.find('MultiSelectComponent');
            
            if(reinit != undefined)
            reinit.reInit();
            localStorage.removeItem("selectedTypeList");
            helper.getCampaigns(component, event, helper); 
        }else if(Filterreset == 'Filterregionreset')
        {
            component.set("v.open",false);
            component.set("v.openregionfilter",false);
            component.set("v.Regiontemp",'All Regions');
            component.set("v.Regiontempplaceholder",'');
            component.set("v.Regionofcampaings",'All Regions');
            component.set("v.RegionofcampaingsArraytemp", empty);
            var reinit = component.find('MultiSelectComponentRegions');
            
            if(reinit != undefined)
            reinit.reInit();
            localStorage.removeItem("selectedRegionList");
            helper.getCampaigns(component, event, helper); 
        }else
        {
            
            var footerclosebuttonid = event.currentTarget.id;
            
            if(footerclosebuttonid == 'Filtertypebuttonclose')
            {
                if(component.get("v.Typetemp") == undefined)
                    component.set("v.Typetemp",'All');
                
                component.set("v.Typeofcampaings",component.get("v.Typetemp"));
                component.set("v.open",false);
                component.set("v.opentypefilter",false);
                var reinit = component.find('MultiSelectComponent');
                reinit.reInit();
            }else if(footerclosebuttonid == 'Filterregionbuttonclose')
            {
                if(component.get("v.Regiontemp") == undefined)
                {
                    component.set("v.Regiontemp",'All Regions');
                    component.set("v.Regiontempplaceholder",'');
                }
                
                component.set("v.Regionofcampaings",component.get("v.Regiontemp"));
                component.set("v.open",false);
                component.set("v.openregionfilter",false);
            }            
        }
    },
    ApplyTypefilterconditions : function(component, event, helper){
        helper.ApplyTypefiltercondition(component, event, helper,true);      
    },

    ApplyRegionfiltercondition : function(component, event, helper,fromEvent){
        helper.ApplyRegionfiltercondition(component, event, helper,true);
    },

    handleLinkClick : function(component, event, helper){
        var articleId = $A.get("$Label.c.CampaignCalendar_help_article");
        console.log('Link Clicked-----'+articleId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/'+articleId,
            focus: true
        }).catch(function(error) {
            console.log(error);
        });
    }
})