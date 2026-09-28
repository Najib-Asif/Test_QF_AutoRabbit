({
    jsLoaded: function(component, event, helper) {
        //var map = L.map('map', {zoomControl: true,zoom:1,zoomAnimation:false,fadeAnimation:true,markerZoomAnimation:true}).setView([37.784173, -122.401557], 14);        
        //window.scrollTo(0, 0);
        var map = L.map('map', {zoomControl: true, zoom:1,zoomAnimation:false,fadeAnimation:true,markerZoomAnimation:true, tap: false}).setView([-33.8688, 151.2093], 14);
        window.scrollTo(0, 0);
        L.control.zoom({
             position:'topright'
        }).addTo(map);
        L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          {
               attribution: 'Map'
          }).addTo(map);
         //L.marker(latLng, {account: account}).addTo(map).on('click', function(event) {
         //   helper.navigateToDetailsView(event.target.options.account.Id);
       // });

        component.set("v.map", map);
    },

    accountsLoaded: function(component, event, helper) {

        // Add markers
        var map = component.get('v.map');
        var accounts = event.getParam('accounts');
          console.log('accounts',accounts);
        for (var i=0; i<accounts.length; i++) {
            
            
            var account = accounts[i];
            var iconUrl = account.RecordType.name == 'Agency Account' ? $A.get('$Resource.AgencyAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531078821000/HeatMapMarkerBlue1' :
                          account.RecordType.Name == 'Prospect Account'? $A.get('$Resource.ProspectAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079430000/HeatMapMarkerBlue2' :                                    
                          account.RecordType.Name == 'Freight Account'? $A.get('$Resource.FreightAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079505000/HeatMapMarkerBlue3' :                                    
                          account.RecordType.Name == 'Customer Account'? $A.get('$Resource.CustomerAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079544000/HeatMapMarkerBlue4' :
                          account.RecordType.Name == 'Charter Account'? $A.get('$Resource.CharterAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079710000/HeatMapMarkerBlue5' : 
           																 $A.get('$Resource.OtherAccount_HeatMapMarker') ;//'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079954000/HeatMapMarkerBlue6';
                          //account.RecordType.Name == 'Regional Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|6A5BA3|000000' :'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|4412FF|000000';
          if(account.RecordType.Name== 'Agency Account')
            {
              console.log('account',account);	
                console.log('iconUrl',iconUrl);	
                iconUrl = 'https://qantas--lightning--c.cs72.visual.force.com/resource/1531078821000/HeatMapMarkerBlue1';
            }
           // var iconUrl =  'https://qantas--lightning--c.cs72.visual.force.com/resource/1531078821000/HeatMapMarkerBlue1';        
            // chart APi
           // var iconUrl = //account.RecordType.Name == 'Other Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|33F0FF|000000' :
            /*  var iconUrl = account.RecordType.name == 'Agency Account' ? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|00bfff|000000' :
                          account.RecordType.Name == 'Prospect Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|FF1493|000000' :                                    
                          account.RecordType.Name == 'Freight Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|398b39|000000' :                                    
                          account.RecordType.Name == 'Customer Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|8b3a62|000000' :
                          account.RecordType.Name == 'Charter Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|7275A7|000000' : 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|7275A7|000000';
                          //account.RecordType.Name == 'Regional Account'? 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|6A5BA3|000000' :'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=|4412FF|000000';
            */
           // github
           // var iconUrl =	'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png';
            /* var iconUrl = account.RecordType.Name == 'Other Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-grey.png' :
                 			account.RecordType.name == 'Agency Account' ? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png' :
                       account.RecordType.Name == 'Prospect Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png' :                                    
                        account.RecordType.Name == 'Freight Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png' :                                    
                        account.RecordType.Name == 'Customer Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-orange.png' :
                        account.RecordType.Name == 'Charter Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png' : 
                        account.RecordType.Name == 'Regional Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png' :'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-black.png';
         
            if(account.RecordType.Name== 'Agency Account')
            {
              console.log('account',account);	
                console.log('iconUrl',iconUrl);	
                iconUrl = 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=A|33BBFF|000000';
            }else if(account.RecordType.Name == 'Prospect Account'){
                
                 console.log('account',account);	
                console.log('iconUrl',iconUrl);	
                iconUrl = 'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=A|2567C6|000000';
                
            }   */
             var RedIcon = new L.Icon({
          iconUrl: iconUrl,//'https://qantas--lightning--c.cs72.visual.force.com/resource/1530998522000/HeatMapMarkerBlue?isdtp=p1',
                 //{!URLFOR($Resource.HeatMapMarkerBlue)}',//'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',//'{!$Resource.HeatMapMarkerBlue}',//iconUrl,
          //shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
          iconSize: [100, 120],
          iconAnchor: [50, 60],
          popupAnchor: [1, -34],
          shadowSize: [41, 41]
        });  
            
            
          // console.log('account',account);
            var latLng = [account.Billing_Latitude__c, account.Billing_Longitude__c];
         var marker1  =  L.marker(latLng, {account: account}).addTo(map);
            marker1.setIcon(RedIcon);
           /* marker1.on('mouseover', function(e) {
                //marker1.openPopup()
              //open popup;
              var popup = L.popup()
               .setLatLng(e.latlng) 
               .setContent('Popup')
               .openOn(map);
            }); */
            var messagePopUp = '<strong> Name: </strong>'+account.Name+'</br>' 
            					+ '<strong> Type: </strong>'+account.RecordType.Name+'</br>' 
            					+ '<strong> City: </strong>'+account.BillingCity+'</br>';
                        		+ '<strong> Street: </strong>'+account.BillingStreet+'</br>';            					

            					//+ '<strong> Phone: </strong>'+account.Phone
            					//+ '<strong> Email: </strong>'+account.Email__c;           
             marker1.bindPopup(messagePopUp);
        marker1.on('mouseover', function (e) {
            this.openPopup();
        });
        marker1.on('mouseout', function (e) {
            this.closePopup();
        });
           
        }  
    },
    
    accountSelected: function(component, event, helper) {
        // Center the map on the account selected in the list
        var map = component.get('v.map');
        var lastAccount = component.get("v.acc");
        console.log('lastAccount',lastAccount);
        var account = event.getParam("account");
        
        var iconUrl = 	$A.get('$Resource.SelectedAccount_HeatMapMarker');
//'https://qantas--lightning--c.cs72.visual.force.com/resource/1531080078000/HeatMapMarkerRed';
        //var iconUrl = 	'https://qantas--lightning--c.cs72.visual.force.com/resource/1531080078000/HeatMapMarkerRed';
        //'https://chart.googleapis.com/chart?chst=d_map_pin_letter_withshadow&chld=%20|b30000|000000';
        //var iconUrl = 	'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png';
        /*var iconUrl = account.RecordType.Name == 'Other Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-grey.png' :
                 			account.RecordType.name == 'Agency Account' ? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-violet.png' :
                       account.RecordType.Name == 'Prospect Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png' :                                    
                        account.RecordType.Name == 'Freight Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png' :                                    
                        account.RecordType.Name == 'Customer Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-orange.png' :
                        account.RecordType.Name == 'Charter Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png' : 
                        account.RecordType.Name == 'Regional Account'? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png' :'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-black.png';
            */
        //var pinAnchor = new L.Point(25, 60);
        var RedIcon = new L.Icon({
          iconUrl: iconUrl,
          shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
          iconSize: [100, 120],
          iconAnchor: [50, 60],
          popupAnchor: [1, -34],
          shadowSize: [100, 120]
         // iconAnchor: [12, 41],
          //iconAnchor: [42, 41],
          //iconAnchor: [25, 60],
          //iconAnchor: pinAnchor,
          //popupAnchor: [1, -34],
          //shadowSize: [41, 41]
        }); 
        if(lastAccount != null){
            console.log('lastAccount222',lastAccount.Billing_Longitude__c);
        }
      	if(lastAccount == null){
             lastAccount = event.getParam("account");
            component.set("v.acc",lastAccount);
        }else{
            console.log($A.get('$Resource.HeatMapMarkerBlue1'));
            var iconUrlc = lastAccount.RecordType.name == 'Agency Account' ? $A.get('$Resource.AgencyAccount_HeatMapMarker') : //'https://qantas--lightning--c.cs72.visual.force.com/resource/1531078821000/HeatMapMarkerBlue1' :
                          lastAccount.RecordType.Name == 'Prospect Account'? $A.get('$Resource.ProspectAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079430000/HeatMapMarkerBlue2' :                                    
                          lastAccount.RecordType.Name == 'Freight Account'? $A.get('$Resource.FreightAccount_HeatMapMarker') :// 'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079505000/HeatMapMarkerBlue3' :                                    
                          lastAccount.RecordType.Name == 'Customer Account'? $A.get('$Resource.CustomerAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079544000/HeatMapMarkerBlue4' :
                          lastAccount.RecordType.Name == 'Charter Account'? $A.get('$Resource.CharterAccount_HeatMapMarker') ://'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079710000/HeatMapMarkerBlue5' : 
            $A.get('$Resource.OtherAccount_HeatMapMarker'); //'https://qantas--lightning--c.cs72.visual.force.com/resource/1531079954000/HeatMapMarkerBlue6';
                
              var ResetIcon = new L.Icon({
          iconUrl: iconUrlc,
          shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
          iconSize: [100, 120],
          iconAnchor: [50, 60],
          popupAnchor: [1, -34],
          shadowSize: [100, 120]
         // iconAnchor: [12, 41],
          //iconAnchor: [42, 41],
          //iconAnchor: [25, 60],
          //iconAnchor: pinAnchor,
          //popupAnchor: [1, -34],
          //shadowSize: [41, 41]
          
        }); 
            console.log('lastAccount.Billing_Latitude__c',lastAccount.Billing_Latitude__c);
            console.log('lastAccount.Billing_Longitude__c',lastAccount.Billing_Longitude__c);
          var mark =  L.marker([lastAccount.Billing_Latitude__c, lastAccount.Billing_Longitude__c], {icon: ResetIcon}).addTo(map);
            mark.setIcon(ResetIcon);
          lastAccount = event.getParam("account"); 
            component.set("v.acc",lastAccount);
            console.log('#########');
        }
        L.marker([account.Billing_Latitude__c, account.Billing_Longitude__c], {icon: RedIcon},{rotationAngle: 90},{RotationOrigin :"center center"}).addTo(map);
       // L.marker([account.Billing_Latitude__c, account.Billing_Longitude__c]).addTo(map);
        var zoom = 18;
          console.log('#########account',account.Id);
         console.log('account.Billing_Latitude__c',account.Billing_Latitude__c);
            console.log('account.Billing_Longitude__c',account.Billing_Longitude__c);
        console.log('#########');
        //map.panTo([account.Billing_Latitude__c, account.Billing_Longitude__c]);
        map.setView([account.Billing_Latitude__c, account.Billing_Longitude__c], zoom);
       // map.flyTo([account.Billing_Latitude__c, account.Billing_Longitude__c], zoom);
		window.scrollTo(0, 0);       
	}

})