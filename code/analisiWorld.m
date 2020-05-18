%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download data
flag_download_1=1;
if flag_download_1
    websave('world.csv', 'https://opendata.ecdc.europa.eu/covid19/casedistribution/csv','timeout',1);
    %         websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_dal_%d.%d.%s.pdf', serverAddress,dd_1,mm_1,yy),'timeout',1);
    movefile('world.csv',sprintf('%s/_json',WORKroot),'f');
end



% decode data
filename = sprintf('%s/_json/world.csv',WORKroot);



[world.dateRep,world.day,world.month,world.year,world.cases,world.deaths,world.countriesAndTerritories,world.geoId,world.countryterritoryCode,world.popData2018,world.continentExp] = textread(filename,...
    '%s%d%d%d%d%d%s%s%s%d%s','delimiter',',','headerlines',1);

l=[];
l_i=0;
world.dateNum=nan(size(world.dateRep,1),1);
for k = 1: size(world.dateRep,1)    
    try
    world.dateNum(k,1) = datenum(char(world.dateRep(k)),'dd/mm/yyyy');
    catch
        l_i=l_i+1;
        l(l_i)=k;
    end
end


% cut for minimum population
pop_tresh = 5000000;


indexOk = find(isfinite(world.dateNum) &world.popData2018>pop_tresh);
list_country =unique(world.countriesAndTerritories(indexOk));
list_day=unique(world.dateNum(indexOk));

worldData=struct;
worldData.timeNum(:,1) = list_day;
worldData.data=nan(numel(list_day), numel(list_country));
worldData.dataWeight=nan(numel(list_day), numel(list_country));
worldData.death=nan(numel(list_day), numel(list_country));
worldData.deathWeight=nan(numel(list_day), numel(list_country));
worldData.population=nan(1, numel(list_country));

for k = 1 : size(list_country,1)
    idx_k=find(strcmp(world.countriesAndTerritories,list_country(k)));
    worldData.population(1,k)=world.popData2018(idx_k(1));
    
    for l = 1 : numel(idx_k)
        date_l=world.dateNum(idx_k(l));
        idx_l=find(list_day==date_l);
        worldData.data(idx_l,k)=world.cases(idx_k(l));
        worldData.dataWeight(idx_l,k)=world.cases(idx_k(l))/world.popData2018(idx_k(l));
        worldData.death(idx_l,k)=world.deaths(idx_k(l));
        worldData.deathWeight(idx_l,k)=world.deaths(idx_k(l))/world.popData2018(idx_k(l));        
        
    end
end
temp=worldData.data;
temp(isnan(temp))=0;
worldData.dataSum = sum(temp);

temp=worldData.dataWeight;
temp(isnan(temp))=0;
worldData.dataSumWeight = sum(temp);


temp=worldData.death;
temp(isnan(temp))=0;
worldData.deathsSum = sum(temp);

temp=worldData.deathWeight;
temp(isnan(temp))=0;
worldData.deathsSumWeight = sum(temp);


%% TOTAL CASES
n_lines=20;

[worstWeight,idx]=sort(worldData.dataSumWeight,'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))

worldData.dataSumWeight(idx_country_worst)


colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end




%% confronto tra stati: casi totali allineato da 20 casi su 100.000

aligmnent=25;

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di casi totali per abitante %s',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 967 603]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Casi totali per 100.000 abitanti')
a=[];



for reg = 1:size(idx_country_worst,2)
    regione = char(list_country(idx_country_worst(reg),1));
    y=(worldData.dataWeight(:,idx_country_worst(reg))*100000);
    y(isnan(y))=0;
    y=cumsum(y);
    
       try
        aligmnent_reg=find(y>=aligmnent); aligmnent_reg=aligmnent_reg(1);
        
        a(reg)=plot([-aligmnent_reg:-aligmnent_reg+size(date_s,1)-1]', y,'LineWidth', 2.0, 'Color', colors{reg});
        
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
        text(-aligmnent_reg+size(date_s,1)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',7);
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end




% add custom country
customC_list = {'Brazil'; 'Russia';'China'};

for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=cumsum(worldData.dataWeight(:,idx_cR)*100000);
    
       try
        aligmnent_reg=find(y>=aligmnent); aligmnent_reg=aligmnent_reg(1);
        
        a(reg)=plot([-aligmnent_reg:-aligmnent_reg+size(date_s,1)-1]', y,'LineWidth', 2.0, 'Color', colors{reg});
        
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
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
        text(-aligmnent_reg+size(date_s,1)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',7);
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end





x_lim=get(gca,'xlim');
xlim([-10,x_lim(2)]);

xlabel('giorni dal caso 25/100.000');






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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento.PNG']);
close(gcf);
  








%% TOTAL DEATHS
n_lines=20;

[worstWeight,idx]=sort(worldData.dataSumWeight,'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))
worldData.population(idx(1:n_lines))

worldData.dataSumWeight(idx_country_worst)


colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:n_lines
    colors{k}=Cmap.getColor(k, n_lines);
end




%% confronto tra stati: morti allineato da 20 casi su 100.000

aligmnent=5;

date_s=list_day;
h = figure;
set(h,'NumberTitle','Off');
title(sprintf('Nazioni con maggior numero di deceduti totali per abitante %s',datestr(date_s(end),'dd/mm/yyyy')));
set(h,'Position',[26 79 967 603]);

hold on; grid on; grid minor;
% xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Deceduti per 100.000 abitanti')
a=[];



for reg = 1:size(idx_country_worst,2)
    regione = char(list_country(idx_country_worst(reg),1));
    y=(worldData.deathWeight(:,idx_country_worst(reg))*100000);
    y(isnan(y))=0;
    y=cumsum(y);
    
       try
        aligmnent_reg=find(y>=aligmnent); aligmnent_reg=aligmnent_reg(1);
        
        a(reg)=plot([-aligmnent_reg:-aligmnent_reg+size(date_s,1)-1]', y,'LineWidth', 2.0, 'Color', colors{reg});
        
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
        text(-aligmnent_reg+size(date_s,1)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',7);
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end




% add custom country
customC_list = {'Brazil'; 'Russia';'China'};

for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=cumsum(worldData.deathWeight(:,idx_cR)*100000);
    
       try
        aligmnent_reg=find(y>=aligmnent); aligmnent_reg=aligmnent_reg(1);
        
        a(reg)=plot([-aligmnent_reg:-aligmnent_reg+size(date_s,1)-1]', y,'LineWidth', 2.0, 'Color', colors{reg});
        
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
        
        
        %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
        text(-aligmnent_reg+size(date_s,1)-1+0.5, y(i)+d, sprintf('%s', count), 'rotation', a,'fontSize',7);
        
       catch
           fprintf('error on %d: %s\n', reg, char(list_country(idx(reg))));           
       end
end





x_lim=get(gca,'xlim');
xlim([-10,x_lim(2)]);

xlabel('giorni dal decesso 5/100.000');






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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecessiAndamento.PNG']);
close(gcf);


