%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download data
flag_download_1=1;
if flag_download_1
%     websave('world1.csv', 'https://opendata.ecdc.europa.eu/covid19/casedistribution/csv','timeout',1);
    %         websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_dal_%d.%d.%s.pdf', serverAddress,dd_1,mm_1,yy),'timeout',1);
    
   websave('world.csv', 'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv','timeout',1); 
   
    movefile('world.csv',sprintf('%s/_json',WORKroot),'f');
end



% decode data
% filename = sprintf('%s/_json/world1.csv',WORKroot);
filename1 = sprintf('%s/_json/world.csv',WORKroot);
% 
% fout=fopen(filename1,'wt');
% fid=fopen(filename,'rt');
% l=fgetl(fid);
% while length(l)>2
%     if isempty(strfind(l,'Bonaire,'))    
%     fprintf(fout,'%s\n',l);
%     end
%     l=fgetl(fid);
% end
% fclose(fid);
% fclose(fout);



% [world.dateRep,world.day,world.month,world.year,world.cases,world.deaths,world.countriesAndTerritories,world.geoId,world.countryterritoryCode,world.popData2018,world.continentExp,world.cumnum] = textread(filename1,...
%     '%s%d%d%d%d%d%s%s%s%d%s%f','delimiter',',','headerlines',1);


[world.iso_code,world.continent,world.location,world.date,world.total_cases,world.new_cases,world.new_cases_smoothed,world.total_deaths,world.new_deaths,new_deaths_smoothed,world.total_cases_per_million,world.new_cases_per_million,world.new_cases_smoothed_per_million,world.total_deaths_per_million,world.new_deaths_per_million,world.new_deaths_smoothed_per_million,world.reproduction_rate,world.icu_patients,world.icu_patients_per_million,world.hosp_patients,world.hosp_patients_per_million,world.weekly_icu_admissions,world.weekly_icu_admissions_per_million,world.weekly_hosp_admissions,world.weekly_hosp_admissions_per_million,world.new_tests,world.total_tests,world.total_tests_per_thousand,world.new_tests_per_thousand,world.new_tests_smoothed,world.new_tests_smoothed_per_thousand,world.positive_rate,world.tests_per_case,world.tests_units,world.total_vaccinations,world.people_vaccinated,world.people_fully_vaccinated,world.new_vaccinations,world.new_vaccinations_smoothed,world.total_vaccinations_per_hundred,world.people_vaccinated_per_hundred,world.people_fully_vaccinated_per_hundred,world.new_vaccinations_smoothed_per_million,world.stringency_index,world.population,world.population_density,world.median_age,world.aged_65_older,world.aged_70_older,world.gdp_per_capita,world.extreme_poverty,world.cardiovasc_death_rate,world.diabetes_prevalence,world.female_smokers,world.male_smokers,world.handwashing_facilities,world.hospital_beds_per_thousand,world.life_expectancy,world.human_development_index] = textread(filename1,...
    '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','delimiter',',','headerlines',1);


world.dateNum=datenum(world.date);
world.population=str2double(world.population);
world.total_cases_per_million=str2double(world.total_cases_per_million);
world.total_deaths_per_million=str2double(world.total_deaths_per_million);
world.new_cases_smoothed_per_million=str2double(world.new_cases_smoothed_per_million);
world.new_tests_smoothed_per_thousand=str2double(world.new_tests_smoothed_per_thousand);
world.positive_rate=str2double(world.positive_rate);
world.new_deaths_smoothed_per_million=str2double(world.new_deaths_smoothed_per_million);
world.hosp_patients_per_million=str2double(world.hosp_patients_per_million);
world.new_vaccinations_smoothed_per_million=str2double(world.new_vaccinations_smoothed_per_million);




% cut for minimum population
pop_tresh = 8000000;
indexOk = find(isfinite(world.dateNum) &world.population>pop_tresh & ~strcmp(world.location,cellstr('European Union')) & ~strcmp(world.location,cellstr('North America'))& ~strcmp(world.location,cellstr('South America')));
list_country =unique(world.location(indexOk));
list_day=unique(world.dateNum(indexOk));


worldData=struct;
worldData.timeNum(:,1) = list_day;
worldData.total_cases_per_million=nan(numel(list_day), numel(list_country));
worldData.total_deaths_per_million=nan(numel(list_day), numel(list_country));
worldData.new_cases_smoothed_per_million=nan(numel(list_day), numel(list_country));
worldData.new_tests_smoothed_per_thousand=nan(numel(list_day), numel(list_country));
worldData.positive_rate=nan(numel(list_day), numel(list_country));
worldData.new_deaths_smoothed_per_million=nan(numel(list_day), numel(list_country));
worldData.hosp_patients_per_million=nan(numel(list_day), numel(list_country));
worldData.new_vaccinations_smoothed_per_million=nan(numel(list_day), numel(list_country));


for k = 1 : size(list_country,1)
    idx_k=find(strcmp(world.location,list_country(k)));
    worldData.population(1,k)=world.population(idx_k(1));
    
    for l = 1 : numel(idx_k)
        date_l=world.dateNum(idx_k(l));
        idx_l=find(list_day==date_l);
        worldData.total_cases_per_million(idx_l,k)=world.total_cases_per_million(idx_k(l));
        worldData.total_deaths_per_million(idx_l,k)=world.total_deaths_per_million(idx_k(l));
        worldData.new_cases_smoothed_per_million(idx_l,k)=world.new_cases_smoothed_per_million(idx_k(l)); 
        worldData.new_tests_smoothed_per_thousand(idx_l,k)=world.new_tests_smoothed_per_thousand(idx_k(l)); 
        worldData.positive_rate(idx_l,k)=world.positive_rate(idx_k(l)); 
        worldData.new_deaths_smoothed_per_million(idx_l,k)=world.new_deaths_smoothed_per_million(idx_k(l));
        worldData.hosp_patients_per_million(idx_l,k)=world.hosp_patients_per_million(idx_k(l));
        worldData.new_vaccinations_smoothed_per_million(idx_l,k)=world.hosp_patients_per_million(idx_k(l));
    end
end




%% TOTAL CASES
n_lines=10;

[worstWeight,idx]=sort(worldData.total_cases_per_million(end,:),'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))


colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: casi totali allineato da 20 casi su 100.000

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di casi totali ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Casi totali per 100.000 abitanti')
a=[];

last_days=120;

last_days=length(worldData.timeNum)-1;

for reg = 1:size(idx_country_worst,2)
    reg
    regione = char(list_country(idx_country_worst(reg),1))
    
    y=(worldData.total_cases_per_million(:,idx_country_worst(reg))./10);
    y(isnan(y))=0;
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(list_country(idx(reg)));
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([10,y_lim(2)*1.1]);

xlabel('date');
ax=get(gca);

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento.PNG']);
close(gcf);
  






%% deceduti

[worstWeight,idx]=sort(worldData.total_deaths_per_million(end,:),'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))



date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di deceduti ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Deceduti per 100.000 abitanti')
a=[];

last_days=120;

last_days=length(worldData.timeNum)-1;

for reg = 1:size(idx_country_worst,2)
    reg
    regione = char(list_country(idx_country_worst(reg),1))
    
    y=(worldData.total_deaths_per_million(:,idx_country_worst(reg))./10);

    
    if y(end)~=nan
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(list_country(idx(reg)));
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
    end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([0,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecessiAndamento.PNG']);
close(gcf);

































%% daily cases
n_lines=10;


[worstWeight,idx]=sort(worldData.new_cases_smoothed_per_million(end,:),'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))


colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: casi giornalieri 

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di casi settimanali ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Casi giornalieri per 100.000 abitanti')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(idx_country_worst,2)
    reg
    regione = char(list_country(idx_country_worst(reg),1))
    
    y=(worldData.new_cases_smoothed_per_million(:,idx_country_worst(reg))./10);
    y(isnan(y))=0;
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(list_country(idx(reg)));
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([0,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento_mediamobile.PNG']);
close(gcf);
  














%% daily cases: specific
n_lines=10;

custom_list = {'Israel';'United Kingdom'};



colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: casi giornalieri 

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Casi giornalieri ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Casi giornalieri per 100.000 abitanti')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(custom_list,1)
    reg
    regione = char(custom_list(reg));
    idx_country_worst(reg)=find(strcmp(list_country,regione));
    
    y=(worldData.new_cases_smoothed_per_million(:,idx_country_worst(reg))./10);
    y(isnan(y))=0;
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(regione);
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(regione));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([00,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiSpecific.PNG']);
close(gcf);
  




% 
% 
% %% confronto tra stati: casi giornalieri 
% 
% date_s=list_day;
% h = figure;
% set(h,'NumberTitle','Off');
% title(sprintf('Nuove vaccinazioni ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
% set(h,'Position',[26 79 1632 886]);
% 
% hold on; grid on; grid minor;
% % xlabel('Giorni dal caso 10/100.000 ab');
% ylabel('Persone vaccinate ogni 100.000 abitanti')
% a=[];
% 
% last_days=size(worldData.timeNum,1)-1;
% 
% 
% for reg = 1:size(custom_list,1)
%     reg
%     regione = char(custom_list(reg));
%     idx_country_worst(reg)=find(strcmp(list_country,regione));
%     
%     y=(worldData.new_vaccinations_smoothed_per_million(:,idx_country_worst(reg)))./10;
% %     y=cumsum(y);
%     
%        try
% 
%         a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
%         
%         idxx=find(~isnan(y));idxx=idxx(end);
%         i = round(idxx/1)-1;
%         
%         % Get the local slope
%         d = (y(i+1)-y(i-3))/4;
%         X = diff(get(gca, 'xlim'));
%         Y = diff(get(gca, 'ylim'));
%         p = pbaspect;
%         a = atan(d*p(2)*X/p(1)/Y)*180/pi;
%         if ~isfinite(a)
%             a=90;
%         end
%         
%         % Display the text
%         count = char(regione);
%         count=strrep(count,'_',' ');
%         
%         
%         %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
%         text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
%         
%        catch
%            fprintf('error on %d: %s\n', reg, char(regione));           
%        end
% end
% 
% 
% 
% x_lim=get(gca,'xlim');
% xlim([worldData.timeNum(1),x_lim(2)]);
% % xlim([-10,120]);
% 
% y_lim=get(gca,'ylim');
% ylim([00,y_lim(2)*1.1]);
% 
% xlabel('date');
% 
% ax.XTick = (worldData.timeNum(1):5:x_lim(2));
% datetick('x', 'dd/mm/yyyy', 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',10);
% 
% 
% 
% % overlap copyright info
% datestr_now = datestr(now);
% annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
%     'String',{['Fonte: https://raw.githubusercontent.com']},...
%     'HorizontalAlignment','center',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off',...
%     'LineStyle','none',...
%     'Color',[0 0 0]);
% 
% annotation(gcf,'textbox',...
%     [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
%     'String',{'https://covidguard.github.io/#covid-19-italia'},...
%     'LineStyle','none',...
%     'HorizontalAlignment','left',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
% 
% 
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiSpecific.PNG']);
% close(gcf);
%   


%% daily death: specific
n_lines=10;

custom_list = {'United Kingdom';'Israel'};



colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: deceduti giornalieri 

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Deceduti giornalieri ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Deceduti giornalieri per 100.000 abitanti')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(custom_list,1)
    reg
    regione = char(custom_list(reg));
    idx_country_worst(reg)=find(strcmp(list_country,regione));
    
    y=(worldData.new_deaths_smoothed_per_million(:,idx_country_worst(reg))./10);
    y(isnan(y))=0;
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(regione);
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(regione));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([00,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecedutiDaySpecific.PNG']);
close(gcf);
  





%% hosp: specific
n_lines=10;

custom_list = {'United Kingdom';'Israel'};



colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: ospedalizzati

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Ospedalizzati  ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Ospedalizzati per 100.000 abitanti')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(custom_list,1)
    reg
    regione = char(custom_list(reg));
    idx_country_worst(reg)=find(strcmp(list_country,regione));
    
    y=(worldData.hosp_patients_per_million(:,idx_country_worst(reg))./10);

%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(regione);
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(regione));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([00,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleOspedalizzatiDaySpecific.PNG']);
close(gcf);
  




%% daily test: specific
n_lines=10;

custom_list = {'United Kingdom';'Israel'};



colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: casi giornalieri 

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Test giornalieri ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Test giornalieri per 100.000 abitanti')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(custom_list,1)
    reg
    regione = char(custom_list(reg));
    idx_country_worst(reg)=find(strcmp(list_country,regione));
    
    y=(worldData.new_tests_smoothed_per_thousand(:,idx_country_worst(reg))./10);

%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(regione);
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(regione));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([00,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'fontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleTestDaySpecific.PNG']);
close(gcf);
  



%% daily test: positive_rate
n_lines=10;

custom_list = {'United Kingdom';'Israel'};



colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end

%% confronto tra stati: casi giornalieri 

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Postive rate (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Positive rate (%)')
a=[];

last_days=size(worldData.timeNum,1)-1;


for reg = 1:size(custom_list,1)
    reg
    regione = char(custom_list(reg));
    idx_country_worst(reg)=find(strcmp(list_country,regione));
    
    y=(worldData.positive_rate(:,idx_country_worst(reg))*100);
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(regione);
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(regione));           
       end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([00,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'fontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_Positive rateSpecific.PNG']);
close(gcf);
  












%% deceduti

[worstWeight,idx]=sort(worldData.total_deaths_per_million(end,:),'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))



date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di deceduti ogni 100.000 abitanti (%s)',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 1632 886]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Deceduti per 100.000 abitanti')
a=[];

last_days=120;

last_days=length(worldData.timeNum)-1;

for reg = 1:size(idx_country_worst,2)
    reg
    regione = char(list_country(idx_country_worst(reg),1))
    
    y=(worldData.total_deaths_per_million(:,idx_country_worst(reg))./10);

    
    if y(end)~=nan
%     y=cumsum(y);
    
       try

        a(reg)=plot(worldData.timeNum(end-last_days:end), y(end-last_days:end),'LineWidth', 2.0, 'Color', colors{reg});
        
        idxx=find(~isnan(y));idxx=idxx(end);
        i = round(idxx/1)-1;
        
        % Get the local slope
        d = (y(i+1)-y(i-3))/4;
        X = diff(get(gca, 'xlim'));
        Y = diff(get(gca, 'ylim'));
        p = pbaspect;
        a = atan(d*p(2)*X/p(1)/Y)*180/pi;
        if ~isfinite(a)
            a=90;
        end
        
        % Display the text
        count = char(list_country(idx(reg)));
        count=strrep(count,'_',' ');
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',10);
        text(worldData.timeNum(end)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',10, 'color',  colors{reg});
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
    end
end



x_lim=get(gca,'xlim');
xlim([worldData.timeNum(1),x_lim(2)]);
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([10,y_lim(2)*1.1]);

xlabel('date');

ax.XTick = (worldData.timeNum(1):5:x_lim(2));
datetick('x', 'dd/mm/yyyy', 'keepticks') ;
set(gca,'XTickLabelRotation',53,'fontSize',10);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://raw.githubusercontent.com']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecessiAndamento.PNG']);
close(gcf);



% 
% %% worst rate last week
% rate=(worldData.data(end,:)-worldData.data(end-6,:))./worldData.data(end-6,:);
% 
% [rate_sort,idx_sort]=sort(rate,'descend');
% idx_sort(isnan(rate_sort))=[];
% rate_sort(isnan(rate_sort))=[];
% idx_sort(~isfinite(rate_sort))=[];
% rate_sort(~isfinite(rate_sort))=[];
% 
% bar(rate_sort(1:10))
% 
% 
% list_country(idx_sort(1:20),:)
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %% 
% idx_sweden = find(strcmp(list_country,'Sweden'));
% idx_norway = find(strcmp(list_country,'Norway'));
% idx_finland = find(strcmp(list_country,'Finland'));
% idx_italy = find(strcmp(list_country,'Italy'));
% 
% 
% k=0;
% i=1;
% 
% dead=[];
% 
% try
% for w=size(date_s,1):-7:1
%      k=k+1;
%      dead(k,1) = (sum(worldData.death(w-6:w,idx_sweden)))/worldData.population(idx_sweden)*1000000;
%      dead(k,2) = (sum(worldData.death(w-6:w,idx_norway)))/worldData.population(idx_norway)*1000000;
%      dead(k,3) = (sum(worldData.death(w-6:w,idx_finland)))/worldData.population(idx_finland)*1000000;
%      dead(k,4) = (sum(worldData.death(w-6:w,idx_italy)))/worldData.population(idx_italy)*1000000;
% end
% catch
% end
% 
% dead(isnan(dead))=0;
% 
% figure;
% hold on
% grid on
% a=plot(flip(dead),'-','linewidth',2);
% legend(a,'Sweden','Norway','Finland');
% xlim([8, size(dead,1)]);
% xlabel('week')
% ylabel('deaths over 1.000.000 people');
% 
% 
% 
% 
% 
% 
% %% 
% idx_uk = find(strcmp(list_country,'United_Kingdom'));
% idx_belgium = find(strcmp(list_country,'Belgium'));
% idx_spain = find(strcmp(list_country,'Spain'));
% idx_italy = find(strcmp(list_country,'Italy'));
% idx_usa = find(strcmp(list_country,'United_States_of_America'));
% idx_brazil = find(strcmp(list_country,'Brazil'));
% 
% k=0;
% i=1;
% 
% dead=[];
% 
% try
% for w=size(date_s,1):-7:1
%      k=k+1;
%      dead(k,1) = (sum(worldData.death(w-6:w,idx_uk)))/worldData.population(idx_uk)*1000000;
%      dead(k,2) = (sum(worldData.death(w-6:w,idx_belgium)))/worldData.population(idx_belgium)*1000000;
%      dead(k,3) = (sum(worldData.death(w-6:w,idx_spain)))/worldData.population(idx_spain)*1000000;
%      dead(k,4) = (sum(worldData.death(w-6:w,idx_italy)))/worldData.population(idx_italy)*1000000;
%      dead(k,5) = (sum(worldData.death(w-6:w,idx_usa)))/worldData.population(idx_usa)*1000000;
%      dead(k,6) = (sum(worldData.death(w-6:w,idx_brazil)))/worldData.population(idx_brazil)*1000000;
% end
% catch
% end
% 
% dead(isnan(dead))=0;
% 
% figure;
% hold on
% grid on
% a=plot(flip(dead),'-','linewidth',2);
% legend(a,'United Kingdom','Belgium','Spain','Italy','United States of America','Brazil');
% xlim([8, size(dead,1)-1]);
% xlabel('week')
% ylabel('deaths over 1.000.000 people');
% 









% death last 15 days and cases from 30 to 15 days
world_an=struct;
for k = 30:size(worldData.timeNum,1)
    
    world_an.cases15(k,:)=worldData.total_cases_per_million(k-15,:)-worldData.total_cases_per_million(k-29,:);
    world_an.death15(k,:)=worldData.total_deaths_per_million(k,:)-worldData.total_deaths_per_million(k-14,:);
    

end
world_an.ratio=world_an.death15./world_an.cases15;


customC_list = {'Italy'; 'Israel';'United States';'United Kingdom'};
customC_list = {'United Kingdom';'Israel'};

testo = struct;
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto % mortalità nuovi casi (15gg shift)')

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
clear a1_tot t_tot;


for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=world_an.ratio(1:end,idx_cR)*100;
    t1=worldData.timeNum(1:end);

    t_tot{reg}=t1;
    b1(reg)=plot(t1,y,'-','LineWidth', 3,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
%     b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=y;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s);',string_legend);
% eval(string_legend)


font_size = 10;
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% ylim([0 max(a1_tot(:))*1.1]);
ylabel('% deceduti 15 gg su casi di 15 gg prima', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);

set(gca, 'Xlim', [t1(1), t1(end)]);
datetick('x', datetickFormat) ;
set(gca, 'Xlim', [t1(1), t1(end)]);
ax.FontSize = font_size;

y_lim=ylim;
y_lim(1)=0;
ylim(y_lim);


for h=1:size(customC_list,1)
    a1_tot_h=[a1_tot{h}];
    idx_max=find(a1_tot_h==max(a1_tot_h))-10;
    i = idx_max(1);
    
    t_h=[t_tot{h}];
    % Get the local slope
    dy=a1_tot_h(i+1)-a1_tot_h(i-1);
    dx=t_h(i+1)-t_h(i-1);
    d = dy/dx;
    
    
    X = diff(get(gca, 'xlim'));
    Y = diff(get(gca, 'ylim'));
    p = pbaspect;
    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
  
    text(t_h(i), a1_tot_h(i), strrep(upper(char(customC_list(h))),'_',' '),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(customC_list,1)));

    
    end




% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://data.europa.eu']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

% ylim([0 40]);


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_andamentopercdec15.PNG']);
close(gcf);




























last10DaysIncrement=worldData.dataWeight(end,:)-worldData.dataWeight(end-10,:);


%% interpolazione e confronto tra paesi diversi: casi giornalieri
customC_list = {'Italy'; 'Israel';};

% customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'Brazil';'Chile';'United_States_of_America';'Peru';'United_Kingdom';'Mexico'};

% customC_list = {'Italy'; 'Sweden';'Spain';'France';'United_States_of_America';'United_Kingdom';'Germany'};

% customC_list = {'Sweden';'Norway';'Finland'};

% customC_list = {''};

testo = struct;
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto casi giornalieri')

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
clear a1_tot t_tot;

ytot=(worldData.dataWeight(:)*100000);
[a,b]=sort(ytot,'descend');


for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=(worldData.dataWeight(:,idx_cR)*100000);
    t1=worldData.timeNum;
    
    a1=movmean(y, 20, 'omitnan');
    t=t1;
    
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=40:size(t1,1)
%         if isfinite(y(i)) && y(i)>0
%             fprintf(fout,'%d;%d\n',t1(i),y(i));
%         end
%     end
%     fclose(fout);
% 
%     command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%     [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     

    t_tot{reg}=t;
    b1(reg)=plot(t1,y,'-','LineWidth', 3,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
%     b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=y;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s);',string_legend);
% eval(string_legend)


font_size = 10;
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% ylim([0 max(a1_tot(:))*1.1]);
ylabel('Numero casi giornalieri ogni 100.000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);

set(gca, 'Xlim', [t(1)+50, t(end)]);
datetick('x', datetickFormat) ;
set(gca, 'Xlim', [t(1)+50, t(end)]);
ax.FontSize = font_size;

y_lim=ylim;
y_lim(1)=0;
ylim(y_lim);


for h=1:size(customC_list,1)
    a1_tot_h=[a1_tot{h}];
    idx_max=find(a1_tot_h==max(a1_tot_h))-10;
    i = idx_max(1);
    
    t_h=[t_tot{h}];
    % Get the local slope
    dy=a1_tot_h(i+1)-a1_tot_h(i-1);
    dx=t_h(i+1)-t_h(i-1);
    d = dy/dx;
    
    
    X = diff(get(gca, 'xlim'));
    Y = diff(get(gca, 'ylim'));
    p = pbaspect;
    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
  
    text(t_h(i), a1_tot_h(i), strrep(upper(char(customC_list(h))),'_',' '),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(customC_list,1)));

    
    end




% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://data.europa.eu']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

% ylim([0 40]);


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento_mediamobile_ITA_ISR.PNG']);
close(gcf);








%% interpolazione e confronto tra paesi diversi: casi giornalieri: peggiori paesi

a=worldData.dataWeight; a(isnan(a))=0;

last10DaysIncrement=[sum(a(1:end,:))-sum(a(1:end-10,:))]';
[last10DaysIncrement, idxSort]=sort(last10DaysIncrement,'descend');

n_count = 10;

list_country(idxSort)

clear customC_list;

for k=1:n_count
    customC_list(k,1)=list_country(idxSort(k));
    
end


% customC_list = {'Italy'; 'Sweden';};
% 
% customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'Brazil';'Chile';'United_States_of_America';'Peru';'United_Kingdom';'Mexico'};

% customC_list = {'Italy'; 'Sweden';'Spain';'France';'United_States_of_America';'United_Kingdom';'Germany'};

% customC_list = {'Sweden';'Norway';'Finland'};

testo = struct;
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto casi giornalieri')

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
clear a1_tot t_tot;
for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=(worldData.dataWeight(:,idx_cR)*100000)./7;
    t1=worldData.timeNum;
    
    a1=movmean(y, 20, 'omitnan');
    t=t1;
    
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=40:size(t1,1)
%         if isfinite(y(i)) && y(i)>0
%             fprintf(fout,'%d;%d\n',t1(i),y(i));
%         end
%     end
%     fclose(fout);
% 
%     command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%     [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     

    t_tot{reg}=t;
    b1(reg)=plot(t1,y,'-','LineWidth', 3,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
%     b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=y;
    
end
string_legend='l=legend([b1]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s,''location'',''NorthWest'');',string_legend);
 eval(string_legend)


font_size = 10;
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% ylim([0 max(a1_tot(:))*1.1]);
ylabel('Numero casi giornalieri ogni 100.000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);

set(gca, 'Xlim', [t(1)+50, t(end)]);
datetick('x', datetickFormat) ;
set(gca, 'Xlim', [t(1)+50, t(end)]);
ax.FontSize = font_size;

y_lim=ylim;
y_lim(1)=0;
ylim(y_lim);


for h=1:size(customC_list,1)
    a1_tot_h=[a1_tot{h}];
    idx_max=find(a1_tot_h==max(a1_tot_h))-1;
    i = idx_max(1);
    
    t_h=[t_tot{h}];
    % Get the local slope
    dy=a1_tot_h(i)-a1_tot_h(i-1);
    dx=t_h(i)-t_h(i-1);
    d = dy/dx;
    
    
    X = diff(get(gca, 'xlim'));
    Y = diff(get(gca, 'ylim'));
    p = pbaspect;
    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
    text(t_h(i)-0.2, a1_tot_h(i)+2, strrep(upper(char(customC_list(h))),'_',' '),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(customC_list,1)));
end




% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://data.europa.eu']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

% ylim([0 80])

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento_mediamobile_worst10.PNG']);
close(gcf);






%% interpolazione e confronto tra paesi diversi: casi decessi
% customC_list = {'Italy'; 'Sweden';};

% customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'Brazil';'Chile';'United_States_of_America';'Peru';'United_Kingdom';'Mexico'};
% customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'United_States_of_America';'United_Kingdom'};

testo = struct;
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto deceduti giornalieri')

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
clear a1_tot t_to b;
for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=(worldData.deathWeight(:,idx_cR)*100000)./7;
    t1=worldData.timeNum;
    
    a1=movmean(y, 20, 'omitnan');
    t=t1;
    
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=40:size(t1,1)
%         if isfinite(y(i)) && y(i)>0
%             fprintf(fout,'%d;%d\n',t1(i),y(i));
%         end
%     end
%     fclose(fout);
% 
%     command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%     [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     

    t_tot{reg}=t;
    b(reg)=plot(t1,y,'-','LineWidth', 3,'color',Cmap.getColor(reg, size(customC_list,1)));

    window=7;
%     b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=y;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s,''location'',''NorthWest'');',string_legend);
eval(string_legend)


font_size = 10;
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% ylim([0 max(a1_tot(:))*1.1]);
ylabel('Numero decessi giornalieri ogni 100.000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);

set(gca, 'Xlim', [t(1)+50, t(end)]);
datetick('x', datetickFormat) ;
set(gca, 'Xlim', [t(1)+50, t(end)]);
ax.FontSize = font_size;

y_lim=ylim;
y_lim(1)=0;
ylim(y_lim);


for h=1:size(customC_list,1)
    a1_tot_h=[a1_tot{h}];
    idx_max=find(a1_tot_h==max(a1_tot_h));
    i = idx_max(1);
    
    t_h=[t_tot{h}];
    % Get the local slope
    dy=a1_tot_h(i)-a1_tot_h(i-1);
    dx=t_h(i)-t_h(i-1);
    d = dy/dx;
    
    
    X = diff(get(gca, 'xlim'));
    Y = diff(get(gca, 'ylim'));
    p = pbaspect;
    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
    text(t_h(i)-0.2, a1_tot_h(i)+0.02, strrep(upper(char(customC_list(h))),'_',' '),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(customC_list,1)));
end
% ylim([0 2.4]);



% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://data.europa.eu']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecessiAndamento_mediamobile.PNG']);
close(gcf);























































% 
% 
% %% radar regioni casi-deceduti
% 
% 
% 
% [worstWeight,idx]=sort(worldData.deathsSumWeight,'descend');
% idx_country_worst=idx(1:end);
% n_lines=size(idx_country_worst,2);
% % list_country(idx(1:end))
% % worldData.population(idx(1:end))
% 
% % worldData.dataSumWeight(idx_country_worst)
% 
% 
% colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
% colors={};
% for k=1:n_lines
%     colors{k}=Cmap.getColor(k, n_lines);
% end
% 
% 
% 
% figure;
% hold on
% id_f = gcf;
% set(id_f, 'Name', sprintf('Deceduti vs Casi totali'));
% title( sprintf('Deceduti vs Casi totali'));
% 
% 
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% 
% x_data=[];
% y_data=[];
% 
% y_data=worldData.deathsSumWeight(idx);
% x_data=worldData.dataSumWeight(idx);
%     
% 
% set(gca,'Xscale','log');
% set(gca,'Yscale','log');
% % 
% ylim([min(y_data) (max(y_data))*1.5])
% xlim([min(x_data) max(x_data)*1.5])
% 
% x = logspace(-10,log10(max(x_data)*1.5),500);
% 
% perc = [0.25 0.5 1 2 5 10 40];
% for p=1:size(perc,2)
%     y = x./100*perc(p);
%     hg = loglog(x,y,'--');
%     set(hg,'color',[0.831372549019608 0.815686274509804 0.784313725490196]);
% end
% 
% 
% 
% colors={};
% for k=1:n_lines
%     colors{k}=Cmap.getColor(k, n_lines);
% end
% % Init labels
% l=1;
% x = x_data;
% y = y_data;
% clear lbl;
% hold on;
% fontsize=10;
% for q=1:length(x)
%     %plot(x(q)',y(q)',markers{l},'w')
%     lbl(q) = text(x(q),y(q), upper(list_country(idx(q))),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
%     l=l+1;
%     if l==size(colors,2)
%         l=1;
%     end
% end
% ax=gca;
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';
% 
% 
% ylabel('Deceduti totali ogni 100.000 ab')
% xlabel('Casi totali ogni 100.000 ab')
% set(gcf,'color','w');
% 
% 
% datestr_now = datestr(now);
% annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
%     'String',{['Fonte: https://github.com/pcm-dpc']},...
%     'HorizontalAlignment','center',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off',...
%     'LineStyle','none',...
%     'Color',[0 0 0]);
% 
% annotation(gcf,'textbox',...
%     [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
%     'String',{'https://covidguard.github.io/#covid-19-italia'},...
%     'LineStyle','none',...
%     'HorizontalAlignment','left',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
% 
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_radarDecVSCasi.PNG']);
% close(gcf);







