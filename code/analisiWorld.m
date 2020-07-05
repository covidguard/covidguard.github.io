%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download data
flag_download_1=1;
if flag_download_1
    websave('world1.csv', 'https://opendata.ecdc.europa.eu/covid19/casedistribution/csv','timeout',1);
    %         websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_dal_%d.%d.%s.pdf', serverAddress,dd_1,mm_1,yy),'timeout',1);
    movefile('world1.csv',sprintf('%s/_json',WORKroot),'f');
end



% decode data
filename = sprintf('%s/_json/world1.csv',WORKroot);
filename1 = sprintf('%s/_json/world.csv',WORKroot);

fout=fopen(filename1,'wt');
fid=fopen(filename,'rt');
l=fgetl(fid);
while length(l)>2
    if isempty(strfind(l,'Bonaire,'))    
    fprintf(fout,'%s\n',l);
    end
    l=fgetl(fid);
end
fclose(fid);
fclose(fout);



[world.dateRep,world.day,world.month,world.year,world.cases,world.deaths,world.countriesAndTerritories,world.geoId,world.countryterritoryCode,world.popData2018,world.continentExp] = textread(filename1,...
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
    reg
    regione = char(list_country(idx_country_worst(reg),1))
    
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
customC_list = {'Italy'; 'Sweden'};

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
% xlim([-10,120]);

y_lim=get(gca,'ylim');
ylim([10,y_lim(2)*1.1]);

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

aligmnent=2;

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
    reg
    regione = char(list_country(idx_country_worst(reg),1))
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

xlabel('giorni dal decesso 2/100.000');






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











last10DaysIncrement=worldData.dataWeight(end,:)-worldData.dataWeight(end-10,:);


%% interpolazione e confronto tra paesi diversi: casi giornalieri
customC_list = {'Italy'; 'Sweden';};

customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'Brazil';'Chile';'United_States_of_America';'Peru';'United_Kingdom';'Mexico'};

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
    b1(reg)=plot(t1,y,':','LineWidth', 0.5,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
    b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=a1;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s);',string_legend);
% eval(string_legend)


font_size = 6.5;
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
    i = idx_max;
    
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento_mediamobile.PNG']);
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
    b1(reg)=plot(t1,y,':','LineWidth', 0.5,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
    b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=a1;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s);',string_legend);
% eval(string_legend)


font_size = 6.5;
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
    i = idx_max;
    
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleCasiAndamento_mediamobile_worst10.PNG']);
close(gcf);






%% interpolazione e confronto tra paesi diversi: casi decessi
customC_list = {'Italy'; 'Sweden';};

customC_list = {'Italy'; 'Sweden';'Spain';'Belgium';'France';'Brazil';'Chile';'United_States_of_America';'Peru';'United_Kingdom';'Mexico'};
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
clear a1_tot t_tot;
for reg = 1:size(customC_list,1)    
    regione = char(customC_list{reg});    
    idx_cR = find(strcmp(list_country,regione));
    
    y=(worldData.deathWeight(:,idx_cR)*100000);
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
    b1(reg)=plot(t1,y,':','LineWidth', 0.5,'color',Cmap.getColor(reg, size(customC_list,1)));
    window=7;
    b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(customC_list,1)));
    
    testo.sigla(reg,:)=(customC_list(reg));
%     testo.pos(reg,:)=[t(end)+((t(end)-t(40)))*0.01, sf(end)];
    a1_tot{reg}=a1;
    
end
string_legend='l=legend([b]';
for reg = 1:size(customC_list,1)
    regione = char(customC_list{reg});    
    regione_leg=strrep(regione,'_', ' ');
    string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
end
string_legend=sprintf('%s);',string_legend);
% eval(string_legend)


font_size = 6.5;
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
    idx_max=find(a1_tot_h==max(a1_tot_h))-10;
    i = idx_max;
    
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/World_totaleDecessiAndamento_mediamobile.PNG']);
close(gcf);









