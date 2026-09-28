({

    onClientEvent: function (component, message, helper) {
        
        var eventData = message.getParams();
        if (eventData) {
            var message = JSON.stringify(eventData);
            console.log('>>>>>>>-----------');
            console.log('@@QCC_ManageSoftphoneWidget event: '+JSON.stringify(eventData, null, 2));
            console.log('>>>>>>>-----------');
            if(eventData.type === 'Interaction' && eventData.data.id) {
                component.set("v.interactionId", eventData.data.id );
            }
            else if(eventData.type=='PureCloud.Interaction.addCustomAttributes') 
            {
                console.log('@@QCC_ManageSoftphoneWidget addCustomAttributes')
                if(eventData.data.id && eventData.data.attributes['SoftPhonePop']){
                   window.console.log('@@QCC_ManageSoftphoneWidget SoftPhonePop retrieved: '+eventData.data.attributes['SoftPhonePop']);
                }
                else {
                    console.log('@@QCC_ManageSoftphoneWidget addCustomAttributes not SoftPhonePop instead')
                    console.log(eventData.data.attributes)
                }
            }
            helper.outputToConsole(component, message);
        }
    },
  
})