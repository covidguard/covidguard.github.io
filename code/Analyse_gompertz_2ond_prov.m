

dataRegioni = dataReg;
dataProvince = dataProv;

regioni_tot = unique(dataRegioni.denominazione_regione);
province_tot = unique(dataProvince.denominazione_provincia);

province_tot=setdiff(province_tot,'Fuori Regione \/ Provincia Autonoma');
province_tot=setdiff(province_tot,'In fase di definizione\/aggiornamento');


timeTot_datenum=datenum(unique(dataReg.data));

tabelloneProvince = NaN(length(timeTot_datenum),length(province_tot));
tabelloneProvinceWeigth = NaN(length(timeTot_datenum),length(province_tot));


%% calcolo incrementi per provincia ogni 100.000 abitanti
for pr = 1:length(province_tot)
    
    idx=strcmp(dataProvince.denominazione_provincia, province_tot(pr));
    tabelloneProvince(:,pr)=dataProvince.totale_casi(idx);
    sigla = unique(dataProvince.sigla_provincia(find(idx)));
    
    tabelloneProvince(:,pr)=dataProvince.totale_casi(idx);
    idx=strcmp(pop.sigla, sigla);    
    tabelloneProvinceWeigth(:,pr)=tabelloneProvince(:,pr)./pop.number(idx)*100000;
end

% peggiori province degli ultimi 7 giorni

worst=tabelloneProvinceWeigth(end,:)-tabelloneProvinceWeigth(end-6,:);


[a,idx]=sort(worst,'descend');
province_tot(idx);


n_prv = 20;




%% incremento casi 7-giorni /100000 abitanti
figure
datetickFormat = 'dd mmm';
id_f = gcf;
set(id_f, 'Name', ['Incrementi settimanali']);
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[73 82 1812 966]);


start_t = length(timeTot_datenum)-60;


table0 =tabelloneProvinceWeigth(7:end,:);
table1 =tabelloneProvinceWeigth(1:end-6,:);

tableDiffSett = table0-table1;


table0 =tabelloneProvinceWeigth(14:end,:);
table1 =tabelloneProvinceWeigth(8:end-6,:);
table2 =tabelloneProvinceWeigth(1:end-13,:);


tablePercSett = (table0-table1)./(table1-table2)*100-100;



for k=1:n_prv
   
    subplot(5,4,k)
    hold on
    grid on

    inc = ceil((size(timeTot_datenum,1)-start_t)/25);
    
    a=bar(timeTot_datenum(7:end),tableDiffSett(:,idx(k)));
    a.BarWidth=1.1;
    set(gca,'XTick',timeTot_datenum(1:inc:end))
    set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    
    if strcmp(province_tot(idx(k)),cellstr('Forl\u00ec-Cesena'))
        provWrite=cellstr('Forlì-Cesena');
    else
        provWrite=province_tot(idx(k));
    end
    
    ylabel(provWrite);
    
    ylabel(provWrite);
    xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
    ylim([0,600]);
    
    plot([timeTot_datenum(7) timeTot_datenum(end)],[350 350],'-r');
    
end
annotation(gcf,'textbox',...
    [0.377379690949227 0.955486542443065 0.349441501103753 0.0351966873706017],...
    'String','Incremento 7 giorni dei Nuovi Casi Positivi su 100.000 abitanti',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Tahoma',...
    'FitBoxToText','off');

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
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
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleNuoviPositivi7g_PROVINCEWORST.PNG']);
close(gcf);















%% per regione
listaRegioni=unique(dataProvince.denominazione_regione);

for reg=1:length(listaRegioni)
    idx1=find(strcmp(dataProvince.denominazione_regione,listaRegioni(reg)));
    
    provList=unique(dataProvince.denominazione_provincia(idx1));
    provList=setdiff(provList,'Fuori Regione \/ Provincia Autonoma');
    provList=setdiff(provList,'In fase di definizione\/aggiornamento');
    

    %% incremento casi 7-giorni /100000 abitanti
    figure
    datetickFormat = 'dd mmm';
    id_f = gcf;
    set(id_f, 'Name', ['Incrementi settimanali']);
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[73 82 1812 966]);
    
    
    start_t = length(timeTot_datenum)-60;
    
   
    for k=1:length(provList)
        
        subplot(4,3,k)
        hold on
        grid on
        
        inc = ceil((size(timeTot_datenum,1)-start_t)/25);
        
        idx=find(strcmp(provList(k),province_tot));
        
        
        a=bar(timeTot_datenum(7:end),tableDiffSett(:,idx));
        a.BarWidth=1.1;
        set(gca,'XTick',timeTot_datenum(1:inc:end))
        set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        if strcmp(provList(k),cellstr('Forl\u00ec-Cesena'))
            provWrite=cellstr('Forlì-Cesena');
        else
            provWrite=provList(k);
        end
        
        ylabel(provWrite);
        xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
        ylim([0,600]);
        
        plot([timeTot_datenum(7) timeTot_datenum(end)],[350 350],'-r');
        
    end
    annotation(gcf,'textbox',...
        [0.132291666666667 0.955486542443066 0.774479166666667 0.0351966873706017],...
        'String',[char(listaRegioni(reg)) ' - Incremento 7 giorni dei Nuovi Casi Positivi su 100.000 abitanti'],...
        'LineStyle','none',...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'FontName','Tahoma',...
        'FitBoxToText','off');
    
        
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
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
    % %     cd([WORKroot,'/assets/img/regioni']);
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleNuoviPositivi7g_REG_' char(listaRegioni(reg)) '.PNG']);
    close(gcf);
    
    
end




    
    
    
    
    




%% per regione percentuale
listaRegioni=unique(dataProvince.denominazione_regione);

for reg=1:length(listaRegioni)
    idx1=find(strcmp(dataProvince.denominazione_regione,listaRegioni(reg)));
    
    provList=unique(dataProvince.denominazione_provincia(idx1));
    provList=setdiff(provList,'Fuori Regione \/ Provincia Autonoma');
    provList=setdiff(provList,'In fase di definizione\/aggiornamento');
    

    %% incremento casi 7-giorni /100000 abitanti percentuale
    figure
    datetickFormat = 'dd mmm';
    id_f = gcf;
    set(id_f, 'Name', ['Incrementi settimanali']);
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[73 82 1812 966]);
    
    
    start_t = length(timeTot_datenum)-60;
    
   
    for k=1:length(provList)
        
        subplot(4,3,k)
        hold on
        grid on
        
        inc = ceil((size(timeTot_datenum,1)-start_t)/25);
        
        idx=find(strcmp(provList(k),province_tot));
        
        
        a=bar(timeTot_datenum(14:end),tablePercSett(:,idx));
        a.BarWidth=1.1;
        set(gca,'XTick',timeTot_datenum(1:inc:end))
        set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        if strcmp(provList(k),cellstr('Forl\u00ec-Cesena'))
            provWrite=cellstr('Forlì-Cesena');
        else
            provWrite=provList(k);
        end
        
        ylabel(provWrite);
        xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
       ylim([-50,100]);
        
        plot([timeTot_datenum(7) timeTot_datenum(end)],[350 350],'-r');
        
    end
    annotation(gcf,'textbox',...
        [0.132291666666667 0.955486542443066 0.774479166666667 0.0351966873706017],...
        'String',[char(listaRegioni(reg)) ' - Incremento % 7 giorni dei Nuovi Casi Positivi su 100.000 abitanti'],...
        'LineStyle','none',...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'FontName','Tahoma',...
        'FitBoxToText','off');
    
        
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
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
    % %     cd([WORKroot,'/assets/img/regioni']);
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleNuoviPositivi7g_REGPERC_' char(listaRegioni(reg)) '.PNG']);
    close(gcf);
    
    
end




