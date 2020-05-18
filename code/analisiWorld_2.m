%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download data
flag_download_1=1;
if flag_download_1
    websave('world2.csv', 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv','timeout',1);
    %         websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_dal_%d.%d.%s.pdf', serverAddress,dd_1,mm_1,yy),'timeout',1);
    movefile('world2.csv',sprintf('%s/_json',WORKroot),'f');
end


% decode data
filename = sprintf('%s/_json/world2.csv',WORKroot);

fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};
file_scan=char(file_scan);


world=struct;

i=1;
l=char(file_scan(i,:));
idx_comma=strfind(l,',');
ll=4;
k=0;
while ll<length(idx_comma)
    k=k+1;
    world.timestr(i,k)=cellstr(l(idx_comma(ll)+1:idx_comma(ll+1)-1));
    ll=ll+1;
end
world.timestr(i,k+1)=cellstr(l(idx_comma(ll)+1:end));
world.timestr=world.timestr';

world.dateNum=datenum(world.timestr,'mm/dd/yy');
 
 
for i = 2:size(file_scan,1)
    l=char(file_scan(i,:));
    l=strrep(l,'"Bonaire, Sint Eustatius and Saba",Netherlands','Bonaire Sint Eustatius and Saba,Netherlands');
    
    idx_comma=strfind(l,',');
    if idx_comma(1)==1
        world.name(i-1,1) = cellstr(l(idx_comma(1)+1:idx_comma(2)-1));
    else
       world.name(i-1,1) = cellstr(l(1:idx_comma(1)-1));
    end
    
    if strcmp(world.name(i-1,1),cellstr('"Bonaire'))
        world.name(i-1,1)=cellstr('Bonaire');
        i
        add=1;
    else
        add=0;
    end

    if strcmp(world.name(i-1,1),cellstr('"Korea'))
        world.name(i-1,1)=cellstr('Korea South');
        add=1;
    else
        add=0;
    end    
 
    
    
    lat_i = str2double(l(idx_comma(2+add)+1:idx_comma(3+add)-1));
    lon_i = str2double(l(idx_comma(3+add)+1:idx_comma(4+add)-1));
    
    ll=4+add;
    k=0;
    while ll<length(idx_comma)
        k=k+1;
        world.cases(i-1,k)=str2double(l(idx_comma(ll)+1:idx_comma(ll+1)-1));
        ll=ll+1;
    end
    world.cases(i-1,k+1)=str2double(l(idx_comma(ll)+1:end));
        

end

% % cut for minimum population
% pop_tresh = 5000000;
list_country =world.name;
list_day=world.dateNum;



%% TOTAL CASES
n_lines=20;

[worstWeight,idx]=sort(world.cases(:,end),'descend');
idx_country_worst=idx(1:n_lines);
list_country(idx(1:n_lines))



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


