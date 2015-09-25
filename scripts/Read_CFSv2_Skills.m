%% This one evaluates provided Forecast Skills
% With emphasis on different Starting Months and Lead Time

clc
clear all;
close all;

%% Import data

n=1
Nino = zeros(6);

list = dir('/Home/siv24/dsc063/HiWi/CFSv2/')
for i=[5 10:3:size(list)]
file = ['/Home/siv24/dsc063/HiWi/CFSv2/' list(i,1).name];
ncdisp(file);

lat = ncread(file,'lat');
lon = ncread(file,'lon');
time = ncread(file,'time');

skill_01 = ncread(file,'sk1');
skill_02 = ncread(file,'sk2');
skill_03 = ncread(file,'sk3');
skill_04 = ncread(file,'sk4');
skill_05 = ncread(file,'sk5');
skill_06 = ncread(file,'sk6');

% Regrid to -180:180 Longitudes
lon(find(lon>180))=lon(find(lon>180))-360;
[lon,I]=sort(lon);
skill_01 = skill_01(I,:);
skill_02 = skill_02(I,:);
skill_03 = skill_03(I,:);
skill_04 = skill_04(I,:);
skill_05 = skill_05(I,:);
skill_06 = skill_06(I,:);
clear I
clear ans

% Merge to one Array
skills = cat(3,skill_01,skill_02,skill_03,skill_04,skill_05,skill_06);
clear skill_01
clear skill_02
clear skill_03
clear skill_04
clear skill_05
clear skill_06
clear file
clear time

% for i=1:6
% % Plot
% figure;
% contourf(lon,lat,skills(:,:,i)',-0.5:0.025:1,'LineColor','none')
% c=colorbar
% caxis([-0.5 1])
% set(c,'YTick',-0.5:0.25:1)
% hold on
% geoshow('landareas.shp','FaceColor',[0.75 0.75 0.75])
% hold on
% rectangle('Position',[-15,-3,15,6])
% hold on
% plot([lon(1) lon(end)], [0 0], ':k')
% xlim([-60 30])
% ylim([-30 30])
% set(gca,'linewidth',2,'fontsize',14)
% xlabel('Longitude','fontweight','bold')
% ylabel('Latitude','fontweight','bold')
% set(gca,'XTick',-60:30:30,'YTick',-30:15:30)
% grid on
% title(['Lead Time: ' num2str(i) ' week'])
% eval(['print -dpng JulIC_Lead0' num2str(i) '.png']);
% end
% % Atlantic Nino3 (15W-0W, 3S-3N)

skills_n3 = skills(find(lon>=-20 & lon<=0),find(lat>=-3 & lat<=3),:);   % Switch between ATL3 and Nino 3.4 here
skills_n3 = squeeze(nanmean(nanmean(skills_n3)));
% figure
% % plot(1:6,skills_n3_2,'b')
% % hold on
% plot(1:6,skills_n3,'k')
% xlim([1 6])
% ylim([0 1])
% title('Forecast Skills @ Atlantic Nino3','fontsize',14)
% %legend('JulIC','AugIC')
% set(gca,'YTick',0:0.2:1)
% set(gca,'XTick',1:1:6)
% set(gca,'fontsize',14)
% xlabel('period [months]')
% %print -dpng SkillsNino3_NCEP.png

Nino(:,n)=skills_n3;
n=n+1;
end

figure
dates = [8 12 2 1 7 6 3 5]
[dates, I] = sort(dates);
Nino = Nino(:,[I(end) I(1:end-1)]);
dates = dates + 1
dates(end)=1
Nino3=NaN*zeros(6,12);
Nino3(:,dates([(end) (1:end-1)])) = Nino;
contourf(Nino3,51,'linecolor','none')
hold on
[X,Y] = contour(Nino3,[0.6 0.6],'linecolor','k')
clabel(X,Y)
caxis([0 1])
c=colorbar
set(c,'ytick',0:0.25:1)
xlim([1 9])
ylim([1 6])
set(gca,'XTick',1:9)
set(gca,'YTick',1:6)
Labels = ['Dec';'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug']
set(gca,'XTickLabel',Labels)
title('CFSv2 Provided Forecast Skills @ ATL3, 2015','fontsize',14)
ylabel('Lead Time [months]','fontsize',14)
xlabel('Starting Date','fontsize',14)
set(gca,'fontsize',14)
print -dpng SkillsATL3_CFSv2.png

clear list
clear n
clear i