# Seasonal Prediction on SST (ALT3) of the tropic Atlantic 

* ALT3 (20W-0W, 3S-3N) (pic of climatology)

## Prediction Skills ##
>> Evaluatable skills of the tropic Atlantic
>> Based on the available observations (__HadISST__)
>> Starts with one of models involved in the CPC NMME project.
 
* __NCEP-CFS__ (model version __2__) (24 members)
  * Skills we are going to look at:

    * SST ![](../figures/Tropical_Atlantic_SST/CFSv2_HadISST_Corr_ATL3.png)

    * Wind stress
    
    * Upper Ocean Heat Contant (0-300m, HC300)

  * Persistent Skills:

    * SST

    * Wind stress
    
    * Upper Ocean Heat Contant (0-300m, HC300)

  * Time series for November prediction on ALT3 (__?__):

    * SST

    * Wind stress
    
    * Upper Ocean Heat Contant (0-300m, HC300)


  * Skills that CPC uploaded. (They uploaded globle skill map and anomalies. Not clear if this is useful for accessing the skills of regional index, ex: Nino 3.4)
    * SST
    * Two meter air temperature
    * Precipitation 

    * Questions/issues of the products
      
or is it purely monthly anomaly? (normally skill will be better if seasonal average is applied.)


#### thoughts ####
  * Should the energy budget be studied? 

caxis([MinVal MaxVal])
lim = get(gca,'clim');
mycmap = redblue((lim(2)-lim(1))*2*ICMAP);
acmap = mycmap(1:4:end,:); %acmap(end/2:(end/2+1),:) = 1;
colormap(acmap);

