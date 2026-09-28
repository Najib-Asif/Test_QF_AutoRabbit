({
    sendMessage: function (component, message) {
        component.find('clientEventMessageChannel').publish(message);
    },
    outputToConsole: function(component, message) {
        if(message){
            if(JSON.parse(message)){
                var obj=JSON.parse(message);
                console.log(obj);
                console.log('############category: '+obj.category);
                var catx =obj.category ? obj.category:'undefined';
                switch(catx){
                        
                    //fransiska added feature on Consultant pressed Consult Transfer (from AgentScript) will show Phone Widget //
                     case "change":
                        var consult_participant_name=component.get("v.Consult_ParticipantData_Name")
                        var consult_particpant_defval=component.get("v.Consult_ParticipantData_DefVal")
                        var consult_participant_updval=component.get("v.Consult_ParticipantData_UpdVal")
                        console.log(`@QCC_ManagePhoneWidget: consult_participant_name ${consult_participant_name} consult_particpant_defval ${consult_particpant_defval} consult_participant_updval ${consult_participant_updval}`);
                        if(obj.data)
                        {
                            if((obj.data.old && obj.data.old.attributes) || (obj.data.new && obj.data.new.attributes))
                            {
                                if(
                                (obj.data.old.attributes[`${consult_participant_name}`] && obj.data.old.attributes[`${consult_participant_name}`]==`${consult_participant_updval}`) ||
                                (obj.data.new.attributes[`${consult_participant_name}`] && obj.data.new.attributes[`${consult_participant_name}`]==`${consult_participant_updval}`))
                                {
                                    component.set('v.consoleMessages', `ONChange Old/New, ${consult_participant_name} is ${consult_participant_updval}, start show PhoneWidget`);
                                    var utilityBarAPI = component.find("utilitybar");
                                    utilityBarAPI.getAllUtilityInfo().then(function(response) 
                                    {
                                        if(Array.isArray(response))
                                        {
                                            var arrayLength = response.length;
                                            var phoneWidgetUtility;
                                            var phoneisExsist=false;
                                            var phoneVisible=false;
                                            for (var i = 0; i < arrayLength; i++) 
                                            {
                                                if(response[i].panelHeaderIcon=='call' && response[i].utilityIcon=='call')
                                                {
                                                    phoneWidgetUtility=response[i];
                                                    phoneisExsist=true;
                                                    phoneVisible=response[i].utilityVisible;
                                                }
                                            }
                                            //foundPhone Widget
                                            if(phoneisExsist==true&&phoneVisible==false)
                                            {
                                                //show Phone Widget
                                                utilityBarAPI.openUtility({
                                                    utilityId: phoneWidgetUtility.id
                                                }).then(function(res)
                                                {
                                                    console.log(res)
                                            		if(res==true)
                                                    {

														component.set('v.consoleMessages', 'ONCHANGE - ConsultTransfer'+'\nPHONE MAXIMISED\n');
                                                    }
                                                })
                                            }
                                            else console.log('@QCC_ManagePhoneWidget ONCHANGE - ConsultTransfer, no phone widget utility found');
                                            //revert back Participant.SoftPhonePop to false
                                            console.log(`@QCC_ManagePhoneWidget start revert back Participant.SoftPhonePop to false`);
											var jsonAttrStr = '{\"SoftPhonePop\":\"false\"}';
                                            component.find('clientEventMessageChannel').publish({
                                                type: 'PureCloud.Interaction.addCustomAttributes',
                                                data: {
                                                      attributes: JSON.parse(jsonAttrStr),
                                                      id: component.get('v.interactionId')
                                                }
                                            });
                                        }
                                    });
                                }
                            }
                            else
                            {
                                console.log(`@QCC_ManagePhoneWidget: OnChange Old/New unable to found any attributes, so not do anything`);
                            }
                        }
                        else
                        {
                            console.log('@QCC_ManagePhoneWidget: OnChange obj.data not exist, this is for listen Consult Transfer')
                        }
                    break;
                    //fransiska added for Consult Transfer Test //
                    case "undefined":
                        console.log('############ this is undefined');
                        if(obj.type){
                            console.log('############ obj.type exist');
                            if(obj.type=='PureCloud.Interaction.addCustomAttributes'){
                                console.log('############ obj.type is PureCloud.Interaction.addCustomAttributes');
                                if(obj.data){
                                    console.log('############ obj.data is exist');
                                    if(obj.data.attributes){
                                         console.log('############ obj.data is exist');
                                        if(obj.data.attributes["CaseNumber"]!=null && obj.data.attributes["CaseNumber"]!=""){
                                            console.log('############ obj.data.attributes casenumber is exist');
                                            /******** start minimised phone ********/
                        					var utilityBarAPI = component.find("utilitybar");
                        					utilityBarAPI.getAllUtilityInfo().then(function(response) {
                            if(Array.isArray(response)){
                                var arrayLength = response.length;
                                
                                var phoneWidgetUtility;
                                var phoneisExsist=false;
                                var phoneVisible=false;
                                for (var i = 0; i < arrayLength; i++) {
                                    console.log(response[i]);
                                    if(response[i].utilityIcon=='call' && response[i].panelHeaderIcon=='call'){
                                        phoneWidgetUtility=response[i];
                                        phoneisExsist=true;
                                        phoneVisible=response[i].utilityVisible;
                                    }
                                }
                                if(phoneisExsist==true){
                                    if(phoneVisible==true){
                                        utilityBarAPI.minimizeUtility({
                                            utilityId: phoneWidgetUtility.id
                                        }).then(function(resmin){
                                            console.log('UPON CONNECTED, after opened widget, succesfully minimise widget');
                                            console.log(resmin);
                                            component.set('v.consoleMessages', 'CONNECTED'+'\nPHONE MINIMISED\n'+JSON.stringify(obj.data));
                                       });                                  
                                    }
                                    else{
                                        utilityBarAPI.openUtility({
                                                utilityId: phoneWidgetUtility.id
                                        }).then(function(res){
                                             console.log('UPON DISCONNECTED, succesfully set phone Widget opened');
                                             console.log(phoneWidgetUtility);
                                             var utilityBarAPI1 = component.find("utilitybar");
                                             console.log(utilityBarAPI1);
                                             utilityBarAPI.minimizeUtility({
                                                    utilityId: phoneWidgetUtility.id
                                             }).then(function(resmin){
                                                     console.log('UPON DISCONNECTED, after opened widget, succesfully minimise widget');
                                                     console.log(resmin);
                                                     component.set('v.consoleMessages', 'DISCONNECTED'+'\nPHONE MINIMISED\n'+JSON.stringify(obj.data));
                                            });
                                       });                                        
                                    }

                               }
                               else console.log('UPON DISCONNECTED, no phone widget utility found');
                             }
                        });
                                            /******** end minimised phone **********/
                                            component.set('v.consoleMessages', 'addCustomAttributes - CaseNumber'+"\n"+JSON.stringify(obj.data));
                        					//minimise phoneWidgetUtility
                                        }
                                        else {
                                            console.log('############ addCustomAttributes - Theres no CaseNumber');
                                            component.set('v.consoleMessages', 'addCustomAttributes - Theres no CaseNumber'+"\n"+JSON.stringify(obj.data));
                                        }
                                    }
                                    else {
                                        console.log('############ addCustomAttributes - no participant data');
                                        component.set('v.consoleMessages', 'addCustomAttributes - no participant data'+"\n"+JSON.stringify(obj.data));
                                    }
                                }
                                else {
                                    console.log('############ PureCloud.Interaction.addCustomAttributes but no obj data');
                                    component.set('v.consoleMessages', 'PureCloud.Interaction.addCustomAttributes but no obj data'+"\n"+JSON.stringify(obj.data));
                                }
                            }
                            else {
                                console.log('############ its not PureCloud.Interaction.addCustomAttributes');
                                component.set('v.consoleMessages', 'its not PureCloud.Interaction.addCustomAttributes'+"\n"+JSON.stringify(obj.data));
                            }
                        }
                        

                    	break;                        
                    case "disconnect":
                        component.set('v.consoleMessages', 'DISCONNECT'+"\n"+JSON.stringify(obj.data));
                        //minimise phoneWidgetUtility
                        var utilityBarAPI = component.find("utilitybar");
                        utilityBarAPI.getAllUtilityInfo().then(function(response) {
                            if(Array.isArray(response)){
                                var arrayLength = response.length;
                                
                                var phoneWidgetUtility;
                                var phoneisExsist=false;
                                var phoneVisible=false;
                                for (var i = 0; i < arrayLength; i++) {
                                    console.log(response[i]);
                                    if(response[i].utilityIcon=='call' && response[i].panelHeaderIcon=='call'){
                                        phoneWidgetUtility=response[i];
                                        phoneisExsist=true;
                                        phoneVisible=response[i].utilityVisible;
                                    }
                                }
                                if(phoneisExsist==true){
                                    if(phoneVisible==true){
                                        utilityBarAPI.minimizeUtility({
                                            utilityId: phoneWidgetUtility.id
                                        }).then(function(resmin){
                                            console.log('UPON DISCONNECTED, after opened widget, succesfully minimise widget');
                                            console.log(resmin);
                                            component.set('v.consoleMessages', 'DISCONNECTED'+'\nPHONE MINIMISED\n'+JSON.stringify(obj.data));
                                       });                                  
                                    }
                                    else{
                                        utilityBarAPI.openUtility({
                                                utilityId: phoneWidgetUtility.id
                                        }).then(function(res){
                                             console.log('UPON DISCONNECTED, succesfully set phone Widget opened');
                                             console.log(phoneWidgetUtility);
                                             var utilityBarAPI1 = component.find("utilitybar");
                                             console.log(utilityBarAPI1);
                                             utilityBarAPI.minimizeUtility({
                                                    utilityId: phoneWidgetUtility.id
                                             }).then(function(resmin){
                                                     console.log('UPON DISCONNECTED, after opened widget, succesfully minimise widget');
                                                     console.log(resmin);
                                                     component.set('v.consoleMessages', 'DISCONNECTED'+'\nPHONE MINIMISED\n'+JSON.stringify(obj.data));
                                            });
                                       });                                        
                                    }

                               }
                               else console.log('UPON DISCONNECTED, no phone widget utility found');
                             }
                        });
                    	break;
                    case "acw":
                        component.set('v.consoleMessages', 'ACW'+'\n'+JSON.stringify(obj.data));
                        //maximise phoneWidgetUtility
                        var utilityBarAPI = component.find("utilitybar");
                        utilityBarAPI.getAllUtilityInfo().then(function(response) {
                            if(Array.isArray(response)){
                                var arrayLength = response.length;
                                for (var i = 0; i < arrayLength; i++) {
                                    console.log(response[i]);
                                    if(response[i].utilityIcon=='call' && response[i].panelHeaderIcon=='call'){
                                        var phoneWidgetUtility=response[i];
                                        utilityBarAPI.openUtility({
                							utilityId: phoneWidgetUtility.id
            							});
                            			component.set('v.consoleMessages', 'ACW'+'\nPHONE MAXIMISED\n'+JSON.stringify(obj.data));
                                    }
                                }
                            }
                        });
                    	break;
                    //call not responding, consultant back on queue
                    case "routingStatus":
                        if(obj.data=='NOT_RESPONDING'){
                            component.set('v.consoleMessages', 'CALL NOT RESPONDING, Consultant back on queue'+'\n'+JSON.stringify(obj.data));
                            //maximise phoneWidgetUtility
                            var utilityBarAPI = component.find("utilitybar");
                            utilityBarAPI.getAllUtilityInfo().then(function(response) {
                                if(Array.isArray(response)){
                                    var arrayLength = response.length;
                                    for (var i = 0; i < arrayLength; i++) {
                                        console.log(response[i]);
                                        if(response[i].utilityIcon=='call' && response[i].panelHeaderIcon=='call'){
                                            var phoneWidgetUtility=response[i];
                                            utilityBarAPI.openUtility({
                                                utilityId: phoneWidgetUtility.id
                                            });
                                            component.set('v.consoleMessages', 'CALL NOT RESPONDING, Consultant back on queue'+'\nPHONE MAXIMISED\n'+JSON.stringify(obj.data));
                                        }
                                    }
                                }
                            });
                        }
                    	break;                        
                    default:
                    	break;                        
                }
            }
        }
    }
})