% mkdir([WORKroot,'/slides/img/regioni']);
% mkdir([WORKroot,'/slides/img/province']);
% mkdir('slides');
% mkdir('slides/img');
% mkdir('slides/img/province');
% mkdir('slides/img/regioni');
analisiWorld

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
    [prov_della_regione, ixs]=setdiff(prov_della_regione,cellstr('A'));
    
    
    pop.popolazioneRegioniPop(kk)=0;
    pop.popolazioneRegioniNome(kk)=Regione_lista(kk);
    for jj=1:size(prov_della_regione,1)
        idx=find(strcmp(pop.sigla,prov_della_regione(jj)));   
        pop.popolazioneRegioniPop(kk)=pop.popolazioneRegioniPop(kk)+pop.number(idx);
    end
end


%% report pdf
analisiReportPdf

analisiExtra

%% percorsi:
data=struct;
data.dataReg=dataReg;
% animated_gif_reg_gara(data,pop,'A');
% animated_gif_prov_gara(dataProv,pop,'A');

animated_gif_reg_Andrea(data,'A');
% animated_gif_reg_Andrea_fase2(data,'A');
try
    %     animated_gif_reg_Andrea(data,'N');
    %     animated_gif_reg_Andrea(data,'C');
    %     animated_gif_reg_Andrea(data,'S');
catch
end
animated_gif_reg_fase2(data,pop,'A');

% animated_gif_reg_gara(data,pop,'A');



%% indice fine epidemia
customC_list=regioni_tot;

testo = struct;
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
title('Indice fine epidemia')

set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
clear a1_tot t_tot max_a1;
t1=datenum(unique(dataReg.data));



for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    
    y=(dataReg.dimessi_guariti(index)+dataReg.deceduti(index))./(dataReg.totale_casi(index));
    a1=movmean(y, 20, 'omitnan');
    t=t1;
    t_tot{reg}=t;
    b1(reg)=plot(t1,y,':','LineWidth', 0.5,'color',Cmap.getColor(reg, size(regioni_tot,1)));
    window=7;
    b(reg)=plot(t,a1,'-','LineWidth', 3.0,'color',Cmap.getColor(reg, size(regioni_tot,1)));
    a1_tot{reg}=a1;
    max_a1(reg,1)=a1(end);
end



font_size = 6.5;
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

% ylim([0 max(a1_tot(:))*1.1]);
ylabel('Indice fine epidemia', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);

set(gca, 'Xlim', [t(1), t(end)]);
datetick('x', datetickFormat) ;
set(gca, 'Xlim', [t(1), t(end)]);
ax.FontSize = font_size;

ylim([0 1]);

[~,idx_sort] = sort(max_a1);

kk=0;
for g=1:size(customC_list,1)
    kk=kk+1;
    if kk==1
        delta = 5;
    elseif kk==2
        delta = 10;
    elseif kk==3
        delta = 15;
        kk=0;
    end
    
    
    h=idx_sort(g);
    
    a1_tot_h=[a1_tot{h}];
    
    
    idx_max=find(a1_tot_h==max(a1_tot_h))-delta;
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/Reg_indiceFineEpidemia.PNG']);
close(gcf);









%% best regioni day
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di nuovi contagi per abitante (il %s)',datestr(max(datenum(dataReg.data)),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di nuovi contagi per abitante il %s',datestr(max(datenum(dataReg.data)),'dd mmm')));
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-1)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-1)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Nuovi positivi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Nuovi casi / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di nuovi contagi per abitante il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegDay.PNG']);
close(gcf);




%% best regioni week
list_day = unique(datenum(dataReg.data));


figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di nuovi contagi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di nuovi contagi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];

   
xlabel('Nuovi positivi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Nuovi casi / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di nuovi contagi per abitante (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeek.PNG']);
close(gcf);


















%% deceduti week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di decessi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di decessi  (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.deceduti(index(end))-dataReg.deceduti(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.deceduti(index(end))-dataReg.deceduti(index(end-6)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Deceduti / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Deceduti / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di deceduti per abitante (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekDeceduti.PNG']);
close(gcf);







%% tamponi week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di tamponi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di tamponi  (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.tamponi(index(end))-dataReg.tamponi(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.tamponi(index(end))-dataReg.tamponi(index(end-6)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Tamponi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Tamponi / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di tamponi per abitante (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekTamponi.PNG']);
close(gcf);



%% casi testati week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di nuovi casi testati (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di nuovi casi testati  (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)));    
    worstRegValuePercPos(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)))./worstAbsValue(reg,1)*100;
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

worstRegValuePercPos=worstRegValuePercPos(idxSort);

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Nuovi casi testati / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Nuovi casi testati / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di Nuovi casi testati per abitante (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekCasiTestati.PNG']);
close(gcf);


%% % positivi week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con la maggior %% di nuovi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con la maggior %% di nuovi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)));    
    worstRegValuePercPos(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)))./worstAbsValue(reg,1)*100;
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

worstRegValuePercPos=worstRegValuePercPos(idxSort);

x_data_i=flip(worstRegValuePercPos);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%.2f%%)', char(regioni_tot(idx_i(k))),worstRegValuePercPos(k)), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Percentuale Nuovi casi testati positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Percentuale Nuovi casi testati positivi')
title(sprintf('Italia: Regioni con la maggior %% di nuovi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekCasiTestatiPercent.PNG']);
close(gcf);







%% radar test week / positivi week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Nuovi casi wrt Casi testati (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Nuovi casi wrt Casi testati (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)));    
    worstRegValuePercPos(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)))./worstAbsValue(reg,1)*100;
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;


x_data=worstRegValue;
y_data=worstRegValuePercPos;

ylim([0 ceil(max(y_data))])
xlim([0 max(x_data)*1.1])



patch([0, 0, max(x_data)*1.1/2], [0 ceil(max(y_data)) ceil(max(y_data))], 'r','FaceAlpha',0.2);
patch([0, max(x_data)*1.1/2, max(x_data)*1.1*1.5], [0 ceil(max(y_data)) ceil(max(y_data))], 'y','FaceAlpha',0.2);
patch([0, max(x_data)*1.1*1.5, max(x_data)*1.1*1.5], [0 ceil(max(y_data)) 0], 'g','FaceAlpha',0.2);
colors={};
for k=1:size(regioni_tot,1)
    colors{k}=Cmap.getColor(k, size(regioni_tot,1));
end
% Init labels
l=1;
x = x_data;
y = y_data;
clear lbl;
hold on;
fontsize=10;
for q=1:length(x)
    %plot(x(q)',y(q)',markers{l},'w')
    if strcmp('P.A. Bolzano',regioni_tot{q})
        lbl(q) = text(x(q),y(q), 'BOLZ','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
    elseif strcmp('P.A. Trento',regioni_tot{q})
        lbl(q) = text(x(q),y(q), 'TREN','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
    elseif strcmp('Valle d Aosta',regioni_tot{q})
        lbl(q) = text(x(q),y(q), 'VDAO','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
    else
        lbl(q) = text(x(q),y(q), upper(regioni_tot{q}(1:4)),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
    end
    l=l+1;
    if l==size(colors,2)
        l=1;
    end
end

ylabel('Percentuale Nuovi casi testati Positivi')
xlabel('Nuovi casi testati ogni 100.000 ab.')
set(gcf,'color','w');

for n = 1:size(x_data,1)
    % Draw plot for y = x.^n
    x = x_data(n,:);
    y = y_data(n,:);
    
    for q=1:length(x)
        %plot(x(q)',y(q)',markers{l},'w')
        lbl(q).Position(1:2) = [x(q), y(q)];
    end
    for q=1:length(x)
        %plot(x(q)',y(q)',markers{l},'w')
        lbl(q).Position(1:2) = [x(q), y(q)];
    end
end

datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekCasiTestatiPercentMAP.PNG']);
close(gcf);






























%% positivi su casi testati week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior percentuale di nuovi casi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior percentuale di nuovi casi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-6)))/(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)))*100;
    worstAbsValue(reg,1)=(dataReg.casi_testati(index(end))-dataReg.casi_testati(index(end-6)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%.2f%%)', char(regioni_tot(idx_i(k))),worstRegValue(end-k+1)), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Percentuale di nuovi casi testati positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Percentuale di nuovi casi testati positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
title(sprintf('Italia: Regioni con maggior percentuale di nuovi casi testati positivi (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekCasiTestatiPerc.PNG']);
close(gcf);




%% deceduti day
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di deceduti il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));
title(sprintf('Italia: Regioni con maggior numero di deceduti il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.deceduti(index(end))-dataReg.deceduti(index(end-1)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.deceduti(index(end))-dataReg.deceduti(index(end-1)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];

xlabel('Deceduti / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Deceduti / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di deceduti per abitante (il %s)',datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegDayDeceduti.PNG']);
close(gcf);




%% dimessi guariti day
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di dimessi/guariti il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));
title(sprintf('Italia: Regioni con maggior numero di dimessi/guariti il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.dimessi_guariti(index(end))-dataReg.dimessi_guariti(index(end-1)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.dimessi_guariti(index(end))-dataReg.dimessi_guariti(index(end-1)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];

xlabel('Dimessi/guariti / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Deceduti / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di dimessi/guariti per abitante (il %s)',datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegDayDimessi.PNG']);
close(gcf);






%% dimessi-guariti week
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: Regioni con maggior numero di dimessi/guariti (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));
title(sprintf('Italia: Regioni con maggior numero di dimessi/guariti  (dal %s al %s)',datestr(list_day(end-6),'dd mmm'),datestr(list_day(end),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
worstRegValue=[];
worstRegValue_abs=[];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    worstRegValue(reg,1)=(dataReg.dimessi_guariti(index(end))-dataReg.dimessi_guariti(index(end-6)))./pop.popolazioneRegioniPop(reg)*100000;
    worstAbsValue(reg,1)=(dataReg.dimessi_guariti(index(end))-dataReg.dimessi_guariti(index(end-6)));
end
worstRegValue(worstRegValue<0)=0;
worstAbsValue(worstAbsValue<0)=0;
[worstRegValue,idxSort]=sort(worstRegValue,'descend');

x_data_i=flip(worstRegValue);
idx_i=flip(idxSort);

a=barh([1 2], [x_data_i ,x_data_i]');
grid minor

for k=1:size(regioni_tot,1)
    set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
end

hT={};              % placeholder for text object handles
for k=1:size(regioni_tot,1) % iterate over number of bar objects
    hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
        'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
    d=hT{k};
    xx=a(k).YData(2);
    yy=a(k).XData(2)+a(k).XOffset(1);    
    d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
    drawnow
end

d=hT{1};
xx=a(1).YData(2);
yy=a(1).XData(2)+a(1).XOffset(1);
d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
   
xlabel('Dimessi/guariti / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

set(gca,'YTick',[])
set(gca,'YLim',[1.6,2.4])
set(gca,'FontSize',8);
set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
xlabel('Dimessi/guariti / 100.000 abitanti')
title(sprintf('Italia: Regioni con maggior numero di dimessi/guariti per abitante (dal %s al %s)',datestr(list_day(end-6),'dd/mm/yyyy'),datestr(list_day(end),'dd/mm/yyyy')));

ax=get(gca);
ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegWeekDimessi.PNG']);
close(gcf);



% 
% %% percentuale positivi da screening
% figure;
% id_f = gcf;
% set(id_f, 'Name', sprintf('Italia: Regioni con maggior percentuale di positivi da screening il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));
% title(sprintf('Italia: Regioni con maggior percentuale di positivi da screening il %s',datestr(max(datenum(dataReg.data)),'dd/mm/yyyy')));
% 
% 
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% worstRegValue=[];
% worstRegValue_abs=[];
% for reg=1:size(regioni_tot,1)
%     regione = char(regioni_tot(reg,1));
%     index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
%     worstAbsValue(reg,1)=(dataReg.casi_da_screening(index(end))-dataReg.casi_da_screening(index(end-1)))/(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-1)))*100;
% end
% % worstRegValue(worstRegValue<0)=0;
% worstAbsValue(worstAbsValue<0)=0;
% [worstAbsValue,idxSort]=sort(worstAbsValue,'descend');
% 
% x_data_i=flip(worstAbsValue);
% idx_i=flip(idxSort);
% 
% a=barh([1 2], [x_data_i ,x_data_i]');
% grid minor
% 
% for k=1:size(regioni_tot,1)
%     set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
% end
% 
% hT={};              % placeholder for text object handles
% for k=1:size(regioni_tot,1) % iterate over number of bar objects
%     try
%     hT{k}=text(a(k).YData+max(x_data_i(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(regioni_tot(idx_i(k))),worstAbsValue(idx_i(k))), ...
%         'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
%     d=hT{k};
%     xx=a(k).YData(2);
%     yy=a(k).XData(2)+a(k).XOffset(1);    
%     d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];    
%     drawnow
%     catch
%     end
% end
% 
% d=hT{1};
% xx=a(1).YData(2);
% yy=a(1).XData(2)+a(1).XOffset(1);
% d(2).Position=[xx+max(x_data_i(:))*0.01,yy,0];
% 
% xlabel('Deceduti / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
% 
% set(gca,'YTick',[])
% set(gca,'YLim',[1.6,2.4])
% set(gca,'FontSize',8);
% set(gca,'xlim',[0,max(x_data_i(:))*1.12]);
% xlabel('Deceduti / 100.000 abitanti')
% title(sprintf('Italia: Regioni con maggior numero di deceduti per abitante (il %s)',datestr(list_day(end),'dd/mm/yyyy')));
% 
% ax=get(gca);
% ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';
% 
% % overlap copyright info
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
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestRegDayDeceduti.PNG']);
% close(gcf);
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
        
        bbb=[dataReg.terapia_intensiva(index,1)';dataReg.totale_ospedalizzati(index,1)'-dataReg.terapia_intensiva(index,1)';dataReg.isolamento_domiciliare(index,1)';dataReg.dimessi_guariti(index,1)';dataReg.deceduti(index,1)'];
        if reg==9
            bbb_lombardia = bbb;
        end
        
        
        bbbar = bar(bbb','stacked'); hold on
        set(bbbar(5),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
        set(bbbar(1),'FaceColor',[1 0 0]);
        set(bbbar(2),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
        set(bbbar(3),'FaceColor',[1 1 0.400000005960464]);
        set(bbbar(4),'FaceColor',[0 0.800000011920929 0.200000002980232]);
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        
        set(gca,'XTick',1:2:size(time_num,1));
        set(gca,'XTickLabel',datestr(time_num(1:2:end),'dd mmm'));
        set(gca,'XLim',[0.5,size(time_num,1)+0.5]);
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        ax=gca;
        ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
        
        l=legend([bbbar(4), bbbar(3),bbbar(2),bbbar(1),bbbar(5)],'Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
        
        
        set(gca,'XTick',1:2:size(time_num(2:end),1));
        set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'));
        set(gca,'XLim',[0.5,size(time_num(2:end),1)+0.5]);
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
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
        
        
        
        
        
        
        
        %% esito malattia
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', [regione ': esito malattia']);
        title(sprintf([regione ': esito malattia\\fontsize{5}\n ']))
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        
        a=plot(time_num,(dataReg.deceduti(index)./(dataReg.deceduti(index)+dataReg.dimessi_guariti(index)))*100,'-k','LineWidth', 2.0);
        b=plot(time_num,100-(dataReg.deceduti(index)./(dataReg.deceduti(index)+dataReg.dimessi_guariti(index)))*100,'-g','LineWidth', 2.0);
        
        
        
        
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
        ylabel('% casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
        
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        ax.XTick = time_num(1):2:time_num(end);
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        ax.FontSize = font_size;
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        
        
        t_lim=ylim;
        if t_lim(2)<100
            ylim([t_lim(1) 100]);
        end
        
        l=legend([b,a],'Dimessi Guariti','Deceduti');
        set(l,'Location','northeast')
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
        print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_esito.PNG']);
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
                a=plot(time_num,dataReg.ricoverati_con_sintomi(index,1),'-','LineWidth', 2.0, 'Color', [1 0 1]);
                b=plot(time_num,dataReg.totale_casi(index,1),'-','LineWidth', 2.0, 'Color', [0.23137255012989 0.443137258291245 0.337254911661148]);
                c=plot(time_num,dataReg.dimessi_guariti(index,1),'-','LineWidth', 2.0, 'Color', [0 0.800000011920929 0.200000002980232]);
                d=plot(time_num,dataReg.deceduti(index,1),'-','LineWidth', 2.0, 'Color', [0.400000005960464 0.400000005960464 0.400000005960464]);
                e=plot(time_num,dataReg.terapia_intensiva(index,1),'-','LineWidth', 2.0, 'Color', [1 0 0]);
                f=plot(time_num,dataReg.totale_ospedalizzati(index,1),'-','LineWidth', 2.0, 'Color', [0.929411768913269 0.694117665290833 0.125490203499794]);
                g=plot(time_num,dataReg.isolamento_domiciliare(index,1),'-','LineWidth', 2.0, 'Color', [0 0.447058826684952 0.74117648601532]);
                h=plot(time_num,dataReg.totale_positivi(index,1),'-','LineWidth', 2.0, 'Color', [0 0.749019622802734 0.749019622802734]);
            catch
%                 a=plot(time_num,str2double(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
%                 b=plot(time_num,str2double(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(2, 8));
%                 c=plot(time_num,str2double(dataReg.dimessi_guariti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(3, 8));
%                 d=plot(time_num,str2double(dataReg.deceduti(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(4, 8));
%                 e=plot(time_num,str2double(dataReg.terapia_intensiva(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(5, 8));
%                 f=plot(time_num,str2double(dataReg.totale_ospedalizzati(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(6, 8));
%                 g=plot(time_num,str2double(dataReg.isolamento_domiciliare(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(7, 8));
%                 h=plot(time_num,str2double(dataReg.totale_positivi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(8, 8));
                
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
        ax.XTick = time_num(1:2:end);
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        ax.FontSize = font_size;
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        
        
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
%         if mediamobile_yn==0
%             try
%                 a=plot(time_num(2:end),diff(dataReg.ricoverati_con_sintomi(index,1)),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
%                 b=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
%                 c=plot(time_num(2:end),diff(dataReg.dimessi_guariti(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
%                 d=plot(time_num(2:end),diff(dataReg.deceduti(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
%                 e=plot(time_num(2:end),diff(dataReg.terapia_intensiva(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
%                 f=plot(time_num(2:end),diff(dataReg.totale_ospedalizzati(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
%                 g=plot(time_num(2:end),diff(dataReg.isolamento_domiciliare(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
%                 h=plot(time_num(2:end),diff(dataReg.totale_positivi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
%             catch
%                 
%                 a=plot(time_num(2:end),diff(str2double(dataReg.ricoverati_con_sintomi(index,1))),'-','LineWidth', 2.0, 'Color', Cmap.getColor(1, 8));
%                 b=plot(time_num(2:end),diff(str2double(dataReg.totale_casi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(2, 8));
%                 c=plot(time_num(2:end),diff(str2double(dataReg.dimessi_guariti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(6, 8));
%                 d=plot(time_num(2:end),diff(str2double(dataReg.deceduti(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(4, 8));
%                 e=plot(time_num(2:end),diff(str2double(dataReg.terapia_intensiva(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(5, 8));
%                 f=plot(time_num(2:end),diff(str2double(dataReg.totale_ospedalizzati(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(3, 8));
%                 g=plot(time_num(2:end),diff(str2double(dataReg.isolamento_domiciliare(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(7, 8));
%                 h=plot(time_num(2:end),diff(str2double(dataReg.totale_positivi(index,1))),'-','LineWidth', 2.0,  'Color', Cmap.getColor(8, 8));
%             end
%             
%         else
            a1=plot(time_num(2:end),diff(dataReg.ricoverati_con_sintomi(index,1)),':','LineWidth', 0.5, 'Color', [1 0 1]);
            b1=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),':','LineWidth', 0.5,  'Color', [0.23137255012989 0.443137258291245 0.337254911661148]);
            c1=plot(time_num(2:end),diff(dataReg.dimessi_guariti(index,1)),':','LineWidth', 0.5,  'Color', [0 0.800000011920929 0.200000002980232]);
            d1=plot(time_num(2:end),diff(dataReg.deceduti(index,1)),':','LineWidth', 0.5,  'Color', [0.400000005960464 0.400000005960464 0.400000005960464]);
            e1=plot(time_num(2:end),diff(dataReg.terapia_intensiva(index,1)),':','LineWidth', 0.5,  'Color', [1 0 0]);
            f1=plot(time_num(2:end),diff(dataReg.totale_ospedalizzati(index,1)),':','LineWidth', 0.5,  'Color', [0.929411768913269 0.694117665290833 0.125490203499794]);
            g1=plot(time_num(2:end),diff(dataReg.isolamento_domiciliare(index,1)),':','LineWidth', 0.5,  'Color', [0 0.447058826684952 0.74117648601532]);
            h1=plot(time_num(2:end),diff(dataReg.totale_positivi(index,1)),':','LineWidth', 0.5,  'Color', [0 0.749019622802734 0.749019622802734]);
            
            
            window=3;
            
            a=plot(time_num(2:end),movmean(diff(dataReg.ricoverati_con_sintomi(index,1)), window, 'omitnan'),'-','LineWidth', 2.0, 'Color', [1 0 1]);
            b=plot(time_num(2:end),movmean(diff(dataReg.totale_casi(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [0.23137255012989 0.443137258291245 0.337254911661148]);
            c=plot(time_num(2:end),movmean(diff(dataReg.dimessi_guariti(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [0 0.800000011920929 0.200000002980232]);
            d=plot(time_num(2:end),movmean(diff(dataReg.deceduti(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [0.400000005960464 0.400000005960464 0.400000005960464]);
            e=plot(time_num(2:end),movmean(diff(dataReg.terapia_intensiva(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [1 0 0]);
            f=plot(time_num(2:end),movmean(diff(dataReg.totale_ospedalizzati(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [0.929411768913269 0.694117665290833 0.125490203499794]);
            g=plot(time_num(2:end),movmean(diff(dataReg.isolamento_domiciliare(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color',[0 0.447058826684952 0.74117648601532]);
            h=plot(time_num(2:end),movmean(diff(dataReg.totale_positivi(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', [0 0.749019622802734 0.749019622802734]);
%         end
        






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
        ax.XTick = time_num(1:2:end);
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',90,'FontSize',6.5);
        ax.FontSize = font_size;
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
        
        t_lim=ylim;
        if t_lim(2)<100
            ylim([t_lim(1) 100]);
        end
        
        %     l=legend([a,b,c,d],'Ricoverati con sintomi','Totale Casi','Dimessi Guariti','Deceduti');
%         l=legend([b,a,c,d,e,f,g,h],'Totale Casi','Ricoverati con sintomi','Dimessi Guariti','Deceduti','Terapia intensiva','Totale ospedalizzati','Isolamento domiciliare','Attualmente positivi');
        l=legend([b,h,c,g,f,a,e,d],'Totale Casi','Attualmente positivi','Dimessi Guariti','Isolamento domiciliare','Totale ospedalizzati','Ricoverati con sintomi','Terapia intensiva','Deceduti');        
        set(l,'Location','northwest')
        
%         l1=legend([b1,b],'Dato giornaliero','Media mobile (3 giorni)');
%         set(l1,'Location','SouthOutside')
%         
        
        
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
    
    
    %% tamponi totali
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
    
    
    casiTestati =  diff(dataReg.casi_testati(index,1));
    casiTestati(casiTestati<0)=nan; casiTestati(casiTestati==0)=nan;
    
    totaleTamponi = diff(dataReg.tamponi(index,1)); totaleTamponi(totaleTamponi<0)=nan;
    
    
    %     a=bar([tamp_positivi, casiTestati-tamp_positivi, totaleTamponi-casiTestati-tamp_positivi],1,'stacked');
    
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
    
    
    set(gca,'XTick',1:2:size(tamp_positivi,1))
    set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'))
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
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
    
    
    %% tamponi totali e casi testati
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
    
    
    casiTestati =  diff(dataReg.casi_testati(index,1));
    casiTestati(casiTestati<0)=nan; casiTestati(casiTestati==0)=nan;
    
    totaleTamponi = diff(dataReg.tamponi(index,1)); totaleTamponi(totaleTamponi<0)=nan;
    
    
    a=bar([tamp_positivi, casiTestati-tamp_positivi, totaleTamponi-casiTestati-tamp_positivi],1,'stacked');
    
    %     a=bar([tamp_positivi, yy],1,'stacked');
    
    
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    hold on; grid minor
    %     a(1).FaceColor = [0.8 0.8 0.8];
    %     a(2).FaceColor = [1 0.200000002980232 0.200000002980232];
    
    a(3).FaceColor = [0.8 0.8 0.8];
    a(2).FaceColor = [0.678431391716003 0.921568632125854 1];
    a(1).FaceColor = [1 0.200000002980232 0.200000002980232];
    
    
    set(gca,'XTick',1:2:size(tamp_positivi,1))
    set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'))
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
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
    b=plot(1:size(tamp_positivi,1), c,'-b','LineWidth', 2.0,'Color',[0.313725501298904 0.313725501298904 0.313725501298904]);
    
    d = tamp_positivi./diff(dataReg.casi_testati(index,1))*100;  d(d>100)=NaN; d(d<0)=NaN;
    e=plot(1:size(tamp_positivi,1), d,'-b','LineWidth', 2.0);
    
    
    ylim([0 100]);
    set(gca,'YColor', [0 0 0]);
    ylabel('Percentuale tamponi positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    l=legend([a(3),a(2),a(1),b, e],'Tamponi a casi ripetuti','Tamponi a casi nuovi','Tamponi positivi','Percent. tamponi totali positivi', 'Percent. tamponi nuovi testati positivi');
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
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_tamponi_misti.PNG']);
    close(gcf);
    
    
    
    %% casi testati
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    
    datetickFormat = 'dd mmm';
    figure;
    id_f = gcf;
    set(id_f, 'Name', [regione ': casi testati']);
    title(sprintf([regione ': casi testati\\fontsize{5}\n ']))
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    tamp_positivi = diff(dataReg.totale_casi(index,1));
    %     a=bar([diff(dataReg.tamponi(index,1)),tamp_positivi],1,'stacked');
    yy =diff(dataReg.casi_testati(index,1))-tamp_positivi; yy(yy<0)=0;
    
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
    
    
    set(gca,'XTick',1:2:size(tamp_positivi,1))
    set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'))
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    set(gca,'XLim',[0.5,size(time_num,1)-0.5]);
    yL=get(gca,'ylim');
    set(gca,'ylim',[0 yL(2)]);
    ax = gca;
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Casi testati', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    
    
    
    
    yyaxis right
    c=tamp_positivi./diff(dataReg.casi_testati(index,1))*100;  c(c>100)=NaN; c(c<0)=NaN;
    b=plot(1:size(tamp_positivi,1), c,'-b','LineWidth', 2.0);
    ylim([0 100]);
    set(gca,'YColor', [0 0 0]);
    ylabel('Percentuale casi testati positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    l=legend([a(2),a(1),b],'Casi testati negativi','Tamponi positivi','Percent. tamponi positivi');
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
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_casitestati.PNG']);
    close(gcf);
end





%% analisi nazionale sulla correlazione casi-deceduti: versione 2
for reg = 1:size(regioni_tot,1);
    regione = char(regioni_tot(reg,1));
    index0 = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index0)));
    
    
    data_casiPositivi=dataReg.totale_casi(index0);
    data_deceduti=dataReg.deceduti(index0);
    
    t=time_num(2:end);
    



y1=diff(data_casiPositivi);
y2=diff(data_deceduti);
% y2=data_terapie;

l1='Casi positivi gionalieri';
l2='Deceduti giornalieri';
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
for d=0:16
    a=corrcoef(a1_1(1:end-d),a1_2(d+1:end));
    corrcoeff_tot(d+1)=a(1,2);
end
[coerrcoeff_max, idx]=max(corrcoeff_tot);
offset_dec=idx-1;


figure;
id_f = gcf;
set(gcf, 'Name', sprintf('%s: correlazione temporale',regione));
% tt=title(sprintf([regione ': correlazione nuovi casi/deceduti giornalieri\\fontsize{5}\n ']),'fontsize',9)
annotation(gcf,'textbox',...
    [0.222148098732488 0.890266851563407 0.537691794529685 0.0630182421227199],...
    'String',[regione ': correlazione nuovi casi/deceduti giornalieri'],...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontSize',10,...
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

set(a,'marker','o','markersize',3,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 0.5);
set(b,'marker','o','markersize',3,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 0.5);
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
l=legend([a,b],l1,l2);

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

annotation(gcf,'textbox',...
    [0.328498902750058 0.735693681496092 0.537691794529686 0.0630182421227199],...
    'String',['Offset: ', num2str(offset_dec), ' giorni'],...
    'LineStyle','none',...
    'HorizontalAlignment','right',...
    'FontName','Verdana',...
    'FitBoxToText','off');



print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_correlazioneCasiDeceduti_v2_spline_', num2str(reg) ,'_', regione,'.PNG']);
close(gcf);

    
    
    
end










%% lombardia andamenti con previsioni
for reg = [5,9];
    regione = char(regioni_tot(reg,1));
    index0 = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index0)));
    
    
    day_unique = unique(dataReg.data);
    time_num=datenum(day_unique);
    data=NaN(size(day_unique,1),5);
    totaleCasi=NaN(size(day_unique,1),1);
    for k = 1: size(day_unique,1)
        index = find(strcmp(dataReg.data,day_unique(k)));
        index=intersect(index0,index);
        data(k,1)=sum(dataReg.deceduti(index));
        data(k,2)=sum(dataReg.terapia_intensiva(index));
        data(k,3)=sum(dataReg.totale_ospedalizzati(index));
        data(k,4)=sum(dataReg.isolamento_domiciliare(index));
        data(k,5)=sum(dataReg.dimessi_guariti(index));
        totaleCasi(k,1)=sum(dataReg.totale_casi(index));
        
    end
    
    %%
    data_interp=[];
    % interpolazione di ogni serie
    
    % 2: terapia_intensiva
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data(i,2));
    end
    fclose(fout);
    %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
    %
    command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
    [t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    
    
    
    % 1: deceduti
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data(i,1));
    end
    fclose(fout);
    %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,1),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
    command=sprintf('gomp_estim testIn_gauss.txt');system(command);
    [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
    [t_1, idx1]= intersect(t_temp, t);
    data_interp(:,1)=data_interpTemp(idx1);
    
    
    % 3: ospedalizzati
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data(i,3));
    end
    fclose(fout);
    %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
    command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
    [t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    
    % 4: isolamento_domiciliare
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data(i,4));
    end
    fclose(fout);
    %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
    command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
    [t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
    
    
    % 5: dimessiGuariti
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data(i,5));
    end
    fclose(fout);
    %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,5),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
    command=sprintf('gomp_estim testIn_gauss.txt');system(command);
    [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
    [t_1, idx1]= intersect(t_temp, t);
    data_interp(:,5)=data_interpTemp(idx1);
    
    
    
    % 6: CasiTotali
    fout=fopen('testIn_gauss.txt','wt');
    data6= [data(:,1)'+data(:,3)'+data(:,4)'+data(:,5)']';
    for i=1:size(data,1)
        fprintf(fout,'%f;%d\n',time_num(i),data6(i,1));
    end
    fclose(fout);
    %     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
    %     [t,data_interp(:,6),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
    
    command=sprintf('gomp_estim testIn_gauss.txt');system(command);
    [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
    [t_1, idx1]= intersect(t_temp, t);
    data_interp(:,6)=data_interpTemp(idx1);
    
    
    
    
    
    t_min = time_num(1);
    t_max = time_num(end)+30;
    
    idx=t_1>=t_min & t_1<=t_max;
    
    
    datetickFormat = 'dd mmm';
    figure;
    id_f = gcf;
    regione = char(regioni_tot(reg,1));
    set(id_f, 'Name', [regione ': dati cumulati']);
    title(sprintf([regione ': dati cumulati\\fontsize{5}\n ']))
    
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    hold on
    grid minor; grid on
    
    bbb1=[data_interp(idx,1)';data_interp(idx,2)';data_interp(idx,3)';data_interp(idx,4)';data_interp(idx,5)';data_interp(idx,6)';data_interp(idx,3)'+data_interp(idx,4)'+data_interp(idx,2)'];
    bbb1(:,1:size(time_num,1)-3)=NaN;
    bbbar1 = plot(bbb1','--'); hold on
    set(bbbar1(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',1);
    set(bbbar1(2),'Color',[1 0 0],'linewidth',1);
    set(bbbar1(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',1);
    set(bbbar1(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',1);
    set(bbbar1(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',1);
    set(bbbar1(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',1);
    set(bbbar1(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',1);
    
    hold on
    
    bbb=[data(:,1)';data(:,2)';data(:,3)';data(:,4)';data(:,5)';data6';data(:,3)'+data(:,4)'+data(:,2)'];
    
    bbbar = plot(bbb','-'); hold on
    set(bbbar(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',3);
    set(bbbar(2),'Color',[1 0 0],'linewidth',3);
    set(bbbar(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',3);
    set(bbbar(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',3);
    set(bbbar(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',3);
    set(bbbar(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',3);
    set(bbbar(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',3);
    
    
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    
    fidx=find(idx);
    set(gca,'XTick',1:3:size(t(idx),1));
    set(gca,'XTickLabel',datestr(t(fidx(1):3:fidx(end)),'dd mmm'));
    set(gca,'XLim',[0.5,size(t(idx),1)+0.5]);
    set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    ax=gca;
    ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    
    ax = gca;
    set(ax, 'FontName', 'Verdana');
    set(ax, 'FontSize', font_size);
    
    l=legend([bbbar(6),bbbar(7),bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Casi Totali','Attualmente positivi','Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
    print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_linee_cumulati.PNG']);
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


bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,2)';data(:,4)';data(:,5)'];

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

set(gca,'XTick',1:2:size(time_num,1));
set(gca,'XTickLabel',datestr(time_num(1:2:end),'dd mmm'));
set(gca,'XLim',[0.5,size(time_num,1)+0.5]);
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
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

%%
data_interp=[];
% interpolazione di ogni serie

% 2: terapia_intensiva
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,2));
end
fclose(fout);
%     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
%
command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,data_interp(:,2),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');



% 1: deceduti
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,1));
end
fclose(fout);
%     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,1),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
[t_1, idx1]= intersect(t_temp, t);
data_interp(:,1)=data_interpTemp(idx1);


% 3: ospedalizzati
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,3));
end
fclose(fout);
%     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,data_interp(:,3),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');

% 4: isolamento_domiciliare
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,4));
end
fclose(fout);
%     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,data_interp(:,4),a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');


% 5: dimessiGuariti
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data(i,5));
end
fclose(fout);
%     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,5),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
[t_1, idx1]= intersect(t_temp, t);
data_interp(:,5)=data_interpTemp(idx1);



% 6: CasiTotali
fout=fopen('testIn_gauss.txt','wt');
data6= [data(:,1)'+data(:,3)'+data(:,4)'+data(:,5)']';
for i=1:size(data,1)
    fprintf(fout,'%f;%d\n',time_num(i),data6(i,1));
end
fclose(fout);
%     command=sprintf('sigm_estim testIn_gauss.txt');system(command);
%     [t,data_interp(:,6),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
[t_1, idx1]= intersect(t_temp, t);
data_interp(:,6)=data_interpTemp(idx1);





t_min = time_num(1);
t_max = time_num(end)+60;

idx=t_1>=t_min & t_1<=t_max;


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

bbb1=[data_interp(idx,1)';data_interp(idx,2)';data_interp(idx,3)';data_interp(idx,4)';data_interp(idx,5)';data_interp(idx,6)';data_interp(idx,3)'+data_interp(idx,4)'+data_interp(idx,2)'];
bbb1(:,1:size(time_num,1)-3)=NaN;
bbbar1 = plot(bbb1','--'); hold on
set(bbbar1(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',1);
set(bbbar1(2),'Color',[1 0 0],'linewidth',1);
set(bbbar1(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',1);
set(bbbar1(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',1);
set(bbbar1(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',1);
set(bbbar1(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',1);
set(bbbar1(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',1);

hold on

bbb=[data(:,1)';data(:,2)';data(:,3)';data(:,4)';data(:,5)';data6';data(:,3)'+data(:,4)'+data(:,2)'];

bbbar = plot(bbb','-'); hold on
set(bbbar(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',3);
set(bbbar(2),'Color',[1 0 0],'linewidth',3);
set(bbbar(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',3);
set(bbbar(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',3);
set(bbbar(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',3);
set(bbbar(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',3);
set(bbbar(7),'Color',[0.301960796117783 0.745098054409027 0.933333337306976],'linewidth',3);



if ismac
    font_size = 9;
else
    font_size = 6.5;
end

fidx=find(idx);
set(gca,'XTick',1:3:size(t(idx),1));
set(gca,'XTickLabel',datestr(t(fidx(1):3:fidx(end)),'dd mmm'));
set(gca,'XLim',[0.5,size(t(idx),1)+0.5]);
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

l=legend([bbbar(6),bbbar(7),bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Casi Totali','Attualmente positivi','Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_linee_cumulati.PNG']);
close(gcf);









%
% %% BARRE ITALIA PREVISIONE
%
%
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
%
%
% bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,1)';data(:,4)';data(:,5)'];
% bbb1=[data_interp(:,1)';data_interp(:,2)';data_interp(:,3)';data_interp(:,4)';data_interp(:,5)'];
% % bbb1=[data_interp(:,1)';data_interp(:,2)';data_interp(:,3)';data_interp(:,4)';dimessi_guariti'];
%
% bbb1(:,1:size(time_num,1))=NaN;
%
% bbbar = bar(bbb','stacked'); hold on
% set(bbbar(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464]);
% set(bbbar(2),'FaceColor',[1 0 0]);
% set(bbbar(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794]);
% set(bbbar(4),'FaceColor',[1 1 0.400000005960464]);
% set(bbbar(5),'FaceColor',[0 0.800000011920929 0.200000002980232]);
%
% bbbar1 = bar(bbb1','stacked'); hold on
% set(bbbar1(1),'FaceColor',[0.400000005960464 0.400000005960464 0.400000005960464],'FaceAlpha',0.2);
% set(bbbar1(2),'FaceColor',[1 0 0],'FaceAlpha',0.2);
% set(bbbar1(3),'FaceColor',[0.929411768913269 0.694117665290833 0.125490203499794],'FaceAlpha',0.2);
% set(bbbar1(4),'FaceColor',[1 1 0.400000005960464],'FaceAlpha',0.2);
% set(bbbar1(5),'FaceColor',[0 0.800000011920929 0.200000002980232],'FaceAlpha',0.2);
%
%
% if ismac
%     font_size = 9;
% else
%     font_size = 6.5;
% end
%
% set(gca,'XTick',1:2:size(t,1));
% set(gca,'XTickLabel',datestr(t(1:2:end),'dd mmm'));
% set(gca,'XLim',[0.5,size(t,1)+0.5]);
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
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
% %%
% % %     cd([WORKroot,'/assets/img/regioni']);
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_bars_cumulatiPrevisione.PNG']);
% close(gcf);


%
%
% %% grafico a linee Italia
%
% % 6: CasiTotali
% fout=fopen('testIn_gauss.txt','wt');
% data6= [data(:,1)'+data(:,2)'+data(:,3)'-data(:,1)'+data(:,4)'+data(:,5)']';
% for i=1:size(data,1)
%     fprintf(fout,'%f;%d\n',time_num(i),data6(i,1));
% end
% fclose(fout);
% % command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% % [t,data_interp(:,6),a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%f%f%f%f%f%f','delimiter',';');
%
% command=sprintf('gomp_estim testIn_gauss.txt');system(command);
% [t_temp,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% [t_1, idx1]= intersect(t_temp, t);
% data_interp(:,6)=data_interpTemp(idx1);
%
%
%
%
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
% bbb1=[data_interp(:,1)';data_interp(:,2)';data_interp(:,3)';data_interp(:,4)';data_interp(:,5)';data_interp(:,6)'];
% bbb1(:,1:size(time_num,1)-3)=NaN;
% bbbar1 = plot(bbb1','--'); hold on
% set(bbbar1(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',1);
% set(bbbar1(2),'Color',[1 0 0],'linewidth',1);
% set(bbbar1(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',1);
% set(bbbar1(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',1);
% set(bbbar1(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',1);
% set(bbbar1(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',1);
%
% hold on
%
% bbb=[data(:,1)';data(:,2)';data(:,3)'-data(:,1)';data(:,4)';data(:,5)';data(:,1)'+data(:,2)'+data(:,3)'-data(:,1)'+data(:,4)'+data(:,5)'];
%
% bbbar = plot(bbb','-'); hold on
% set(bbbar(1),'Color',[0.400000005960464 0.400000005960464 0.400000005960464],'linewidth',3);
% set(bbbar(2),'Color',[1 0 0],'linewidth',3);
% set(bbbar(3),'Color',[0.929411768913269 0.694117665290833 0.125490203499794],'linewidth',3);
% set(bbbar(4),'Color',[0 0.447058826684952 0.74117648601532],'linewidth',3);
% set(bbbar(5),'Color',[0 0.800000011920929 0.200000002980232],'linewidth',3);
% set(bbbar(6),'Color',[0.23137255012989 0.443137258291245 0.337254911661148],'linewidth',3);
%
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
% set(gca,'XTick',1:2:size(t,1));
% set(gca,'XTickLabel',datestr(t(1:2:end),'dd mmm'));
% set(gca,'XLim',[0.5,size(t,1)+0.5]);
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax=gca;
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
%
% ax = gca;
% set(ax, 'FontName', 'Verdana');
% set(ax, 'FontSize', font_size);
%
% l=legend([bbbar(6),bbbar(5), bbbar(4),bbbar(3),bbbar(2),bbbar(1)],'Casi Totali','Dimessi Guariti','Isolamento domiciliare', 'Ricoverati con sintomi', 'Terapia intensiva','Deceduti');
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





%% Decorrelazione con numero tamponi: Lombardia

day_unique = unique(dataReg.data);

reg=9;
n_tamponi=NaN(size(day_unique,1),1);
n_totaleCasi =NaN(size(day_unique,1),1);
n_deceduti = NaN(size(day_unique,1),1);
n_guariti = NaN(size(day_unique,1),1);

n_casi_da_sospetto_diagnostico = NaN(size(day_unique,1),1);
n_casi_da_screening = NaN(size(day_unique,1),1);


for k = 1: size(day_unique,1)
    index = find(strcmp(dataReg.data,day_unique(k)) & strcmp(dataReg.denominazione_regione,'Lombardia'));
    %     index = find(strcmp(dataReg.data,day_unique(k)) & strcmp(dataReg.denominazione_regione,'Liguria'));
    n_tamponi(k)=sum(dataReg.tamponi(index));
    n_totaleCasi(k)=sum(dataReg.totale_casi(index));
    n_deceduti(k)=sum(dataReg.deceduti(index));
    n_guariti(k)=sum(dataReg.dimessi_guariti(index));
    n_casi_da_sospetto_diagnostico(k)=sum(dataReg.casi_da_sospetto_diagnostico(index));
    n_casi_da_screening(k)=sum(dataReg.casi_da_screening(index));
end

time_num = fix(datenum(day_unique));
regione = 'Lombardia';
% regione = 'Liguria';

% % model numero tamponi
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%d;%d\n',time_num(i),n_tamponi(i));
% end
% command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%
%% figura cumulata
datetickFormat = 'dd mmm';
%     figure;
%     id_f = gcf;
%     set(id_f, 'Name', [regione ': numero totale tamponi']);
%     title(sprintf([regione ': numero totale tamponi\\fontsize{5}\n ']))
%     set(gcf,'NumberTitle','Off');
%     set(gcf,'Position',[26 79 967 603]);
%     grid on
%     hold on
%     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
%     d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
%     c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
%     b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
%     a=plot(time_num,n_tamponi,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);

%

P = polyfit(time_num,n_tamponi,3)  ;
PP = polyval(P,time_num);
corr_factor=(n_tamponi./PP);

n_totaleCasiCorretti=n_totaleCasi./corr_factor;
% %
% id_f=figure;
% hold on
% plot(time_num,n_tamponi,'*-b');
% plot(time_num,PP,'*-r');
% grid on
% ylabel('numero tamponi')
% ax = gca;
% code_axe = get(id_f, 'CurrentAxes');
% set(code_axe, 'FontName', 'Verdana');
% set(code_axe, 'FontSize', font_size);
%
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% datetick('x', datetickFormat, 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax.FontSize = font_size;




% interpolazione casi corretti
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(n_totaleCasiCorretti,1)
    fprintf(fout,'%d;%d\n',time_num(i),n_totaleCasiCorretti(i));
end
% command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');


datetickFormat = 'dd mmm';

figure;
id_f = gcf;
set(id_f, 'Name', [regione ': numero totale casi (corretti col numero tamponi)']);
title(sprintf([regione ': numero totale casi (corretti col numero tamponi)\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
a=plot(time_num,n_totaleCasiCorretti,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);


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
ylabel('Casi Totali (corretti con il numero tamponi)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

set(gca,'xlim',([time_num(1) time_num(end)+50]));
set(gca,'XTick',[time_num(1):2:time_num(end)+50]);
set(gca,'XTickLabel',datestr([time_num(1):2:time_num(end)+50],'dd mmm'));




% datetick('x', datetickFormat) ;
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasiCorretti_',regione, '_cumulati.PNG']);
close(gcf);




% attualmente positivi corretti
n_attualmetePositivi_corretti=n_totaleCasiCorretti-n_deceduti-n_guariti;
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(time_num,1)
    fprintf(fout,'%d;%d\n',time_num(i),n_attualmetePositivi_corretti(i));
end
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');


datetickFormat = 'dd mmm';

figure;
id_f = gcf;
set(id_f, 'Name', [regione ': attualmente positivi (corretti col numero tamponi)']);
title(sprintf([regione ': attualmente positivi (corretti col numero tamponi)\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
a=plot(time_num,n_attualmetePositivi_corretti,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
[max1, idxMaxa1]=max(a1); [max2, idxMaxa2]=max(a2); [max3, idxMaxa3]=max(a3);


piccoMin=[];
piccoMax=[];
zeroMin=[];
zeroMax=[];
try
    idxMina1=find(round(a1(fix(size(a1,1)/2):end))<100)+fix(size(a1,1)/2); idxMina1=idxMina1(1);
    idxMina2=find(round(a2(fix(size(a2,1)/2):end))<100)+fix(size(a2,1)/2); idxMina2=idxMina2(1);
    idxMina3=find(round(a3(fix(size(a3,1)/2):end))<100)+fix(size(a3,1)/2); idxMina3=idxMina3(1);
catch
    idxMina1=[];
    idxMina2=[];
    idxMina3=[];
    
end
try
    piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
    piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
catch
end

try
    zeroMin=min([t(idxMina1),t(idxMina2),t(idxMina3)]);
    zeroMax=max([t(idxMina1),t(idxMina2),t(idxMina3)]);
catch
end

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
ylabel('Attualmente positivi (corretti con il numero tamponi)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);


set(gca,'xlim',([time_num(1) time_num(end)+90]));
set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoAttualmentePositiviCorretti_',regione, '_cumulati.PNG']);
close(gcf);





% interpolazione totale casi corretti giornalieri
fout=fopen('testIn_gauss.txt','wt');
time_num1= time_num(2:end);
n_totaleCasiCorretti1 = diff(n_totaleCasiCorretti);
for i=1:size(time_num1,1)
    fprintf(fout,'%d;%d\n',time_num1(i),n_totaleCasiCorretti1(i));
end
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');



datetickFormat = 'dd mmm';

figure;
id_f = gcf;
set(id_f, 'Name', [regione ': totale casi giornalieri (corretti col numero tamponi)']);
title(sprintf([regione ': totale casi giornalieri (corretti col numero tamponi)\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
a=plot(time_num1,n_totaleCasiCorretti1,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
[max1, idxMaxa1]=max(a1); [max2, idxMaxa2]=max(a2); [max3, idxMaxa3]=max(a3);

piccoMin=[];
piccoMax=[];
zeroMin=[];
zeroMax=[];

try
    idxMina1=find(round(a1(fix(size(a1,1)/5*4):end))<100)+fix(size(a1,1)/5*4); idxMina1=idxMina1(1);
    idxMina2=find(round(a2(fix(size(a2,1)/5*4):end))<100)+fix(size(a2,1)/5*4); idxMina2=idxMina2(1);
    idxMina3=find(round(a3(fix(size(a3,1)/5*4):end))<100)+fix(size(a3,1)/5*4); idxMina3=idxMina3(1);
catch
    idxMina1=[];
    idxMina2=[];
    idxMina3=[];
    
end

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
ylabel('Nuovi casi giornalieri (corretti con il numero tamponi)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;

set(gca,'xlim',([time_num(1) time_num(end)+90]));
set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasiGiornalieriCorretti_',regione, '_cumulati.PNG']);
close(gcf);






















%% interpolazione Nazionale
day_unique = unique(dataReg.data);

for type=1:3
    
    data=NaN(size(day_unique,1),1);
    for k = 1: size(day_unique,1)
        index = find(strcmp(dataReg.data,day_unique(k)));
        %         index = find(strcmp(dataReg.data,day_unique(k)) & ~strcmp(dataReg.denominazione_regione,'Lombardia') & ~strcmp(dataReg.denominazione_regione,'Veneto') & ~strcmp(dataReg.denominazione_regione,'Emilia-Romagna')...
        %             & ~strcmp(dataReg.denominazione_regione,'Piemonte') & ~strcmp(dataReg.denominazione_regione,'Valle d Aosta') & ~strcmp(dataReg.denominazione_regione,'P.A. Trento') & ~strcmp(dataReg.denominazione_regione,'P.A. Bolzano') ...
        %             & ~strcmp(dataReg.denominazione_regione,'Friuli Venezia Giulia') & ~strcmp(dataReg.denominazione_regione,'Liguria'));
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
    %     regione = 'Italia-noNord';
    
    fout=fopen('testIn_gauss.txt','wt');
    for i=1:size(data,1)
        fprintf(fout,'%d;%d\n',time_num(i),data(i));
    end
    fclose(fout);
    
    if type==1 || type==3
        %         command=sprintf('gauss_estim testIn_gauss.txt');system(command);
        %         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
        command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
        
        %                 command=sprintf('chi_estim_conf testIn_gauss.txt');system(command);
        %                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_chi_fit.txt','%d%f%f%f%f%f','delimiter',';');
    elseif type==2
        %         command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
        
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
        
        try
            idxMina1=find(round(a1(fix(size(a1,1)/5*4):end))<100)+fix(size(a1,1)/5*4); idxMina1=idxMina1(1);
            idxMina2=find(round(a2(fix(size(a2,1)/5*4):end))<100)+fix(size(a2,1)/5*4); idxMina2=idxMina2(1);
            idxMina3=find(round(a3(fix(size(a3,1)/5*4):end))<100)+fix(size(a3,1)/5*4); idxMina3=idxMina3(1);
        catch
            idxMina1=[];
            idxMina2=[];
            idxMina3=[];
        end
        
        piccoMin=[];
        piccoMax=[];
        zeroMin=[];
        zeroMax=[];
        try
            piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
            piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
            
            zeroMin=min([t(idxMina1),t(idxMina2),t(idxMina3)]);
            zeroMax=max([t(idxMina1),t(idxMina2),t(idxMina3)]);
        catch
            
            
        end
        try
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
        catch
        end
    end
    
    
    
    if ismac
        font_size = 9;
    else
        font_size = 6.5;
    end
    grid minor
    ax = gca;
    code_axe = get(id_f, 'CurrentAxes');
    set(code_axe, 'FontName', 'Verdana');
    set(code_axe, 'FontSize', font_size);
    ylimi=get(gca,'ylim');
    set(gca,'ylim',([0,ylimi(2)]));
    ax.YTick=ax.YTick(1):(ax.YTick(2)-(ax.YTick(1)))/4:ax.YTick(end);
    
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
    
    set(gca,'xlim',([time_num(1) time_num(end)+90]));
    set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
    set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
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

%
%
% %% Decorrelazione con numero tamponi
%
% %% interpolazione Nazionale
%
% day_unique = unique(dataReg.data);
%
%
% n_tamponi=NaN(size(day_unique,1),1);
% n_totaleCasi =NaN(size(day_unique,1),1);
% for k = 1: size(day_unique,1)
%     index = find(strcmp(dataReg.data,day_unique(k)));
%     n_tamponi(k)=sum(dataReg.tamponi(index));
%     n_totaleCasi(k)=sum(dataReg.totale_casi(index))
% end
%
% time_num = fix(datenum(day_unique));
% regione = 'Italia';
%
% % % model numero tamponi
% % fout=fopen('testIn_gauss.txt','wt');
% % for i=1:size(data,1)
% %     fprintf(fout,'%d;%d\n',time_num(i),n_tamponi(i));
% % end
% % command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% % [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
% %
% %% figura cumulata
% datetickFormat = 'dd mmm';
% %     figure;
% %     id_f = gcf;
% %     set(id_f, 'Name', [regione ': numero totale tamponi']);
% %     title(sprintf([regione ': numero totale tamponi\\fontsize{5}\n ']))
% %     set(gcf,'NumberTitle','Off');
% %     set(gcf,'Position',[26 79 967 603]);
% %     grid on
% %     hold on
% %     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
% %     d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% %     c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
% %     b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
% %     a=plot(time_num,n_tamponi,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
% %
% %
%
% P = polyfit(time_num,n_tamponi,3)  ;
% PP = polyval(P,time_num);
% corr_factor=(n_tamponi./PP);
%
% n_totaleCasiCorretti=n_totaleCasi./corr_factor;
%
%
% % interpolazione casi corretti
% fout=fopen('testIn_gauss.txt','wt');
% for i=1:size(data,1)
%     fprintf(fout,'%d;%d\n',time_num(i),n_totaleCasiCorretti(i));
% end
% % command=sprintf('sigm_estim testIn_gauss.txt');system(command);
% % [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
%
% command=sprintf('gomp_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%
%
%
% datetickFormat = 'dd mmm';
%
% figure;
% id_f = gcf;
% set(id_f, 'Name', [regione ': numero totale casi (corretti col numero tamponi)']);
% title(sprintf([regione ': numero totale casi (corretti col numero tamponi)\\fontsize{5}\n ']))
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
% b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
% a=plot(time_num,n_totaleCasiCorretti,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
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
% xlim([time_num(1) time_num(end)+50]);
% ylimi=get(gca,'ylim');
% set(gca,'ylim',([0,ylimi(2)]));
% ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
% ylabel('Casi Totali (corretti con il numero tamponi)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
% datetick('x', datetickFormat, 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax.FontSize = font_size;
%
%
%
% l=legend([a,b,c,d],'Dati Reali',sprintf('Stima al %s',datestr(time_num(end),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-1),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-2),'dd mmm')));
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
%
% annotation(gcf,'textbox',...
%     [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
%     'String',{'https://covidguard.github.io/#covid-19-italia'},...
%     'LineStyle','none',...
%     'HorizontalAlignment','left',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasiCorretti_',regione, '_cumulati.PNG']);
% close(gcf);
%
%
% % interpolazione casi corretti giornalieri
% fout=fopen('testIn_gauss.txt','wt');
% time_num1= time_num(2:end);
% n_totaleCasiCorretti1 = diff(n_totaleCasiCorretti);
% for i=1:size(time_num1,1)
%     fprintf(fout,'%d;%d\n',time_num1(i),n_totaleCasiCorretti1(i));
% end
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
% datetickFormat = 'dd mmm';
%
% figure;
% id_f = gcf;
% set(id_f, 'Name', [regione ': totale casi giornalieri (corretti col numero tamponi)']);
% title(sprintf([regione ': totale casi giornalieri (corretti col numero tamponi)\\fontsize{5}\n ']))
% set(gcf,'NumberTitle','Off');
% set(gcf,'Position',[26 79 967 603]);
% grid on
% hold on
% shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
% b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
% a=plot(time_num1,n_totaleCasiCorretti1,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
%
%
%
% [max1, idxMaxa1]=max(a1); [max2, idxMaxa2]=max(a2); [max3, idxMaxa3]=max(a3);
%
%
% try
% idxMina1=find(round(a1(fix(size(a1,1)/2):end))<100)+fix(size(a1,1)/2); idxMina1=idxMina1(1);
% idxMina2=find(round(a2(fix(size(a2,1)/2):end))<100)+fix(size(a2,1)/2); idxMina2=idxMina2(1);
% idxMina3=find(round(a3(fix(size(a3,1)/2):end))<100)+fix(size(a3,1)/2); idxMina3=idxMina3(1);
% catch
%     idxMina1=[];
%     idxMina2=[];
%     idxMina3=[];
%
% end
%
% piccoMin=min([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
% piccoMax=max([t(idxMaxa1),t(idxMaxa2),t(idxMaxa3)]);
%
% zeroMin=min([t(idxMina1),t(idxMina2),t(idxMina3)]);
% zeroMax=max([t(idxMina1),t(idxMina2),t(idxMina3)]);
%
% if piccoMin<piccoMax
%     picco = sprintf('Stima picco: %s-%s', datestr(piccoMin,'dd mmm'), datestr(piccoMax,'dd mmm'));
% else
%     picco = sprintf('Stima picco: %s', datestr(piccoMin,'dd mmm'));
% end
%
% if piccoMin<piccoMax
%     zero = sprintf('Stima <100 casi: %s-%s', datestr(zeroMin,'dd mmm'), datestr(zeroMax,'dd mmm'));
% else
%     zero = sprintf('Stima <100 casi: %s', datestr(zeroMin,'dd mmm'));
% end
%
% annotation(gcf,'textbox',...
%     [0.59875904860393 0.814262023217247 0.29886246122027 0.0845771144278608],...
%     'String',{picco},...
%     'LineStyle','none',...
%     'HorizontalAlignment','right',...
%     'FontSize',10,...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
%
% annotation(gcf,'textbox',...
%     [0.59875904860393 0.779436152570481 0.29886246122027 0.0845771144278606],...
%     'String',{zero},...
%     'LineStyle','none',...
%     'HorizontalAlignment','right',...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
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
% ylabel('Nuovi casi giornalieri (corretti con il numero tamponi)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
% datetick('x', datetickFormat, 'keepticks') ;
% set(gca,'XTickLabelRotation',53,'FontSize',6.5);
% ax.FontSize = font_size;
%
%
%
% l=legend([a,b,c,d],'Dati Reali',sprintf('Stima al %s',datestr(time_num(end),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-1),'dd mmm')),sprintf('Stima al %s',datestr(time_num(end-2),'dd mmm')));
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
%
% annotation(gcf,'textbox',...
%     [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
%     'String',{'https://covidguard.github.io/#covid-19-italia'},...
%     'LineStyle','none',...
%     'HorizontalAlignment','left',...
%     'FontSize',6,...
%     'FontName','Verdana',...
%     'FitBoxToText','off');
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoTotaleCasiGiornalieriCorretti_',regione, '_cumulati.PNG']);
% close(gcf);
%
%
%

















%% analisi nazionale sulla correlazione casi-deceduti
offset_dec = 5;
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

y1=data_casiPositivi;
y2=data_deceduti;

[a1_1] = splinerMat(t,y1,10);
% figure;hold on
% plot(t,y1,'.b');
% plot(t,a1_1,'-r');


[a1_2] = splinerMat(t,y2,10);
% figure;hold on




corrcoef_d=[];
for dd=0:15
    temp=corrcoef(a1_1(1:end-dd),a1_2(dd+1:end));
    corrcoef_d(dd+1)=temp(1,2);
end
[coerrcoeff_max, idx]=max(corrcoef_d);
offset_dec=idx-1;





figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: correlazione temporale');
% title(sprintf([regione ': totale Italia: correlazione temporale casi/deceduti\\fontsize{5}\n ']))


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
ylabel(ax1, 'Incremento percentuale giornaliero casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ylabel(ax2, 'Incremento percentuale giornaliero deceduti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
set(ax1, 'FontName', 'Verdana');
set(ax1, 'FontSize', font_size);
set(ax1,'xlim',([t(1),t(end)]));
set(ax1,'ylim',([0,80]));
ax1.XTick = time_num;
ax1.XTick = time_num(1):2:time_num(end);
datetick('x', 'dd mmm', 'keepticks') ;
set(ax1,'XTickLabelRotation',53,'FontSize',6.5);
set(ax1,'Xcolor',[0 0.447058826684952 0.74117648601532]);
set(ax1,'Ycolor',[0 0.447058826684952 0.74117648601532]);

set(gcf,'CurrentAxes',ax2)
set(ax2, 'FontName', 'Verdana');
set(ax2, 'FontSize', font_size);
set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec]));

ax2.XTick = t(1)+offset_dec-1:2:t(end)+offset_dec;
set(ax2,'ylim',([0,80]));
datetick('x', 'dd mmm', 'keepticks') ;
% set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec]));
set(ax2,'XTickLabelRotation',53,'FontSize',6.5);
l=legend([a,b],'Casi totali','Deceduti');
set(ax2,'Xcolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);
set(ax2,'Ycolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);


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






%% analisi nazionale sulla correlazione casi-deceduti: versione 2
offset_dec = 3;
offset_guar = 0;

% reg=9
% regione = char(regioni_tot(reg,1));
% index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
% time_num = fix(datenum(dataReg.data(index)));



day_unique = unique(dataReg.data);
data_casiPositivi=NaN(size(day_unique,1),1);
data_deceduti=NaN(size(day_unique,1),1);
data_terapie=NaN(size(day_unique,1),1);
data_guariti=NaN(size(day_unique,1),1);
for k = 1: size(day_unique,1)
    index = find(strcmp(dataReg.data,day_unique(k)));
    data_casiPositivi(k)=sum(dataReg.totale_casi(index));
    data_deceduti(k)=sum(dataReg.deceduti(index));
    data_guariti(k)=sum(dataReg.dimessi_guariti(index));
    data_terapie(k)=sum(dataReg.terapia_intensiva(index));
end
time_num = fix(datenum(day_unique));
regione = 'Italia';

t=time_num(2:end);
data_casiPositivi=diff(data_casiPositivi);
data_deceduti=diff(data_deceduti);
data_terapie=diff(data_terapie);

% interpolazione totale casi giornalieri
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(t,1)
    fprintf(fout,'%d;%d\n',t(i),data_casiPositivi(i));
end
fclose(fout);
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t_1,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');



% interpolazione deceduti giornalieri
fout=fopen('testIn_gauss.txt','wt');

for i=1:size(t,1)
    fprintf(fout,'%d;%d\n',t(i),data_deceduti(i));
end
fclose(fout);
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t_1_d,a1_d,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');


corrcoeff_tot=[];
for d=0:10
    a=corrcoef(a1(1:end-d),a1_d(d+1:end));
    corrcoeff_tot(d+1)=a(1,2);
end
[coerrcoeff_max, idx]=max(corrcoeff_tot);
offset_dec=idx-1;





figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: correlazione temporale');
% title(sprintf([regione ': Italia: correlazione nuovi casi/deceduti giornalieri\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

[ax,a,b] = plotxx(t,data_casiPositivi,t,data_deceduti);
hold on

ax1 = ax(1);
ax2 = ax(2);

set(gcf,'CurrentAxes',ax1)
c=plot(t_1,a1,'-r');

set(gcf,'CurrentAxes',ax2)
d=plot(t_1_d,a1_d,'-b');

%
% a=plot(t,data_casiPositivi,'-ob','LineWidth', 2.0,'color',[0 0.200000002980232 0.600000023841858]); set(a,'markersize',6,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532]);
% b=plot(t-offset_dec,data_deceduti,'-ob','LineWidth', 2.0,'color',[1 0.200000002980232 0.600000023841858],'Parent',ax2); set(b,'markersize',6,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);


if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(a,'marker','o','markersize',6,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 1.0);
set(b,'marker','o','markersize',6,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 1.0);
set(c,'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 2.0);
set(d,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 2.0);



set(gcf,'CurrentAxes',ax1)
ylabel('Nuovi positivi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
set(ax1, 'FontName', 'Verdana');
set(ax1, 'FontSize', font_size);
set(ax1,'xlim',([t(1),t(end)+10]));
% set(ax1,'ylim',([0,80]));
ax1.XTick = [time_num(1):2:time_num(end)+10];
datetick('x', 'dd mmm', 'keepticks') ;
set(ax1,'XTickLabelRotation',53,'FontSize',6.5);
set(ax1,'Xcolor',[0 0.447058826684952 0.74117648601532]);
set(ax1,'Ycolor',[0 0.447058826684952 0.74117648601532]);

set(gcf,'CurrentAxes',ax2)
ylabel('Deceduti giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
set(ax2, 'FontName', 'Verdana');
set(ax2, 'FontSize', font_size);
set(ax2,'xlim',([t(1)+offset_dec,t(end)+offset_dec+10]));
% set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec-1]));
% set(ax2,'xlim',([t(1)+offset_dec-1,t(end)+offset_dec-1]));
% ax2.XTick = t(1:2:end)+offset_dec-1
% set(ax2,'ylim',([0,80]));
ax2.XTick = [time_num(1):2:time_num(end)+10]+offset_dec;
ax2.XTickLabel = [time_num(1):2:time_num(end)+10]+offset_dec;
datetick('x', 'dd mmm', 'keepticks') ;
set(ax2,'XTickLabelRotation',53,'FontSize',6.5);
set(ax2,'Xcolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);
set(ax2,'Ycolor',[0.850980401039124 0.325490206480026 0.0980392172932625]);

l=legend([a,b],'Nuovi positivi giornalieri','Deceduti giornalieri');

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

yl = get(ax2,'ylim');
set(ax2,'ylim',([0,yl(2)]));

yl = get(ax1,'ylim');
set(ax1,'ylim',([0,yl(2)]));

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_correlazioneCasiDeceduti_v2.PNG']);
close(gcf);







% % % % % lombardia
% % % % reg=9
% % % % regione = char(regioni_tot(reg,1));
% % % % index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
% % % % time_num = fix(datenum(dataReg.data(index)));
% % % %
% % % %
% % % %
% % % % day_unique = unique(dataReg.data(index));
% % % % data_casiPositivi=NaN(size(day_unique,1),1);
% % % % data_deceduti=NaN(size(day_unique,1),1);
% % % % data_terapie=NaN(size(day_unique,1),1);
% % % % data_guariti=NaN(size(day_unique,1),1);
% % % % for k = 1: size(day_unique,1)
% % % %     index = find(strcmp(dataReg.data,day_unique(k))&strcmp(dataReg.denominazione_regione,cellstr(regione)));
% % % %     data_casiPositivi(k)=sum(dataReg.totale_casi(index));
% % % %     data_deceduti(k)=sum(dataReg.deceduti(index));
% % % %     data_guariti(k)=sum(dataReg.dimessi_guariti(index));
% % % %     data_terapie(k)=sum(dataReg.terapia_intensiva(index));
% % % % end
% % % % time_num = fix(datenum(day_unique));
% % % % % regione = 'Italia';
% % % %
% % % % t=time_num(2:end);
% % % % data_casiPositivi=diff(data_casiPositivi);
% % % % data_deceduti=diff(data_deceduti);
% % % % data_terapie=diff(data_terapie);







y1=data_casiPositivi;
y2=data_deceduti;
% y2=data_terapie;

l1='Casi positivi gionalieri';
l2='Deceduti giornalieri';
% l2='Terapie giornalieri';

[a1_1] = splinerMat(t,y1,10);
% figure;hold on
% plot(t,y1,'.b');
% plot(t,a1_1,'-r');


[a1_2] = splinerMat(t,y2,10);
% figure;hold on
% plot(t,y2,'.b');
% plot(t,a1_2,'-r');

t_1_1=t;
t_1_2=t;

corrcoeff_tot=[];
for d=0:16
    a=corrcoef(a1_1(1:end-d),a1_2(d+1:end));
    corrcoeff_tot(d+1)=a(1,2);
end
[coerrcoeff_max, idx]=max(corrcoeff_tot);
offset_dec=idx-1;





figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: correlazione temporale');
% title(sprintf([regione ': Italia: correlazione nuovi casi/deceduti giornalieri\\fontsize{5}\n ']))


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

set(a,'marker','o','markersize',4,'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'Color',[0 0.447058826684952 0.74117648601532],'LineWidth', 0.5);
set(b,'marker','o','markersize',4,'MarkerFaceColor',[0.850980401039124 0.325490206480026 0.0980392172932625],'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],'LineWidth', 0.5);
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
l=legend([a,b],l1,l2);

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

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_correlazioneCasiDeceduti_v2_spline.PNG']);
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
title(sprintf(['Italia: indice di mortalita'' dei contagiati \\fontsize{5}\n ']))


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
annotation(gcf,'textbox',[0.709976359875908 0.923714759535656 0.238100000000001 0.0463800000000001],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.708942233712513 0.903814262023218 0.2381 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_mortalita.PNG']);
close(gcf);










%% esito malattia Italia
regione = 'Italia';
datetickFormat = 'dd mmm';
figure;
id_f = gcf;
set(id_f, 'Name', [regione ': esito malattia']);
title(sprintf([regione ': esito malattia\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

tot_x=[];
for i = 1:size(time_num,1)
    index = find(fix(datenum(dataReg.data))==time_num(i));
    tot_x(i,1)=sum(dataReg.deceduti(index))./(sum(dataReg.deceduti(index))+sum(dataReg.dimessi_guariti(index)))*100;
end


a=plot(time_num,tot_x,'-k','LineWidth', 2.0);
b=plot(time_num,(100-tot_x),'-g','LineWidth', 2.0);

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
ylabel('% casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);

set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
ax.XTick = time_num(1):2:time_num(end);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
t_lim=ylim;
if t_lim(2)<100
    ylim([t_lim(1) 100]);
end

l=legend([b,a],'Dimessi Guariti','Deceduti');
set(l,'Location','northeast')
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
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_',regione, '_esito.PNG']);
close(gcf);

%% tamponi totali Italia
tamponiIta=[];
totalePosIta=[];
casiTestatiIta = [];
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    tamponiIta(:,reg)=dataReg.tamponi(index);
    totalePosIta(:,reg)=dataReg.totale_casi(index);
    casiTestatiIta(:,reg)=dataReg.casi_testati(index);
    
end

time_num = unique(dataReg.data);


tamponiIta=diff(sum(tamponiIta')');
totalePosIta=diff(sum(totalePosIta')');
casiTestatiIta=diff(sum(casiTestatiIta')');
perTampPos=totalePosIta./tamponiIta*100;
perCastiTestPos=totalePosIta./casiTestatiIta*100;

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

set(gca,'XTick',1:2:size(time_num(2:end),1));
set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'));
set(gca,'XLim',[0.5,size(time_num(2:end),1)+0.5]);
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero tamponi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

t_lim=get(ax,'ylim');
ylim([0 t_lim(2)]);

yyaxis right
c=plot(perTampPos,'-b','LineWidth', 1.5);
ylim([0 100]);
set(gca,'YColor', [0 0 1]);
ylabel('Percentuale tamponi positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
grid minor

l=legend([b(2),b(1),c],'Tamponi negativi','Tamponi positivi','Percent. tamponi positivi');
set(l,'Location','northwest')

t_lim=ylim;
ylim([0 100]);



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






%casi testati ita
figure;
id_f = gcf;
set(id_f, 'Name', 'Italia: casi testati');
title(sprintf(['Italia: casi testati \\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

b=bar([totalePosIta,casiTestatiIta-totalePosIta],'stacked');
set(b(1),'FaceColor',[1 0 0]);
set(b(2),'FaceColor',[0.200000002980232 0.600000023841858 1]);


if ismac
    font_size = 9;
else
    font_size = 6.5;
end

set(gca,'XTick',1:2:size(time_num(2:end),1));
set(gca,'XTickLabel',datestr(time_num(2:2:end),'dd mmm'));
set(gca,'XLim',[0.5,size(time_num(2:end),1)+0.5]);
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ax=gca;
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero tamponi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);


yyaxis right
c=plot(perCastiTestPos,'-b','LineWidth', 1.5);
ylim([0 100]);
set(gca,'YColor', [0 0 1]);
ylabel('Percentuale tamponi positivi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
grid minor

l=legend([b(2),b(1),c],'Casi testati - positivi','Tamponi positivi','Percent. tamponi positivi su casi testati');
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

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_tamponi_casiTestati.PNG']);
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
    catch
    end
    
    
    % %     comodaily
    %     data=dataReg.totale_casi(index,1);
    %     data=diff(data);   time_num=time_num(2:end);
    %     fout=fopen('testIn_gauss.txt','wt');
    %     for i=1:size(data,1)
    %         fprintf(fout,'%d;%d\n',time_num(i),data(i));
    %     end
    %     command=sprintf('gauss_estim testIn_gauss.txt');system(command);
    %     [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%d%f%f%f%f%f','delimiter',';');
    %     id_f = gcf;
    %     set(id_f, 'Name', [regione ': casi giornalieri']);
    %     title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
    %     set(gcf,'NumberTitle','Off');
    %     set(gcf,'Position',[26 79 967 603]);
    %     grid on; hold on; grid minor
    %     shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
    %     d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
    %     c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
    %     b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
    %     a=plot(time_num,data,'.-b','markersize',14,'linewidth',1);
    %
    %     ax = gca;
    %     code_axe = get(id_f, 'CurrentAxes');
    %     set(code_axe, 'FontName', 'Verdana');
    %     set(code_axe, 'FontSize', font_size);
    %     ylimi=get(gca,'ylim');
    %     set(gca,'ylim',([0,ylimi(2)]));
    %     ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
    %     ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
    %     datetick('x', datetickFormat, 'keepticks') ;
    %     set(gca,'XTickLabelRotation',53,'FontSize',6.5);
    %     ax.FontSize = font_size;
    %     print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_',regione, '_giornalieri.PNG']);
    %    close(gcf);
    
    
    
    
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
        annotation(gcf,'textbox',[0.709976359875905 0.907131011608624 0.2381 0.0463800000000001],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        
        
        annotation(gcf,'textbox',...
            [0.708942233712519 0.925373134328359 0.238100000000001 0.04638],...
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
        
        
        command = sprintf('[x,idx]=sort(regioni_conf.%s,''ascend'');',char(loop.var(type)));
        eval(command);
        tick_all=regioni_tot(idx);
        
        idx1=[];
        for ll=1:length(tick_all)
            idx1(ll) = find(strcmp(pop.popolazioneRegioniNome, tick_all(ll)));
        end
        
        if pesata==1
            x=x./pop.popolazioneRegioniPop(idx1)*100000;
            [x,idx1]=sort(x,'ascend');
            tick_all=tick_all(idx1);
        end
        
        figure;
        id_f = gcf;
        if pesata==1
            command = sprintf('title(sprintf([''%s ogni 100.000 abitanti (al '', datestr(time_num(end),''dd/mm/yyyy''),'')\\\\fontsize{5}\\n '']));',char(loop.title(type)));eval(command);
        else
            command = sprintf('title(sprintf([''%s (al '', datestr(time_num(end),''dd/mm/yyyy''),'')\\\\fontsize{5}\\n '']));',char(loop.title(type)));eval(command);
        end
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        a=barh([1 2], [x ;x]);
        grid minor
        for k=1:size(x,2)
            set(a(k),'FaceColor',Cmap.getColor(idx(k), size(x,2)));
        end
        
        hT={};              % placeholder for text object handles
        for k=1:size(x,2) % iterate over number of bar objects
            if pesata==1
                hT{k}=text(a(k).YData+max(x(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%.2f)', char(tick_all(k)),x(k)), ...
                    'VerticalAlignment','middle','horizontalalign','left','fontsize',7);                
            else
                hT{k}=text(a(k).YData+max(x(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%d)', char(tick_all(k)),x(k)), ...
                    'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
            end
            d=hT{k};
            xx=a(k).YData(2);
            yy=a(k).XData(2)+a(k).XOffset(1);
            d(2).Position=[xx+max(x(:))*0.01,yy,0];
            drawnow
        end
        
        d=hT{1};
        xx=a(1).YData(2);
        yy=a(1).XData(2)+a(1).XOffset(1);
        d(2).Position=[xx+max(x(:))*0.01,yy,0];
        
       
        set(gca,'YTick',[])
        set(gca,'YLim',[1.6,2.4])
        set(gca,'FontSize',8);
        set(gca,'xlim',[0,max(x(:))*1.12]);
        if pesata==1
            command = sprintf(' xlabel(''%s ogni 100.000 abitanti'', ''FontName'', ''Verdana'', ''FontWeight'', ''Bold'',''FontSize'', 7);', char(loop.title(type)));eval(command);
        else
            command = sprintf(' xlabel(''%s'', ''FontName'', ''Verdana'', ''FontWeight'', ''Bold'',''FontSize'', 7);', char(loop.title(type)));eval(command);
        end
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
       
        ax=get(gca);
        ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';
        
        
        
        % overlap copyright info
        datestr_now = datestr(now);
        annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        
        annotation(gcf,'textbox',...
            [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
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
    annotation(gcf,'textbox',[0.709976359875905 0.907131011608624 0.2381 0.0463800000000001],...
        'String',{['Fonte: https://github.com/pcm-dpc']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    
    annotation(gcf,'textbox',...
        [0.708942233712519 0.925373134328359 0.238100000000001 0.04638],...
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





%% esito
[x,idx]=sort(regioni_conf.dimessi_guariti./(regioni_conf.dimessi_guariti+regioni_conf.deceduti)*100,'descend');
tick_all=regioni_tot(idx);
idx1=[];


figure;
id_f = gcf;
title(sprintf('%% esito positivo infezione (al %s)', datestr(time_num(end),'dd mmm')))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on
b=bar(x);
for i1=1:numel(x)
    text(i1,x(i1),num2str(x(i1),'%.1f%%'),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

hold on; grid minor
set(gca,'XTick',1:size(regioni_tot,1))
set(gca,'XTickLabel',tick_all)
set(gca,'XLim',[0.5,size(regioni_tot,1)+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Percentuale esito positivo', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

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
annotation(gcf,'textbox',[0.709976359875905 0.907131011608624 0.2381 0.0463800000000001],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);


annotation(gcf,'textbox',...
    [0.708942233712519 0.925373134328359 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/regioni_esito.PNG']);



close(gcf);










%% COMO
for reg=9%1:size(regioni_tot,1)
    
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(dataReg.denominazione_regione,cellstr(regione)));
    time_num = fix(datenum(dataReg.data(index)));
    dataReg=dataProv;RegioneTot={'Como'}'; h=1;regione = char(RegioneTot(h));index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));time_num = fix(datenum(dataReg.data(index)));type=2;
    
    %     RegioneTot={'In fase di definizione/aggiornamento';
    
    %
    % RegioneTot={'Lecco'}'
    %
    %
    %
    %
    %
    
    %
    %         for type=1:3
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
        [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
        % %
        %                                 command=sprintf('chi_estim_conf testIn_gauss.txt');system(command);
        %                                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_chi_fit.txt','%d%f%f%f%f%f','delimiter',';');
    elseif type==2
        
        %command=sprintf('sigm_estim_conf_0 testIn_gauss.txt');system(command);
        
        
        %         command=sprintf('sigm_estim testIn_gauss.txt');system(command);
        %         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_sigm_fit.txt','%d%f%f%f%f%f','delimiter',';');
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
    xlim([time_num(1) time_num(end)+50]);
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



% %     comodaily
data=dataReg.totale_casi(index,1);
data=diff(data);   time_num=time_num(2:end);
fout=fopen('testIn_gauss.txt','wt');
for i=1:size(data,1)
    fprintf(fout,'%d;%d\n',time_num(i),data(i));
end
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');
command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
[t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');




id_f = gcf;
set(id_f, 'Name', [regione ': casi giornalieri']);
title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on; hold on; grid minor
shadedplot(t,a4',a5',[0.9 0.9 1]);  hold on
d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);
b=plot(t,a1,'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);
a=plot(time_num,data,'.-b','markersize',14,'linewidth',1);

ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ylabel('Numero nuovi casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
set(gca,'xlim',([time_num(1) time_num(end)+90]));
set(gca,'XTick',[time_num(1):3:time_num(end)+90]);
set(gca,'XTickLabel',datestr([time_num(1):3:time_num(end)+90],'dd mmm'));
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_',regione, '_giornalieri.PNG']);
close(gcf);









%%%%%%%%%%%%%%%%%%
%% Province

% RegioneTot={'Genova','Imperia','Savona','La Spezia'}

% % RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}

% RegioneTot={'Padova','Brescia'}

normalizza_per_popolazione=0;
normalizza_per_densita = 0;
normalizza_per_superficie = 0;

dataReg=dataProv;

splined_yn=0;





% peggior provincie sempre
province_totale = struct;
Provincia_lista=unique(dataReg.denominazione_provincia);
ppt = 0;

prov_tot=[];
for reg = 1:size(Provincia_lista,1)
    try
    idx_reg=find(strcmp(dataReg.denominazione_provincia,cell(Provincia_lista(reg,:))));             
    sigla_prov=dataReg.sigla_provincia(idx_reg);
    if ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('')) & ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('In fase di definizione/aggiornamento')) & ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('In fase di definizione')) & ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('fuori Regione/P.A.'))
        %     [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
        
        %     [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
        %      [RegioneTot, ixs]=setdiff(RegioneTot,cellstr(''));
        
        sigla_prov=sigla_prov(1);
        % find population
        [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
        prov_tot(reg,1)=dataReg.totale_casi(idx_reg(end))/pop.number(idx_pop)*100000;
%         prov_tot(reg,1)=dataReg.totale_casi(idx_reg(end));
    end
    catch
    end
end
[prov_sort, idx_sort]=sort(prov_tot,'descend');
Provincia_lista(idx_sort)

n_data=30;
x=prov_sort(1:n_data);
x=flip(x);

 tick_all=flip(Provincia_lista(idx_sort(1:n_data)));
        
        figure;
        id_f = gcf;
        title(sprintf('Province: totale casi ogni 100.000 abitanti (al %s)', datestr(dataReg.data(end),'dd/mm/yyyy')));
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        a=barh([1 2], [x' ;x']);
        grid minor
        for k=1:size(x,2)
            set(a(k),'FaceColor',Cmap.getColor(idx(k), size(x,2)));
        end
        
        hT={};              % placeholder for text object handles
        for k=1:size(x,1) % iterate over number of bar objects
            hT{k}=text(a(k).YData+max(x(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%.2f)', char(tick_all(k)),x(k)), ...
                'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
            d=hT{k};
            xx=a(k).YData(2);
            yy=a(k).XData(2)+a(k).XOffset(1);
            d(2).Position=[xx+max(x(:))*0.01,yy,0];
            drawnow
        end
        
        d=hT{1};
        xx=a(1).YData(2);
        yy=a(1).XData(2)+a(1).XOffset(1);
        d(2).Position=[xx+max(x(:))*0.01,yy,0];
        
       
        set(gca,'YTick',[])
        set(gca,'YLim',[1.6,2.4])
        set(gca,'FontSize',8);
        set(gca,'xlim',[0,max(x(:))*1.12]);

        xlabel('Casi totali ogni 100.000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);

        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(ax, 'FontName', 'Verdana');
        set(ax, 'FontSize', font_size);
       
        ax=get(gca);
        ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';
        
        
        
        % overlap copyright info
        datestr_now = datestr(now);
        annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
            'String',{['Fonte: https://github.com/pcm-dpc']},...
            'HorizontalAlignment','center',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off',...
            'LineStyle','none',...
            'Color',[0 0 0]);
        
        annotation(gcf,'textbox',...
            [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
            'String',{'https://covidguard.github.io/#covid-19-italia'},...
            'LineStyle','none',...
            'HorizontalAlignment','left',...
            'FontSize',6,...
            'FontName','Verdana',...
            'FitBoxToText','off');
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_worstProvEver.PNG']);
close(gcf);




% 
% 
% % peggior provincie ultimo mese
% province_totale = struct;
% Provincia_lista=unique(dataReg.denominazione_provincia);
% ppt = 0;
% n_day=30;
% prov_tot=[];
% for reg = 1:size(Provincia_lista,1)
%     idx_reg=find(strcmp(dataReg.denominazione_provincia,cell(Provincia_lista(reg,:))));
%     sigla_prov=dataReg.sigla_provincia(idx_reg);
%     if ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('')) & ~strcmp(cellstr(Provincia_lista(reg,:)),cellstr('In fase di definizione/aggiornamento'))
%         %     [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
%         
%         %     [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
%         %      [RegioneTot, ixs]=setdiff(RegioneTot,cellstr(''));
%         
%         sigla_prov=sigla_prov(1);
%         % find population
%         [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
%         prov_tot(reg,1)=(dataReg.totale_casi(idx_reg(end))-dataReg.totale_casi(idx_reg(end-n_day)))/pop.number(idx_pop)*100000;
% %         prov_tot(reg,1)=dataReg.totale_casi(idx_reg(end));
%     end
% end
% [prov_sort, idx_sort]=sort(prov_tot,'descend');
% Provincia_lista(idx_sort)
% 
% n_data=30;
% x=prov_sort(1:n_data);
% x=flip(x);
% 
%  tick_all=flip(Provincia_lista(idx_sort(1:n_data)));
%         
%         figure;
%         id_f = gcf;
%         title(sprintf('Province: totale casi ogni 100.000 abitanti (al %s)', datestr(dataReg.data(end),'dd/mm/yyyy')));
%         set(gcf,'NumberTitle','Off');
%         set(gcf,'Position',[26 79 967 603]);
%         grid on
%         hold on
%         
%         a=barh([1 2], [x' ;x']);
%         grid minor
%         for k=1:size(x,2)
%             set(a(k),'FaceColor',Cmap.getColor(idx(k), size(x,2)));
%         end
%         
%         hT={};              % placeholder for text object handles
%         for k=1:size(x,1) % iterate over number of bar objects
%             hT{k}=text(a(k).YData+max(x(:))*0.01,a(k).XData+a(k).XOffset,sprintf('%s (%.2f)', char(tick_all(k)),x(k)), ...
%                 'VerticalAlignment','middle','horizontalalign','left','fontsize',7);
%             d=hT{k};
%             xx=a(k).YData(2);
%             yy=a(k).XData(2)+a(k).XOffset(1);
%             d(2).Position=[xx+max(x(:))*0.01,yy,0];
%             drawnow
%         end
%         
%         d=hT{1};
%         xx=a(1).YData(2);
%         yy=a(1).XData(2)+a(1).XOffset(1);
%         d(2).Position=[xx+max(x(:))*0.01,yy,0];
%         
%        
%         set(gca,'YTick',[])
%         set(gca,'YLim',[1.6,2.4])
%         set(gca,'FontSize',8);
%         set(gca,'xlim',[0,max(x(:))*1.12]);
% 
%         xlabel('Casi totali ogni 100.000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
% 
%         if ismac
%             font_size = 9;
%         else
%             font_size = 6.5;
%         end
%         
%         ax = gca;
%         set(ax, 'FontName', 'Verdana');
%         set(ax, 'FontSize', font_size);
%        
%         ax=get(gca);
%         ax.XTickLabel = mat2cell(ax.XTick, 1, numel(ax.XTick))';
%         
%         
%         
%         % overlap copyright info
%         datestr_now = datestr(now);
%         annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
%             'String',{['Fonte: https://github.com/pcm-dpc']},...
%             'HorizontalAlignment','center',...
%             'FontSize',6,...
%             'FontName','Verdana',...
%             'FitBoxToText','off',...
%             'LineStyle','none',...
%             'Color',[0 0 0]);
%         
%         annotation(gcf,'textbox',...
%             [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
%             'String',{'https://covidguard.github.io/#covid-19-italia'},...
%             'LineStyle','none',...
%             'HorizontalAlignment','left',...
%             'FontSize',6,...
%             'FontName','Verdana',...
%             'FitBoxToText','off');
% print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_worstProvEver.PNG']);
% close(gcf);







% peggior provincia giornaliera
province_totale = struct;
ppt = 0;
n_days_comp = 7;
for reg = 1:size(Regione_lista)
    idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
    sigla_prov=dataReg.sigla_provincia(idx_reg);
%     [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
    


    [sigla_prov, ixs]= unique(sigla_prov);
    
    RegioneTot=dataReg.denominazione_provincia(idx_reg(ixs));
    
    
    
    
%     sigla_prov=sigla_prov(ixs);
    
    
    
    
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
    sigla_prov=sigla_prov(ixs);
    
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione'));
    sigla_prov=sigla_prov(ixs);
    
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('fuori Regione/P.A.'));
    sigla_prov=sigla_prov(ixs);    
    
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr(''));
    sigla_prov=sigla_prov(ixs);
    
    % find population
    [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
    
    for h=1:size(RegioneTot,1) 
        regione = char(RegioneTot(h));
        index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
        ppt=ppt+1;
        province_totale.nome(ppt,1)=cellstr(regione);
        province_totale.datoUltimo(ppt,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-1)))./pop.number(idx_pop(h))*1000;
        province_totale.datoLastDays(ppt,1)=(dataReg.totale_casi(index(end))-dataReg.totale_casi(index(end-n_days_comp+1)))./pop.number(idx_pop(h))*1000;
        end
end

[worstProvValue,idx]=sort(province_totale.datoUltimo,'descend');
worstProvName = province_totale.nome(idx);

[worstProvValue_day,idx_day]=sort(province_totale.datoLastDays,'descend');
worstProvName_day = province_totale.nome(idx_day);



for i = 1 : size(worstProvName,1)
    regione_leg=char(worstProvName(i));
    regione_leg(strfind(regione_leg,''''))=' ';
    regione_leg(strfind(regione_leg,'ì'))='i';
    regione_leg(strfind(regione_leg,'Ã'))='i';
    regione_leg(strfind(regione_leg,'¬'))='';
    worstProvName(i)=cellstr(regione_leg);
end



n_bars=15;
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: province con più nuovi contagi il %s',datestr(max(datenum(dataReg.data)),'dd mmm')));
title(sprintf('Italia: %d province con maggior numero di nuovi contagi il %s',n_bars, datestr(max(datenum(dataReg.data)),'dd mmm')))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on


b=bar(worstProvValue(1:n_bars));
for i1=1:n_bars
    text(i1,worstProvValue(i1),sprintf('%.3f',worstProvValue(i1)),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

hold on; grid minor
set(gca,'XTick',1:n_bars)
set(gca,'XTickLabel',worstProvName)
set(gca,'XLim',[0.5,n_bars+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Nuovi positivi / 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
if ismac
    font_size = 9;
else
    font_size = 6.5;
end

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

ylimit=ylim;
% if ylimit(2)<25
%     ylim([0 25]);
% end

ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';


% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.706873981385729 0.873963515754561 0.2381 0.0463800000000001],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.706873981385737 0.850746268656719 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_worstProvDay.PNG']);
close(gcf);



%best province
n_bars=15;
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: province con meno nuovi contagi il %s',datestr(max(datenum(dataReg.data)),'dd mmm')));
title(sprintf('Italia: %d province con minor numbero di nuovi contagi il %s',n_bars, datestr(max(datenum(dataReg.data)),'dd mmm')))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

worstProvValue(worstProvValue<0)=0;
b=bar(worstProvValue(end:-1:end-n_bars+1));
for i1=1:n_bars
    text(i1,worstProvValue(end-i1+1),sprintf('%.3f',worstProvValue(end-i1+1)),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

hold on; grid minor
set(gca,'XTick',1:n_bars)
set(gca,'XTickLabel',flip(worstProvName))
set(gca,'XLim',[0.5,n_bars+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Nuovi positivi / 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
if ismac
    font_size = 9;
else
    font_size = 6.5;
end

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

ylimit=ylim;
% if ylimit(2)<25
%     ylim([0 25]);
% end

ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';


% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.706873981385729 0.873963515754561 0.2381 0.0463800000000001],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.706873981385737 0.850746268656719 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestProvDay.PNG']);
close(gcf);






n_bars=15;
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: province con più nuovi contagi dal %s al %s',datestr(max(datenum(dataReg.data))-n_days_comp+1,'dd mmm'), datestr(max(datenum(dataReg.data)),'dd mmm')));
title(sprintf('Italia: %d province con maggior numero di nuovi contagi dal %s al %s',n_bars, datestr(max(datenum(dataReg.data))-n_days_comp+1,'dd mmm'), datestr(max(datenum(dataReg.data)),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on


b=bar(worstProvValue_day(1:n_bars));
for i1=1:n_bars
    text(i1,worstProvValue_day(i1),sprintf('%.3f',worstProvValue_day(i1)),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

hold on; grid minor
set(gca,'XTick',1:n_bars)
set(gca,'XTickLabel',worstProvName_day)
set(gca,'XLim',[0.5,n_bars+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Nuovi positivi / 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
if ismac
    font_size = 9;
else
    font_size = 6.5;
end

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

ylimit=ylim;
% if ylimit(2)<25
%     ylim([0 25]);
% end

ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';


% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.706873981385729 0.873963515754561 0.2381 0.0463800000000001],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.706873981385737 0.850746268656719 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_worstProv7Day.PNG']);
close(gcf);



%best province
n_bars=15;
figure;
id_f = gcf;
set(id_f, 'Name', sprintf('Italia: province con più nuovi contagi dal %s al %s',datestr(max(datenum(dataReg.data))-n_days_comp+1,'dd mmm'), datestr(max(datenum(dataReg.data)),'dd mmm')));
title(sprintf('Italia: %d province con minor numero di nuovi contagi dal %s al %s',n_bars, datestr(max(datenum(dataReg.data))-n_days_comp+1,'dd mmm'), datestr(max(datenum(dataReg.data)),'dd mmm')));


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

worstProvValue_day(worstProvValue_day<0)=0;
b=bar(worstProvValue_day(end:-1:end-n_bars+1));
for i1=1:n_bars
    text(i1,worstProvValue_day(end-i1+1),sprintf('%.3f',worstProvValue_day(end-i1+1)),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom','fontsize',7)
    
end

hold on; grid minor
set(gca,'XTick',1:n_bars)
set(gca,'XTickLabel',flip(worstProvName_day))
set(gca,'XLim',[0.5,n_bars+0.5])
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ylabel('Nuovi positivi / 1000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
if ismac
    font_size = 9;
else
    font_size = 6.5;
end

ax = gca;
set(ax, 'FontName', 'Verdana');
set(ax, 'FontSize', font_size);

ylimit=ylim;
% if ylimit(2)<25
%     ylim([0 25]);
% end

ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';


% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.709976359875905 0.908789386401327 0.2381 0.0463800000000002],...
    'String',{['Fonte: https://github.com/pcm-dpc']},...
    'HorizontalAlignment','center',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 0]);

annotation(gcf,'textbox',...
    [0.709976359875913 0.93034825870647 0.238100000000001 0.04638],...
    'String',{'https://covidguard.github.io/#covid-19-italia'},...
    'LineStyle','none',...
    'HorizontalAlignment','left',...
    'FontSize',6,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/ita_bestProv7Day.PNG']);
close(gcf);






for reg = 1:size(Regione_lista)
    %%
    idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
    sigla_prov=dataReg.sigla_provincia(idx_reg);
    [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('fuori Regione/P.A.'));
    sigla_prov=sigla_prov(ixs);
   [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione'));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('Fuori Regione / Provincia Autonoma'));
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
        set(gca,'YScale','log')
        for h=1:size(RegioneTot,1)
            try
            regione = char(RegioneTot(h));
            index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
            
            time_num = fix(datenum(dataReg.data(index)));
            [time_num, aaa] = unique(time_num);
            index=index(aaa);
            if normalizza_per_popolazione==1
                try
                    y=(dataReg.totale_casi(index,1)/pop.number(idx_pop(h)))*1000;
                    b(h)=plot(time_num,(dataReg.totale_casi(index,1)/pop.number(idx_pop(h)))*1000,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));                    
                    i = round(numel(time_num)/1)-1;                    
                    % Get the local slope
                    d = (y(i+1)-y(i-3))/4;
                    X = diff(get(gca, 'xlim'));
                    Y = diff(get(gca, 'ylim'));
                    p = pbaspect;
                    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
                    % Display the text
                    %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
                    text(time_num(i)+1.2, y(i)+d, sprintf('%s', regione), 'rotation', a,'fontSize',7);
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
                    
                    y=(dataReg.totale_casi(index,1));
                    b(h)=plot(time_num,dataReg.totale_casi(index,1),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h+4, size(RegioneTot,1)));                    
                    % Get the local slope
                    i = round(numel(time_num)/1)-1;   
                    d = (y(i+1)-y(i-3))/4;
                    X = diff(get(gca, 'xlim'));
                    Y = diff(get(gca, 'ylim'));
                    p = pbaspect;
                    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
                    % Display the text
                    %     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
                    text(time_num(i)+1.2, y(i)+d, sprintf('%s', regione), 'rotation', a,'fontSize',7);
                    
                    
                catch
                    b(h)=plot(time_num,str2double(dataReg.totale_casi(index,1)),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h+4, size(RegioneTot,1)));
                end
            end
            regione_leg=regione;
            regione_leg(strfind(regione_leg,''''))=' ';
            regione_leg(strfind(regione_leg,'ì'))='i';
            regione_leg(strfind(regione_leg,'Ã'))='i';
            regione_leg(strfind(regione_leg,'¬'))='';
            
            
            string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            catch
            end
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
        ax.XTick = time_num(1:2:end);
        datetick('x', datetickFormat, 'keepticks') ;
        set(code_axe, 'Xlim', [time_num(1), time_num(end)]);
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
        
        RegioneTot=setdiff(RegioneTot,cellstr('Forl\u201c-Cesena'));
        set(gca,'YScale','log')
        for h=1:size(RegioneTot,1)
            regione = char(RegioneTot(h));
            %         index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione))&strcmp(dataReg.denominazione_regione,cellstr(Regione_lista(reg,:))));
            index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
            time_num = fix(datenum(dataReg.data(index)));
            
            if normalizza_per_popolazione==1
                if splined_yn == 0
                   
                    b1(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000,':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    window=7;
                    b(h)=plot(time_num(2:end),movmean(diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000, window, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                    testo.sigla(h,:)=char(sigla_prov(h));
                    
                    sf=movmean(diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000, window, 'omitnan');
                    testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
                    testo.val(h,1)=sf(end);
                else
                    [ySplined, xSpline, sWeights, ySplined_ext] = splinerMat(time_num(2:end),diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000,7)
                    plot(time_num(2:end),ySplined,'-r');
                    b(h)=plot(time_num(2:end),ySplined,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h+4, size(RegioneTot,1)));
                    testo.sigla(h,:)=char(sigla_prov(h));
                    testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, ySplined(end)];
                    testo.val(h,1)=ySplined(end);
                end

            else
                try
                    if splined_yn == 0
                        
%                         y=diff(dataReg.totale_casi(index,1));
%                         fout=fopen('testIn_gauss.txt','wt');
%                         for i=1:size(time_num,1)-1
%                             fprintf(fout,'%d;%d\n',time_num(i)+1,y(i));
%                         end
%                         
%                         command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%                         [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%                         
%                         
%                         b1(h)=plot(time_num(2:end),diff(dataReg.totale_casi(index,1)),':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
%                         window=7;
%                         b(h)=plot(t,a1,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                        
                        b(h)=plot(time_num(2:end),movmean(diff(dataReg.totale_casi(index,1)), window, 'omitnan'),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                        testo.sigla(h,:)=char(sigla_prov(h));
                        sf=movmean(diff(dataReg.totale_casi(index,1)), window, 'omitnan');
                        testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
                        testo.val(h,1)=sf(end);
                        
                    else
                        [ySplined, xSpline, sWeights, ySplined_ext] = splinerMat(time_num(2:end),diff(dataReg.totale_casi(index,1)),7)
                        plot(time_num(2:end),ySplined,'-r');
                        b(h)=plot(time_num(2:end),ySplined,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h+4, size(RegioneTot,1)));
                        
                        testo.sigla(h,:)=char(sigla_prov(h));
                        testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, ySplined(end)];
                        testo.val(h,1)=ySplined(end);
                        
                    end
                    
                catch
                    %                     bbbb=str2double(dataReg.totale_casi(index,1));
                    %                     b(h)=plot(time_num(2:end),diff(bbbb),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h+4, size(RegioneTot,1)));
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
            
            %             if normalizza_per_popolazione==1
            %
            %             else
            %
            %             end
            
            %             testo.sigla(h,:)=char(sigla_prov(h));
            %             testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
            %             testo.val(h,1)=sf(end);
            
            
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
            t_lim=ylim;
            if t_lim(2)<100
                ylim([0 100]);
            else
                ylim([0 t_lim(2)]);
            end
        end
        t_lim=ylim;
        if normalizza_per_popolazione==1
            ylim([0 t_lim(2)]);
        end
        
        
        
        
        if normalizza_per_popolazione==0
            ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        end
        if normalizza_per_popolazione==0
            if splined_yn == 0
                ylabel('Numero casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            else
                ylabel('Numero casi (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            end
        else
            if splined_yn == 0
                ylabel('Numero casi ogni 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            else
                ylabel('Numero casi ogni 1000 abitanti (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            end
        end
        
        
        set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
        ax.XTick = time_num(2):2:time_num(end);
        set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
        datetick('x', datetickFormat, 'keepticks') ;
        set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;
        set(code_axe, 'Xlim', [time_num(2), time_num(end)]);  

        
        
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
        
        
        if splined_yn == 0
            
            if normalizza_per_popolazione==1
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
            else
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri.PNG']);
            end
            
        else
            
            if normalizza_per_popolazione==1
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri_smooth.PNG']);
            else
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri_smooth.PNG']);
            end
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
ListaProvince = setdiff(ListaProvince,'In fase di definizione');
ListaProvince = setdiff(ListaProvince,'Fuori Regione / Provincia Autonoma');
ListaProvince = setdiff(ListaProvince,'fuori Regione/P.A.');
ListaProvince = setdiff(ListaProvince,'Forl\u201c-Cesena');


tabellone=struct;


fout=fopen('C:/Temp/Repo/covidguard/_json/province_daily_spline.csv','wt');
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
    
    try
    tabellone.casi(:,p)=dataProv_diff_int;
    tabellone.coord(p,:)=[dataReg.lat(idx(1)) dataReg.long(idx(1))];
    catch
    end
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







% analisi di Gompertz sulla Lombardia

sf=0;
for reg = [9]
% for reg = 1:size(Regione_lista,1);
    
    %%
    idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
    sigla_prov=dataReg.sigla_provincia(idx_reg);
    [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('fuori Regione/P.A.'));
    sigla_prov=sigla_prov(ixs);
    [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione'));
    sigla_prov=sigla_prov(ixs);
    
    % find population
    [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
    
    %     RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}';
    %     RegioneTot={'Como','Bergamo','Brescia','Lecco'}'
    
 
    for tipoGraph=1:2
        
        try
        if tipoGraph==1
            normalizza_per_popolazione = 0;
        else
            normalizza_per_popolazione = 1;
        end
        
        datetickFormat = 'dd mmm';
        
        
        %% figura giornaliera
        datetickFormat = 'dd mmm';
        figure;
        id_f = gcf;
        set(id_f, 'Name', ['Giornalieri']);
        title(sprintf([char(Regione_lista(reg)), ': andamento epidemia delle Province\\fontsize{5}\n ']))
        set(gcf,'NumberTitle','Off');
        set(gcf,'Position',[26 79 967 603]);
        grid on
        hold on
        
        b=[];
        string_legend='l=legend([b]';
        
        testo=struct;
        
        RegioneTot=setdiff(RegioneTot,cellstr('Forl\u201c-Cesena'));
        a1_tot=[];
        
        for h=1:size(RegioneTot,1)
            regione = char(RegioneTot(h));
            index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
            time_num = fix(datenum(dataReg.data(index)));
            
            if normalizza_per_popolazione==1
                y=diff(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000;
                fout=fopen('testIn_gauss.txt','wt');
                for i=1:size(time_num,1)-1
                    fprintf(fout,'%d;%d\n',time_num(i)+1,y(i));
                end
                
                command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
                [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
                
                
                b1(h)=plot(time_num(2:end),y,':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                window=7;
                b(h)=plot(t,a1,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));                
                testo.sigla(h,:)=char(sigla_prov(h));
  
                testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
                testo.val(h,1)=sf(end);
                a1_tot(h,:)=a1;
                
                
                
                
            else
                y=diff(dataReg.totale_casi(index,1));
                fout=fopen('testIn_gauss.txt','wt');
                for i=1:size(time_num,1)-1
                    fprintf(fout,'%d;%d\n',time_num(i)+1,y(i));
                end
                fclose(fout);
                command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
                [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
                
                
                b1(h)=plot(time_num(2:end),y,':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
                window=7;
                b(h)=plot(t,a1,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));                
                testo.sigla(h,:)=char(sigla_prov(h));
  
                testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
                testo.val(h,1)=sf(end);
                a1_tot(h,:)=a1;
            end
            
            
            regione_leg=regione;
            regione_leg(strfind(regione_leg,''''))=' ';
            regione_leg(strfind(regione_leg,'Ã'))='i';
            regione_leg(strfind(regione_leg,'¬'))='';
            string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
            code_axe = get(id_f, 'CurrentAxes');
            set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
            
            %             if normalizza_per_popolazione==1
            %
            %             else
            %
            %             end
            
            %             testo.sigla(h,:)=char(sigla_prov(h));
            %             testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
            %             testo.val(h,1)=sf(end);
            
            
        end
        string_legend=sprintf('%s);',string_legend);
        eval(string_legend)
        
%         
%         [~,indext]=sort(testo.pos(:,2));
%         for ll=1:size(indext,1)
%             if ll/2==fix(ll/2)
%                 text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
%                     ['------> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]);
%             else
%                 text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
%                     ['-> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]) ;
%             end
%         end
        
        if ismac
            font_size = 9;
        else
            font_size = 6.5;
        end
        
        ax = gca;
        set(code_axe, 'FontName', 'Verdana');
        set(code_axe, 'FontSize', font_size);
        
        if normalizza_per_popolazione==0
            t_lim=ylim;
            if t_lim(2)<100
                ylim([0 100]);
            else
                ylim([0 t_lim(2)]);
            end
        end
        t_lim=ylim;
        if normalizza_per_popolazione==1
            ylim([0 t_lim(2)]);
        end
        
        t_lim=ylim;
        ylim([0 max(a1_tot(:))*1.1]);    
        
        
        
        
        if normalizza_per_popolazione==0
            ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
        end
        if normalizza_per_popolazione==0
            if splined_yn == 0
                ylabel('Numero casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            else
                ylabel('Numero casi (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            end
        else
            if splined_yn == 0
                ylabel('Numero casi giornalieri ogni 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            else
                ylabel('Numero casi ogni 1000 abitanti (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
            end
        end
        
        
        set(code_axe, 'Xlim', [time_num(1)-50, time_num(end)+100]);
%         ax.XTick = time_num(2):2:time_num(end);
%         set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
        datetick('x', datetickFormat) ;
        set(code_axe, 'Xlim', [time_num(1)-50, time_num(end)+100]);
%         set(gca,'XTickLabelRotation',53,'FontSize',6.5);
        ax.FontSize = font_size;


        for h=1:size(RegioneTot,1)
            idx_max=find(a1_tot(h,:)==max(a1_tot(h,:)))-3;
            i = idx_max;
            
                % Get the local slope
                dy=a1_tot(h,i+1)-a1_tot(h,i-1);
                dx=t(i+1)-t(i-1);
                d = dy/dx;
             
            
            X = diff(get(gca, 'xlim'));
            Y = diff(get(gca, 'ylim'));
            p = pbaspect;
            a = atan(d*p(2)*X/p(1)/Y)*180/pi;
            text(t(i), a1_tot(h,i), char(sigla_prov(h)),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(RegioneTot,1)));
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
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri_gomp.PNG']);
            else
                print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliGiornalieri_gomp.PNG']);
            end

        
        close(gcf);
        catch
            close all
        end
    end
    
    
    
    
    
    
    
    
end




% 
% 
% %% calcolo proressioni percentuali della curva di crescita 
% for reg = [9]
% % for reg = 1:size(Regione_lista,1);
%     
%     %%
%     idx_reg=find(strcmp(dataReg.denominazione_regione,cell(Regione_lista(reg,:))));
%     sigla_prov=dataReg.sigla_provincia(idx_reg);
%     [RegioneTot, ixs]= unique(dataReg.denominazione_provincia(idx_reg));
%     sigla_prov=sigla_prov(ixs);
%     [RegioneTot, ixs]=setdiff(RegioneTot,cellstr('In fase di definizione/aggiornamento'));
%     sigla_prov=sigla_prov(ixs);
%     
%     % find population
%     [~,idx_pop] = intersect(pop.sigla,cell(sigla_prov));
%     
%     %     RegioneTot={'Como','Lecco','Milano','Bergamo','Varese','Lodi','Monza e della Brianza'}';
%     %     RegioneTot={'Como','Bergamo','Brescia','Lecco'}'
%     
%  
%     for tipoGraph=2
%         
%         try
%         if tipoGraph==1
%             normalizza_per_popolazione = 0;
%         else
%             normalizza_per_popolazione = 1;
%         end
%         
%         datetickFormat = 'dd mmm';
%         
%         
%         %% figura giornaliera
%         datetickFormat = 'dd mmm';
%         figure;
%         id_f = gcf;
%         set(id_f, 'Name', ['Giornalieri']);
%         title(sprintf([char(Regione_lista(reg)), ': andamento epidemia delle Province\\fontsize{5}\n ']))
%         set(gcf,'NumberTitle','Off');
%         set(gcf,'Position',[26 79 967 603]);
%         grid on
%         hold on
%         
%         b=[];
%         string_legend='l=legend([b]';
%         
%         testo=struct;
%         
%         RegioneTot=setdiff(RegioneTot,cellstr('Forl\u201c-Cesena'));
%         a1_tot=[];
%         
%         for h=1:size(RegioneTot,1)
%             regione = char(RegioneTot(h));
%             index = find(strcmp(dataReg.denominazione_provincia,cellstr(regione)));
%             time_num = fix(datenum(dataReg.data(index)));
%             
%             if normalizza_per_popolazione==1
%                 y=(dataReg.totale_casi(index,1))/pop.number(idx_pop(h))*1000;
%                 fout=fopen('testIn_gauss.txt','wt');
%                 for i=1:size(time_num,1)
%                     fprintf(fout,'%d;%d\n',time_num(i),y(i));
%                 end
%                 fclose(fout);
%                 
%                 command=sprintf('gomp_estim testIn_gauss.txt');system(command);
%                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
%                 
%                 
%                 b1(h)=plot(time_num(1:end),y,':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
%                 window=7;
%                 b(h)=plot(t,a1,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));                
%                 testo.sigla(h,:)=char(sigla_prov(h));
%   
%                 testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
%                 testo.val(h,1)=sf(end);
%                 a1_tot(h,:)=a1;
%                 
%                 
%                 
%                 
%             else
%                 y=diff(dataReg.totale_casi(index,1));
%                 fout=fopen('testIn_gauss.txt','wt');
%                 for i=1:size(time_num,1)-1
%                     fprintf(fout,'%d;%d\n',time_num(i)+1,y(i));
%                 end
%                 fclose(fout);
%                 command=sprintf('gomp_d1_estim testIn_gauss.txt');system(command);
%                 [t,a1,a2,a3,a4,a5]=textread('testIn_gauss_gomp_d1_fit.txt','%f%f%f%f%f%f','delimiter',';');
%                 
%                 
%                 b1(h)=plot(time_num(2:end),y,':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
%                 window=7;
%                 b(h)=plot(t,a1,'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));                
%                 testo.sigla(h,:)=char(sigla_prov(h));
%   
%                 testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
%                 testo.val(h,1)=sf(end);
%                 a1_tot(h,:)=a1;
%             end
%             
%             
%             regione_leg=regione;
%             regione_leg(strfind(regione_leg,''''))=' ';
%             regione_leg(strfind(regione_leg,'Ã'))='i';
%             regione_leg(strfind(regione_leg,'¬'))='';
%             string_legend=sprintf('%s,''%s''',string_legend,regione_leg);
%             code_axe = get(id_f, 'CurrentAxes');
%             set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
%             
%             %             if normalizza_per_popolazione==1
%             %
%             %             else
%             %
%             %             end
%             
%             %             testo.sigla(h,:)=char(sigla_prov(h));
%             %             testo.pos(h,:)=[time_num(end)+((time_num(end)-time_num(1)))*0.01, sf(end)];
%             %             testo.val(h,1)=sf(end);
%             
%             
%         end
%         string_legend=sprintf('%s);',string_legend);
%         eval(string_legend)
%         
% %         
% %         [~,indext]=sort(testo.pos(:,2));
% %         for ll=1:size(indext,1)
% %             if ll/2==fix(ll/2)
% %                 text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
% %                     ['------> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]);
% %             else
% %                 text(time_num(end)+((time_num(end)-time_num(1)))*0.01, (testo.pos(indext(ll),2)),...
% %                     ['-> ',testo.sigla(indext(ll),:)], 'HorizontalAlignment','left','FontSize',7','Color',[0 0 0]) ;
% %             end
% %         end
%         
%         if ismac
%             font_size = 9;
%         else
%             font_size = 6.5;
%         end
%         
%         ax = gca;
%         set(code_axe, 'FontName', 'Verdana');
%         set(code_axe, 'FontSize', font_size);
%         
%         if normalizza_per_popolazione==0
%             t_lim=ylim;
%             if t_lim(2)<100
%                 ylim([0 100]);
%             else
%                 ylim([0 t_lim(2)]);
%             end
%         end
%         t_lim=ylim;
%         if normalizza_per_popolazione==1
%             ylim([0 t_lim(2)]);
%         end
%         
%         t_lim=ylim;
%         ylim([0 max(a1_tot(:))*1.1]);    
%         
%         
%         
%         
%         if normalizza_per_popolazione==0
%             ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
%         end
%         if normalizza_per_popolazione==0
%             if splined_yn == 0
%                 ylabel('Numero casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
%             else
%                 ylabel('Numero casi (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
%             end
%         else
%             if splined_yn == 0
%                 ylabel('Numero casi giornalieri ogni 1000 abitanti', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
%             else
%                 ylabel('Numero casi ogni 1000 abitanti (smoothed)', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
%             end
%         end
%         
%         
%         set(code_axe, 'Xlim', [time_num(1)-50, time_num(end)+100]);
% %         ax.XTick = time_num(2):2:time_num(end);
% %         set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
%         datetick('x', datetickFormat) ;
%         set(code_axe, 'Xlim', [time_num(1)-50, time_num(end)+100]);
% %         set(gca,'XTickLabelRotation',53,'FontSize',6.5);
%         ax.FontSize = font_size;
% 
% 
%         for h=1:size(RegioneTot,1)
%             idx_max=find(a1_tot(h,:)==max(a1_tot(h,:)))-3;
%             i = idx_max;
%             
%             plot(t(i),a1_tot(h,i),'*')
%                 % Get the local slope
%                 dy=a1_tot(h,i+1)-a1_tot(h,i-1);
%                 dx=t(i+1)-t(i-1);
%                 d = dy/dx;
%              
%             
%             X = diff(get(gca, 'xlim'));
%             Y = diff(get(gca, 'ylim'));
%             p = pbaspect;
%             a = atan(d*p(2)*X/p(1)/Y)*180/pi;
%             text(t(i), a1_tot(h,i), char(sigla_prov(h)),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(RegioneTot,1)));
%         end
%         
%         
%         
%         
%         
%         
%         % l=legend([b],'Totale Casi');
%         set(l,'Location','northwest')
%         
%         %% overlap copyright info
%         datestr_now = datestr(now);
%         annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
%             'String',{['Fonte: https://github.com/pcm-dpc']},...
%             'HorizontalAlignment','center',...
%             'FontSize',6,...
%             'FontName','Verdana',...
%             'FitBoxToText','off',...
%             'LineStyle','none',...
%             'Color',[0 0 0]);
%         
%         annotation(gcf,'textbox',...
%             [0.125695077559464 0.00165837479270315 0.238100000000001 0.04638],...
%             'String',{'https://covidguard.github.io/#covid-19-italia'},...
%             'LineStyle','none',...
%             'HorizontalAlignment','left',...
%             'FontSize',6,...
%             'FontName','Verdana',...
%             'FitBoxToText','off');
% 
%             if normalizza_per_popolazione==1
%                 print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliCumulati_gomp.PNG']);
%             else
%                 print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_',char(Regione_lista(reg)) ,'_casiTotaliCumulati_gomp.PNG']);
%             end
% 
%         
%         close(gcf);
%         catch
%             close all
%         end
%         
%         
%         
%         
%         figure;
%         id_f = gcf;
%         set(id_f, 'Name', ['Giornalieri']);
%         title(sprintf([char(Regione_lista(reg)), ': andamento epidemia delle Province (tasso di crescita)\\fontsize{5}\n ']))
%         set(gcf,'NumberTitle','Off');
%         set(gcf,'Position',[26 79 967 603]);
%         grid on
%         hold on
%         inc =[];
%         a1_tot(a1_tot<10^-6)=0;
%         for h=1:size(RegioneTot,1)            
%             for i=2:size(a1_tot(h,:),2)
%                inc(i-1,h)=(a1_tot(h,i)-a1_tot(h,i-1))/a1_tot(h,i-1)*100;            
%             end
%                         b1(h)=plot(t(1:end),a1_tot(h,:),':','LineWidth', 1.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
%             window=7;
%             b(h)=plot(t(2:end),inc(:,h),'-','LineWidth', 2.0,  'Color', Cmap.getColor(h, size(RegioneTot,1)));
%             testo.sigla(h,:)=char(sigla_prov(h));
%             
%             k=find(isfinite(inc(:,h)));
%             
%             testo.pos(h,:)=[k(1)+4, sf(end)];
%             testo.val(h,1)=sf(end);
%         end
%         
%         
%         for h=1:size(RegioneTot,1)
%             idx_max=find(inc(:,h)==max(inc(:,h)))+3;
%             i = idx_max;
%             
%            
%             % Get the local slope
%             dy=inc(i+1,h)-inc(i-1,h);
%             dx=t(i+1)-t(i-1);
%             d = dy/dx;
%             
%             
%             X = diff(get(gca, 'xlim'));
%             Y = diff(get(gca, 'ylim'));
%             p = pbaspect;
%             a = 0; atan(d*p(2)*X/p(1)/Y)*180/pi;
%             text(t(i)+1, inc(i,h), char(sigla_prov(h)),'HorizontalAlignment','center', 'rotation', a, 'fontsize',6,'backgroundcolor','w', 'margin',0.001,'color',Cmap.getColor(h, size(RegioneTot,1)));
%         end
%         
%         
%         
%         set(gca, 'Xlim', [time_num(1)-50, time_num(end)+20]);
%         %         ax.XTick = time_num(2):2:time_num(end);
%         %         set(code_axe, 'Xlim', [time_num(2), time_num(end)]);
%         datetick('x', datetickFormat) ;
%         set(gca, 'Xlim', [time_num(1)-50, time_num(end)+20]);
%         %         set(gca,'XTickLabelRotation',53,'FontSize',6.5);
%         ylabel('Progressione percentuale nuovi casi', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', font_size);
%         
%         
%         
%         print(gcf, '-dpng', [WORKroot,'/slides/img/province/Province_norm_',char(Regione_lista(reg)) ,'_casiTotaliCumulati_gompProgPerc.PNG']);
%         
%         
%         
%         
%         
%         
% 
%     end
%     
%     
%     
%     
%     
%     
%     
%     
% end















%% MAPPE
mappeprovincia;
mappeprovincia_var;








% mkdir('GRAPHS');
% movefile('*.PNG','GRAPHS','f');
fclose all

