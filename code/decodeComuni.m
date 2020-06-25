if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end







analizza_nuovo=0;

if analizza_nuovo==1
    year=2020;
    month=06;
    day=24;
    
    
    dateNume=datenum(year,month,day);
    
    fileout=sprintf('%s/_json/Lombardia_comuni_html/datiComuni.txt',WORKroot);
    
    filename = sprintf('%s/_json/Lombardia_comuni_html/%04d-%02d-%02d.html',WORKroot,year,month,day);
    fid       = fopen(filename, 'rt');
    file_scan = textscan(fid, '%s', 'whitespace', '');
    fclose(fid);
    file_scan                             = file_scan{1};
    file_scan=char(file_scan);
%     pattern = '_Flourish_data_column_names = {"data":{"nest_columns":["","003 comuni PER MINISTERO"],"size_columns":[""]}}';
    pattern = '_Flourish_data_column_names = {"data":{"nest_columns":["Provincia","Comuni"],"size_columns":["Contagiati"';
    pattern2 = 'for (var _Flourish_dataset in _Flourish_data) {';
    pattern = '_Flourish_data_column_names = {"data"';
    
    idx1=strfind(file_scan,pattern);
    idx2=strfind(file_scan,pattern2);
    
    file_scan=file_scan(idx1:idx2);
    
    pattern = '_Flourish_data = {"data":';
    idx1=strfind(file_scan,pattern);
    file_scan=file_scan(idx1:end);
    file_scan=file_scan(27:end-7);
    
    file_scan=strrep(file_scan,'{"nest_columns":[','');
    file_scan=strrep(file_scan,'],"size_columns":[',',');
    file_scan=strrep(file_scan,']},',',');
    file_scan=strrep(file_scan,'"','');
    file_scan=file_scan(1:end-2);
    
    
    idx=strfind(file_scan,',');
    k=1;
    j=0;
    
    data=struct;
    while k<numel(idx)-1
        j=j+1;
        if k==1
            id1=1;
        else
            id1=idx(k-1)+1;
        end
        id2=idx(k)-1;
        data.prov(j,1)=cellstr(file_scan(id1:id2));
        k=k+1;
        id1=idx(k-1)+1;
        id2=idx(k)-1;
        data.citta(j,1)=cellstr(file_scan(id1:id2));
        k=k+1;
        id1=idx(k-1)+1;
        id2=idx(k)-1;
        data.casi(j,1)=str2double(file_scan(id1:id2));
        k=k+1;
    end
    
    fout=fopen(fileout,'at');
    for i = 1:numel(data.casi)
        fprintf(fout,'%d;%s;%s;%d\n',dateNume,char(data.prov(i,1)),char(data.citta(i,1)),data.casi(i,1));
    end
    fclose(fout);
    
end





%% Analisi

fileout=sprintf('%s/_json/Lombardia_comuni_html/datiComuni.txt',WORKroot);
[dateNumber_tot,prov_tot,comune_tot,casi_tot]=textread(fileout,'%d%s%s%d','delimiter',';');

%popolazione
filename =sprintf('%s/_json/Lombardia_comuni_html/PopolazioneComuni.txt',WORKroot);
[pop.name, pop.pop, pop.dens]=textread(filename,'%s%f%f','delimiter','\t','headerlines',1);

% calcolo casi/popolazione
casi_totPesati=NaN(size(casi_tot));

for i=1:size(comune_tot,1)
    idx=find(strcmp(upper(pop.name), comune_tot(i)));
    if isempty(idx)
        fprintf('WARNING: %s not found\n',char(comune_tot(i)));
    else
        casi_totPesati(i,:)= casi_tot(i,:)/pop.pop(idx);
    end
end

[comune_unique, idx1] = unique(comune_tot);
comune_unique=comune_unique(1:end-1);
[day_unique, idx2]=unique(dateNumber_tot);


data_comune_unique=struct;
data_comune_unique.casi_tot=zeros(numel(comune_unique),numel(day_unique));
data_comune_unique.casi_pesati=zeros(numel(comune_unique),numel(day_unique));

for i = 1:numel(comune_unique)
    data_comune_unique.comune(i,1)=comune_unique(i);
    data_comune_unique.prov(i,1)=prov_tot(idx1(i));
    for k = 1:numel(day_unique)
        idx = find(strcmp(comune_tot,comune_unique(i))&dateNumber_tot==day_unique(k));
        if ~isempty(idx)
            data_comune_unique.casi_tot(i,k)=casi_tot(idx);
            data_comune_unique.casi_pesati(i,k)=casi_totPesati(idx);
        end
    end
end






%% Casi complessivi provinciali: plot liscio
prov_list=unique(data_comune_unique.prov);
dateNume=day_unique(end);
for pp = 1 : numel(prov_list)
    
    sigla_prov_1 = char(prov_list(pp));
    
    if ~isempty(sigla_prov_1)
    
    idx=find(strcmp(data_comune_unique.prov,cellstr(sigla_prov_1)));
    
    dataComo = struct;
    dataComo.comuni=data_comune_unique.comune(idx);
    dataComo.casi=data_comune_unique.casi_tot(idx,end);
    
    [dataComo.casi,idx]=sort(dataComo.casi,'descend');
    dataComo.comuni=dataComo.comuni(idx);
    
    
    
    datetickFormat = 'dd mmm';
    regione = sigla_prov_1;
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': casi totali']);
    title(sprintf('%s: casi totali al %s', regione, datestr(dateNume,'dd-mm-yyyy')))
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid minor
    hold on
    
    n_citta=25;
    
    bbbar = bar(dataComo.casi(1:n_citta)); hold on
    set(bbbar(1),'FaceColor',[0 0.000000011920929 0.500000002980232]);
    
    for i1=1:numel(dataComo.casi(1:n_citta))
        text(i1,dataComo.casi(i1),num2str(dataComo.casi(i1),'%.0f'),...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','fontsize',7)
        
    end
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    
    set(gca,'XTick',1:n_citta);
    set(gca,'XTickLabel',dataComo.comuni(1:n_citta));
    set(gca,'XLim',[0.5,n_citta+0.5]);
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax=gca;
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Numero casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.647895149350142 0.927031509121062 0.286235615305067 0.04638],...
        'String',{['Fonte: https://flo.uri.sh/visualisation/1809981/embed']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    annotation(gcf,'textbox',...
        [0.709573685824212 0.908789386401327 0.238100000000001 0.04638],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', [WORKroot,'/slides/img/comuniLombardia/', regione, '_casiTotali.PNG']);
    close(gcf);
    end
    
end


%% Casi complessivi provinciali: plot pesato sulla popolazione
prov_list=unique(data_comune_unique.prov);
dateNume=day_unique(end);
for pp = 1 : numel(prov_list)
    
    sigla_prov_1 = char(prov_list(pp));
    if ~isempty(sigla_prov_1)
    idx=find(strcmp(data_comune_unique.prov,cellstr(sigla_prov_1)));
    
    dataComo = struct;
    dataComo.comuni=data_comune_unique.comune(idx);
    dataComo.casiPesati=data_comune_unique.casi_pesati(idx,end);
    dataComo.casiTotali=data_comune_unique.casi_tot(idx,end);
       
    [dataComo.casi,idx]=sort(dataComo.casiPesati,'descend');
    dataComo.comuni=dataComo.comuni(idx);
    
    
    
    datetickFormat = 'dd mmm';
    regione = sigla_prov_1;
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': casi totali']);
    title(sprintf('%s: casi totali al %s ogni 1000 ab.', regione, datestr(dateNume,'dd-mm-yyyy')))
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid minor
    hold on
    
    n_citta=25;
    
    bbbar = bar(dataComo.casi(1:n_citta)*1000); hold on
    set(bbbar(1),'FaceColor',[0 0.000000011920929 0.500000002980232]);
    
    for i1=1:numel(dataComo.casi(1:n_citta))
        text(i1,dataComo.casi(i1)*1000,['(', num2str(dataComo.casiTotali(idx(i1)),'%.0f'),')'],...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','fontsize',7)
        
    end
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    
    set(gca,'XTick',1:n_citta);
    set(gca,'XTickLabel',dataComo.comuni(1:n_citta));
    set(gca,'XLim',[0.5,n_citta+0.5]);
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax=gca;
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Numero casi totali ogni 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.647895149350142 0.927031509121062 0.286235615305067 0.04638],...
        'String',{['Fonte: https://flo.uri.sh/visualisation/1809981/embed']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    annotation(gcf,'textbox',...
        [0.709573685824212 0.908789386401327 0.238100000000001 0.04638],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', [WORKroot,'/slides/img/comuniLombardia/', regione, '_casiTotaliPesati.PNG']);
    close(gcf);
    end
    
end



%% Casi complessivi regionali: plot pesato sulla popolazione

dateNume=day_unique(end);
dataComo = struct;
dataComo.comuni=data_comune_unique.comune;
dataComo.casiPesati=data_comune_unique.casi_pesati(:,end);
dataComo.casiTotali=data_comune_unique.casi_tot(:,end);
dataComo.prov=data_comune_unique.prov;

[dataComo.casi,idx]=sort(dataComo.casiPesati,'descend');
dataComo.comuni=dataComo.comuni(idx);
dataComo.prov=dataComo.prov(idx);


datetickFormat = 'dd mmm';
regione = 'Comuni lombardi';
figure;
id_f = gcf;
set(id_f, 'Name', [regione ': casi totali']);
title(sprintf('%s: casi totali al %s ogni 1000 ab.', regione, datestr(dateNume,'dd-mm-yyyy')))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid minor
hold on

n_citta=25;

bbbar = bar(dataComo.casi(1:n_citta)*1000); hold on
set(bbbar(1),'FaceColor',[0 0.000000011920929 0.500000002980232]);

for i1=1:numel(dataComo.casi(1:n_citta))
    text(i1,dataComo.casi(i1)*1000,['(', num2str(dataComo.casiTotali(idx(i1)),'%.0f'),')'],...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

if ismac
    font_size = 9;
else
    font_size = 6.5;
end


set(gca,'XTick',1:n_citta);
labels={};
for k=1:n_citta
    labels(k)=cellstr(sprintf('%s (%s)', char(dataComo.comuni(k)), char(dataComo.prov(k))));
    
end


set(gca,'XTickLabel',labels);
set(gca,'XLim',[0.5,n_citta+0.5]);
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero casi totali ogni 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.647895149350142 0.927031509121062 0.286235615305067 0.04638],...
    'String',{['Fonte: https://flo.uri.sh/visualisation/1809981/embed']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.709573685824212 0.908789386401327 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/comuniLombardia/', regione, '_casiTotaliPesati.PNG']);
close(gcf);

















%% Nuovi casi tra ultimo giorno e precedente
data_comune_newLast = data_comune_unique.casi_tot(:,end)-data_comune_unique.casi_tot(:,end-1);

% plot Province liscio

prov_list=unique(data_comune_unique.prov);

for pp = 1 : numel(prov_list)
    
    sigla_prov_1 = char(prov_list(pp));
    if ~isempty(sigla_prov_1)
    
    
    idx=find(strcmp(data_comune_unique.prov,cellstr(sigla_prov_1)));
    
    dataComo = struct;
    dataComo.comuni=data_comune_unique.comune(idx);
    dataComo.casi=data_comune_newLast(idx);
    
    [dataComo.casi,idx]=sort(dataComo.casi,'descend');
    dataComo.comuni=dataComo.comuni(idx);
    
    datetickFormat = 'dd mmm';
    regione = sigla_prov_1;
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': casi totali']);
    title(sprintf('%s: nuovi casi tra %s e %s', regione, datestr(day_unique(end-1),'dd-mm-yyyy'), datestr(day_unique(end),'dd-mm-yyyy')))
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid minor
    hold on
    
    n_citta=25;
    
    
    
    
    
    bbbar = bar(dataComo.casi(1:n_citta)); hold on
    set(bbbar(1),'FaceColor',[0 0.000000011920929 0.500000002980232]);
    
    for i1=1:numel(dataComo.casi(1:n_citta))
        text(i1,dataComo.casi(i1),num2str(dataComo.casi(i1),'%.0f'),...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','fontsize',7)
        
    end
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    
    set(gca,'XTick',1:n_citta);
    set(gca,'XTickLabel',dataComo.comuni(1:n_citta));
    set(gca,'XLim',[0.5,n_citta+0.5]);
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax=gca;
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Numero casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.647895149350142 0.927031509121062 0.286235615305067 0.04638],...
        'String',{['Fonte: https://flo.uri.sh/visualisation/1809981/embed']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    annotation(gcf,'textbox',...
        [0.709573685824212 0.908789386401327 0.238100000000001 0.04638],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', [WORKroot,'/slides/img/comuniLombardia/newgiornalieri_', regione, '.PNG']);
    close(gcf);
    end
end











