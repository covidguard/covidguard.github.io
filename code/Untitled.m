%% Regioni

filename = 'datiRegioni.txt';

fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};


i=0;
j=2;

dataReg=struct;




for j=2:length(file_scan)
    l=char(file_scan(j,:));
    i=i+1;
    
    a = textscan(l,'%s','delimiter','\t'); a=a{1};
    b=char(a(1));dataReg.data(i,1)  = cellstr(b(1:end-1));
    b=char(a(2));dataReg.stato(i,1) = cellstr(b(1:end-1));
    dataReg.codice_regione(i,1) = cellstr(a(3));
    b=char(a(4));dataReg.denominazione_regione(i,1) = cellstr(b(1:end-1));
    dataReg.lat(i,1)  = str2double(a(5));
    dataReg.long(i,1)  = str2double(a(6));
    dataReg.ricoverati_con_sintomi(i,1)  = str2double(a(7));
    dataReg.terapia_intensiva(i,1)  = str2double(a(8));
    dataReg.totale_ospedalizzati(i,1)  = str2double(a(9));
    dataReg.isolamento_domiciliare(i,1)  = str2double(a(10));
    dataReg.totale_attualmente_positivi(i,1)  = str2double(a(11));
    dataReg.nuovi_attualmente_positivi(i,1)  = str2double(a(12));
    dataReg.dimessi_guariti(i,1)  = str2double(a(13));
    dataReg.deceduti(i,1)  = str2double(a(14));
    dataReg.totale_casi(i,1)  = str2double(a(15));
    dataReg.tamponi(i,1)  = str2double(a(16));
end






regioni_tot = unique(dataReg.denominazione_regione)

for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    %% figura cumulata
    datetickFormat = 'dd-mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': dati cumulati']);
    title([regione ': dati cumulati'])
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    a=plot(time_num,dataReg.ricoverati_con_sintomi(index,1),'-b','LineWidth', 2.0);
    b=plot(time_num,dataReg.totale_casi(index,1),'-r','LineWidth', 2.0);
    c=plot(time_num,dataReg.dimessi_guariti(index,1),'-g','LineWidth', 2.0);
    d=plot(time_num,dataReg.deceduti(index,1),'-k','LineWidth', 2.0);
    
    code_axe = get(id_f, 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', 8);
    ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
    datetick('x', datetickFormat, 'keeplimits') ;
    
    l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
    set(l,'Location','northwest')
    %% overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.01426 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    print(gcf, '-dpng', ['reg_',regione, '_cumulati.PNG']);
    close(gcf);
    
    
    %% figura giornaliera
    datetickFormat = 'dd-mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': dati cumulati']);
    title([regione ': progressione giornaliera'])
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    a=plot(time_num(2:end),diff(dataReg.ricoverati_con_sintomi(index,1)),'-b','LineWidth', 2.0);
    b=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-r','LineWidth', 2.0);
    c=plot(time_num(2:end),diff(dataReg.dimessi_guariti(index,1)),'-g','LineWidth', 2.0);
    d=plot(time_num(2:end),diff(dataReg.deceduti(index,1)),'-k','LineWidth', 2.0);
    
    code_axe = get(id_f, 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', 8);
    ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
    datetick('x', datetickFormat, 'keeplimits') ;
    
    l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
    set(l,'Location','northwest')
    
    %% overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.01426 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    print(gcf, '-dpng', ['reg_',regione, '_giornalieri.PNG']);
    close(gcf);
    
end



% 
% 
% 
% 
% 
% %loop on all regions
% values_tot=[];
% regioni_tot=unique(dataReg.denominazione_regione);
% %% figura giornaliera
% datetickFormat = 'dd-mmm';
% figure;
% id_f = gcf;
% set(id_f, 'Name', ['Regioni: dati cumulati']);
% title(['Regioni: dati giornalieri'])
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% for r=1:size(regioni_tot)
%     regione = char(regioni_tot(r));
%     index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
%     time_num = fix(datenum(dataReg.data(index)));
%     
%     
%     
%     %     a=plot(time_num(2:end),diff(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0);
%     b=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0);
%     %     c=plot(time_num(2:end),diff(dataReg.dimessi_guariti(index,1)),'-g','LineWidth', 2.0);
%     %     d=plot(time_num(2:end),diff(dataReg.deceduti(index,1)),'-k','LineWidth', 2.0);
%     
%     code_axe = get(id_f, 'CurrentAxes');
%     set(code_axe, 'FontName', 'Verdana');
%     set(code_axe, 'FontSize', 8);
%     ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
%     set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
%     datetick('x', datetickFormat, 'keeplimits') ;
%     
%     g=diff(dataReg.ricoverati_con_sintomi(index,1));
%     g=diff(dataReg.totale_casi(index,1));
%     values_tot(r,1)=g(end);
%     
%     
% end
% 
% [values,index]=sort(values_tot,'descend');
% for r=1:length(values)
%     fprintf('%25s: %3d casi giornalieri\n', char(regioni_tot(index(r))),values(r) );
% end
% 
% 
% 
% %% overlap copyright info
% datestr_now = datestr(now);
% annotation(gcf,'textbox',[0.72342 0.01426 0.2381 0.04638],...
%     'String',{['Fonte: https://github.com/pcm-dpc']},...
%     'HorizontalAlignment','center',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off',...
%     'LineStyle','none',...
%     'Color',[0 0 0]);
% print(gcf, '-dpng', ['reiogni_giornalieri.PNG']);
% close(gcf);
% %     l=legend([a],'Ricoverati con sintomi');
% % %     l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
% %     set(l,'Location','northwest')
























%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%




%% Province

filename = 'datiProvince.txt';

fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};


i=0;
j=2;

dataReg=struct;




for j=2:length(file_scan)
    l=char(file_scan(j,:));
    i=i+1;
    
    a = textscan(l,'%s','delimiter','\t'); a=a{1};
    b=char(a(1));dataReg.data(i,1)  = cellstr(b(1:end-1));
    b=char(a(2));dataReg.stato(i,1) = cellstr(b(1:end-1));
    dataReg.codice_regione(i,1) = cellstr(a(3));
    b=char(a(4));dataReg.denominazione_regione(i,1) = cellstr(b(1:end-1));
    dataReg.codice_provincia(i,1) = cellstr(a(5));
    try
        b=char(a(6));dataReg.denominazione_provincia(i,1) = cellstr(b(1:end-1));
        b=char(a(7));dataReg.sigla_provincia(i,1) = cellstr(b(1:end-1));
        dataReg.lat(i,1)  = str2double(a(8));
        dataReg.long(i,1)  = str2double(a(9));
        dataReg.totale_casi(i,1)  = str2double(a(10));
    catch
    end
    
end


Regione_lista = unique(dataReg.denominazione_regione);


% RegioneTot={'Genova','Imperia','Savona','La Spezia'}

% RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}

% RegioneTot={'Padova','Brescia'}

for reg = 1:size(Regione_lista)
    idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
    RegioneTot= unique(dataReg.denominazione_provincia(idx_reg));
    RegioneTot=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
    RegioneTot={'Lucca';'Bergamo'}
    
    %% figura cumulata
    datetickFormat = 'dd-mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', ['Cumulati']);
    title([char(Regione_lista(reg)), ': Casi totali cumulati'])
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    b=[];
    string_legend='l=legend([b]';
    for h=1:size(RegioneTot,1)
        regione = char(RegioneTot(h));
        index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
        index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
        time_num = fix(datenum(dataReg.data(index)));
        b(h)=plot(time_num,dataReg.totale_casi(index,1),'-','LineWidth', 2.0);
        regione_leg=regione;
        regione_leg(strfind(regione_leg,''''))=' ';
        string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
    end
    string_legend=sprintf('%s);',string_legend);
    code_axe = get(id_f, 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', 8);
    ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
    datetick('x', datetickFormat, 'keeplimits') ;
    
    eval(string_legend)
    
    % l=legend([b],'Totale Casi');
    set(l,'Location','northwest')
    %% overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.01426 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    print(gcf, '-dpng', ['Province_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
    close(gcf);
    
    
    
    
    %% figura giornaliera
    datetickFormat = 'dd-mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', ['Giornalieri']);
    title([char(Regione_lista(reg)), ': Casi totali progressione giornaliera'])
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    b=[];
    string_legend='l=legend([b]';
    for h=1:size(RegioneTot,1)
        regione = char(RegioneTot(h));
        index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
        index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
        time_num = fix(datenum(dataReg.data(index)));
        b(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0);
        regione_leg=regione;
        regione_leg(strfind(regione_leg,''''))=' ';
        string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
    end
    string_legend=sprintf('%s);',string_legend);
    eval(string_legend)
    
    code_axe = get(id_f, 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', 8);
    ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
    datetick('x', datetickFormat, 'keeplimits') ;
    
    % l=legend([b],'Totale Casi');
    set(l,'Location','northwest')
    
    %% overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.72342 0.01426 0.2381 0.04638],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    print(gcf, '-dpng', ['Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
    close(gcf);
end


