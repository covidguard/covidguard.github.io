% function animated_gif_reg(path_mat_file,gif_filename)
function animated_gif_reg_gara(data,pop,regions)

% regions: 'A': all regions, 'N': north, 'C': center, 'S': south
regioni_tot_geog = ['C';'S';'S';'S';'N';'N';'C';'N';'N';'C';'S';'N';'N';'N';'S';'S';'S';'C';'C';'N';'N'];

regioni_tot = unique(data.dataReg.denominazione_regione);
index_regioni=1:size(regioni_tot,1);

try
    if ~strcmp(regions,'A')
        index_regioni = find(strcmp(cellstr(regioni_tot_geog),cellstr(regions)));
        idx=[];
        for id = 1:size(index_regioni,1)
            idx=[idx;find(strcmp(data.dataReg.denominazione_regione,regioni_tot(index_regioni(id))))];
        end
        data.dataReg.stato = data.dataReg.stato(idx);
        data.dataReg.codice_regione = data.dataReg.codice_regione(idx);
        data.dataReg.denominazione_regione = data.dataReg.denominazione_regione(idx);
        data.dataReg.lat = data.dataReg.lat(idx);
        data.dataReg.long = data.dataReg.long(idx);
        data.dataReg.ricoverati_con_sintomi = data.dataReg.ricoverati_con_sintomi(idx);
        data.dataReg.terapia_intensiva = data.dataReg.terapia_intensiva(idx);
        data.dataReg.totale_ospedalizzati = data.dataReg.totale_ospedalizzati(idx);
        data.dataReg.isolamento_domiciliare = data.dataReg.isolamento_domiciliare(idx);
        data.dataReg.totale_positivi = data.dataReg.totale_attualmente_positivi(idx);
        data.dataReg.nuovi_positivi = data.dataReg.nuovi_attualmente_positivi(idx);
        data.dataReg.dimessi_guariti = data.dataReg.dimessi_guariti(idx);
        data.dataReg.deceduti=data.dataReg.deceduti(idx);
        data.dataReg.totale_casi = data.dataReg.totale_casi(idx);
        data.dataReg.tamponi = data.dataReg.tamponi(idx);
        regioni_tot=regioni_tot(index_regioni);
        filename = ['Andamento_Regioni_',regions,'.gif'];
    end
catch
end


% data=load(path_mat_file);
filename = 'Andamento_Regioni_Race.gif';

day_list = unique(data.dataReg.data);
x_data = nan(numel(day_list), size(regioni_tot,1));

for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(data.dataReg.denominazione_regione,cellstr(regione)));
    x_data(:,reg) = data.dataReg.totale_casi(index)./pop.popolazioneRegioniPop(reg)*100000;
    
end




x_data_int=[];
y_data_int=[];
%interpolation piecewise
tmp = x_data;
tmp(tmp == 0) = 1;
step = 0.2;
for i = 1:size(x_data,2)
    [~, ~, ~, y_data_int(:,i)] = splinerMat(1:size(x_data,1),tmp(:,i),2,0,1:step:size(x_data,1));
end
clear tmp

tmp = datenum(day_list);
x_data_int=[];
tmp(tmp == 0) = 1;
step = 0.2;
for i = 1:1
    [~, ~, ~, x_data_int(:,i)] = splinerMat(1:size(day_list,1),tmp(:,i),2,0,1:step:size(x_data,1));
end
clear tmp




h = figure;
% set(h,'visible','off');
set(h,'NumberTitle','Off');
set(h,'Position',[26 79 967 603]);
axis tight manual % this ensures that getframe() returns a consistent size
days = (datenum(unique(data.dataReg.data)));
ylabel('Totale casi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);



ann=annotation(gcf,'textbox',[0.721351747673216 0.135986733001659 0.2381 0.0463800000000001],...
    'String',datestr(days(1), 'dd mmm'),...
    'HorizontalAlignment','center',...
    'FontSize',20,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.5 .5 0.5]);


for i=1:size(y_data_int,1)
    i
    [x_data_i, idx_i] = sort(y_data_int(i,:), 'ascend');
    a=barh([1 2],[x_data_i; x_data_i]);
    grid minor
    ann.String = datestr(x_data_int(i), 'dd mmm');
    
    for k=1:size(regioni_tot,1)
        set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
    end
    
    hT=[];              % placeholder for text object handles
    for k=1:length(a)  % iterate over number of bar objects
        hT=[hT,text(a(k).YData+5,a(k).XData+a(k).XOffset,char(regioni_tot(idx_i(k))), ...
            'VerticalAlignment','middle','horizontalalign','left','fontsize',7)];
    end
    
    set(gca,'YTick',[])
    %     set(gca,'YTickLabel',regioni_tot(idx_i));
    set(gca,'YLim',[1.6,2.4])
    set(gca,'FontSize',8);
    set(gca,'xlim',[0,max(y_data_int(:))*1.12]);
    xlabel('Casi totali / 100.000 abitanti')
    title('Totale casi / 100.000 ab.');
    drawnow
    % Capture the plot as an image
    %set(gca,'position',[0 0 1 1],'units','normalized')
    %set(gca,'nextplot','replacechildren','visible','on')
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.07);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.07);
    end
    
end
% Pause on the last frame
for n = 1 : 30
    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
end

close all




















% data=load(path_mat_file);
filename = 'Andamento_Regioni_Race_attPositivi.gif';

day_list = unique(data.dataReg.data);
x_data = nan(numel(day_list), size(regioni_tot,1));

for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(data.dataReg.denominazione_regione,cellstr(regione)));
    x_data(:,reg) = data.dataReg.totale_positivi(index)./pop.popolazioneRegioniPop(reg)*100000;
    
end




x_data_int=[];
y_data_int=[];
%interpolation piecewise
tmp = x_data;
tmp(tmp == 0) = 1;
step = 0.2;
for i = 1:size(x_data,2)
    [~, ~, ~, y_data_int(:,i)] = splinerMat(1:size(x_data,1),tmp(:,i),2,0,1:step:size(x_data,1));
end
clear tmp

tmp = datenum(day_list);
x_data_int=[];
tmp(tmp == 0) = 1;
step = 0.2;
for i = 1:1
    [~, ~, ~, x_data_int(:,i)] = splinerMat(1:size(day_list,1),tmp(:,i),2,0,1:step:size(x_data,1));
end
clear tmp




h = figure;
% set(h,'visible','off');
set(h,'NumberTitle','Off');
set(h,'Position',[26 79 967 603]);
axis tight manual % this ensures that getframe() returns a consistent size
days = (datenum(unique(data.dataReg.data)));
ylabel('Attualmente positivi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);



ann=annotation(gcf,'textbox',[0.721351747673216 0.135986733001659 0.2381 0.0463800000000001],...
    'String',datestr(days(1), 'dd mmm'),...
    'HorizontalAlignment','center',...
    'FontSize',20,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.5 .5 0.5]);


for i=1:size(y_data_int,1)
    i
    [x_data_i, idx_i] = sort(y_data_int(i,:), 'ascend');
    
    x_data_i=y_data_int(i,:);
    idx_i=1:size(y_data_int,2);
    x_data_i=flip(x_data_i);
    idx_i=flip(idx_i);
    
    a=barh([1 2],[x_data_i; x_data_i]);
    grid minor
    ann.String = datestr(x_data_int(i), 'dd mmm');
    
    for k=1:size(regioni_tot,1)
        set(a(k),'FaceColor',Cmap.getColor(idx_i(k), size(regioni_tot,1)));
    end
    
    hT=[];              % placeholder for text object handles
    for k=1:length(a)  % iterate over number of bar objects
        hT=[hT,text(a(k).YData+5,a(k).XData+a(k).XOffset,char(regioni_tot(idx_i(k))), ...
            'VerticalAlignment','middle','horizontalalign','left','fontsize',7)];
    end
    
    set(gca,'YTick',[])
    %     set(gca,'YTickLabel',regioni_tot(idx_i));
    set(gca,'YLim',[1.6,2.4])
    set(gca,'FontSize',8);
    set(gca,'xlim',[0,max(y_data_int(:))*1.12]);
    xlabel('Attualmente positivi / 100.000 abitanti')
    title('Attualmente Positivi / 100.000 ab.');
    drawnow
    % Capture the plot as an image
    %set(gca,'position',[0 0 1 1],'units','normalized')
    %set(gca,'nextplot','replacechildren','visible','on')
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.07);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.07);
    end
    
end
% Pause on the last frame
for n = 1 : 30
    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
end

close all







end