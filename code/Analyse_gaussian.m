% mkdir([WORKroot,'/slides/img/regioni']);
% mkdir([WORKroot,'/slides/img/province']);
% mkdir('slides');
% mkdir('slides/img');
% mkdir('slides/img/province');
% mkdir('slides/img/regioni');
if ismac
    flag_download = false;
else
    flag_download = true;
end


%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download json from server
if flag_download
    delete(sprintf('%s/_json/*.json',WORKroot))
    
    serverAddress = 'https://raw.githubusercontent.com';
    
    command = sprintf('wget --no-check-certificate %s/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-province.json', serverAddress);
    system(command);
    
    command = sprintf('wget --no-check-certificate %s/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json', serverAddress);
    system(command);
    
    movefile('dpc-covid19-ita-province.json',sprintf('%s/_json',WORKroot),'f');
    movefile('dpc-covid19-ita-regioni.json',sprintf('%s/_json',WORKroot)),'f';
end

%% load population
%% ---------------
filename = fullfile(WORKroot, '_json', 'popolazione_province.txt');
[pop.id, pop.name, pop.number, pop.perc, pop.superf, pop.numCom, pop.sigla]=textread(filename,'%d%s%d%f%%%d%d%s','delimiter',';');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Regioni
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = sprintf('%s/_json/dpc-covid19-ita-regioni.json',WORKroot);
fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};
file_scan=char(file_scan);

json_oneRaw='';
for i=1:size(file_scan,1)
    json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
end
dataReg = decodeJSON(json_oneRaw);
regioni_tot = unique(dataReg.denominazione_regione);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Province
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = sprintf('%s/_json/dpc-covid19-ita-province.json',WORKroot);
fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};
file_scan=char(file_scan);

json_oneRaw='';
json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
for i=1:size(file_scan,1)
    json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
%     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
end

dataProv = decodeJSON(json_oneRaw);
Regione_lista = unique(dataProv.denominazione_regione);


pop.popolazioneRegioniNome=cell('');
pop.popolazioneRegioniPop=[];
%% popolazione regioni
for kk = 1:size(Regione_lista,1)
    idx = find(strcmp(dataProv.denominazione_regione,Regione_lista(kk)));
    prov_della_regione=unique(dataProv.sigla_provincia(idx));
    [prov_della_regione, ixs]=setdiff(prov_della_regione,cellstr(''));
    
    pop.popolazioneRegioniPop(kk)=0;
    pop.popolazioneRegioniNome(kk)=Regione_lista(kk);
    for jj=1:size(prov_della_regione,1)
        idx=find(strcmp(pop.sigla,prov_della_regione(jj)));
        pop.popolazioneRegioniPop(kk)=pop.popolazioneRegioniPop(kk)+pop.number(idx);
    end
end



%% GRAFICI SINGOLA REGIONE
mediamobile_yn=0;
for reg=1:size(regioni_tot,1)
    try        
        regione = char(regioni_tot(reg,1));
        index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
        time_num = fix(datenum(dataReg.data(index)));
        
        %% figura cumulata
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', [regione ': dati cumulati']);
        if mediamobile_yn==0
            title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))
        else
            title(sprintf([regione ': dati cumulati (media mobile)\\fontsize{5}\n ']))
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        if mediamobile_yn==0
            try
                a=plot(time_num,dataReg.ricoverati_con_sintomi(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num,dataReg.totale_casi(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
                c=plot(time_num,dataReg.dimessi_guariti(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(3, 8));
                d=plot(time_num,dataReg.deceduti(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(4, 8));
                e=plot(time_num,dataReg.terapia_intensiva(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(5, 8));
                f=plot(time_num,dataReg.totale_ospedalizzati(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(6, 8));
                g=plot(time_num,dataReg.isolamento_domiciliare(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(7, 8));
                h=plot(time_num,dataReg.totale_attualmente_positivi(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
            catch
                a=plot(time_num,str2double(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num,str2double(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
                c=plot(time_num,str2double(dataReg.dimessi_guariti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(3, 8));
                d=plot(time_num,str2double(dataReg.deceduti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(4, 8));
                e=plot(time_num,str2double(dataReg.terapia_intensiva(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(5, 8));
                f=plot(time_num,str2double(dataReg.totale_ospedalizzati(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(6, 8));
                g=plot(time_num,str2double(dataReg.isolamento_domiciliare(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(7, 8));
                h=plot(time_num,str2double(dataReg.totale_attualmente_positivi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
                
            end
        else
            
            b=plot(time_num,movmean(dataReg.totale_casi(index,1), 3, 'omitnan') ,'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
            a=plot(time_num,movmean(dataReg.ricoverati_con_sintomi(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
            b=plot(time_num,movmean(dataReg.totale_casi(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
            c=plot(time_num,movmean(dataReg.dimessi_guariti(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(3, 8));
            d=plot(time_num,movmean(dataReg.deceduti(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(4, 8));
            e=plot(time_num,movmean(dataReg.terapia_intensiva(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(5, 8));
            f=plot(time_num,movmean(dataReg.totale_ospedalizzati(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(6, 8));
            g=plot(time_num,movmean(dataReg.isolamento_domiciliare(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(7, 8));
            h=plot(time_num,movmean(dataReg.totale_attualmente_positivi(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
        end
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        ax.XTick = time_num;
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        t_lim=ylim;
        if t_lim(2)<100
            ylim([t_lim(1) 100]);
        end
        
        %     l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
        l=legend([b,a,c,d,e,f,g,h],'Totale Casi','Ricoverati con sintomi','Dimessi Guariti','Deceduti','Terapia intensiva','Totale ospedalizzati','Isolamento domiciliare','Attualmente positivi');
        set(l,'Location','northwest')
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
        
        %%
        % %     cd([WORKroot,'/assets/img/regioni']);
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_cumulati.PNG']);
        close(gcf);
        %     cd([WORKroot,'/code']);
        
        %% figura giornaliera
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', [regione ': dati cumulati']);
        if mediamobile_yn==0
            title(sprintf([regione ': progressione giornaliera\\fontsize{5}\n ']))
        else
            title(sprintf([regione ': progressione giornaliera (media mobile)\\fontsize{5}\n ']))
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        if mediamobile_yn==0
            try
                a=plot(time_num(2:end),diff(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
                c=plot(time_num(2:end),diff(dataReg.dimessi_guariti(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
                d=plot(time_num(2:end),diff(dataReg.deceduti(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
                e=plot(time_num(2:end),diff(dataReg.terapia_intensiva(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
                f=plot(time_num(2:end),diff(dataReg.totale_ospedalizzati(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
                g=plot(time_num(2:end),diff(dataReg.isolamento_domiciliare(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
                h=plot(time_num(2:end),diff(dataReg.totale_attualmente_positivi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
            catch
                
                a=plot(time_num(2:end),diff(str2double(dataReg.ricoverati_con_sintomi(index,1))),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num(2:end),diff(str2double(dataReg.totale_casi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
                c=plot(time_num(2:end),diff(str2double(dataReg.dimessi_guariti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
                d=plot(time_num(2:end),diff(str2double(dataReg.deceduti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
                e=plot(time_num(2:end),diff(str2double(dataReg.terapia_intensiva(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
                f=plot(time_num(2:end),diff(str2double(dataReg.totale_ospedalizzati(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
                g=plot(time_num(2:end),diff(str2double(dataReg.isolamento_domiciliare(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
                h=plot(time_num(2:end),diff(str2double(dataReg.totale_attualmente_positivi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
            end
            
        else
            a=plot(time_num(2:end),movmean(diff(dataReg.ricoverati_con_sintomi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
            b=plot(time_num(2:end-1),movmean(diff(dataReg.totale_casi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
            c=plot(time_num(2:end),movmean(diff(dataReg.dimessi_guariti(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
            d=plot(time_num(2:end),movmean(diff(dataReg.deceduti(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
            e=plot(time_num(2:end),movmean(diff(dataReg.terapia_intensiva(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
            f=plot(time_num(2:end),movmean(diff(dataReg.totale_ospedalizzati(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
            g=plot(time_num(2:end),movmean(diff(dataReg.isolamento_domiciliare(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
            h=plot(time_num(2:end),movmean(diff(dataReg.totale_attualmente_positivi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
        end
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        ax.XTick = time_num;
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        t_lim=ylim;
        if t_lim(2)<100
            ylim([t_lim(1) 100]);
        end
        
        %     l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
        l=legend([b,a,c,d,e,f,g,h],'Totale Casi','Ricoverati con sintomi','Dimessi Guariti','Deceduti','Terapia intensiva','Totale ospedalizzati','Isolamento domiciliare','Attualmente positivi');
        set(l,'Location','northwest')
        
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
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_giornalieri.PNG']);
        close(gcf);
    catch
    end
end





%% Regioni confronto

regioni_conf=struct;
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    regioni_conf.ricoverati_con_sintomi(reg) = dataReg.ricoverati_con_sintomi(index(end));
    regioni_conf.terapia_intensiva(reg) = dataReg.terapia_intensiva(index(end));
    regioni_conf.totale_ospedalizzati(reg) = dataReg.totale_ospedalizzati(index(end));
    regioni_conf.isolamento_domiciliare(reg) = dataReg.isolamento_domiciliare(index(end));
    regioni_conf.totale_attualmente_positivi(reg) = dataReg.totale_attualmente_positivi(index(end));
    regioni_conf.nuovi_attualmente_positivi(reg) = dataReg.nuovi_attualmente_positivi(index(end));
    regioni_conf.dimessi_guariti(reg) = dataReg.dimessi_guariti(index(end));
    regioni_conf.deceduti(reg) = dataReg.deceduti(index(end));
    regioni_conf.totale_casi(reg) = dataReg.totale_casi(index(end));
    regioni_conf.tamponi(reg) = dataReg.tamponi(index(end));
    
end

loop=struct;
loop.var={'ricoverati_con_sintomi';...
'terapia_intensiva';...
'totale_ospedalizzati';...
'isolamento_domiciliare';...
'totale_attualmente_positivi';...
'dimessi_guariti';...
'deceduti';...
'totale_casi';...
'tamponi';
};

loop.title={'Ricoverati con sintomi';...
'Terapia intensiva';...
'Totale ospedalizzati';...
'Isolamento domiciliare';...
'Totale attualmente positivi';...
'Dimessi guariti';...
'Deceduti';...
'Totale casi';...
'Tamponi';
};


for type= 1: size(loop.var,1)
    
    for kk=1:2
        if kk==1
            pesata=0;
        else
            pesata=1;
        end
        
        
        command = sprintf('[x,idx]=sort(regioni_conf.%s,''descend'');',char(loop.var(type)));
        eval(command);
        tick_all=regioni_tot(idx);
        
        idx1=[];
        for ll=1:length(tick_all)
            idx1(ll) = find(strcmp(pop.popolazioneRegioniNome, tick_all(ll)));
        end
        
        if pesata==1
            x=x./pop.popolazioneRegioniPop(idx1)*1000;            
            [x,idx1]=sort(x,'descend');
            tick_all=tick_all(idx1);
            
            
        end
        
        figure;
        id_f = gcf;
        if pesata==1
            command = sprintf('title(sprintf([''%s ogni 1000 abitanti (al '', datestr(time_num(end),''dd/mm''),'')\\\\fontsize{5}\\n '']));',char(loop.title(type)));eval(command);
        else
            command = sprintf('title(sprintf([''%s (al '', datestr(time_num(end),''dd/mm''),'')\\\\fontsize{5}\\n '']));',char(loop.title(type)));eval(command);
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        b=bar(x);
        hold on; grid minor
        set(gca,'XTick',1:size(regioni_tot,1))
        set(gca,'XTickLabel',tick_all)
        set(gca,'XLim',[0.5,size(regioni_tot,1)+0.5])
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        if pesata==1
            command = sprintf(' ylabel(''%s ogni 1000 abitanti'', ''FontName'', ''Verdana'', ''FontWeight'', ''Bold'',''FontSize'', 7);', char(loop.title(type)));eval(command);
        else
            command = sprintf(' ylabel(''%s'', ''FontName'', ''Verdana'', ''FontWeight'', ''Bold'',''FontSize'', 7);', char(loop.title(type)));eval(command);
        end
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        
        %% overlap copyright info
        datestr_now = datestr(now);
        annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        if pesata==1
            command = sprintf('print(gcf, ''-dpng'', [WORKroot,''/slides/img/regioni/regioni_pesata_'', num2str(type),''_'',char(loop.var(type)),''.png'']);');eval(command)
        else
            command = sprintf('print(gcf, ''-dpng'', [WORKroot,''/slides/img/regioni/regioni_'', num2str(type),''_'',char(loop.var(type)),''.png'']);');eval(command)
        end
        close(gcf);
    end
end


















%%%%%%%%%%%%%%%%%%
%% Province

% RegioneTot={'Genova','Imperia','Savona','La Spezia'}

% % RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}

% RegioneTot={'Padova','Brescia'}

normalizza_per_popolazione=0;
normalizza_per_densita = 0;
normalizza_per_superficie = 0;

dataReg=dataProv;
for reg = 1:size(Regione_lista)
    %%
    idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
    sigla_prov=dataReg.sigla_provincia(idx_reg);
    [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
    sigla_prov=sigla_prov(ixs);
    
    % find population
    [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
    
    %     RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}';
    %     RegioneTot={'Como','Bergamo','Brescia','Lecco'}'
    try
        %% figura cumulata
        for tipoGraph=1:3
            if tipoGraph==1
                normalizza_per_popolazione = 0;
            else
                normalizza_per_popolazione = 1;
            end
            
            datetickFormat = 'dd mmm';
            figure;
            id_f = gcf;
            set(id_f, 'Name', ['Cumulati']);
            title(sprintf([char(Regione_lista(reg)), ': Casi totali cumulati\\fontsize{5}\n ']))
            set(gcf,'NumberTitle','Off');
            set(gcf,'Position',[26 79 967 603]);
            grid on
            hold on
            b=[];
            string_legend='l=legend([b]';
            for h=1:size(RegioneTot,1)
                regione = char(RegioneTot(h));
                index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
                time_num = fix(datenum(dataReg.data(index)));
                if normalizza_per_popolazione==1
                    try
                        b(h)=plot(time_num,(dataReg.totale_casi(index,1)/pop.number(idx_pop(h)))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    catch
                        b(h)=plot(time_num,(str2double(dataReg.totale_casi(index,1))/pop.number(idx_pop(h)))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    end
                elseif normalizza_per_densita==1
                    try
                        b(h)=plot(time_num,(dataReg.totale_casi(index,1)/pop.number(idx_pop(h))*pop.superf(idx_pop(h))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    catch
                        b(h)=plot(time_num,(str2double(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*pop.superf(idx_pop(h))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    end
                elseif normalizza_per_superficie==1
                    try
                        b(h)=plot(time_num,(dataReg.totale_casi(index,1)/pop.superf(idx_pop(h))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    catch
                        b(h)=plot(time_num,(str2double(dataReg.totale_casi(index,1))/pop.superf(idx_pop(h))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    end
                else
                    try
                        b(h)=plot(time_num,dataReg.totale_casi(index,1),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    catch
                        b(h)=plot(time_num,str2double(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    end
                end
                regione_leg=regione;
                regione_leg(strfind(regione_leg,''''))=' ';
                regione_leg(strfind(regione_leg,'�'))='i';
                regione_leg(strfind(regione_leg,'�'))='i';
                regione_leg(strfind(regione_leg,'�'))='';
                
                
                string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            end
            string_legend=sprintf('%s);',string_legend);
            
            if ismac
                font_size = 9;
            else
                font_size = 6.5;
            end
            
            ax = gca;
            code_axe = get(id_f, 'CurrentAxes');
            set(code_axe, 'FontName', 'Verdana');
            set(code_axe, 'FontSize', font_size);
            ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
            if normalizza_per_popolazione==1
                ylabel('Numero casi x1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
            elseif normalizza_per_densita==1
                ylabel('Numero casi / abitanti *kmq', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
            elseif normalizza_per_superficie==1
                ylabel('Numero casi / kmq', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
            else
                ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
                t_lim=ylim;
                if t_lim(2)<100
                    ylim([t_lim(1) 100]);
                end
            end
            set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
            ax.XTick = time_num;
            datetick('x', datetickFormat, 'keepticks') ;
            set(gca,'XTickLabelRotation',53,'FontSize',6.5);
            ax.FontSize = font_size;
            
            eval(string_legend)
            
            % l=legend([b],'Totale Casi');
            set(l,'Location','northwest')
            %% overlap copyright info
            datestr_now = datestr(now);
            annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
                'String',{['Fonte: https://github.com/pcm-dpc']},...
                'HorizontalAlignment','center',...
                'FontSize',6,...
                'FontName','Verdana',...
                'FitBoxToText','off',...
                'LineStyle','none',...
                'Color',[0 0 0]);
            if normalizza_per_popolazione==1
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
            elseif normalizza_per_superficie==1
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_normSup_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
            else
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
            end
            
            close(gcf);
        end
        
        
        
        %% figura giornaliera
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', ['Giornalieri']);
        title(sprintf([char(Regione_lista(reg)), ': Casi totali progressione giornaliera\\fontsize{5}\n ']))
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        b=[];
        string_legend='l=legend([b]';
        
        testo=struct;
        
        for h=1:size(RegioneTot,1)
            regione = char(RegioneTot(h));
            %         index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
            index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
            time_num = fix(datenum(dataReg.data(index)));
            
            %         if normalizza_per_popolazione==1
            %             try
            %                 b(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            %             catch
            %                 bbbb=str2double(dataReg.totale_casi(index,1));
            %                 b(h)=plot(time_num(2:end),diff(bbbb)/pop.number(idx_pop(h))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            %             end
            %         else
            try
                b(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            catch
                bbbb=str2double(dataReg.totale_casi(index,1));
                b(h)=plot(time_num(2:end),diff(bbbb),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            end
            %         end
            regione_leg=regione;
            regione_leg(strfind(regione_leg,''''))=' ';
            regione_leg(strfind(regione_leg,'�'))='i';
            regione_leg(strfind(regione_leg,'�'))='';
            string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            code_axe = get(id_f, 'CurrentAxes');
            set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
            
            
            try
                sf=diff((dataReg.totale_casi(index,1)));
            catch
                sf=diff(str2double(dataReg.totale_casi(index,1)));
            end
            testo.sigla(h,:)=char(sigla_prov(h));
            testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
            testo.val(h,1)=sf(end);
            %          text(time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end),...
            %             test, 'HorizontalAlignment','left','FontSize',7','Color',[.3 .3 .3])
            
        end
        string_legend=sprintf('%s);',string_legend);
        eval(string_legend)
        
        
        [~,indext]=sort(testo.pos(:,2));
        for ll=1:size(indext,1)
            if ll/2==fix(ll/2)
                text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
                    ['------> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]);
            else
                text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
                    ['-> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]) ;
            end
        end
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
        set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
        ax.XTick = time_num;
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        t_lim=ylim;
        if t_lim(2)<100
            ylim([t_lim(1) 100]);
        end
        % l=legend([b],'Totale Casi');
        set(l,'Location','northwest')
        
        %% overlap copyright info
        datestr_now = datestr(now);
        annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
        close(gcf);
    catch
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    try
        %% progressione percentuale
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', ['Giornalieri']);
        title(sprintf([char(Regione_lista(reg)), ': Casi totali - incremento percentuale\\fontsize{5}\n ']))
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        b=[];
        string_legend='l=legend([b]';
        
        testo=struct;
        
        bar_all=[];
        tick_all=cell('');
        for h=1:size(RegioneTot,1)
            regione = char(RegioneTot(h));
            
            regione_leg=char(RegioneTot(h));
            regione_leg(strfind(regione_leg,''''))=' ';
            regione_leg(strfind(regione_leg,'�'))='i';
            regione_leg(strfind(regione_leg,'�'))='';
            tick_all(h,1)=cellstr(regione_leg);
            
            %         index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
            index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
            time_num = fix(datenum(dataReg.data(index)));
            
            
            a= dataReg.totale_casi(index,1);
            prog=[];
            for kkk=2:size(a,1)
                prog(kkk,1)=a(kkk)/a(kkk-1)*100-100;
            end
            bar_all(h,:)=[prog(end-4),prog(end-3), prog(end-2), prog(end-1),prog(end)];
            %             b(h)=bar(time_num,prog,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            
            regione_leg=regione;
            regione_leg(strfind(regione_leg,''''))=' ';
            string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            %             code_axe = get(id_f, 'CurrentAxes');
            %             set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
            
            sf=prog;
            testo.sigla(h,:)=char(sigla_prov(h));
            testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
            testo.val(h,1)=sf(end);
            %          text(time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end),...
            %             test, 'HorizontalAlignment','left','FontSize',7','Color',[.3 .3 .3])
            
        end
        
        if size(bar_all,1)==1
            reduce_yn=1;
            bar_all(2,:)=NaN;
        else
            reduce_yn=0;
        end
        
        
        b=bar(bar_all);
        cmap = Cmap.get('winter', 5);
        try
            for iii=1:5
                b(iii).FaceColor = cmap(6-iii,:);
            end
        catch
        end
        
        grid minor
        ylabel('Incremento percentuale ultimi giorni', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
        set(gca,'XTick',1:size(RegioneTot,1))
        set(gca,'XTickLabel',tick_all)
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        if reduce_yn
            set(gca,'XLim',[0.5, size(RegioneTot,1)+0.5]);
        else
            set(gca,'XLim',[0.5, 1+0.5]);
        end
        set(gca,'XLim',[0.5, size(RegioneTot,1)+0.5]);
        string_legend=sprintf('%s);',string_legend);
        eval(string_legend)
        
        l=legend(b,datestr(time_num(end-4),'dd-mmm'),datestr(time_num(end-3),'dd-mmm'),datestr(time_num(end-2),'dd-mmm'),datestr(time_num(end-1),'dd-mmm'),datestr(time_num(end),'dd-mmm'));
        set(l,'Location','northwest')
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        
        %% overlap copyright info
        datestr_now = datestr(now);
        annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_prog_perc_',char(Regione_lista(reg)) ,'_progressioneUltimoGiorno.PNG']);
        close(gcf);
    catch
    end
    
    
    
    
end


% mkdir('GRAPHS');
% movefile('*.PNG','GRAPHS','f');

