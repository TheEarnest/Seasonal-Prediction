%% This one evaluates provided Forecast Skills
% With emphasis on regional differences

clc
clear all;
close all;

%% Comparing 2015 Forecast Skill @ Nino3, Lead 2, Init May

file ='/Home/siv24/dsc063/HiWi/CFSv2/MayIC_cfsv2_sst_skill.nc';
ncdisp(file);

lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = ncread(file,'time');
skill_may_02 = ncread(file,'sk2');

% Regrid to -180:180 Longitudes
lon(find(lon>180))=lon(find(lon>180))-360;
[lon,I]=sort(lon);
skill_may_02 = skill_may_02(I,:);

skills_n3 = skill_may_02(find(lon>=-170 & lon<=-120),find(lat>=-5 & lat<=5),:); % Switch between ATL3 and NINO3.4 here
lon_n3 = lon(find(lon>=-170 & lon<=-120));                                      % but remember to change plot labels further down
lat_n3 = lat(find(lat>=-5 & lat<=5));

close all

figure;
contourf(lon_n3, lat_n3, skills_n3',51,'linecolor','none')
c=colorbar
hold on
[C,h]=contour(lon_n3, lat_n3, skills_n3',[0.6,0.6],'k')
clabel(C,h)
hold on
plot([min(lon_n3) max(lon_n3)],[0 0],':k')
caxis([0 1])
set(c,'YTick',0:0.25:1)
set(gca,'fontsize',14)
title('CFSv2 Provided Skills @ NINO3.4, Init May, Lead 2')
% xlabel('Longitude')
% ylabel('Latitude')
% xlabels = ['20°W';'15°W';'10°W';' 5°W';' 0°W']
% ylabels = ['3°S';'2°S';'1°S';'Eq.';'1°N';'2°N';'3°N']
% set(gca,'XTick',-20:5:0,'XTickLabel',xlabels)
% set(gca,'YTick',-3:1:3,'YTickLabel',ylabels)

xlabel('Longitude')
ylabel('Latitude')
xlabels = ['170°W';'160°W';'150°W';'140°W';'130°W';'120°W']
ylabels = ['4°S';'2°S';'Eq.';'2°N';'4°N']
set(gca,'XTick',-170:10:-120,'XTickLabel',xlabels)
set(gca,'YTick',-4:2:4,'YTickLabel',ylabels)

hold on
geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])

print -dpng Skills_CFSv2_N34_May_L2.png