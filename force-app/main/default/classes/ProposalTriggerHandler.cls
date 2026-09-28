//Test Class : Test_ProposalTriggerHandler
public class ProposalTriggerHandler {

    public static Map<Id, Proposal__c> staticpropMap; 
    public ProposalTriggerHandler(List<Proposal__c> newList){
        staticpropMap = getProposalMap(newList);
    }
    

      public void approvedByInternalTeam(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){
      
           //Map<Id, Proposal__c> propMap = getProposalMap(newList); 
           Map<Id, Proposal__c> propMap;
           if(!staticpropMap.isEmpty()) {
            propMap = staticpropMap;
           }      
           List<Discount_List__c> updateDiscountList = new List<Discount_List__c>();
           
           for(Proposal__c prop : newList){
                // If Approved by NAM
                if(prop.NAM_Approved__c != oldMap.get(prop.Id).NAM_Approved__c){
                       if(prop.NAM_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.Approval_Required_NAM__c == true) dL.Approved_by_NAM__c = true;  
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Rejected by NAM
                if(prop.NAM_Rejected__c != oldMap.get(prop.Id).NAM_Rejected__c){
                       if(prop.NAM_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.Approval_Required_NAM__c == true) dL.NAM_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Approved by Pricing
                if(prop.Pricing_Approved__c != oldMap.get(prop.Id).Pricing_Approved__c){
                    
                      if(prop.Pricing_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                              if(dL.Approval_Required_Pricing__c == true) 
                              dL.Approved_by_Pricing__c = true;
                               updateDiscountList.add(dL);
                          }             
                      }
                }
                
                // If Rejected by Pricing
                if(prop.Pricing_Rejected__c != oldMap.get(prop.Id).Pricing_Rejected__c){
                       if(prop.Pricing_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.Approval_Required_Pricing__c == true) dL.Pricing_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Approved by Deal Optimization
                if(prop.DO_Approved__c != oldMap.get(prop.Id).DO_Approved__c){
                       if(prop.DO_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.Approval_Required_DO__c == true) 
                               dL.DO_Approved__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Rejected by Deal Optimization
                if(prop.DO_Rejected__c != oldMap.get(prop.Id).DO_Rejected__c){
                       if(prop.DO_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.Approval_Required_DO__c == true) dL.DO_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                      // CRM-2003 If Approved by Team Lead on Corporate Airfares
                if(prop.TL_Approved__c != oldMap.get(prop.Id).TL_Approved__c){
                       if(prop.TL_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_Team_Lead_CA__c == true) dL.Approved_by_TL__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                
                  // CRM-2003 If Rejected by Team Lead on Corporate Airfares
                if(prop.TL_Rejected__c != oldMap.get(prop.Id).TL_Rejected__c){
                       if(prop.TL_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_Team_Lead_CA__c == true) dL.TL_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Approved by Team Lead for QBS
                if(prop.TeamLead_Approved__c != oldMap.get(prop.Id).TeamLead_Approved__c){
                       if(prop.TeamLead_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_Team_Lead__c  == true) dL.TeamLead_Approved__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Rejected by TeamLead
                if(prop.TeamLead_Rejected__c != oldMap.get(prop.Id).TeamLead_Rejected__c){
                       if(prop.TeamLead_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_Team_Lead__c  == true) dL.TeamLead_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // CRM 1989 -- SBD for CA
                
                if(prop.Approved_by_SBD__c != oldMap.get(prop.Id).Approved_by_SBD__c){
                       if(prop.Approved_by_SBD__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_SBD_CA__c  == true) dL.Approved_by_SBD__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Rejected by SBD
                if(prop.Rejected_by_SBD__c != oldMap.get(prop.Id).Rejected_by_SBD__c){
                       if(prop.Rejected_by_SBD__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_SBD_CA__c  == true) dL.Rejected_by_SBD__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
             // CRM 1989 -- SBD for QBS
                
                if(prop.SBD_Approved__c != oldMap.get(prop.Id).SBD_Approved__c){
                       if(prop.SBD_Approved__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_SBD_QBS__c  == true) dL.SBD_Approved__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                }
                
                // If Rejected by SBD
                if(prop.SBD_Rejected__c != oldMap.get(prop.Id).SBD_Rejected__c){
                       if(prop.SBD_Rejected__c == true){
                           for(Discount_List__c dL : propMap.get(prop.Id).Fare_Structure_Lists__r){
                               if(dL.ApprovalRequired_SBD_QBS__c  == true) dL.SBD_Rejected__c = true;
                               updateDiscountList.add(dL);
                           }             
                       }
                } 
                
            }
            
            try{
                Database.Update(updateDiscountList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
      }
      
      // Revenue changes
      public void revenueChanges(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){
          
          //Map<Id, Proposal__c> propMap = getProposalMap(newList);
          Map<Id, Proposal__c> propMap;
          if(!staticpropMap.isEmpty()) {
            propMap = staticpropMap;
           }
          Set<Discount_List__c> updateDList = new Set<Discount_List__c>();
          //List<Discount_List__c> updateDList3 = new List<Discount_List__c>();
          Map<id,Discount_List__c> updateDList3Map = new Map<Id,Discount_List__c>();
          
          // Creating Map of Standard Discount Guidelines records
          Map<Id, List<Standard_Discount_Guidelines__c>> prodIdDiscMap = new Map<Id, List<Standard_Discount_Guidelines__c>>();
          List<Standard_Discount_Guidelines__c> allDiscountGuidelines = [SELECT Id, Fare_Structure__c, Fare_Structure__r.ProductCode__c, Fare_Combination__c, Minimum_Revenue__c, Maximum_Revenue__c, Discount_Threshold_TL__c, Discount_Threshold_AM__c,Network__c,Segment__c, Discount_Threshold_NAM__c,Discount_Threshold_DO__c,Maximum_Forecast_QF_Share_Int_MCA__c,Minimum_Forecast_QF_Share_Int_MCA__c FROM Standard_Discount_Guidelines__c where Active__c=true];    
          for(Standard_Discount_Guidelines__c dG : allDiscountGuidelines){
            if(!prodIdDiscMap.containsKey(dG.Fare_Structure__c)) prodIdDiscMap.put(dG.Fare_Structure__c, new List<Standard_Discount_Guidelines__c>());
            prodIdDiscMap.get(dG.Fare_Structure__c).add(dG);
          }
          
          for(Proposal__c prop : newList){
              
      //*****************************************************************************************************************************************************************************************************
        //CRM-2270 : Proposal Approvals are not Correct (Added the below 'for' condition to copy the Forecast QF spend from Proposal to associated Proposal Fare Discount )
        //Added By : Vinoth Balasubramanian
        //Date     : 08/09/2016 (DD/MM/YYYY) 
        //******************************************************************************************************************************************************************************************************
          
               for(Discount_List__c dls : propMap.get(prop.Id).Fare_Structure_Lists__r){
              if(prop.Qantas_Annual_Expenditure__c != oldMap.get(prop.Id).Qantas_Annual_Expenditure__c){
                    dls.Qantas_Annual_Expenditures__c = prop.Qantas_Annual_Expenditure__c;
                               //updateDList3.add(dls);
                               updateDList3Map.put(dls.id,dls);
                           }
                        }
                           

              if(prop.Qantas_Annual_Expenditure__c != oldMap.get(prop.Id).Qantas_Annual_Expenditure__c || prop.Forecast_MCA_Revenue__c != oldMap.get(prop.Id).Forecast_MCA_Revenue__c ||
               prop.International_Annual_Share__c!= oldMap.get(prop.Id).International_Annual_Share__c || prop.MCA_Routes_Annual_Share__c!= oldMap.get(prop.Id).MCA_Routes_Annual_Share__c ){
                  System.debug('&&&&& Discount List: '+propMap.get(prop.Id).Fare_Structure_Lists__r);
                  for(Discount_List__c dl : propMap.get(prop.Id).Fare_Structure_Lists__r){

                      List<Standard_Discount_Guidelines__c> discountGuideList = prodIdDiscMap.get(dl.FareStructure__c);
                      if(discountGuideList != null){
                          for(Standard_Discount_Guidelines__c discountGuide : discountGuideList){
        //*****************************************************************************************************************************************************************************************************
        //CRM-2270 : Proposal Approvals are not Correct (Added the Product code Unique field in the below if condtion to avoid the Duplicate id's in a set )
        //Added By : Vinoth Balasubramanian
        //Date     : 07/09/2016 (DD/MM/YYYY) 
        //******************************************************************************************************************************************************************************************************
        //*****************************************************************************************************************************************************************************************************
        //CRM-2402    : Add International route deal and D classes to Domestic Trunk & Route deal 
        //Description : Added Two new Deals (MCA Route Deal & Non-MCA Route Deal)
        //Added By    : Priyadharshini Vellingiri
        //Date        : 08/03/2017 (DD/MM/YYYY) 
        //******************************************************************************************************************************************************************************************************
                // Changed Qantas_Annual_Expenditure__c from 300k to 250k only for Domestic as part of JIRA CRM-4466 (Stand down Period)
                              if(discountGuide != null && discountGuide.Fare_Combination__c == dl.Fare_Combination__c && discountGuide.Fare_Structure__r.ProductCode__c== dl.FareStructure__r.ProductCode__c){
                              System.debug(discountGuide+'   '+'**** Step 0'+prop.Qantas_Annual_Expenditure__c+'   '+discountGuide.Minimum_Revenue__c+'  '+discountGuide.Maximum_Revenue__c);
                              if((prop.Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && prop.Qantas_Annual_Expenditure__c <= discountGuide.Maximum_Revenue__c && prop.Qantas_Annual_Expenditure__c >= 250000 && discountGuide.Segment__c == 'Domestic')||
                   (prop.Qantas_Annual_Expenditure__c >= discountGuide.Minimum_Revenue__c && 
                    prop.Qantas_Annual_Expenditure__c <= discountGuide.Maximum_Revenue__c &&
                    prop.International_Annual_Share__c >= discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c && 
                    prop.International_Annual_Share__c <= discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c && prop.Qantas_Annual_Expenditure__c >= 250000 && discountGuide.Fare_Combination__c == 'International' && discountGuide.Network__c == 'Non-MCA')||
                   (prop.Forecast_MCA_Revenue__c >= discountGuide.Minimum_Revenue__c &&
                    prop.Forecast_MCA_Revenue__c <= discountGuide.Maximum_Revenue__c &&
                    prop.Qantas_Annual_Expenditure__c >= 300000 && discountGuide.Fare_Combination__c == 'INT Non MCA Route Deal' && discountGuide.Network__c == 'Non-MCA' && discountGuide.Segment__c == 'International')||
                    (prop.Forecast_MCA_Revenue__c >= discountGuide.Minimum_Revenue__c &&
                    prop.Forecast_MCA_Revenue__c <= discountGuide.Maximum_Revenue__c &&
                    prop.MCA_Routes_Annual_Share__c  >= discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c &&
                    prop.MCA_Routes_Annual_Share__c <= discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c && discountGuide.Fare_Combination__c == 'International' && discountGuide.Network__c == 'MCA')||
                   (prop.Forecast_MCA_Revenue__c >= discountGuide.Minimum_Revenue__c &&
                    prop.Forecast_MCA_Revenue__c <= discountGuide.Maximum_Revenue__c &&
                    prop.Qantas_Annual_Expenditure__c >= 300000&&
                    discountGuide.Fare_Combination__c == 'INT MCA Route Deal' && discountGuide.Network__c == 'MCA'&& discountGuide.Segment__c == 'International')) { 
                                  dL.Discount_Threshold_AM__c = discountGuide.Discount_Threshold_AM__c; 
                                  dL.Discount_Threshold_TL__c = discountGuide.Discount_Threshold_TL__c;  // CRM 2003 - To populate the Discount Threshold(TL) from Fare Discount guidelines to Proposal Fare discount.
                                  dL.Discount_Threshold_NAM__c = discountGuide.Discount_Threshold_NAM__c;
                                  dL.discount_threshold_do__c = discountguide.discount_threshold_do__c; // CRM 2003 - To populate the Discount Threshold(DO) from Fare Discount guidelines to Proposal Fare discount.
                                  dL.Maximum_Forecast_QF_Share_Int_MCA__c = discountGuide.Maximum_Forecast_QF_Share_Int_MCA__c;
                                  dL.Minimum_Forecast_QF_Share_Int_MCA__c = discountGuide.Minimum_Forecast_QF_Share_Int_MCA__c;
                                  //dL.Qantas_Annual_Expenditures__c = prop.Qantas_Annual_Expenditure__c;
                                  dL.Approved_by_NAM__c = false;
                                  dL.Approved_by_TL__c = false;
                                  dL.Approved_by_Pricing__c = false;
                                  dL.DO_Approved__c = false;
                                  dL.Approved_by_SBD__c = false;        //CRM 1989 SBD
                                  System.debug('*** Step1'+dL);
                                  updateDList.add(dl);
                              }else if(!updateDList.contains(dL)){
                                  dL.Discount_Threshold_AM__c = 0;
                                  dL.Discount_Threshold_TL__c = 0;
                                  dL.Discount_Threshold_NAM__c = 0;
                                  dL.discount_threshold_do__c = 0; // CRM 2003
                                  dL.Maximum_Forecast_QF_Share_Int_MCA__c = 0;
                                  dL.Minimum_Forecast_QF_Share_Int_MCA__c = 0;
                                  dL.Approved_by_NAM__c = false;
                                  dL.Approved_by_TL__c = false;
                                  dL.Approved_by_Pricing__c = false;
                                  dL.DO_Approved__c = false;
                                  dL.Approved_by_SBD__c = false;        //CRM 1989 SBD
                                  System.debug('*** Step2'+dL);
                                  updateDList.add(dL);
                              }
                              
                            
        //*****************************************************************************************************************************************************************************************************
        //CRM-2270 : Proposal Approvals are not Correct (Commented the below 'if' condition and added the condition above in this method )
        //Added By : Vinoth Balasubramanian
        //Date     : 08/09/2016 (DD/MM/YYYY) 
        //******************************************************************************************************************************************************************************************************
              
                               /*if(prop.Qantas_Annual_Expenditure__c != oldMap.get(prop.Id).Qantas_Annual_Expenditure__c){
                                    dl.Qantas_Annual_Expenditures__c = prop.Qantas_Annual_Expenditure__c;
                                    updateDList3.add(dl);
                               }
                               else if(!updateDList3.contains(dL)){
                               dl.Qantas_Annual_Expenditures__c = 0;
                               updateDList3.add(dl);
                               }*/
                              

                          }
                          System.debug('*****'+dl);
                          
                          }
                      }
                  }
              }
          }
          
          try{
              System.debug('Final List: *** '+updateDList);
              List<Discount_List__c> updateDList1 = new List<Discount_List__c>(updateDList);
              //Map<Id,Discount_List__c> updateDList1Map=new Map<Id,Discount_List__c>(updateDList1);
              
              //List<Discount_List__c> updateDList2 = new List<Discount_List__c>(updateDList3);
              //merging both discount list for update
              //Database.Update(updateDList1);
              updateDList3Map.putall(updateDList1);
              if(updateDList3Map!=null && updateDList3Map.values().size()>0)
              {
                Database.Update(updateDList3Map.values());
              }
              
              
          }catch(Exception e){
              System.debug('Exception Occured '+e.getMessage());
          }

      }
      
       public void statusChange(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap){
          
          for(Proposal__c prop : newList){
          
              // If Qantas Annual Expenditure changes flag off DO Approvd
              if(prop.Qantas_Annual_Expenditure__c != oldMap.get(prop.Id).Qantas_Annual_Expenditure__c && prop.Qantas_Annual_Expenditure__c < 250000 ){
                  prop.DO_Approved__c = false;
              }              
              
              // If Domestic Annual Share changes (Corporate Airfares)
              if( (prop.Domestic_Annual_Share__c != oldMap.get(prop.Id).Domestic_Annual_Share__c) || (prop.Standard__c != oldMap.get(prop.Id).Standard__c && prop.Standard__c != 'No') || (prop.Qantas_Club_Discount_Offer__c != oldMap.get(prop.Id).Qantas_Club_Discount_Offer__c && (prop.Qantas_Club_Discount_Offer__c != '20%' || prop.Qantas_Club_Discount_Offer__c != '25%' || prop.Qantas_Club_Discount_Offer__c != '30%')) || (prop.Frequent_Flyer_Status_Upgrade__c != oldMap.get(prop.Id).Frequent_Flyer_Status_Upgrade__c && prop.Frequent_Flyer_Status_Upgrade__c!= 'No') ){
                  prop.NAM_Approved1__c = false;
                  prop.TL_Approved__c = false; 
                  prop.Pricing_Approved1__c = false;
                  prop.DO_Approved__c = false;
                  prop.Approved_by_SBD__c = false;    //CRM 1989 SBD
              }
              
              // If Shares OR Standard OR QCDO OR FFSU Changes (Qantas Business Savings)
             
              if((prop.Domestic_Annual_Share__c != oldMap.get(prop.Id).Domestic_Annual_Share__c && prop.Domestic_Annual_Share__c != 90) || (prop.International_Annual_Share__c != oldMap.get(prop.Id).International_Annual_Share__c && prop.International_Annual_Share__c != 70) || (prop.MCA_Routes_Annual_Share__c != oldMap.get(prop.Id).MCA_Routes_Annual_Share__c && prop.MCA_Routes_Annual_Share__c != 70) || (prop.Standard__c != oldMap.get(prop.Id).Standard__c && prop.Standard__c != 'No') || (prop.Qantas_Club_Discount_Offer__c != oldMap.get(prop.Id).Qantas_Club_Discount_Offer__c && (prop.Qantas_Club_Discount_Offer__c != '20%' || prop.Qantas_Club_Discount_Offer__c != '25%' || prop.Qantas_Club_Discount_Offer__c != '30%')) || (prop.Frequent_Flyer_Status_Upgrade__c != oldMap.get(prop.Id).Frequent_Flyer_Status_Upgrade__c && prop.Frequent_Flyer_Status_Upgrade__c!= 'No')){                  
                  prop.TeamLead_Approved__c = false;
                  prop.SBD_Approved__c = false;
                  prop.QIS_Approved__c = false;
              }               
              
              // Update the Proposal Status to "Approval Required - Customer"
              // CRM 1992 - Added TeamLead_Approved__c for QBS and removed Leadership_Approved__c
              // CRM 1989 - SBD
              if((prop.TL_Approved__c != oldMap.get(prop.Id).TL_Approved__c || prop.TeamLead_Approved__c != oldMap.get(prop.Id).TeamLead_Approved__c || prop.Approved_by_SBD__c  != oldMap.get(prop.Id).Approved_by_SBD__c || prop.SBD_Approved__c  != oldMap.get(prop.Id).SBD_Approved__c || prop.NAM_Approved__c != oldMap.get(prop.Id).NAM_Approved__c || prop.DO_Approved__c != oldMap.get(prop.Id).DO_Approved__c || prop.Pricing_Approved__c != oldMap.get(prop.Id).Pricing_Approved__c) && (prop.Status__c == 'Draft' || prop.Status__c == 'Approval Required - Internal')){
                  Boolean namStatus = false;
                  Boolean doStatus = false;
                  Boolean teamleadstatus = false;
                  Boolean TLstatus = false;
                  Boolean pricingStatus = false;
                  Boolean SBDStatus = false;       // CRM 1989 - SBD  - CA
                  Boolean ManagerSBDStatus = false;   // CRM 1989 - SBD - QBS
                  Boolean otherStatus = false;
                  
                  if(prop.Approval_Required_TL__c == true){
                      teamleadstatus = true;
                      if(prop.TL_Approved__c == true){
                          teamleadstatus = false;
                      }
                  }
                  
                  // CRM 1992 Added TeamLead_Approved__c for QBS
                  if(prop.Approval_Required_Team_Lead__c == true){
                      TLstatus = true;
                      if(prop.TeamLead_Approved__c == true){
                          TLstatus = false;
                      }
                  }
                  
                  // CRM 1989 - SBD for CA
                  
                if(prop.Approval_Required_SBD__c == true){
                      SBDStatus = true;
                      if(prop.Approved_by_SBD__c  == true){
                          SBDStatus = false;
                      }
                  }
                  
                 // CRM 1989 - SBD for QBS
                  
                if(prop.Approval_Required_Manager_SBD__c == true){
                      ManagerSBDStatus = true;
                      if(prop.SBD_Approved__c  == true){
                          ManagerSBDStatus = false;
                      }
                  }
                  
                  if(prop.Approval_Required_NAM__c == true){
                      namStatus = true;
                      if(prop.NAM_Approved__c == true){
                          namStatus = false;
                      }
                  }
                  if(prop.Approval_Required_Deal_Optimization__c == true){
                      doStatus = true;
                      if(prop.DO_Approved__c == true){
                          doStatus = false;
                      }
                  }
                  if(prop.Approval_Required_Pricing__c == true){
                      pricingStatus = true;
                      if(prop.Pricing_Approved__c == true){
                          pricingStatus = false;
                      }
                  }
                  if(prop.Approval_Required_Others__c == true){
                      otherStatus = true;
                      if(prop.Leadership_Approved__c == true){
                          otherStatus = false;
                      }
                  }
                  //  CA
                  if(!namStatus && !doStatus && !pricingStatus && !otherStatus && !teamleadstatus && !SBDStatus){
                                   //Commented the below lines as the lgic is handled via workflow
                      //prop.Status__c = 'Acceptance Required - Customer';
                      //prop.RecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('CA - Approval Required - Customer').getRecordTypeId();
                  }
                  
                  // QBS
                 if(!namStatus && !doStatus && !pricingStatus && !otherStatus && !TLstatus && !ManagerSBDStatus){
                 //Commented the below lines as the lgic is handled via workflow
                     // prop.Status__c = 'Acceptance Required - Customer';
                      //prop.RecordTypeId = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get('QBS - Approval Required - Customer').getRecordTypeId();
                  }  
              }
          }
      }
      
      public void changeDiscountListRecordType(List<Proposal__c> newList){
          List<Discount_List__c> allDList = new List<Discount_List__c>();
          //Map<Id, Proposal__c> proposalMap = getProposalMap(newList);
          Map<Id, Proposal__c> proposalMap;
          if(!staticpropMap.isEmpty()) {
            proposalMap = staticpropMap;
           }
          String rType = Schema.SObjectType.Discount_List__c.getRecordTypeInfosByName().get('Approved - Customer').getRecordTypeId();
          
          for(Proposal__c p : newList){
              if(p.Status__c == 'Accepted by Customer' ){ // removed 'Rejected - Internal' and 'Rejected - External' as part of CRM-9581
                  for(Discount_List__c dl : proposalMap.get(p.Id).Fare_Structure_Lists__r){
                    //CRM-9795 introducing check before assignment to prevent CPU consumption
                    if(dl.RecordTypeId!=rType)
                    {
                            dl.RecordTypeId = rType;
                            allDList.add(dl);
                    }
                      
                  }              
              }
          }
          try{
              Database.Update(allDList);
          }catch(Exception e){
              System.debug('Error Occured: '+e.getMessage());
          }
      }
      
      private Map<Id, Proposal__c> getProposalMap(List<Proposal__c> newList){
            List<Id> propIds = new List<Id>();
            Map<Id, Proposal__c> propMap = new Map<Id, Proposal__c>();
            
            for(Proposal__c p: newList){
                propIds.add(p.Id);
            }
            for(Proposal__c prop : [SELECT Id, (SELECT Id,FareStructure__c, FareStructure__r.ProductCode__c, ApprovalRequired_Team_Lead__c ,TeamLead_Approved__c, RecordTypeId, Fare_Combination__c, Approved_by_NAM__c,Approval_Required_NAM__c,Approval_Required_Pricing__c,Approved_by_Pricing__c,Discount__c,Discount_Threshold_AM__c,Discount_Threshold_NAM__c,discount_threshold_do__c,Approved_by_TL__c, Discount_Threshold_TL__c,ApprovalRequired_Team_Lead_CA__c, ApprovalRequired_SBD_CA__c,ApprovalRequired_SBD_QBS__c,Approved_by_SBD__c,Rejected_by_SBD__c,SBD_Approved__c,SBD_Rejected__c,Approval_Required_DO__c, DO_Approved__c, DO_Rejected__c,Maximum_Forecast_QF_Share_Int_MCA__c, Minimum_Forecast_QF_Share_Int_MCA__c FROM Fare_Structure_Lists__r) FROM Proposal__c where Id IN:propIds]){
                propMap.put(prop.Id, prop);
            } 
            return propMap;
      }
    
     public void ApprovalRecall(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap)
     {
            //Map<Id, Proposal__c> propMap = getProposalMap(newList);  
            Map<Id, Proposal__c> propMap;
            if(!staticpropMap.isEmpty()) {
                propMap = staticpropMap;
               }      
           List<Discount_List__c> updateDiscountList = new List<Discount_List__c>();
            for(Proposal__c p: newList)
            {
                if(p.Approval_Recalled__c == 'Recalled' && oldMap.get(p.id).Approval_Recalled__c!=p.Approval_Recalled__c)
                  /* &&oldMap.get(p.id).Special_Condition_Approval_Recalled__c!=p.Special_Condition_Approval_Recalled__c 
                   && p.Special_Condition_Approval_Recalled__c!=null)*/
                {
                   /* p.DO_Approved__c = false;
                    p.NAM_Approved1__c = false;
                    p.Pricing_Approved1__c = false;
                    p.TeamLead_Approved__c =false;
                    p.SBD_Approved__c =false;
                    p.TL_Approved__c = false;*/
                    
                    for(Discount_List__c dL : propMap.get(p.Id).Fare_Structure_Lists__r){
                               dL.Approved_by_Pricing__c= false;
                               dL.Approved_by_SBD__c=false;
                               dL.Approved_by_TL__c=false;
                               dL.DO_Approved__c=false;
                               dL.SBD_Approved__c=false;
                               dL.TeamLead_Approved__c=false;
                               dL.Approved_by_NAM__c=false;
                               updateDiscountList.add(dL);
                           }                                
                }
            }
            try{
                Database.Update(updateDiscountList);
            }catch(Exception e){
                System.debug('Error Occured: '+e.getMessage());
            }
         
     }
    public void propSystemfields(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap)
     {
            //Map<Id, Proposal__c> propMap = getProposalMap(newList);  
            Map<Id, Proposal__c> propMap;
            if(!staticpropMap.isEmpty()) {
                propMap = staticpropMap;
               }      
           List<Discount_List__c> updateDiscountList = new List<Discount_List__c>();
            for(Proposal__c p: newList)
            {
                if(p.Approval_Recalled__c == 'Recalled' && oldMap.get(p.id).Approval_Recalled__c!=p.Approval_Recalled__c)
                  /* &&oldMap.get(p.id).Special_Condition_Approval_Recalled__c!=p.Special_Condition_Approval_Recalled__c 
                   && p.Special_Condition_Approval_Recalled__c!=null)*/
                {
                    p.DO_Approved__c = false;
                    p.NAM_Approved1__c = false;
                    p.Pricing_Approved1__c = false;
                    p.TeamLead_Approved__c =false;
                    p.SBD_Approved__c =false;
                    p.TL_Approved__c = false; 
                    p.Approved_by_SBD__c=false;
            }
            }
     }
}