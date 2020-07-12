% 
% %% -------------------------
% if ismac
%     WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
% else
%     WORKroot = sprintf('C:/Temp/Repo/covidguard');
% end
% 
% %% load population
% %% ---------------
% filename = fullfile(WORKroot, '_json', 'popolazione_province.txt');
% [pop.id, pop.name, pop.number, pop.perc, pop.superf, pop.numCom, pop.sigla]=textread(filename,'%d%s%d%f%%%d%d%s','delimiter',';');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Regioni
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% filename = sprintf('%s/_json/dpc-covid19-ita-regioni.json',WORKroot);
% fid       = fopen(filename, 'rt');
% file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
% fclose(fid);
% file_scan                             = file_scan{1};
% file_scan=char(file_scan);
% 
% json_oneRaw='';
% json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
% for i=1:size(file_scan,1)
%     json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
%     %     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
% end
% dataReg = decodeJSON(json_oneRaw);
% dataReg.dataa = char(dataReg.data);
% dataReg.dataa(:,11)=' ';
% dataReg.data=cellstr(dataReg.dataa);
% regioni_tot = unique(dataReg.denominazione_regione);
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Province
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filename = sprintf('%s/_json/dpc-covid19-ita-province.json',WORKroot);
% fid       = fopen(filename, 'rt');
% file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
% fclose(fid);
% file_scan                             = file_scan{1};
% file_scan=char(file_scan);
% 
% json_oneRaw='';
% json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
% for i=1:size(file_scan,1)
%     json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
%     %     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
% end
% 
% dataProv = decodeJSON(json_oneRaw);
% dataProv.dataa = char(dataProv.data);
% dataProv.dataa(:,11)=' ';
% dataProv.data=cellstr(dataProv.dataa);
% Regione_lista = unique(dataProv.denominazione_regione);
% 
% 
% pop.popolazioneRegioniNome=cell('');
% pop.popolazioneRegioniPop=[];
% %% popolazione regioni
% for kk = 1:size(Regione_lista,1)
%     idx = find(strcmp(dataProv.denominazione_regione,Regione_lista(kk)));
%     prov_della_regione=unique(dataProv.sigla_provincia(idx));
%     [prov_della_regione, ixs]=setdiff(prov_della_regione,cellstr(''));
%     
%     pop.popolazioneRegioniPop(kk)=0;
%     pop.popolazioneRegioniNome(kk)=Regione_lista(kk);
%     for jj=1:size(prov_della_regione,1)
%         idx=find(strcmp(pop.sigla,prov_della_regione(jj)));
%         pop.popolazioneRegioniPop(kk)=pop.popolazioneRegioniPop(kk)+pop.number(idx);
%     end
% end
% 





%% lombardia corretta
filelist = dir('C:\Temp\Repo\covidguard\_json\Lombardia_dati_corretti\*.txt');

%last 
[lombCorrettaLast.date,lombCorrettaLast.totaleCasi]=textread(sprintf('%s/%s','C:\\Temp\\Repo\\covidguard\\_json\\Lombardia_dati_corretti\\',filelist(end).name),'%s%f','delimiter','\t');
lombCorrettaLast.dateNum = datenum(lombCorrettaLast.date,'dd/mm/yyyy');


regione = 'Lombardia';
data=lombCorrettaLast.totaleCasi;
time_num=lombCorrettaLast.dateNum;
for type=2:3
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    fclose(fout);
    
    if type==3
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    elseif type==2
        command=sprintf('gomp_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
    end
    
    %% figura cumulata
    
    
    datetickFormat = 'dd mmm';
    figure;
    id_f = gcf;
    if type==1
        set(id_f, 'Name', [regione ': attualmente positivi']);
        title(sprintf([regione ': attualmente positivi\\fontsize{5}\n ']))
    elseif type==2
        set(id_f, 'Name', [regione ': totale casi']);
        title(sprintf([regione ': totale casi (Corretti)\\fontsize{5}\n ']))
    elseif type==3
        set(id_f, 'Name', [regione ': casi giornalieri']);
        title(sprintf([regione ': casi giornalieri  (Corretti)\\fontsize{5}\n ']))
    end
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    
    
    shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
    d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
    c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
    b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    a=plot(time_num,data,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
    
    
    
    if type==1 || type==3
        [max1, idxMaxa1]=max(a1); [max2, idxMaxa2]=max(a2); [max3, idxMaxa3]=max(a3);
        piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
        piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
        
        try
            idxMina1=find(round(a1(fix(size(a1,1)/5*4):end))<100)+fix(size(a1,1)/5*4); idxMina1=idxMina1(1);
            idxMina2=find(round(a2(fix(size(a2,1)/5*4):end))<100)+fix(size(a2,1)/5*4); idxMina2=idxMina2(1);
            idxMina3=find(round(a3(fix(size(a3,1)/5*4):end))<100)+fix(size(a3,1)/5*4); idxMina3=idxMina3(1);
        catch
            idxMina1=[];
            idxMina2=[];
            idxMina3=[];
        end
        
        zeroMin=min([t(idxMina1),t(idxMina2),t(idxMina3)]);
        zeroMax=max([t(idxMina1),t(idxMina2),t(idxMina3)]);
        
        if piccoMin<piccoMax
            picco = sprintf('Stima picco: %s-%s', datestr(piccoMin,'dd mmm'), datestr(piccoMax,'dd mmm'));
        else
            picco = sprintf('Stima picco: %s', datestr(piccoMin,'dd mmm'));
        end
        
        if piccoMin<piccoMax
            zero = sprintf('Stima <100 casi: %s-%s', datestr(zeroMin,'dd mmm'), datestr(zeroMax,'dd mmm'));
        else
            zero = sprintf('Stima <100 casi: %s', datestr(zeroMin,'dd mmm'));
        end
        
        annotation(gcf,'textbox',...
            [0.59875904860393 0.814262023217247 0.29886246122027 0.0845771144278608],...
            'String',{picco},...
            'LineStyle','none',...
            'HorizontalAlignment','right',...
            'FontSize',10,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        annotation(gcf,'textbox',...
            [0.59875904860393 0.779436152570481 0.29886246122027 0.0845771144278606],...
            'String',{zero},...
            'LineStyle','none',...
            'HorizontalAlignment','right',...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        
        
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
    ylimi=get(gca,'ylim');
    if type==3
         set(gca,'ylim',([0,3500]));
    else
    set(gca,'ylim',([0,ylimi(2)]));
    end
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    
    if type==1
        ylabel('Numero attualmente positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==2
        ylabel('Numero totale casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==3
        ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    end
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    if type==3
       set(gca,'xlim',([time_num(1)-4 time_num(end)+90+1])); 
    end
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax.FontSize = font_size;
    
    ax.FontSize = font_size;
    
    
    
%     l=legend([a,b,c,d],'Dati Reali',sprintf('Stima al %s',datestr(time_num(end),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-1),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-2),'dd mmm')));
%     
%     set(l,'Location','northwest')
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
    
    
    %%
    % %     cd([WORKroot,'/assets/img/regioni']);
    if type==1
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoAttPositivi_',regione, '_cumulati_CORRETTI.PNG']);
    elseif type==2
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasi_',regione, '_cumulati_CORRETTI.PNG']);
    elseif type==3
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_',regione, '_cumulati_CORRETTI.PNG']);
    end
    close(gcf);
    
end






%% italia senza la lombardia
dataRegTot = dataReg;
idx_sinlomb=find(~strcmp(dataReg.denominazione_regione,cellstr('Lombardia')));
idx_lomb=find(strcmp(dataReg.denominazione_regione,cellstr('Lombardia')));
% idx_lomb=find(strcmp(dataReg.denominazione_regione,cellstr('Marche')));

dataReg.data=dataReg.data(idx_sinlomb,:);
dataReg.stato=dataReg.stato(idx_sinlomb,:);
dataReg.codice_regione=dataReg.codice_regione(idx_sinlomb,:);
dataReg.denominazione_regione=dataReg.denominazione_regione(idx_sinlomb,:);
dataReg.lat=dataReg.lat(idx_sinlomb,:);
dataReg.long=dataReg.long(idx_sinlomb,:);
dataReg.ricoverati_con_sintomi=dataReg.ricoverati_con_sintomi(idx_sinlomb,:);
dataReg.terapia_intensiva=dataReg.terapia_intensiva(idx_sinlomb,:);
dataReg.totale_ospedalizzati=dataReg.totale_ospedalizzati(idx_sinlomb,:);
dataReg.isolamento_domiciliare=dataReg.isolamento_domiciliare(idx_sinlomb,:);
dataReg.totale_positivi=dataReg.totale_positivi(idx_sinlomb,:);
dataReg.variazione_totale_positivi=dataReg.variazione_totale_positivi(idx_sinlomb,:);
dataReg.nuovi_positivi=dataReg.nuovi_positivi(idx_sinlomb,:);
dataReg.dimessi_guariti=dataReg.dimessi_guariti(idx_sinlomb,:);
dataReg.deceduti=dataReg.deceduti(idx_sinlomb,:);
dataReg.totale_casi=dataReg.totale_casi(idx_sinlomb,:);
dataReg.tamponi=dataReg.tamponi(idx_sinlomb,:);
dataReg.casi_testati=dataReg.casi_testati(idx_sinlomb,:);
% dataReg.note_it=dataReg.note_it(idx_sinlomb,:);
% dataReg.note_en=dataReg.note_en(idx_sinlomb,:);
dataReg.dataa=dataReg.dataa(idx_sinlomb,:);

dataRegSinLomb = dataReg;
dataReg=dataRegTot;


dataRegLomb.data=dataReg.data(idx_lomb,:);
dataRegLomb.stato=dataReg.stato(idx_lomb,:);
dataRegLomb.codice_regione=dataReg.codice_regione(idx_lomb,:);
dataRegLomb.denominazione_regione=dataReg.denominazione_regione(idx_lomb,:);
dataRegLomb.lat=dataReg.lat(idx_lomb,:);
dataRegLomb.long=dataReg.long(idx_lomb,:);
dataRegLomb.ricoverati_con_sintomi=dataReg.ricoverati_con_sintomi(idx_lomb,:);
dataRegLomb.terapia_intensiva=dataReg.terapia_intensiva(idx_lomb,:);
dataRegLomb.totale_ospedalizzati=dataReg.totale_ospedalizzati(idx_lomb,:);
dataRegLomb.isolamento_domiciliare=dataReg.isolamento_domiciliare(idx_lomb,:);
dataRegLomb.totale_positivi=dataReg.totale_positivi(idx_lomb,:);
dataRegLomb.variazione_totale_positivi=dataReg.variazione_totale_positivi(idx_lomb,:);
dataRegLomb.nuovi_positivi=dataReg.nuovi_positivi(idx_lomb,:);
dataRegLomb.dimessi_guariti=dataReg.dimessi_guariti(idx_lomb,:);
dataRegLomb.deceduti=dataReg.deceduti(idx_lomb,:);
dataRegLomb.totale_casi=dataReg.totale_casi(idx_lomb,:);
dataRegLomb.tamponi=dataReg.tamponi(idx_lomb,:);
dataRegLomb.casi_testati=dataReg.casi_testati(idx_lomb,:);
% dataRegLomb.note_it=dataReg.note_it(idx_lomb,:);
% dataRegLomb.note_en=dataReg.note_en(idx_lomb,:);
dataRegLomb.dataa=dataReg.dataa(idx_lomb,:);










day_unique = unique(dataReg.data);
time_num=datenum(day_unique);
dataSoloLomb=NaN(size(day_unique,1),5);
dataItaliaSenzaLomb=NaN(size(day_unique,1),5);
totaleCasiSoloLomb=NaN(size(day_unique,1),1);
totaleCasiItaliaSenzaLomb=NaN(size(day_unique,1),1);
for k = 1: size(day_unique,1)
    index = find(strcmp(dataRegSinLomb.data,day_unique(k)));
    dataItaliaSenzaLomb(k,1)=sum(dataRegSinLomb.deceduti(index));
    dataItaliaSenzaLomb(k,2)=sum(dataRegSinLomb.terapia_intensiva(index));
    dataItaliaSenzaLomb(k,3)=sum(dataRegSinLomb.totale_ospedalizzati(index));
    dataItaliaSenzaLomb(k,4)=sum(dataRegSinLomb.isolamento_domiciliare(index));
    dataItaliaSenzaLomb(k,5)=sum(dataRegSinLomb.dimessi_guariti(index));
    totaleCasiItaliaSenzaLomb(k,1)=sum(dataRegSinLomb.totale_casi(index));
    
    index = find(strcmp(dataRegLomb.data,day_unique(k)));
    dataSoloLomb(k,1)=sum(dataRegLomb.deceduti(index));
    dataSoloLomb(k,2)=sum(dataRegLomb.terapia_intensiva(index));
    dataSoloLomb(k,3)=sum(dataRegLomb.totale_ospedalizzati(index));
    dataSoloLomb(k,4)=sum(dataRegLomb.isolamento_domiciliare(index));
    dataSoloLomb(k,5)=sum(dataRegLomb.dimessi_guariti(index));
    totaleCasiSoloLomb(k,1)=sum(dataRegLomb.totale_casi(index));    
end
    



datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Casi giornalieri')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(2:end),diff(totaleCasiItaliaSenzaLomb),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(2:end),diff(totaleCasiSoloLomb),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
        
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_1_casiGiornalieri.PNG']);
close(gcf);
       




% deceduti
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Deceduti giornalieri')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(2:end),diff(dataItaliaSenzaLomb(:,1)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(2:end),diff(dataSoloLomb(:,1)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero deceduti giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
        
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_2_decedutiGiornalieri.PNG']);
close(gcf);
       



% terapie intensive
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Terapie intensive')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(1:end),(dataItaliaSenzaLomb(:,2)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(1:end),(dataSoloLomb(:,2)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero terapie intensive', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
        
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_3_terapieIntensive.PNG']);
close(gcf);
       


% ospedalizzati
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Totale Ospedalizzati')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(1:end),(dataItaliaSenzaLomb(:,3)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(1:end),(dataSoloLomb(:,3)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero ospedalizzati', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
        
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_3_opedalizzati.PNG']);
close(gcf);
     



% isolamento domiciliare
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Isolamento domiciliare')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(1:end),(dataItaliaSenzaLomb(:,4)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(1:end),(dataSoloLomb(:,4)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero in isolamento domiciliare', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
        
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_4_isolamento_domiciliare.PNG']);
close(gcf);
     



% dimessi guariti
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: Dimessi-guariti')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(1:end),(dataItaliaSenzaLomb(:,5)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(1:end),(dataSoloLomb(:,5)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Dimessi-guariti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
 
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_5_dimessi_guariti.PNG']);
close(gcf);



% attualmente positivi
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Confronto Lombardia - resto Italia: attualmente positivi')
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

a=plot(time_num(1:end),(dataItaliaSenzaLomb(:,3)+dataItaliaSenzaLomb(:,4)),'.-b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(time_num(1:end),(dataSoloLomb(:,3)+dataSoloLomb(:,4)),'.-r','markersize',14);

font_size=8;
  ax = gca;
        code_axe = get(id_f, 'CurrentAxes');
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Attualmente positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

        set(gca,'xlim',([time_num(1) time_num(end)]));
        set(gca,'XTick',[time_num(1):3:time_num(end)]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        l=legend([a,b],'Resto d''Italia', 'Lombardia');
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
 
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/_confrontoItaliaLombardia_6_attualmente_positivi.PNG']);
close(gcf);


% 

% %% GRAFICI Italia senza lombardia
% mediamobile_yn=0;
% index_tot=[];
% 
% for reg=1:size(regioni_tot,1)
%     try
%         regione = char(regioni_tot(reg,1));
%         index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
%         time_num = fix(datenum(dataReg.data(index)));
%         index_tot=[index;index_tot];
%     end
% end
% index=index_tot;       
%         
% regione = 'Italia senza Lombardia';        
% 
%         
%         
%         
%         
%         
% 
% %% bars Nazionale
% day_unique = unique(dataReg.data);
% time_num=datenum(day_unique);
% data=NaN(size(day_unique,1),5);
% totaleCasi=NaN(size(day_unique,1),1);
% for k = 1: size(day_unique,1)
%     index = find(strcmp(dataReg.data,day_unique(k)));
%     data(k,1)=sum(dataReg.deceduti(index));
%     data(k,2)=sum(dataReg.terapia_intensiva(index));
%     data(k,3)=sum(dataReg.totale_ospedalizzati(index));
%     data(k,4)=sum(dataReg.isolamento_domiciliare(index));
%     data(k,5)=sum(dataReg.dimessi_guariti(index));
%     totaleCasi(k,1)=sum(dataReg.totale_casi(index));
%     
% end
% 
% 
% 
% 
% %% bars Nazionale
% day_unique = unique(dataReg.data);
% time_num=datenum(day_unique);
% data=NaN(size(day_unique,1),5);
% totaleCasi=NaN(size(day_unique,1),1);
% for k = 1: size(day_unique,1)
%     index = find(strcmp(dataReg.data,day_unique(k)));
%     data(k,1)=sum(dataReg.deceduti(index));
%     data(k,2)=sum(dataReg.terapia_intensiva(index));
%     data(k,3)=sum(dataReg.totale_ospedalizzati(index));
%     data(k,4)=sum(dataReg.isolamento_domiciliare(index));
%     data(k,5)=sum(dataReg.dimessi_guariti(index));
%     totaleCasi(k,1)=sum(dataReg.totale_casi(index));
%     
% end
% 
% 
% %% bar stacked: totale casi
% datetickFormat = 'dd mmm';
% figure;
% id_f = gcf;
% regione = 'Italia';
% set(id_f, 'Name', [regione ': dati cumulati']);
% title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))
% 
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% hold on
% grid minor; grid on
% 
% 
% bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,2)';data(:,4)';data(:,5)'];
% 
% bbbar = bar(bbb','stacked'); hold on
% set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
% set(bbbar(2),'FaceColor',[1 0 0]);
% set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
% set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
% set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);
% 
% if ismac
%     font_size = 9;
% else
%     font_size = 6.5;
% end
% 
% set(gca,'XTick',1:2:size(time_num,1));
% set(gca,'XTickLabel',datestr(time_num(1:2:end),'dd mmm'));
% set(gca,'XLim',[0.5,size(time_num,1)+0.5]);
% set(gca,'XTickLabelRotation',90,'FontSize',6.5);
% ax=gca;
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
% 
% ax = gca;
% set(ax, 'FontName', 'Verdana');
% set(ax, 'FontSize', font_size);
% 
% l=legend([bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
% set(l,'Location','northwest')
% % overlap copyright info
% datestr_now = datestr(now);
% annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
%     'String',{['Fonte: https://github.com/pcm-dpc']},...
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
% 
% % %     cd([WORKroot,'/assets/img/regioni']);
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_cumulati.PNG']);
% close(gcf);
% 
% 
% 
% %%
% data_interp=[];
% % interpolazione di ogni serie
% 
% %%
% data_interp=[];
% % interpolazione di ogni serie
% 
% % 2: terapia_intensiva
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data(i,2));
% end
% fclose(fout);
% %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
% %
% command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
% [t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
% 
% 
% 
% % 1: deceduti
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data(i,1));
% end
% fclose(fout);
% %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,1),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gomp_estim testIn_gauss.txt');system(command);
% [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% [t_1, idx1]= intersect(t_temp, t);
% data_interp(:,1)=data_interpTemp(idx1);
% 
% 
% % 3: ospedalizzati
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data(i,3));
% end
% fclose(fout);
% %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
% [t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
% 
% % 4: isolamento_domiciliare
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data(i,4));
% end
% fclose(fout);
% %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
% [t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
% 
% 
% % 5: dimessiGuariti
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data(i,5));
% end
% fclose(fout);
% %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,5),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gomp_estim testIn_gauss.txt');system(command);
% [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% [t_1, idx1]= intersect(t_temp, t);
% data_interp(:,5)=data_interpTemp(idx1);
% 
% 
% 
% % 6: CasiTotali
% fout=fopen('testIn_gauss.txt','wt');
% data6= [data(:,1)'+data(:,3)'+data(:,4)'+data(:,5)']';
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data6(i,1));
% end
% fclose(fout);
% %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% %     [t,data_interp(:,6),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
% 
% command=sprintf('gomp_estim testIn_gauss.txt');system(command);
% [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% [t_1, idx1]= intersect(t_temp, t);
% data_interp(:,6)=data_interpTemp(idx1);
% 
% 
% 
% 
% 
% t_min = time_num(1);
% t_max = time_num(end)+60;
% 
% idx=t_1>=t_min & t_1<=t_max;
% 
% 
% datetickFormat = 'dd mmm';
% figure;
% id_f = gcf;
% regione = 'Italia senza Lombardia';
% set(id_f, 'Name', [regione ': dati cumulati']);
% title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))
% 
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% hold on
% grid minor; grid on
% 
% bbb1=[data_interp(idx,1)';data_interp(idx,2)';data_interp(idx,3)';data_interp(idx,4)';data_interp(idx,5)';data_interp(idx,6)';data_interp(idx,3)'+data_interp(idx,4)'+data_interp(idx,2)'];
% bbb1(:,1:size(time_num,1)-3)=NaN;
% bbbar1 = plot(bbb1','--'); hold on
% set(bbbar1(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',1);
% set(bbbar1(2),'Color',[1 0 0],'linewidth',1);
% set(bbbar1(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',1);
% set(bbbar1(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',1);
% set(bbbar1(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',1);
% set(bbbar1(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',1);
% set(bbbar1(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',1);
% 
% hold on
% 
% bbb=[data(:,1)';data(:,2)';data(:,3)';data(:,4)';data(:,5)';data6';data(:,3)'+data(:,4)'+data(:,2)'];
% 
% bbbar = plot(bbb','-'); hold on
% set(bbbar(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',3);
% set(bbbar(2),'Color',[1 0 0],'linewidth',3);
% set(bbbar(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',3);
% set(bbbar(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',3);
% set(bbbar(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',3);
% set(bbbar(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',3);
% set(bbbar(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',3);
% 
% 
% 
% if ismac
%     font_size = 9;
% else
%     font_size = 6.5;
% end
% 
% fidx=find(idx);
% set(gca,'XTick',1:3:size(t(idx),1));
% set(gca,'XTickLabel',datestr(t(fidx(1):3:fidx(end)),'dd mmm'));
% set(gca,'XLim',[0.5,size(t(idx),1)+0.5]);
% set(gca,'XTickLabelRotation',90,'FontSize',6.5);
% ax=gca;
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
% 
% ax = gca;
% set(ax, 'FontName', 'Verdana');
% set(ax, 'FontSize', font_size);
% 
% l=legend([bbbar(6),bbbar(7),bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Casi Totali','Attualmente positivi','Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
% set(l,'Location','northwest')
% % overlap copyright info
% datestr_now = datestr(now);
% annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
%     'String',{['Fonte: https://github.com/pcm-dpc']},...
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
% 
% % %     cd([WORKroot,'/assets/img/regioni']);
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_linee_cumulati.PNG']);
% close(gcf);
% 
% 
% 
% 
% 
% 
% 
% 
% regioni_tot=regioni_totconLomb;


%% correlazione casi-tamponi
tolerance=0.07;

lag=NaN(size(time_num(2:end),1),21);

for reg=1:21
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    
    tamp_positivi = diff(dataReg.totale_casi(index,1));
    tamp_tot      = diff(dataReg.tamponi(index,1));
    tamp_tot(tamp_tot<0)=nan;
    
    tamp_positivi_perc = tamp_positivi./tamp_tot*100;
    tamp_positivi(tamp_positivi_perc>100 |(tamp_positivi_perc==-Inf) |(tamp_positivi_perc==Inf))=nan;
    tamp_tot(tamp_positivi_perc>100|(tamp_positivi_perc==-Inf) |(tamp_positivi_perc==Inf))=nan;
    tamp_positivi_perc(tamp_positivi_perc>100|(tamp_positivi_perc==-Inf) |(tamp_positivi_perc==Inf))=nan;
    
    t=time_num(2:end);
    
    y1=tamp_positivi;
    y2=tamp_positivi_perc;
    
    
    l1='Numero tamponi positivi giornalieri';
    l2='Percentuale tamponi positivi giornaliera';
    % l2='Terapie giornalieri';
    
    [a1_1] = splinerMat(t,y1,7);
    % figure;hold on
    % plot(t,y1,'.b');
    % plot(t,a1_1,'-r');
    
    
    [a1_2] = splinerMat(t,y2,7);
    % figure;hold on
    % plot(t,y2,'.b');
    % plot(t,a1_2,'-r');
    
    t_1_1=t;
    t_1_2=t;
    
    corrcoeff_tot=[];
    corrcoeff_tot2=[];
    
    for d=0:25
        a=corrcoef(a1_1(1:end-d),a1_2(d+1:end),'rows','complete');
        %         a=corrcoef(a1_1(1:end-d),a1_2(d+1:end),'rows','complete');
        corrcoeff_tot(d+1)=a(1,2);
    end
    
    for d=0:25
        a=corrcoef(a1_2(1:end-d),a1_1(d+1:end),'rows','complete');
        %         a=corrcoef(a1_1(1:end-d),a1_2(d+1:end),'rows','complete');
        corrcoeff_tot2(d+1)=a(1,2);
    end
    
    [coerrcoeff_max1, idx1]=max(corrcoeff_tot);
    [coerrcoeff_max2, idx2]=max(corrcoeff_tot2);
    
    if coerrcoeff_max1>coerrcoeff_max2
        offset_dec=idx1-1;
    else
        offset_dec=-idx2+1;
    end
    offset_dec=0;
    
    figure;
    id_f = gcf;
    set(gcf, 'Name', sprintf('%s: correlazione temporale',regione));
    
    
    % tt=title(sprintf([regione ': correlazione nuovi casi/deceduti giornalieri\\fontsize{5}\n ']),'fontsize',9)
    annotation(gcf,'textbox',...
        [0.130299896587384 0.890266851563407 0.722854188210962 0.0630182421227199],...
        'String',[regione ': correlazione numero tamponi positivi/percentuale tamponi positivi'],...
        'LineStyle','none',...
        'HorizontalAlignment','center',...
        'FontWeight','bold',...
        'FontSize',8,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    [ax,a,b] = plotxx(t,y1,t,y2);
    hold on
    
    ax1 = ax(1);
    ax2 = ax(2);
    
    set(gcf,'CurrentAxes',ax1)
    c=plot(t_1_1,a1_1,'-r');
    
    set(gcf,'CurrentAxes',ax2)
    d=plot(t_1_2,a1_2,'-b');
    
    %
    % a=plot(t,data_casiPositivi,'-ob','LineWidth', 2.0,'color',[0 0.200000002980232 0.600000023841858]); set(a,'markersize',6,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532]);
    % b=plot(t-offset_dec,data_deceduti,'-ob','LineWidth', 2.0,'color',[1 0.200000002980232 0.600000023841858],'Parent',ax2); set(b,'markersize',6,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
    
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    set(a,'marker','o','markersize',0.5,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 1,'LineStyle',':');
    set(b,'marker','o','markersize',0.5,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 1,'LineStyle',':');
    set(c,'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 2.0);
    set(d,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 2.0);
    
    
    
    set(gcf,'CurrentAxes',ax1)
    ylabel(l1, 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(ax1, 'FontName', 'Verdana');
    set(ax1, 'FontSize', font_size);
    
    % set(ax1,'ylim',([0,80]));
    ax1.XTick = datenum(time_num(1:2:end));
    datetick('x', 'dd mmm', 'keepticks') ;
    set(ax1,'xlim',([t(1),t(end)]));
    set(ax1,'XTickLabelRotation',53,'FontSize',6.5);
    set(ax1,'Xcolor',[0 0.447058826684952 0.74117648601532]);
    set(ax1,'Ycolor',[0 0.447058826684952 0.74117648601532]);
    ylims=get(ax1,'ylim');
    ylim(ax1,[0 ylims(2)]);
    
    
    set(gcf,'CurrentAxes',ax2)
    ylabel(l2, 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    set(ax2, 'FontName', 'Verdana');
    set(ax2, 'FontSize', font_size);
    % set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec-1]));
    % set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec-1]));
    % ax2.XTick = t(1:2:end)+offset_dec-1
    % set(ax2,'ylim',([0,80]));
    ax2.XTick = datenum(time_num(1:2:end))+offset_dec;
    set(ax2,'xlim',([t(1)+offset_dec,t(end)+offset_dec]));
    ax2.XTickLabel = datestr(datenum(time_num(1:2:end))+offset_dec);
    datetick('x', 'dd mmm', 'keepticks') ;
    
    set(ax2,'XTickLabelRotation',53,'FontSize',6.5);
    set(ax2,'Xcolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);
    set(ax2,'Ycolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);
    ylims=get(ax2,'ylim');
    ylim(ax2,[0 ylims(2)]);

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
    
    %     annotation(gcf,'textbox',...
    %         [0.328498902750058 0.735693681496092 0.537691794529686 0.0630182421227199],...
    %         'String',['Offset: ', num2str(offset_dec), ' giorni'],...
    %         'LineStyle','none',...
    %         'HorizontalAlignment','right',...
    %         'FontName','Verdana',...
    %         'FitBoxToText','off');
    
    set(gcf,'CurrentAxes',ax2)
    ylimit2=ylim;
    set(gcf,'CurrentAxes',ax1)
    ylimit1=ylim;
    y_ord = ylimit1(2)/5*4;
    
    max1=max(a1_1);
    max2=max(a1_2);
    a1_1_n = a1_1./max1;
    a1_2_n = a1_2./max2;
    
    distance=a1_1_n-a1_2_n;
    
    index_green=find(distance+a1_1_n*(1+tolerance)>a1_1_n*(1+tolerance));
    index_red=find(distance+a1_1_n*(1+tolerance)<a1_1_n*(1-tolerance));
    index_yellow=find(distance+a1_1_n*(1+tolerance)>=a1_1_n*(1-tolerance) & distance+a1_1_n*(1+tolerance)<=a1_1_n*(1+tolerance));
    
    % figure;plot(a1_1_n,'-r');hold on; plot(a1_1_n*(1+tolerance),'-b');plot(distance+a1_1_n*(1+tolerance),'-g');
    
    lag(:,reg)=distance;
    %
    % index_green=find(distance>a1_1_n*(1+tolerance));
    % index_red=find(distance<-tolerance);
    % index_yellow=find(distance>=-tolerance & distance<=tolerance);
    
    ak1 = plot(t_1_1(index_green),repmat(y_ord,size(index_green,1),1),'*g');
    ak2 = plot(t_1_1(index_red),repmat(y_ord,size(index_red,1),1),'*r');
    ak3 = plot(t_1_1(index_yellow),repmat(y_ord,size(index_yellow,1),1),'*y');
    
    l=legend([c,d,ak1,ak3,ak2],l1,l2,'Test sufficienti','Test mirati','Test insufficienti');
    set(l,'Location','northeast')
    
    
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_correlazioneTamponiPositiviCasi_v2_spline_', num2str(reg) ,'_', regione,'.PNG']);
    close(gcf);
    
end















































%% 

%% interpolazione gaussiana regionale

%% GRAFICI SINGOLA REGIONE
for reg=5
    
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));

    for type=1:3
        try
            delete('testIn_gauss.txt');
        catch
        end
        try
            delete('testIn_gauss_fit.txt');
        catch
        end
        
        if type==1 %gauss su attualmente positivi
            data=dataReg.totale_positivi(index,1);
            %         data=dataReg.totale_casi(index,1);
            %          data=diff(data);
            
        elseif type==2  || type==3 %sigmoide su totale casi
            data=dataReg.totale_casi(index,1);
            %              data=dataReg.dimessi_guariti(index,1);
        end
        %         data=dataReg.deceduti(index,1);
        if type==3
            data=diff(data);
            time_num=time_num(2:end);
        end
        
        
        
        fout=fopen('testIn_gauss.txt','wt');
        for i=1:size(data,1)
            fprintf(fout,'%d;%d\n',time_num(i),data(i));
        end
        fclose(fout);
        
        if type==1 || type==3
            %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
            %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
            command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
            [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
        elseif type==2
            
            %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
            
            
            %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
            %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
            command=sprintf('gomp_estim testIn_gauss.txt');system(command);
            [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
            
        end
        
        %% figura cumulata
        
        
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        if type==1
            set(id_f, 'Name', [regione ': attualmente positivi']);
            title(sprintf([regione ': attualmente positivi\\fontsize{5}\n ']))
        elseif type==2
            set(id_f, 'Name', [regione ': totale casi']);
            title(sprintf([regione ': totale casi\\fontsize{5}\n ']))
        elseif type==3
            set(id_f, 'Name', [regione ': casi giornalieri']);
            title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        %                 shadedplot(t(2:end),diff(a4)',diff(a5'),[0.9 0.9 1]);  hold on
        %             a=plot(time_num(2:end),diff(data),'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
        %             b=plot(t(2:end),diff(a1),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
        %
        %
        
        shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
        d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
        c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
        b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
        a=plot(time_num,data,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
        
        
        
        if type==1 || type==3
            [max1, idxMaxa1]=max(a1); [max2, idxMaxa2]=max(a2); [max3, idxMaxa3]=max(a3);
            piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
            piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
            
            try
                idxMina1=find(round(a1(fix(size(a1,1)/5*4):end))<100)+fix(size(a1,1)/5*4); idxMina1=idxMina1(1);
                idxMina2=find(round(a2(fix(size(a2,1)/5*4):end))<100)+fix(size(a2,1)/5*4); idxMina2=idxMina2(1);
                idxMina3=find(round(a3(fix(size(a3,1)/5*4):end))<100)+fix(size(a3,1)/5*4); idxMina3=idxMina3(1);
            catch
                idxMina1=[];
                idxMina2=[];
                idxMina3=[];
            end
            
            zeroMin=min([t(idxMina1),t(idxMina2),t(idxMina3)]);
            zeroMax=max([t(idxMina1),t(idxMina2),t(idxMina3)]);
            
            if piccoMin<piccoMax
                picco = sprintf('Stima picco: %s-%s', datestr(piccoMin,'dd mmm'), datestr(piccoMax,'dd mmm'));
            else
                picco = sprintf('Stima picco: %s', datestr(piccoMin,'dd mmm'));
            end
            
            if piccoMin<piccoMax
                zero = sprintf('Stima <100 casi: %s-%s', datestr(zeroMin,'dd mmm'), datestr(zeroMax,'dd mmm'));
            else
                zero = sprintf('Stima <100 casi: %s', datestr(zeroMin,'dd mmm'));
            end
            
            annotation(gcf,'textbox',...
                [0.59875904860393 0.814262023217247 0.29886246122027 0.0845771144278608],...
                'String',{picco},...
                'LineStyle','none',...
                'HorizontalAlignment','right',...
                'FontSize',10,...
                'FontName','Verdana',...
                'FitBoxToText','off');
            
            annotation(gcf,'textbox',...
                [0.59875904860393 0.779436152570481 0.29886246122027 0.0845771144278606],...
                'String',{zero},...
                'LineStyle','none',...
                'HorizontalAlignment','right',...
                'FontName','Verdana',...
                'FitBoxToText','off');
            
            
            
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
        ylimi=get(gca,'ylim');
        set(gca,'ylim',([0,ylimi(2)]));
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        if type==1
            ylabel('Numero attualmente positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        elseif type==2
            ylabel('Numero totale casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        elseif type==3
            ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        end
        set(gca,'xlim',([time_num(1) time_num(end)+90]));
        set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
        set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        ax.FontSize = font_size;
        
        
        
        l=legend([a,b,c,d],'Dati Reali',sprintf('Stima al %s',datestr(time_num(end),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-1),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-2),'dd mmm')));
        
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        
        %%
        % %     cd([WORKroot,'/assets/img/regioni']);
        if type==1
            print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoAttPositivi_',regione, '_cumulati.PNG']);
        elseif type==2
            print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasi_',regione, '_cumulati.PNG']);
        elseif type==3
            print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_',regione, '_cumulati.PNG']);
        end
        close(gcf);
        %     cd([WORKroot,'/code']);
    end
    
    
    
    
end











 %% CONFRONTO DUE REGIONI STESSO GRAFICO REGIONE

for type=1:3
    
   
    datetickFormat = 'dd mmm';
    regione='LOMB-EMIL';
    figure;
    id_f(type) = gcf;
    if type==1
        set(id_f(type), 'Name', [regione ': attualmente positivi']);
        title(sprintf([regione ': attualmente positivi\\fontsize{5}\n ']))
    elseif type==2
        set(id_f(type), 'Name', [regione ': totale casi']);
        title(sprintf([regione ': totale casi\\fontsize{5}\n ']))
    elseif type==3
        set(id_f(type), 'Name', [regione ': casi giornalieri']);
        title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
    end
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
 
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % EMILIA ROMAGNA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    reg=5;       
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
       
%     try
%         delete('testIn_gauss.txt');
%     catch
%     end
%     try
%         delete('testIn_gauss_fit.txt');
%     catch
%     end
%     
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi(index,1);
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
%     
%     
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=1:size(data,1)
%         fprintf(fout,'%d;%d\n',time_num(i),data(i));
%     end
%     
%     if type==1 || type==3
%         %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     elseif type==2
%         
%         %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
%         
%         
%         %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         
%     end
%     
  
    figure(id_f(type))

%     b05=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    a05=plot(time_num,data,'ob','markersize',3,'color',[0.600000023841858 0.200000002980232 0],'MarkerFaceColor',[0.600000023841858 0.200000002980232 0]);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % LOMBARDIA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    reg=9;       
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
       
%     try
%         delete('testIn_gauss.txt');
%     catch
%     end
%     try
%         delete('testIn_gauss_fit.txt');
%     catch
%     end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi(index,1);
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
%     
%     
%     
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=1:size(data,1)
%         fprintf(fout,'%d;%d\n',time_num(i),data(i));
%     end
%     
%     if type==1 || type==3
%         %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     elseif type==2
%         
%         %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
%         
%         
%         %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         
%     end
%     

    
    figure(id_f(type))
%     b09=plot(t,a1,'-r','LineWidth', 2.0,'color',[0 0.498039215803146 0]);
    a09=plot(time_num,data,'ob','markersize',3,'color',[0.164705887436867 0.384313732385635 0.274509817361832],'MarkerFaceColor',[0.164705887436867 0.384313732385635 0.274509817361832]);
   
        
    ax = gca;
    code_axe = get(id_f(type), 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', font_size);
    ylimi=get(gca,'ylim');
    set(gca,'ylim',([0,ylimi(2)]));
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    if type==1
        ylabel('Numero attualmente positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==2
        ylabel('Numero totale casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==3
        ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    end
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax.FontSize = font_size;
    
    ax.FontSize = font_size;
    
    
%     l=legend([a05,b05,a09,b09],'Emilia-Romagna: Dati Reali',sprintf('Emilia-Romagna: Stima al %s',datestr(time_num(end),'dd mmm')),'Lombardia: Dati Reali',sprintf('Lombardia: Stima al %s',datestr(time_num(end),'dd mmm')));
    l=legend([a05,a09],'Emilia-Romagna','Lombardia');

    
    
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
    
         
end


for type=1:3    
    if type==1
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoAttPositivi_',regione, '_cumulati.PNG']);
    elseif type==2
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoTotaleCasi_',regione, '_cumulati.PNG']);
    elseif type==3
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoNuoviGiornalieri_',regione, '_cumulati.PNG']);
    end
    close(id_f(type));
end











 %% CONFRONTO DUE REGIONI STESSO GRAFICO REGIONE PESATO PER ABITANTI

for type=1:3
    datetickFormat = 'dd mmm';
    regione='LOMB-EMIL';
    figure;
    id_f(type) = gcf;
    if type==1
        set(id_f(type), 'Name', [regione ': attualmente positivi']);
        title(sprintf([regione ': attualmente positivi ogni 100.000 ab.\\fontsize{5}\n ']))
    elseif type==2
        set(id_f(type), 'Name', [regione ': totale casi ogni 100.000 ab.']);
        title(sprintf([regione ': totale casi\\fontsize{5}\n ']))
    elseif type==3
        set(id_f(type), 'Name', [regione ': casi giornalieri ogni 100.000 ab.']);
        title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
    end
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
   
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % EMILIA ROMAGNA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    reg=5;       
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
       
    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi(index,1);
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
%     
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=1:size(data,1)
%         fprintf(fout,'%d;%d\n',time_num(i),data(i));
%     end
%     
%     if type==1 || type==3
%         %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     elseif type==2
%         
%         %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
%         
%         
%         %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         
%     end
    
   
    figure(id_f(type))

%     b05=plot(t,a1./pop.popolazioneRegioniPop(reg)*100000,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    a05=plot(time_num,data./pop.popolazioneRegioniPop(reg)*100000,'ob','markersize',3,'color',[0.600000023841858 0.200000002980232 0],'MarkerFaceColor',[0.600000023841858 0.200000002980232 0]);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % LOMBARDIA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    reg=9;       
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
       
    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi(index,1);
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
%     
%     
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=1:size(data,1)
%         fprintf(fout,'%d;%d\n',time_num(i),data(i));
%     end
%     
%     if type==1 || type==3
%         %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%     elseif type==2
%         
%         %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
%         
%         
%         %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%         %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%         command=sprintf('gomp_estim testIn_gauss.txt');system(command);
%         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%         
%     end
%     

    
    figure(id_f(type))
%     b09=plot(t,a1./pop.popolazioneRegioniPop(reg)*100000,'-r','LineWidth', 2.0,'color',[0 0.498039215803146 0]);
    a09=plot(time_num,data./pop.popolazioneRegioniPop(reg)*100000,'ob','markersize',3,'color',[0.164705887436867 0.384313732385635 0.274509817361832],'MarkerFaceColor',[0.164705887436867 0.384313732385635 0.274509817361832]);
   
        
    ax = gca;
    code_axe = get(id_f(type), 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', font_size);
    ylimi=get(gca,'ylim');
    set(gca,'ylim',([0,ylimi(2)]));
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    if type==1
        ylabel('Numero attualmente positivi ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==2
        ylabel('Numero totale casi ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==3
        ylabel('Numero nuovi casi giornalieri ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    end
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax.FontSize = font_size;
    
    ax.FontSize = font_size;
    
    
%     l=legend([a05,b05,a09,b09],'Emilia-Romagna: Dati Reali',sprintf('Emilia-Romagna: Stima al %s',datestr(time_num(end),'dd mmm')),'Lombardia: Dati Reali',sprintf('Lombardia: Stima al %s',datestr(time_num(end),'dd mmm')));
     l=legend([a05,a09],'Emilia-Romagna','Lombardia');
       
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
    
         
end


for type=1:3    
    if type==1
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoAttPositiviPesata_',regione, '_cumulati.PNG']);
    elseif type==2
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoTotaleCasiPesata_',regione, '_cumulati.PNG']);
    elseif type==3
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_stimapiccoNuoviGiornalieriPesata_',regione, '_cumulati.PNG']);
    end
    close(id_f(type));
end














return




 %% CONFRONTO DUE REGIONI STESSO GRAFICO REGIONE MA SOLO ALCUNE PROVINCE
 
 PROV_LOMB = ['LO';'CR';'BG';'BS';'MB'];
 PROV_EMIL = ['PC';'PR';'RE';'RN'];
 dataReg=struct;

for type=2:3
    datetickFormat = 'dd mmm';
    regione='LOMB-EMIL';
    figure;
    id_f(type) = gcf;
    if type==1
        set(id_f(type), 'Name', [regione ': attualmente positivi']);
        title(sprintf([regione ': attualmente positivi\\fontsize{5}\n ']))
    elseif type==2
        set(id_f(type), 'Name', [regione ': totale casi']);
        title(sprintf([regione ': totale casi\\fontsize{5}\n ']))
    elseif type==3
        set(id_f(type), 'Name', [regione ': casi giornalieri']);
        title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
    end
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
   
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % EMILIA ROMAGNA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    time_num = unique(fix(datenum(dataProv.data)));
    dataReg.totale_casi=zeros(size(time_num));

    for kk = 1: size(PROV_EMIL,1)
        index = find(strcmp(dataProv.sigla_provincia,cellstr(PROV_EMIL(kk,:))));
        dataReg.totale_casi=dataReg.totale_casi+dataProv.totale_casi(index);
    end
    

    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi;
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    
    if type==1 || type==3
        %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    elseif type==2
        
        %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
        
        
        %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
    end
    
   
    figure(id_f(type))
%     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
%     d5=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
%     c5=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
    b05=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    a05=plot(time_num,data,'ob','markersize',3,'color',[0.600000023841858 0.200000002980232 0],'MarkerFaceColor',[0.600000023841858 0.200000002980232 0]);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % LOMBARDIA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    time_num = unique(fix(datenum(dataProv.data)));
    dataReg.totale_casi=zeros(size(time_num));

    for kk = 1: size(PROV_LOMB	,1)
        index = find(strcmp(dataProv.sigla_provincia,cellstr(PROV_LOMB(kk,:))));
        dataReg.totale_casi=dataReg.totale_casi+dataProv.totale_casi(index);
    end
    

    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi;
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    
    if type==1 || type==3
        %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    elseif type==2
        
        %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
        
        
        %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
    end
    

    
    figure(id_f(type))
    b09=plot(t,a1,'-r','LineWidth', 2.0,'color',[0 0.498039215803146 0]);
    a09=plot(time_num,data,'ob','markersize',3,'color',[0.164705887436867 0.384313732385635 0.274509817361832],'MarkerFaceColor',[0.164705887436867 0.384313732385635 0.274509817361832]);
   
        
    ax = gca;
    code_axe = get(id_f(type), 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', font_size);
    ylimi=get(gca,'ylim');
    set(gca,'ylim',([0,ylimi(2)]));
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    if type==1
        ylabel('Numero attualmente positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==2
        ylabel('Numero totale casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==3
        ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    end
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax.FontSize = font_size;
    
    ax.FontSize = font_size;
    
    leg_lomb='';
    for kk = 1:size(PROV_LOMB,1)
        leg_lomb=[leg_lomb,',',PROV_LOMB(kk,:)];
    end
    leg_lomb=leg_lomb(2:end);

    leg_emil='';
    for kk = 1:size(PROV_EMIL,1)
        leg_emil=[leg_emil,',',PROV_EMIL(kk,:)];
    end
    leg_emil=leg_emil(2:end);    
    
    l=legend([a05,b05,a09,b09],sprintf('Emilia-Romagna (%s): Dati Reali',leg_emil),sprintf('Emilia-Romagna (%s): Stima al %s',leg_emil,datestr(time_num(end),'dd mmm')),...
        sprintf('Lombardia (%s): Dati Reali',leg_lomb),sprintf('Lombardia (%s): Stima al %s',leg_lomb,datestr(time_num(end),'dd mmm')));
        
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
    
         
end




for type=2:3    
    if type==1
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoAttPositivi_',regione, '_cumulati.PNG']);
    elseif type==2
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoTotaleCasi_',regione, '_cumulati.PNG']);
    elseif type==3
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoNuoviGiornalieri_',regione, '_cumulati.PNG']);
    end
    close(id_f(type));
end




%% CONFRONTO DUE REGIONI STESSO GRAFICO REGIONE MA SOLO ALCUNE PROVINCE (PESATA SULLA POPOLAZIONE)
 
 PROV_LOMB = ['LO';'CR';'BG';'BS';'MB'];
 PROV_EMIL = ['PC';'PR';'RE';'RN';'MO'];

 dataReg=struct;

for type=2:3
    datetickFormat = 'dd mmm';
    regione='LOMB-EMIL';
    figure;
    id_f(type) = gcf;
    if type==1
        set(id_f(type), 'Name', [regione ': attualmente positivi ogni 100.000 ab.']);
        title(sprintf([regione ': attualmente positivi ogni 100.000 ab.\\fontsize{5}\n ']))
    elseif type==2
        set(id_f(type), 'Name', [regione ': totale casi ogni 100.000 ab.']);
        title(sprintf([regione ': totale casi ogni 100.000 ab.\\fontsize{5}\n ']))
    elseif type==3
        set(id_f(type), 'Name', [regione ': casi giornalieri ogni 100.000 ab.']);
        title(sprintf([regione ': casi giornalieri ogni 100.000 ab.\\fontsize{5}\n ']))
    end
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
   
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % EMILIA ROMAGNA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    time_num = unique(fix(datenum(dataProv.data)));
    dataReg.totale_casi=zeros(size(time_num));

    for kk = 1: size(PROV_EMIL,1)
        index = find(strcmp(dataProv.sigla_provincia,cellstr(PROV_EMIL(kk,:))));  
        idx_pop = find(strcmp(pop.sigla,cellstr(PROV_EMIL(kk,:))));
        dataReg.totale_casi=dataReg.totale_casi+dataProv.totale_casi(index)./pop.number(idx_pop)*100000;
    end
    

    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi;
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    
    if type==1 || type==3
        %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    elseif type==2
        
        %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
        
        
        %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
    end
    
   
    figure(id_f(type))
%     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
%     d5=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
%     c5=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
    b05=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    a05=plot(time_num,data,'ob','markersize',3,'color',[0.600000023841858 0.200000002980232 0],'MarkerFaceColor',[0.600000023841858 0.200000002980232 0]);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % LOMBARDIA
    %%%%%%%%%%%%%%%%%%%%%%%%%
    time_num = unique(fix(datenum(dataProv.data)));
    dataReg.totale_casi=zeros(size(time_num));

    for kk = 1: size(PROV_LOMB	,1)
        index = find(strcmp(dataProv.sigla_provincia,cellstr(PROV_LOMB(kk,:))));
        idx_pop = find(strcmp(pop.sigla,cellstr(PROV_LOMB(kk,:))));
        dataReg.totale_casi=dataReg.totale_casi+dataProv.totale_casi(index)./pop.number(idx_pop)*100000;
    end
    

    try
        delete('testIn_gauss.txt');
    catch
    end
    try
        delete('testIn_gauss_fit.txt');
    catch
    end
    
    if type==1 %gauss su attualmente positivi
        data=dataReg.totale_positivi(index,1);
        %         data=dataReg.totale_casi(index,1);
        %          data=diff(data);
        
    elseif type==2  || type==3 %sigmoide su totale casi
        data=dataReg.totale_casi;
        %              data=dataReg.dimessi_guariti(index,1);
    end
    %         data=dataReg.deceduti(index,1);
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    
    if type==1 || type==3
        %                 command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    elseif type==2
        
        %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
        
        
        %                 command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        command=sprintf('gomp_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
    end
    

    
    figure(id_f(type))
    b09=plot(t,a1,'-r','LineWidth', 2.0,'color',[0 0.498039215803146 0]);
    a09=plot(time_num,data,'ob','markersize',3,'color',[0.164705887436867 0.384313732385635 0.274509817361832],'MarkerFaceColor',[0.164705887436867 0.384313732385635 0.274509817361832]);
   
        
    ax = gca;
    code_axe = get(id_f(type), 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', font_size);
    ylimi=get(gca,'ylim');
    set(gca,'ylim',([0,ylimi(2)]));
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    if type==1
        ylabel('Numero attualmente positivi ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==2
        ylabel('Numero totale casi ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    elseif type==3
        ylabel('Numero nuovi casi giornalieri ogni 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    end
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax.FontSize = font_size;
    
    ax.FontSize = font_size;
    
    leg_lomb='';
    for kk = 1:size(PROV_LOMB,1)
        leg_lomb=[leg_lomb,',',PROV_LOMB(kk,:)];
    end
    leg_lomb=leg_lomb(2:end);

    leg_emil='';
    for kk = 1:size(PROV_EMIL,1)
        leg_emil=[leg_emil,',',PROV_EMIL(kk,:)];
    end
    leg_emil=leg_emil(2:end);    
    
    l=legend([a05,b05,a09,b09],sprintf('Emilia-Romagna (%s): Dati Reali',leg_emil),sprintf('Emilia-Romagna (%s): Stima al %s',leg_emil,datestr(time_num(end),'dd mmm')),...
        sprintf('Lombardia (%s): Dati Reali',leg_lomb),sprintf('Lombardia (%s): Stima al %s',leg_lomb,datestr(time_num(end),'dd mmm')));
        
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
        
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
    
         
end




for type=2:3    
    if type==1
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoAttPositivi_Pesata_',regione, '_cumulati.PNG']);
    elseif type==2
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoTotaleCasi_Pesata_',regione, '_cumulati.PNG']);
    elseif type==3
        print(id_f(type), '-dpng', [WORKroot,'/slides/img/regioni/_extra_regEMILOMB_SUB_stimapiccoNuoviGiornalieri_Pesata_',regione, '_cumulati.PNG']);
    end
    close(id_f(type));
end








