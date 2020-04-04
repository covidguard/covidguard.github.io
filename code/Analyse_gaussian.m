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
json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
for i=1:size(file_scan,1)
    json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
    %     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
end
dataReg = decodeJSON(json_oneRaw);
dataReg.dataa = char(dataReg.data);
dataReg.dataa(:,11)=' ';
dataReg.data=cellstr(dataReg.dataa);
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
dataProv = decodeJSON(json_oneRaw);
dataProv.dataa = char(dataProv.data);
dataProv.dataa(:,11)=' ';
dataProv.data=cellstr(dataProv.dataa);
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


%% percorsi:
data=struct;
data.dataReg=dataReg;
animated_gif_reg_Andrea(data,'A');
try
    animated_gif_reg_Andrea(data,'N');
    animated_gif_reg_Andrea(data,'C');
    animated_gif_reg_Andrea(data,'S');
catch
end


%% calcolo lombardia senza bergamo, brescia, milano,

% lombardia_idx = find(strcmp(dataProv.denominazione_regione,'Lombardia'));
% idx_BBL = find(strcmp(dataProv.sigla_provincia,'BG') | strcmp(dataProv.sigla_provincia,'BS') | strcmp(dataProv.sigla_provincia,'MI') | strcmp(dataProv.sigla_provincia,'CR') | strcmp(dataProv.sigla_provincia,'LO'));
% idx_BBL = find(strcmp(dataProv.sigla_provincia,'BG') | strcmp(dataProv.sigla_provincia,'BS') | strcmp(dataProv.sigla_provincia,'CR') | strcmp(dataProv.sigla_provincia,'LO') | strcmp(dataProv.sigla_provincia,'MI'));
%
% idx_lombResto = setdiff(lombardia_idx,idx_BBL);
%
% casiTotaliReg=[];
% casiTotaliReg_BGBS = [];
% for k = 1:size(listaRegioniTot,1)
%     idx = find(strcmp(dataProv.denominazione_regione,listaRegioniTot(k,:)));
%     casiTotaliReg=[casiTotaliReg;sum(dataProv.totale_casi(idx))];
% end
%
% listaRegioniTot = [listaRegioniTot;'BG-BS-MI-CR-LO'];
% listaRegioniTot = [listaRegioniTot;'Lombardia - BG-BS-MI'];
% casiTotaliReg=[casiTotaliReg;sum(dataProv.totale_casi(idx_BBL))];
% casiTotaliReg=[casiTotaliReg;sum(dataProv.totale_casi(idx_lombResto))];
%
%
% [x,idx]=sort(casiTotaliReg,'descend');
% tick_all=listaRegioniTot(idx);
%
%     figure;
%     id_f = gcf;
%     title(sprintf('Totale Casi\\fontsize{5}\n'));
%     set(gcf,'NumberTitle','Off');
%     set(gcf,'Position',[26 79 967 603]);
%     grid on
%     hold on
%     b=bar(x);
%     for i1=1:numel(x)
%             text(i1,x(i1),num2str(x(i1),'%.0f'),...
%                 'HorizontalAlignment','center',...
%                 'VerticalAlignment','bottom','fontsize',7)
%     end
%
%     hold on; grid minor
%     set(gca,'XTick',1:size(listaRegioniTot,1))
%     set(gca,'XTickLabel',tick_all)
%     set(gca,'XLim',[0.5,size(listaRegioniTot,1)+0.5])
%     set(gca,'XTickLabelRotation',53,'FontSize',6.5);
%     ylabel('Totale Casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
%     if ismac
%         font_size = 9;
%     else
%         font_size = 6.5;
%     end
%
%     ax = gca;
%     set(ax, 'FontName', 'Verdana');
%     set(ax, 'FontSize', font_size);
%
%     ylimit=ylim;
%     if ylimit(2)<20
%         ylim([0 20]);
%     end
%
%     ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
%
%
%
%     %% overlap copyright info
%     datestr_now = datestr(now);
%     annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
%         'String',{['Fonte: https://github.com/pcm-dpc']},...
%         'HorizontalAlignment','center',...
%         'FontSize',6,...
%         'FontName','Verdana',...
%         'FitBoxToText','off',...
%         'LineStyle','none',...
%         'Color',[0 0 0]);
%     if type==1
%         print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/regioni_deced_su_totali.PNG']);
%     else
%         print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/regioni_deced_senzacura.PNG']);
%     end
%
%     close(gcf);
%
%

% %% logistica a cluster
%
% lombardia_idx = find(strcmp(dataProv.denominazione_regione,'Lombardia'));
% idx_BBL = find(strcmp(dataProv.sigla_provincia,'BG') | strcmp(dataProv.sigla_provincia,'BS') | strcmp(dataProv.sigla_provincia,'MI') | strcmp(dataProv.sigla_provincia,'CR') | strcmp(dataProv.sigla_provincia,'LO'));
% idx_BBL = find(strcmp(dataProv.sigla_provincia,'BG') | strcmp(dataProv.sigla_provincia,'BS') | strcmp(dataProv.sigla_provincia,'CR') | strcmp(dataProv.sigla_provincia,'LO') | strcmp(dataProv.sigla_provincia,'MI'));
%
% idx_lombResto = setdiff(lombardia_idx,idx_BBL);
%
%
% dateT= unique(dataProv.data(idx_lombResto));
% dataset = dataProv.totale_casi(idx_lombResto);
% datasetT = dataProv.data(idx_lombResto);
%
% datasetTBG = dataProv.data(idx_BBL);
% datasetBG = dataProv.totale_casi(idx_BBL);
%
% dataSet_LombBG = [];
% dataSet_LombResto = [];
% for k = 1 :size(unique(datasetT),1)
%     idx =  find(strcmp(datasetT,dateT(k)));
%     dataSet_LombResto(k) = sum(dataset(idx));
%     idx =  find(strcmp(datasetTBG,dateT(k)));
%     dataSet_LombBG(k) = sum(datasetBG(idx));
% end
%
% data = dataSet_LombResto;
% time_num = fix(datenum(dateT));
% regione = 'Lombardia (no BG-BS-CR-LO-MI)';
%
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:length(data)
%     fprintf(fout,'%d;%d\n',time_num(i),data(i));
% end
% command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%
%
% data1 = dataSet_LombBG;
% time_num = fix(datenum(dateT));
% regione1 = 'Lombardia (BG-BR-CR-LO)';
%
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:length(data)
%     fprintf(fout,'%d;%d\n',time_num(i),data1(i));
% end
% command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% [tl,a1l,a2l,a3l,a4l,a5l]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%
%
% datetickFormat = 'dd mmm';
% figure;
% id_f = gcf;
%
% set(id_f, 'Name', [regione ': totale casi']);
% title(sprintf([regione ': totale casi\\fontsize{5}\n ']))
%
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% %     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
% %     d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% %     c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
% b=plot(t,a1,'-b','LineWidth', 2.0);
% a=plot(time_num,data,'.b','markersize',14);
%
% bl=plot(tl,a1l,'-r','LineWidth', 2.0);
% al=plot(time_num,data1,'.r','markersize',14);
%
% if ismac
%     font_size = 9;
% else
%     font_size = 6.5;
% end
%
% ax = gca;
% code_axe = get(id_f, 'CurrentAxes');
% set(code_axe, 'FontName', 'Verdana');
% set(code_axe, 'FontSize', font_size);
% ylimi=get(gca,'ylim');
% set(gca,'ylim',([0,ylimi(2)]));
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Numero totale casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
%
% datetick('x', datetickFormat, 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax.FontSize = font_size;
%
% l=legend([al,bl,a,b],'Dati Reali BG-BS-LO-CR-MI','Stima BG-BS-LO-CR-MI','Dati Reali resto della Lombardia','Stima resto della Lombardia');
%
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
% %%
% % %     cd([WORKroot,'/assets/img/regioni']);
%
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoLombardia_2fasce_cumulati.PNG']);
% close(gcf);

%% logistica per provincia
%
% lombardia_idx = find(strcmp(dataProv.denominazione_regione,'Lombardia'));
% [listaProv, id] = unique(dataProv.denominazione_provincia(lombardia_idx));
% listaProv=setdiff(listaProv,'In fase di definizione/aggiornamento');
%
% dateT= unique(dataProv.data);
%
%
% a=[]; b=[]; x=[]; sigTot=cellstr('');
%
% datetickFormat = 'dd mmm';
% figure;
% id_f = gcf;
%
% set(id_f, 'Name', ['Lombardia: totale casi']);
% title(sprintf(['Lombardia: totale casi\\fontsize{5}\n ']))
%
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
%
%
% for pv = 1:size(listaProv,1)
%     provName = listaProv(pv);
%     sigla = find(strcmp(dataProv.denominazione_provincia,provName));provSigla=dataProv.sigla_provincia(sigla(1));
%     idx_prov = find(strcmp(dataProv.sigla_provincia,provSigla));
%
%     dataset = dataProv.totale_casi(idx_prov);
%     index_pop = find(strcmp(pop.sigla,provSigla));
%
%
%
%     fout=fopen('testIn_gauss.txt','wt');
%     for i=1:length(data)
%         fprintf(fout,'%d;%.2f\n',fix(datenum(dateT(i))),dataset(i)./pop.number(index_pop)*1000);
%     end
%     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%     [t,a0,a1,a2,a3,a4]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%
%     b(pv)=plot(t,a1,'-b','LineWidth', 2.0);
%     a(pv)=plot(datenum(dateT),dataset./pop.number(index_pop)*1000,'.b','markersize',14);
%     drawnow
%
%     x(pv)=a1(end); sigTot(pv)=cellstr(provSigla);
% end
%
% for pv = 1:size(listaProv,1)
%     set(a(pv),'color',Cmap.getColor(pv, size(listaProv,1)),'markersize',8);
%     set(b(pv),'color',Cmap.getColor(pv, size(listaProv,1)));
% end
%
%
%
%
%
% last_value= x(:);
% [sort_x, idx_sort] = sort(last_value,'descend');
%
% for ll=1:size(idx_sort,1)
%     lab=upper(char(sigTot(idx_sort(ll))));
%     llab=6;
%     if length(lab)<6
%         llab=length(lab);
%     end
%     if ll/2==fix(ll/2)
%
%         text(t(end)+((t(end)-t(1)))*0.01, sort_x(ll),...
%             ['------> ',lab(1:llab)], 'HorizontalAlignment','left','FontSize',5','Color',[0 0 0]);
%     else
%         text(t(end)+((t(end)-t(1)))*0.01, sort_x(ll),...
%             ['-> ',lab(1:llab)], 'HorizontalAlignment','left','FontSize',5','Color',[0 0 0]) ;
%     end
% end
%
%
%
%
% if ismac
%     font_size = 9;
% else
%     font_size = 6.5;
% end
%
% ax = gca;
% code_axe = get(id_f, 'CurrentAxes');
% set(code_axe, 'FontName', 'Verdana');
% set(code_axe, 'FontSize', font_size);
% ylimi=get(gca,'ylim');
% set(gca,'ylim',([0,ylimi(2)]));
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Numero totale casi / 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
%
% datetick('x', datetickFormat, 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax.FontSize = font_size;
%
%
% % set(l,'Location','northwest')
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
% %%
% % %     cd([WORKroot,'/assets/img/regioni']);
%
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoLombardia_2fasce_cumulati.PNG']);
% close(gcf);
%
%
%






















%% GRAFICI SINGOLA REGIONE
mediamobile_yn=0;
for reg=1:size(regioni_tot,1)
    try
        regione = char(regioni_tot(reg,1));
        index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
        time_num = fix(datenum(dataReg.data(index)));
        
        
        %% bar stacked: totale casi
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
        grid minor
        hold on
        
        bbb=[dataReg.deceduti(index,1)';dataReg.terapia_intensiva(index,1)';dataReg.totale_ospedalizzati(index,1)'-dataReg.terapia_intensiva(index,1)';dataReg.isolamento_domiciliare(index,1)';dataReg.dimessi_guariti(index,1)'];
        
        bbbar = bar(bbb','stacked'); hold on
        set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
        set(bbbar(2),'FaceColor',[1 0 0]);
        set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
        set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
        set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        
        set(gca,'XTick',1:size(time_num,1));
        set(gca,'XTickLabel',datestr(time_num,'dd mmm'));
        set(gca,'XLim',[0.5,size(time_num,1)+0.5]);
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax=gca;
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        
        l=legend([bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_cumulati.PNG']);
        close(gcf);
        
        
        
        
        
        %% bar stacked: giornalieri
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', [regione ': dati giornalieri']);
        if mediamobile_yn==0
            title(sprintf([regione ': dati giornalieri\\fontsize{5}\n ']))
        else
            title(sprintf([regione ': dati giornalieri (media mobile)\\fontsize{5}\n ']))
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid minor
        hold on
        
        bbb=[diff(dataReg.deceduti(index,1))';diff(dataReg.terapia_intensiva(index,1))';diff(dataReg.totale_ospedalizzati(index,1))'-diff(dataReg.terapia_intensiva(index,1))';diff(dataReg.isolamento_domiciliare(index,1))';diff(dataReg.dimessi_guariti(index,1))'];
        
        bbbar = bar(bbb','stacked'); hold on
        set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
        set(bbbar(2),'FaceColor',[1 0 0]);
        set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
        set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
        set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        
        set(gca,'XTick',1:size(time_num(2:end),1));
        set(gca,'XTickLabel',datestr(time_num(2:end),'dd mmm'));
        set(gca,'XLim',[0.5,size(time_num(2:end),1)+0.5]);
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax=gca;
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        
        l=legend([bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_giornalieri.PNG']);
        close(gcf);
        
        
        
        
        
        
        
        
        
        
        
        
        
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
                h=plot(time_num,dataReg.totale_positivi(index,1),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
            catch
                a=plot(time_num,str2double(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num,str2double(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
                c=plot(time_num,str2double(dataReg.dimessi_guariti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(3, 8));
                d=plot(time_num,str2double(dataReg.deceduti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(4, 8));
                e=plot(time_num,str2double(dataReg.terapia_intensiva(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(5, 8));
                f=plot(time_num,str2double(dataReg.totale_ospedalizzati(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(6, 8));
                g=plot(time_num,str2double(dataReg.isolamento_domiciliare(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(7, 8));
                h=plot(time_num,str2double(dataReg.totale_positivi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
                
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
            h=plot(time_num,movmean(dataReg.totale_positivi(index,1), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
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
                h=plot(time_num(2:end),diff(dataReg.totale_positivi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
            catch
                
                a=plot(time_num(2:end),diff(str2double(dataReg.ricoverati_con_sintomi(index,1))),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
                b=plot(time_num(2:end),diff(str2double(dataReg.totale_casi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
                c=plot(time_num(2:end),diff(str2double(dataReg.dimessi_guariti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
                d=plot(time_num(2:end),diff(str2double(dataReg.deceduti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
                e=plot(time_num(2:end),diff(str2double(dataReg.terapia_intensiva(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
                f=plot(time_num(2:end),diff(str2double(dataReg.totale_ospedalizzati(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
                g=plot(time_num(2:end),diff(str2double(dataReg.isolamento_domiciliare(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
                h=plot(time_num(2:end),diff(str2double(dataReg.totale_positivi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
            end
            
        else
            a=plot(time_num(2:end),movmean(diff(dataReg.ricoverati_con_sintomi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
            b=plot(time_num(2:end-1),movmean(diff(dataReg.totale_casi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
            c=plot(time_num(2:end),movmean(diff(dataReg.dimessi_guariti(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
            d=plot(time_num(2:end),movmean(diff(dataReg.deceduti(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
            e=plot(time_num(2:end),movmean(diff(dataReg.terapia_intensiva(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
            f=plot(time_num(2:end),movmean(diff(dataReg.totale_ospedalizzati(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
            g=plot(time_num(2:end),movmean(diff(dataReg.isolamento_domiciliare(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
            h=plot(time_num(2:end),movmean(diff(dataReg.totale_positivi(index,1)), 3, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
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
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_giornalieri.PNG']);
        close(gcf);
    catch
    end
    
    
    %% tamponi
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    datetickFormat = 'dd mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': tamponi']);
    title(sprintf([regione ': tamponi\\fontsize{5}\n ']))
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    tamp_positivi = diff(dataReg.totale_casi(index,1));
    %     a=bar([diff(dataReg.tamponi(index,1)),tamp_positivi],1,'stacked');
    yy =diff(dataReg.tamponi(index,1))-tamp_positivi; yy(yy<0)=0;
    
    a=bar([tamp_positivi, yy],1,'stacked');
    
    
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    hold on; grid minor
    %     a(1).FaceColor = [0.8 0.8 0.8];
    %     a(2).FaceColor = [1 0.200000002980232 0.200000002980232];
    a(2).FaceColor = [0.8 0.8 0.8];
    a(1).FaceColor = [1 0.200000002980232 0.200000002980232];
    
    
    set(gca,'XTick',1:size(tamp_positivi,1))
    set(gca,'XTickLabel',datestr(time_num(2:end),'dd mmm'))
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    set(gca,'XLim',[0.5,size(time_num,1)-0.5]);
    yL=get(gca,'ylim');
    set(gca,'ylim',[0 yL(2)]);
    ax = gca;
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Numero tamponi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    
    
    
    
    yyaxis right
    c=tamp_positivi./diff(dataReg.tamponi(index,1))*100;  c(c>100)=NaN; c(c<0)=NaN;
    b=plot(1:size(tamp_positivi,1), c,'-b','LineWidth', 2.0);
    ylim([0 100]);
    set(gca,'YColor', [0 0 0]);
    ylabel('Percentuale tamponi positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    l=legend([a(2),a(1),b],'Tamponi negativi','Tamponi positivi','Percent. tamponi positivi');
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
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_tamponi.PNG']);
    close(gcf);
    
    
    
    
end











%% bars Nazionale
day_unique = unique(dataReg.data);
time_num=datenum(day_unique);
data=NaN(size(day_unique,1),5);
totaleCasi=NaN(size(day_unique,1),1);  
for k = 1: size(day_unique,1)
    index = find(strcmp(dataReg.data,day_unique(k)));
    data(k,1)=sum(dataReg.deceduti(index));
    data(k,2)=sum(dataReg.terapia_intensiva(index));
    data(k,3)=sum(dataReg.totale_ospedalizzati(index));
    data(k,4)=sum(dataReg.isolamento_domiciliare(index));
    data(k,5)=sum(dataReg.dimessi_guariti(index));
    totaleCasi(k,1)=sum(dataReg.totale_casi(index));
    
end


%% bar stacked: totale casi
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
regione = 'Italia';
set(id_f, 'Name', [regione ': dati cumulati']);
title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on


bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,1)';data(:,4)';data(:,5)'];

bbbar = bar(bbb','stacked'); hold on
set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
set(bbbar(2),'FaceColor',[1 0 0]);
set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);

if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(gca,'XTick',1:size(time_num,1));
set(gca,'XTickLabel',datestr(time_num,'dd mmm'));
set(gca,'XLim',[0.5,size(time_num,1)+0.5]);
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

l=legend([bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_cumulati.PNG']);
close(gcf);


%%
data_interp=[];
% interpolazione di ogni serie
% 1: deceduti
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,1));
end
fclose(fout);
command=sprintf('sigm_estim testIn_gauss.txt');system(command);
[t,data_interp(:,1),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');

% 2: terapia_intensiva
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,2));
end
fclose(fout);
command=sprintf('gauss_estim testIn_gauss.txt');system(command);
[t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
% 3: ospedalizzati
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,3)-data(i,1));
end
fclose(fout);
command=sprintf('gauss_estim testIn_gauss.txt');system(command);
[t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
% 4: isolamento_domiciliare
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,4));
end
fclose(fout);
command=sprintf('gauss_estim testIn_gauss.txt');system(command);
[t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');        
        

% 5: dimessiGuariti
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,5));
end
fclose(fout);
command=sprintf('sigm_estim testIn_gauss.txt');system(command);
[t,data_interp(:,5),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');

% % 5: totaleCasi
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),totaleCasi(i,1));
% end
% fclose(fout);
% command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% [t,totaleCasi_interp,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
% 
% %dimessi guariti
% dimessi_guariti = totaleCasi_interp-data_interp(:,3)-data_interp(:,4)-data_interp(:,1);


%% bar stacked: totale casi
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
regione = 'Italia';
set(id_f, 'Name', [regione ': dati cumulati']);
title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on


bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,1)';data(:,4)';data(:,5)'];
bbb1=[data_interp(:,1)';data_interp(:,2)';data_interp(:,3)';data_interp(:,4)';data_interp(:,5)'];
% bbb1=[data_interp(:,1)';data_interp(:,2)';data_interp(:,3)';data_interp(:,4)';dimessi_guariti'];

bbb1(:,1:size(time_num,1))=NaN;

bbbar = bar(bbb','stacked'); hold on
set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
set(bbbar(2),'FaceColor',[1 0 0]);
set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);

bbbar1 = bar(bbb1','stacked'); hold on
set(bbbar1(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464],'FaceAlpha',0.2);
set(bbbar1(2),'FaceColor',[1 0 0],'FaceAlpha',0.2);
set(bbbar1(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794],'FaceAlpha',0.2);
set(bbbar1(4),'FaceColor',[1 1 0.400000005960464],'FaceAlpha',0.2);
set(bbbar1(5),'FaceColor',[0 0.800000011920929 0.200000002980232],'FaceAlpha',0.2);


if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(gca,'XTick',1:2:size(t,1));
set(gca,'XTickLabel',datestr(t(1:2:end),'dd mmm'));
set(gca,'XLim',[0.5,size(t,1)+0.5]);
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

l=legend([bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_cumulatiPrevisione.PNG']);
close(gcf);





















%% interpolazione Nazionale
day_unique = unique(dataReg.data);

for type=1:3
    
    data=NaN(size(day_unique,1),1);
    for k = 1: size(day_unique,1)
        index = find(strcmp(dataReg.data,day_unique(k)));
        if type==1
            data(k)=sum(dataReg.totale_positivi(index));
        elseif type==2 || type==3
            data(k)=sum(dataReg.totale_casi(index));
        end
    end
    
    
    
    time_num = fix(datenum(day_unique));
    
    if type==3
        data=diff(data);
        time_num=time_num(2:end);
    end
    
    
    regione = 'Italia';
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    
    if type==1 || type==3
        command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%d%f%f%f%f%f','delimiter',';');
        
%                 command=sprintf('chi_estim_conf testIn_gauss.txt');system(command);
%                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_chi_fit.txt','%d%f%f%f%f%f','delimiter',';');
    elseif type==2
        command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        
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
        
        idxMina1=find(round(a1(fix(size(a1,1)/2):end))<100)+fix(size(a1,1)/2); idxMina1=idxMina1(1);
        idxMina2=find(round(a2(fix(size(a2,1)/2):end))<100)+fix(size(a2,1)/2); idxMina2=idxMina2(1);
        idxMina3=find(round(a3(fix(size(a3,1)/2):end))<100)+fix(size(a3,1)/2); idxMina3=idxMina3(1);
        
        piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
        piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
        
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
    
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
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
    
    
    
    
end



%% analisi nazionale sulla correlazione casi-deceduti
offset_dec = 7;
offset_guar = 0;

day_unique = unique(dataReg.data);
data_casiPositivi=NaN(size(day_unique,1),1);
data_deceduti=NaN(size(day_unique,1),1);
data_guariti=NaN(size(day_unique,1),1);
for k = 1: size(day_unique,1)
    index = find(strcmp(dataReg.data,day_unique(k)));
    data_casiPositivi(k)=sum(dataReg.totale_casi(index));
    data_deceduti(k)=sum(dataReg.deceduti(index));
    data_guariti(k)=sum(dataReg.dimessi_guariti(index));
end
time_num = fix(datenum(day_unique));
regione = 'Italia';

t=time_num(2:end);
data_casiPositivi=data_casiPositivi(2:end)./data_casiPositivi(1:end-1)*100-100;
data_deceduti=data_deceduti(2:end)./data_deceduti(1:end-1)*100-100;
data_guariti=data_guariti(2:end)./data_guariti(1:end-1)*100-100;

figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: correlazione temporale');
%     title(sprintf([regione ': totale Italia: correlazione temporale\\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

[ax,a,b] = plotxx(t,data_casiPositivi,t,data_deceduti);

%
% a=plot(t,data_casiPositivi,'-ob','LineWidth', 2.0,'color',[0 0.200000002980232 0.600000023841858]); set(a,'markersize',6,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532]);
% b=plot(t-offset_dec,data_deceduti,'-ob','LineWidth', 2.0,'color',[1 0.200000002980232 0.600000023841858],'Parent',ax2); set(b,'markersize',6,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);


if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(a,'marker','o','markersize',6,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 2.0);
set(b,'marker','o','markersize',6,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 2.0);

ax1 = ax(1);
ax2 = ax(2);

set(gcf,'CurrentAxes',ax1)
ylabel('Incremento percentuale giornaliero', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
set(ax1, 'FontName', 'Verdana');
set(ax1, 'FontSize', font_size);
set(ax1,'xlim',([t(1),t(end)]));
set(ax1,'ylim',([0,80]));
ax1.XTick = time_num;
datetick('x', 'dd mmm', 'keepticks') ;
set(ax1,'XTickLabelRotation',53,'FontSize',6.5);

set(gcf,'CurrentAxes',ax2)
set(ax2, 'FontName', 'Verdana');
set(ax2, 'FontSize', font_size);
ax2.XTick = time_num;
set(ax2,'ylim',([0,80]));
datetick('x', 'dd mmm', 'keepticks') ;
set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec]));
set(ax2,'XTickLabelRotation',53,'FontSize',6.5);


l=legend([a,b],'Casi totali','Deceduti');

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

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_correlazioneCasiDeceduti.PNG']);
close(gcf);




%% tasso mortalità regionale
mort=[];
mort_it = [0 0];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    
    mort(reg,1) = dataReg.deceduti(index(end))/dataReg.totale_casi(index(end))*100;
    
    mort_it(1) = mort_it(1)+dataReg.deceduti(index(end));
    mort_it(2) = mort_it(2)+dataReg.totale_casi(index(end));
end

mort=[mort;mort_it(1)/mort_it(2)*100];
regioni_tot1 = [regioni_tot;cellstr('Italia totale')];
[mort_1, idx] = sort(mort,'descend');

idx_italiaTot = find(strcmp(regioni_tot1(idx), cellstr('Italia totale')));



figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: tasso di mortalita'' dei contagiati');
title(sprintf(['Italia: tasso di mortalita'' dei contagiati \\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

b=bar(mort_1);
for i1=1:numel(mort_1)
    text(i1,mort_1(i1),num2str(mort_1(i1),'%.1f%%'),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end
b1 = bar(idx_italiaTot, mort_1(idx_italiaTot),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);

hold on; grid minor
set(gca,'XTick',1:size(regioni_tot1,1))
set(gca,'XTickLabel',regioni_tot1(idx))
set(gca,'XLim',[0.5,size(regioni_tot1,1)+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Percentuale deceduti/casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
if ismac
    font_size = 9;
else
    font_size = 6.5;
end

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

ylimit=ylim;
if ylimit(2)<25
    ylim([0 25]);
end

ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';


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

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_mortalita.PNG']);
close(gcf);






%% tamponi totali Italia
tamponiIta=[];
totalePosIta=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    tamponiIta(:,reg)=dataReg.tamponi(index);
    totalePosIta(:,reg)=dataReg.totale_casi(index);
end

time_num = unique(dataReg.data);


tamponiIta=diff(sum(tamponiIta')');
totalePosIta=diff(sum(totalePosIta')');
perTampPos=totalePosIta./tamponiIta*100;

figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: tamponi totali');
title(sprintf(['Italia: tamponi totali \\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

b=bar([totalePosIta,tamponiIta-totalePosIta],'stacked');
set(b(1),'FaceColor',[1 0 0]);
set(b(2),'FaceColor',[0.200000002980232 0.600000023841858 1]);


if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(gca,'XTick',1:size(time_num(2:end),1));
set(gca,'XTickLabel',datestr(time_num(2:end),'dd mmm'));
set(gca,'XLim',[0.5,size(time_num(2:end),1)+0.5]);
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero tamponi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);


yyaxis right
c=plot(perTampPos,'-b','LineWidth', 1.5);
ylim([0 100]);
set(gca,'YColor', [0 0 1]);
ylabel('Percentuale tamponi positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
grid minor

l=legend([b(2),b(1),c],'Tamponi negativi','Tamponi positivi','Percent. tamponi positivi');
set(l,'Location','northwest')



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



print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_tamponi.PNG']);
close(gcf);









%% interpolazione gaussiana regionale

%% GRAFICI SINGOLA REGIONE
for reg=9%1:size(regioni_tot,1)
    
    
    try
        regione = char(regioni_tot(reg,1));
        index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
        time_num = fix(datenum(dataReg.data(index)));
        %             dataReg=dataProv;RegioneTot={'Como'}'; h=1;regione = char(RegioneTot(h));index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));time_num = fix(datenum(dataReg.data(index)));type=2;
        %             
        % RegioneTot={'Lecco'}'
        %           
        %             
        %             
        %             
        %                
        
        %
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
            
            if type==1 || type==3
                command=sprintf('gauss_estim testIn_gauss.txt');system(command);
                [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%d%f%f%f%f%f','delimiter',';');
% %                 
%                                 command=sprintf('chi_estim_conf testIn_gauss.txt');system(command);
%                                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_chi_fit.txt','%d%f%f%f%f%f','delimiter',';');
            elseif type==2
                
                %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
                
                
                command=sprintf('sigm_estim testIn_gauss.txt');system(command);
                [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
                
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
                
                
                idxMina1=find(round(a1(fix(size(a1,1)/2):end))<100)+fix(size(a1,1)/2); idxMina1=idxMina1(1);
                idxMina2=find(round(a2(fix(size(a2,1)/2):end))<100)+fix(size(a2,1)/2); idxMina2=idxMina2(1);
                idxMina3=find(round(a3(fix(size(a3,1)/2):end))<100)+fix(size(a3,1)/2); idxMina3=idxMina3(1);
                
                
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
            datetick('x', datetickFormat, 'keepticks') ;
            set(gca,'XTickLabelRotation',53,'FontSize',6.5);
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
    catch
    end
end








%% Regioni confronto

% andamento normalizzato casi totali
regioni_conf=struct;

for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    regioni.name(reg,1)=cellstr(regione);
    regioni_conf.ricoverati_con_sintomi(reg,:) = dataReg.ricoverati_con_sintomi(index);
    regioni_conf.terapia_intensiva(reg,:) = dataReg.terapia_intensiva(index);
    regioni_conf.totale_ospedalizzati(reg,:) = dataReg.totale_ospedalizzati(index);
    regioni_conf.isolamento_domiciliare(reg,:) = dataReg.isolamento_domiciliare(index);
    regioni_conf.totale_positivi(reg,:) = dataReg.totale_positivi(index);
    regioni_conf.nuovi_positivi(reg,:) = dataReg.nuovi_positivi(index);
    regioni_conf.dimessi_guariti(reg,:) = dataReg.dimessi_guariti(index);
    regioni_conf.deceduti(reg,:) = dataReg.deceduti(index);
    regioni_conf.totale_casi(reg,:) = dataReg.totale_casi(index);
    regioni_conf.tamponi(reg,:) = dataReg.tamponi(index);
end


loop=struct;
loop.var={'ricoverati_con_sintomi';...
    'terapia_intensiva';...
    'totale_ospedalizzati';...
    'isolamento_domiciliare';...
    'totale_positivi';...
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


for type= 1: 1
    
    for kk=2
        if kk==1
            pesata=0;
        else
            pesata=1;
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
        
        x=[];
        for ll=1:length(regioni.name)
            idx1(ll) = find(strcmp(pop.popolazioneRegioniNome, regioni.name(ll)));
            x(:,ll)=regioni_conf.totale_casi(ll,:)./pop.popolazioneRegioniPop(idx1(ll))*1000;
        end
        a=plot(time_num,x,'-','LineWidth', 2.0);
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        ylabel('Casi totali ogni 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
        
        set(ax, 'Xlim', [time_num(1), time_num(end)]);
        ax.XTick = time_num;
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        
        last_value= x(end,:)';
        [sort_x, idx_sort] = sort(last_value,'descend');
        
        for ll=1:size(idx_sort,1)
            lab=upper(char(regioni.name(idx_sort(ll))));
            llab=6;
            if length(lab)<6
                llab=length(lab);
            end
            if ll/2==fix(ll/2)
                
                
                text(time_num(end)+((time_num(end)-time_num(1)))*0.01, sort_x(ll),...
                    ['------> ',lab(1:llab)], 'HorizontalAlignment','left','FontSize',5','Color',[0 0 0]);
            else
                text(time_num(end)+((time_num(end)-time_num(1)))*0.01, sort_x(ll),...
                    ['-> ',lab(1:llab)], 'HorizontalAlignment','left','FontSize',5','Color',[0 0 0]) ;
            end
        end
        
        
        % l=legend([b],'Totale Casi');
        %set(l,'Location','northwest')
        
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
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_confrontoPesatoAndamentoCasiTotali.PNG']);
        close(gcf);
    end
end











%% BARS sull'ultimo giorno
regioni_conf=struct;
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    regioni_conf.ricoverati_con_sintomi(reg) = dataReg.ricoverati_con_sintomi(index(end));
    regioni_conf.terapia_intensiva(reg) = dataReg.terapia_intensiva(index(end));
    regioni_conf.totale_ospedalizzati(reg) = dataReg.totale_ospedalizzati(index(end));
    regioni_conf.isolamento_domiciliare(reg) = dataReg.isolamento_domiciliare(index(end));
    regioni_conf.totale_positivi(reg) = dataReg.totale_positivi(index(end));
    regioni_conf.nuovi_positivi(reg) = dataReg.nuovi_positivi(index(end));
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
    'totale_positivi';...
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
        for i1=1:numel(x)
            if pesata==1
                text(i1,x(i1),num2str(x(i1),'%.2f'),...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom','fontsize',7)
            else
                text(i1,x(i1),num2str(x(i1),'%.0f'),...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','bottom','fontsize',7)
            end
        end
        
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
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        
        
        if pesata==1
            command = sprintf('print(gcf, ''-dpng'', [WORKroot,''/slides/img/regioni/regioni_pesata_'', num2str(type),''_'',char(loop.var(type)),''.PNG'']);');eval(command)
        else
            command = sprintf('print(gcf, ''-dpng'', [WORKroot,''/slides/img/regioni/regioni_'', num2str(type),''_'',char(loop.var(type)),''.PNG'']);');eval(command)
        end
        close(gcf);
    end
end




%% rapporto deceduti/casitotali
for type=1:2
    if type==1
        [x,idx]=sort(regioni_conf.deceduti./regioni_conf.totale_casi*100,'descend');
    else
        [x,idx]=sort((regioni_conf.deceduti./regioni_conf.totale_casi.*regioni_conf.totale_casi./sum(regioni_conf.totale_casi)*100)./(regioni_conf.deceduti./regioni_conf.totale_casi*100)*100,'descend');
    end
    
    
    tick_all=regioni_tot(idx);
    
    idx1=[];
    for ll=1:length(tick_all)
        idx1(ll) = find(strcmp(pop.popolazioneRegioniNome, tick_all(ll)));
    end
    
    
    figure;
    id_f = gcf;
    if type==1
        title(sprintf(['Rapporto deceduti/totale casi (al ', datestr(time_num(end),'dd/mm'), ') \\fontsize{5}\n ']))
    else
        title(sprintf(['% deceduti senza cure - stima! (al ', datestr(time_num(end),'dd/mm'), ') \\fontsize{5}\n ']))
    end
    
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    b=bar(x);
    for i1=1:numel(x)
        if pesata==1
            text(i1,x(i1),num2str(x(i1),'%.2f'),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom','fontsize',7)
        else
            text(i1,x(i1),num2str(x(i1),'%.0f'),...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom','fontsize',7)
        end
    end
    
    hold on; grid minor
    set(gca,'XTick',1:size(regioni_tot,1))
    set(gca,'XTickLabel',tick_all)
    set(gca,'XLim',[0.5,size(regioni_tot,1)+0.5])
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    if type==1
        ylabel('Percentuale deceduti/casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
    else
        ylabel('Percentuale deceduti senza cure appropriate - stima!', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
    end
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    ax = gca;
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    
    ylimit=ylim;
    if ylimit(2)<20
        ylim([0 20]);
    end
    
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
    
    
    annotation(gcf,'textbox',...
        [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    
    if type==1
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/regioni_deced_su_totali.PNG']);
    else
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/regioni_deced_senzacura.PNG']);
    end
    
    close(gcf);
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
    
    %% figura cumulata
    for tipoGraph=1:2
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
            regione_leg(strfind(regione_leg,'ì'))='i';
            regione_leg(strfind(regione_leg,'Ã'))='i';
            regione_leg(strfind(regione_leg,'¬'))='';
            
            
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
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        if normalizza_per_popolazione==1
            print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
        elseif normalizza_per_superficie==1
            print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_normSup_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
        else
            print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliCumulati.PNG']);
        end
        
        close(gcf);
        
        
        
        
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
            
            if normalizza_per_popolazione==1
                b(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
            else
                try
                    b(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                catch
                    bbbb=str2double(dataReg.totale_casi(index,1));
                    b(h)=plot(time_num(2:end),diff(bbbb),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                end
                %
            end
            
            regione_leg=regione;
            regione_leg(strfind(regione_leg,''''))=' ';
            regione_leg(strfind(regione_leg,'Ã'))='i';
            regione_leg(strfind(regione_leg,'¬'))='';
            string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            code_axe = get(id_f, 'CurrentAxes');
            set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
            
            if normalizza_per_popolazione==1
                sf=diff((dataReg.totale_casi(index,1)))/pop.number(idx_pop(h))*1000;
            else
                sf=diff((dataReg.totale_casi(index,1)));
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
        if normalizza_per_popolazione==0
            ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        end
        if normalizza_per_popolazione==0
            ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
        else
            ylabel('Numero casi ogni 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
        end
        set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
        ax.XTick = time_num;
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        
        
        if normalizza_per_popolazione==0
            t_lim=ylim;
            if t_lim(2)<100
                ylim([t_lim(1) 100]);
            end
        end
        t_lim=ylim;
        if normalizza_per_popolazione==1
            ylim([0 t_lim(2)]);
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
        
        annotation(gcf,'textbox',...
            [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
        
        
        if normalizza_per_popolazione==1
            print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
        else
            
            print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
        end
        close(gcf);
        
    end
    
    
    
    
    
    
    
    
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
        regione_leg(strfind(regione_leg,'Ã'))='i';
        regione_leg(strfind(regione_leg,'¬'))='';
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
    %         for i1=1:numel(bar_all)
    %             text(i1,bar_all(i1),num2str(bar_all(i1),'%.0f'),...
    %                 'HorizontalAlignment','center',...
    %                 'VerticalAlignment','bottom','fontsize',7)
    %         end
    
    
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
    
    annotation(gcf,'textbox',...
        [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_prog_perc_',char(Regione_lista(reg)) ,'_progressioneUltimoGiorno.PNG']);
    close(gcf);
    
    
    
    
end





%% spline sui casi provinciali giornalieri
dataReg=dataProv;

[ListaProvince]= unique(dataReg.denominazione_provincia);
ListaProvince = setdiff(ListaProvince,'In fase di definizione/aggiornamento');

tabellone=struct;


fout=fopen('province_daily_spline.csv','wt');
for p =1 : size(ListaProvince,1)
    idx = find(strcmp(dataReg.denominazione_provincia,ListaProvince(p)));
    dateTime = dataReg.data(idx);
    dataProv1 = dataReg.totale_casi(idx);
    
    dataTime_diff = dateTime(2:end);
    dataProv_diff = diff(dataProv1);
    
    [~, ~, ~, dataProv_diff_int] = splinerMat(1:size(dataTime_diff,1),dataProv_diff,3,0,1:size(dataTime_diff,1));
    dataProv_diff_int(dataProv_diff_int<0)=0;
    
    for k = 1:size(dataTime_diff,1)
        fprintf(fout,'%s;%s;%.2f\n', char(dataTime_diff(k)), char(dataReg.sigla_provincia(idx(k))), dataProv_diff_int(k));
    end
    
    
    %    figure
    %    plot(datenum(dataTime_diff),dataProv_diff,'-b');
    %    hold on
    %    plot(datenum(dataTime_diff),dataProv_diff_int,'.-r');
    %
    
    
    tabellone.casi(:,p)=dataProv_diff_int;
    tabellone.coord(p,:)=[dataReg.lat(idx(1)) dataReg.long(idx(1))];
    idx_prov = find(strcmp(pop.sigla, dataReg.sigla_provincia(idx(k))));
    tabellone.popolazione(p,1)=pop.number(idx_prov);
    
end

fclose(fout);
%
% fh=figure;
% hold on
% filename='provascatter.gif';
% for k=1:size(tabellone.casi,1)
%
%
%     kk=scatter(tabellone.coord(:,2), tabellone.coord(:,1),tabellone.casi(k,:)+1,'filled','MarkerFaceColor',[1 0 0]);
% %     kk=scatter(tabellone.coord(:,2), tabellone.coord(:,1),tabellone.casi(k,:)./tabellone.popolazione'*1000000,'filled','MarkerFaceColor',[1 0 0]);
%     frame = getframe(fh);
%     im_frame = frame2im(frame);
%
%     drawnow
%     [imind,cm] = rgb2ind(im_frame,256);
%     %     imind = imind(1:1250, 450:1700); % cut the bottom
%     % Write to the GIF File
%     if k == 1
%         imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.40);
%     else
%         imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.40);
%     end
%     delete(kk)
% end












%% MAPPE
mappeprovincia;
mappeprovincia_var;








% mkdir('GRAPHS');
% movefile('*.PNG','GRAPHS','f');

