%% This one evaluates NCEP-CFSv2 SST Forecast skills by a simple correlation (95% sign.) to HadISST Observations
% Focussing on the Nino 3.4 Region

clc
clear all
close all

file = '/Home/siv24/dsc063/HiWi/CFSv2/CFSv2-N34.nc'
ncdisp(file)

SST = ncread(file,'sst');
LON = ncread(file,'X');
LAT = ncread(file,'Y');
LEAD = ncread(file,'L');
TIME = ncread(file,'S');
MEM = ncread(file,'M');

date = datenum(1960,01+double(TIME),01);
datestr(date)
clear file

%% Short Check

% figure
% contourf(LON,LAT,squeeze(nanmean(SST(:,:,:,6,333),3))',51,'linecolor','none')
% c=colorbar
% hold on
% geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])
% title(['Ensemble Mean Hindcast ', datestr(datenum(1960,01+double(TIME(333)),01)), ', Lead ', num2str(LEAD(6))])


%% Pick out Atlantic Nino 3

sst_n34 = SST(find(LON >= -170 & LON <= -120), find(LAT>=-5 & LAT<=5),:,:,:);
lon_n34 = LON(find(LON >= -170 & LON <= -120));
lat_n34 = LAT(find(LAT>=-5 & LAT<=5));

%% And now check todo.txt

clim_n34 = NaN*zeros(size(lon_n34),size(lat_n34),size(LEAD),size(TIME));    % prepare ensemble averaged array
clim_n34_2 = NaN*zeros(size(lon_n34),size(lat_n34),size(LEAD),12);          % prepare monthly averaged array

for m=1:12
    for y=m:12:size(TIME)
        for l=1:size(LEAD)
            clim_n34(:,:,l,y) = squeeze(nanmean(sst_n34(:,:,:,l,y),3));              % average over ensemble members
        end
    end
    clim_n34_2(:,:,:,m) = nanmean(clim_n34(:,:,:,m:12:size(TIME)),4);       % DIM: LON x LAT x LEAD x MONTHS
end

%% Extracts Nino3

clim_nino = squeeze(squeeze(nanmean(nanmean(clim_n34_2))));

% figure
% contourf(clim_nino',24:0.25:30,'linecolor','none')
% c=colorbar
% set(gca,'Fontsize',14)
% xlabel('Lead Time [months]')
% ylabel('Start Date [month]')
% set(gca,'YTick',1:12,'XTick',1:10)
% title('Ensemble Mean SST Climatology')
% title(c,'°C','fontsize',14)

% print -dpng EnsebleMeanClimatology.png

%% Compute Ensemble Mean SST Anomaly Hindcasts

sst_ens = squeeze(nanmean(sst_n34,3));
sst_ano = NaN*sst_ens;
for y=1:12:size(TIME)
    sst_ano(:,:,:,y:y+11)=sst_ens(:,:,:,y:y+11)-clim_n34_2;
end
sst_ano_mean = squeeze(squeeze(nanmean(nanmean(sst_ano))));
sst_ano_lead2 = squeeze(sst_ano(:,:,2,:));      % lead month 2 only

% Detrend
for i=1:10
    sst_ano_mean_d(i,:) = detrend(sst_ano_mean(i,:));
end

dim=size(sst_ano_lead2)
for lo=1:dim(1)
    for la=1:dim(2)
        sst_ano_lead2_d(lo,la,:) = detrend(sst_ano_lead2(lo,la,:));
    end
end
clear dim

sst_ano_lead2_may_d = sst_ano_lead2_d(:,:,5:12:end);    % Pick out May

%% Final Desire
%sst_ano_mean_2 = reshape(sst_ano_mean_d',12,29,10);    % DIM: MONTH x YEAR x LEAD
sst_ano_mean_2 = sst_ano_mean_d';
% Detrended Anomalies of SST Hindcasts

%% Load HadSST Observations

file = '/Home/siv24/dsc063/HiWi/HadSST/HadSST_remap.nc'
ncdisp(file)
SST_Had = ncread(file,'sst');
SST_Had(find(SST_Had < -999))=NaN;
LON_Had = ncread(file,'longitude');
LAT_Had = ncread(file,'latitude');
TIME_Had = ncread(file,'time');

DATE_Had = datenum(1870,1,1+double(TIME_Had));

SST_Had_Atl = SST_Had(find(LON_Had >= -170 & LON_Had<= -120),find(LAT_Had >= -5 & LAT_Had<= 5),:);
LON_Had_Atl = LON_Had(find(LON_Had >= -170 & LON_Had<= -120));
LAT_Had_Atl = LAT_Had(find(LAT_Had >= -5 & LAT_Had<= 5));

%% Find fitting starting and ending date (before calculating Climatology!)

[T I_s] = min(abs(DATE_Had - date(1)))
[T I_e] = min(abs(DATE_Had - date(end)))
DATE_Had_2 = DATE_Had((I_s+1):(I_e+1) + 12);    % Keep one year in addition for the 

SST_Had = SST_Had(:,:,(I_s+1):(I_e+1) + 12);    % calculation of a correlation later

%% HadSST Climatology

SST_Had_clim = zeros(size(LON_Had),size(LAT_Had),12);
for m=1:12
    y=m:12:size(SST_Had,3);
    SST_Had_clim(:,:,m) = nanmean(SST_Had(:,:,y),3);
end

% figure
% contourf(LON_Had,LAT_Had,SST_Had_clim(:,:,2)',51,'linecolor','none')
% colorbar
% hold on
% geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])

%% Anomalies

SST_Had_Ano = NaN*SST_Had;


  for  m=1:12:size(SST_Had,3);
    SST_Had_Ano(:,:,m:m+11) = SST_Had(:,:,m:m+11) - SST_Had_clim(:,:,1:12);
  end

% figure
% contourf(LON_Had,LAT_Had,SST_Had_Ano(:,:,1600)',51,'linecolor','none')
% colorbar
% hold on
% geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])

%% Atlantic 3
SST_Had_Ano_N34 = SST_Had_Ano(find(LON_Had >= -170 & LON_Had<= -120),find(LAT_Had >= -5 & LAT_Had<= 5),:);
SST_Had_Ano_N34_m = detrend(squeeze(nanmean(nanmean(SST_Had_Ano_N34))));

dim=size(SST_Had_Ano_N34)
for lo=1:dim(1)
    for la=1:dim(2)
        SST_Had_Ano_N34_d(lo,la,:) = detrend(SST_Had_Ano_N34(lo,la,:)); % Detrend
    end
end

clearvars -except SST_Had_Ano_N34_m sst_ano_mean_2 date DATE_Had_2 sst_ano_lead2_may_d SST_Had_Ano_N34_d lon_n34 lat_n34

%% Going on with correlations

% figure
% plot(date,sst_ano_mean_2(:,1),'k')
% hold on
% plot(DATE_Had_2,SST_Had_Ano_Atl_m,'b')
% datetick('x')
% 
% figure
% plot(date+datenum(0,10,0),sst_ano_mean_2(:,10),'k')
% hold on
% plot(DATE_Had_2(11:end),SST_Had_Ano_Atl_m(11:end),'b')
% datetick('x')

%close all

%% Correlation of Averaged ATL3 Region

for i=1:10
    for m=1:12
    
%     figure(i)
%     plot(date+datenum(0,i,0),sst_ano_mean_2(:,i),'b')
%     hold on
%     plot(DATE_Had_2(i:end-(13-i)),SST_Had_Ano_N34_m(i:end-(13-i)),'k')
%     xlim([date(find(date == datenum(2000,01,01))) max(date)])
%     hold on
%     plot([min(xlim) max(xlim)], [0 0], ':k')
%     ylim([-1.5 1.5])
%     set(gca,'fontsize',14)
%     set(gca,'ytick',-1.5:0.5:1.5)
%     set(gca,'xtick',datenum(2000:2:2010,06,21))
%     set(gca,'xticklabel',2000:2:2010)
%     l=legend('NMME','HadISST')
%     set(l,'location','southeast')
%     title(['NMME (' num2str(i-0.5) ' months lead) vs. Observations @ ATL3'])
%     ylabel('Temperature Anomaly [°C]','fontsize',14)
%     
%     %eval(['print -dpng NMME_Obs' num2str(i) '.png']);
    
    COR{i,m} = corrcoef(SST_Had_Ano_N34_m((i-1)+m:12:end-(13-i)),sst_ano_mean_2(m:12:end,i));
    C(m,i) = COR{i,m}(1,2);
    end
end



% close all

figure
contourf(C',51,'linecolor','none')
c=colorbar
hold on
[C,h]=contour(C',[0.6,0.6],'k')
clabel(C,h)
caxis([0 1])
set(c,'YTick',0:0.25:1)
set(gca,'fontsize',14)
set(gca,'xtick',1:12,'ytick',1:10)
Labels = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec']
set(gca,'XTickLabel',Labels)
xlabel('Starting Date')
ylabel('Lead Time [months]')
title('Correlation CFSv2/HadISST @ NINO3.4, 1982-2010')
print -dpng CFSv2_HadISST_Corr_N34.png


% 
% figure
% plot(1:10,C,'b')
% hold on
% plot([1 10],[0.6 0.6],':k')
% ylim([0 1])
% xlim([1 10])
% set(gca,'fontsize',14)
% set(gca,'ytick',0:0.2:1)
% title(['Correlation of NMME & Observations @ ATL3'])
% ylabel('Correlation','fontsize',14)
% xlabel('Lead Time [months]','fontsize',14)
% % print -dpng NMME_Obs_Corr.png
% 
% SST_Had_Ano_Atl_m_d = detrend(SST_Had_Ano_Atl_m);
% 
% close all
% plot(SST_Had_Ano_Atl_m)
% hold on
% plot(SST_Had_Ano_Atl_m_d)

%% Pointwise Correlation of 2months lead starting May

dim=size(sst_ano_lead2_may_d)
for lo=1:dim(1)
    for la=1:dim(2)
        COR{lo,la} = corrcoef(SST_Had_Ano_N34_d(lo,la,6:12:end-12),sst_ano_lead2_may_d(lo,la,:));
        Cp(lo,la) = COR{lo,la}(1,2);
    end
end


% close all

figure
contourf(lon_n34, lat_n34, Cp',51,'linecolor','none')
c=colorbar
hold on
[C,h]=contour(lon_n34, lat_n34, Cp',[0.6,0.6],'k')
clabel(C,h)
hold on
plot([min(lon_n34) max(lon_n34)],[0 0],':k')
caxis([0 1])
set(c,'YTick',0:0.25:1)
set(gca,'fontsize',14)
title('Correlation CFSv2/HadISST @ NINO3.4, Init May, Lead 2')
hold on
geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])
xlabel('Longitude')
ylabel('Latitude')
xlabels = ['170°W';'160°W';'150°W';'140°W';'130°W';'120°W']
ylabels = ['4°S';'2°S';'Eq.';'2°N';'4°N']
set(gca,'XTick',-170:10:-120,'XTickLabel',xlabels)
set(gca,'YTick',-4:2:4,'YTickLabel',ylabels)

print -dpng CFSv2_Obs_Corr_May_L2_N34.png