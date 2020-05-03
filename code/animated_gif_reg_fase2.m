% function animated_gif_reg(path_mat_file,gif_filename)
function animated_gif_reg_fase2(data,pop,regions)

if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end



% regions: 'A': all regions, 'N': north, 'C': center, 'S': south
regioni_tot_geog = ['C';'S';'S';'S';'N';'N';'C';'N';'N';'C';'S';'N';'N';'N';'S';'S';'S';'C';'C';'N';'N'];

% data=load(path_mat_file);
filename = 'Andamento_Regioni_fase2.gif';

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


colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:size(regioni_tot,1)
    colors{k}=Cmap.getColor(k, size(regioni_tot,1));
end


%% confronto tra regioni: casi totali allineato da 10 casi su 100.000
h = figure;
set(h,'NumberTitle','Off');
title('Andamento epidemia per Regioni: casi totali')
set(h,'Position',[26 79 967 603]);

hold on; grid on; grid minor;
xlabel('Giorni dal caso 10/100.000 ab');
ylabel('Casi totali per 100.000 abitanti')


date_s=datenum(unique(data.dataReg.data));

a=[];
for reg = 1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = strcmp(data.dataReg.denominazione_regione,cellstr(regione));
    y=data.dataReg.totale_casi(index)./pop.popolazioneRegioniPop(reg)*100000;
    idx=find(y>10);y=y(idx(1):end);
    a(reg)=plot(y,'LineWidth', 2.0, 'Color', colors{reg});
    i = round(numel(y)/1)-1;
    
    % Get the local slope
    d = (y(i+1)-y(i-3))/4;
    X = diff(get(gca, 'xlim'));
    Y = diff(get(gca, 'ylim'));
    p = pbaspect;
    a = atan(d*p(2)*X/p(1)/Y)*180/pi;
    
    
    % Display the text
%     text(i+1.2, y(i)+d, sprintf('%s (t0: %s)', regione, datestr(datenum(date_s(idx(1))),'dd-mmm')), 'rotation', a,'fontSize',7);
    text(i+1.2, y(i)+d, sprintf('%s', regione), 'rotation', a,'fontSize',7);
end
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/confrontoReg_casiTotali.PNG']);
close(gcf);



   

x_data = NaN(size(regioni_tot,1), size(unique(data.dataReg.data),1)-6);
y_data = NaN(size(regioni_tot,1), size(unique(data.dataReg.data),1)-6);

for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(data.dataReg.denominazione_regione,cellstr(regione)));
    for t = 7: size(unique(data.dataReg.data),1)
        x_data(reg,t) = data.dataReg.nuovi_positivi(index(t))/pop.popolazioneRegioniPop(reg)*100000;
        y_data(reg,t) = (data.dataReg.totale_casi(index(t))-data.dataReg.totale_casi(index(t-6)))/data.dataReg.totale_casi(index(t-6))*100;
    end
end

lastDay=unique(data.dataReg.data); lastDay=lastDay(end);
lastWeek=unique(data.dataReg.data); lastWeek=lastWeek(end-6);

idx = find(strcmp(data.dataReg.data,lastDay));
idx2 = find(strcmp(data.dataReg.data,lastWeek));

x_data_ita=sum(data.dataReg.nuovi_positivi(idx))/sum(pop.popolazioneRegioniPop)*100000;
y_data_ita=(sum(data.dataReg.totale_casi(idx))-sum(data.dataReg.totale_casi(idx2)))/sum(data.dataReg.totale_casi(idx2))*100;


h = figure;
set(h,'NumberTitle','Off');
set(h,'Position',[26 79 967 603]);
grid minor
axis tight manual % this ensures that getframe() returns a consistent size
ylim([0 10])
xlim([0 500])


days = (datenum(unique(data.dataReg.data)));


% Init labels
l=1;
x = x_data(:,1);
y = y_data(:,1);
clear lbl;

annotation(gcf,'textbox',[0.671713691830404 0.940298507462687 0.238100000000001 0.0463800000000003],...
    'String',datestr(days(end), 'dd mmm'),...
    'HorizontalAlignment','right',...
    'FontSize',20,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.5 0.5 0.5]);



fontsize=10;
for q=1:size(x,1)
    %plot(x(q)',y(q)',markers{l},'w')
    try
        if ~strcmp(regions,'A')
            lbl(q) = text(x(q),y(q), upper(regioni_tot{q}(:))','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
        else
            if strcmp('P.A. Bolzano',regioni_tot{q})
                lbl(q) = text(x(q),y(q), 'BOLZ','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
            elseif strcmp('P.A. Trento',regioni_tot{q})
                lbl(q) = text(x(q),y(q), 'TREN','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
            elseif strcmp('Valle d Aosta',regioni_tot{q})
                lbl(q) = text(x(q),y(q), 'VDAO','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
            else
                lbl(q) = text(x(q),y(q), upper(regioni_tot{q}(1:4)),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
            end
        end
    catch
        if strcmp('P.A. Bolzano',regioni_tot{q})
            lbl(q) = text(x(q),y(q), 'BOLZ','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
        elseif strcmp('P.A. Trento',regioni_tot{q})
            lbl(q) = text(x(q),y(q), 'TREN','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
        elseif strcmp('Valle d Aosta',regioni_tot{q})
            lbl(q) = text(x(q),y(q), 'VDAO','Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
        else
            lbl(q) = text(x(q),y(q), upper(regioni_tot{q}(1:4)),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center');
        end
    end
    l=l+1;
    if l==size(colors,2)
        l=1;
    end
end


grid on
% text(60, 260000, {'alto tasso di crescita e','  alto numero di casi'},'Color','k','fontsize',14)
% text(0, 260000, {'epidemia sotto','   controllo'},'Color','k','fontsize',14)
xlabel('nuovi positivi x 100.000 ab');
ylabel('Incremento settimanale percentuale di casi totali')
set(gcf,'color','w');

fh = gcf;

% add Italy
hold on

for n = size(x_data,2):size(x_data,2)
    x = x_data(:,n);
    y = y_data(:,n);
end
xlim([0 max(x)*1.1]);
ylim([0 max(y)*1.1]);

xLimF=xlim;
yLimF=ylim;


rectangle('Position',[0,0,x_data_ita,y_data_ita],'FaceColor',[0 1 0 .2],'LineWidth',1)
rectangle('Position',[0,y_data_ita,x_data_ita,yLimF(2)-y_data_ita],'FaceColor',[1 0.400000011920929 0 .2],'LineWidth',1)
rectangle('Position',[x_data_ita,0,xLimF(2)-x_data_ita,y_data_ita],'FaceColor',[1 1 0 .2],'LineWidth',1)
rectangle('Position',[x_data_ita,y_data_ita,xLimF(2)-x_data_ita,yLimF(2)-y_data_ita],'FaceColor',[1 0 0 .2],'LineWidth',1)


annotation(gcf,'textbox',...
    [0.820062047569804 0.882255389718076 0.0825655446397846 0.035531381343986],...
    'Color',[1 0 0],...
    'String','alti numeri',...
    'LineStyle','none',...
    'HorizontalAlignment','right',...
    'VerticalAlignment','middle',...
    'FontSize',8,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1]);

annotation(gcf,'textbox',...
    [0.75387797311272 0.115187865589425 0.145647240606694 0.0324074909611554],...
    'Color',[1 0 0],...
    'VerticalAlignment','middle',...
    'String','non pronto per fase 2',...
    'LineStyle','none',...
    'HorizontalAlignment','right',...
    'FontSize',8,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1]);

annotation(gcf,'textbox',...
    [0.135470527404344 0.884673769403688 0.145647240606694 0.0324074909611556],...
    'Color',[1 0 0],...
    'VerticalAlignment','middle',...
    'String','non pronto per fase 2',...
    'LineStyle','none',...
    'HorizontalAlignment','right',...
    'FontSize',8,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1]);

annotation(gcf,'textbox',...
    [0.137538779731128 0.118504615174833 0.114788004136504 0.0324074909611555],...
    'Color',[1 0 0],...
    'VerticalAlignment','middle',...
    'String','pronto per fase 2',...
    'LineStyle','none',...
    'HorizontalAlignment','right',...
    'FontSize',8,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'BackgroundColor',[1 1 1]);


%     hdate.String = datestr(days(n), 'dd mmm');
for q=1:size(x_data,1)
    %plot(x(q)',y(q)',markers{l},'w')
    lbl(q).Position(1:2) = [x(q), y(q)];
end
lbl(q+1) = text(x_data_ita,y_data_ita, 'ITALIA','Color', [0 0 0],'fontsize',fontsize,'FontWeight','bold','horizontalAlignment','center', 'verticalAlignment','bottom');

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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/status.PNG']);
close(gcf);

end

function beautifyFig(fig_handle)
% Change font size / type colors of a figure
%
% INPUT:
%   fig_handle  figure handler (e.g. gcf)
%   color_mode  two modes are supported:
%               'light'     classic Light mode
%
% SYNTAX:
%   beautifyFig(fig_handle)
FONT = 'Open Sans';
%FONT = 'Helvetica';
if nargin == 0 || isempty(fig_handle)
    fig_handle = gcf;
end
color_mode = 'light';
ax_list = findall(fig_handle,'type','axes');
for ax = ax_list(:)'
    ax.FontName = 'Open Sans';
    ax.FontWeight = 'bold';
end
set(fig_handle, ...
    'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.5, ...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontUnits', 'points', ...
    'DefaultAxesFontSize', 12, ...
    'DefaultAxesFontName', FONT, ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', FONT, ...
    'DefaultTextFontWeight', 'bold', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);

set(fig_handle, 'DefaultAxesTickDir', 'out');
set(fig_handle, 'DefaultAxesTickDirMode', 'manual');


ui_list = findall(fig_handle, 'Type', 'uicontrol');
for ui = ui_list(:)'
    if ~ischar(ui.BackgroundColor) && all(ui.BackgroundColor > 0.5)
        ui.FontName = FONT;
        ui.FontSize = iif(ui.FontSize == 12, 16, 18);
    end
end

cb_list = findall(fig_handle, 'Type', 'colorbar');
for cb = cb_list(:)'
    cb.FontName = FONT;
    cb.FontSize = 18;
    cbt_list = findall(cb.UserData, 'Type', 'text');
    for cbt = cbt_list(:)'
        cbt.FontName = FONT;
        cbt.FontSize = 16;
    end
end

ax_list = findall(fig_handle,'type','axes');
for ax = ax_list(:)'
    ax.FontName = FONT;
    ax.FontSize = 14;
    text_label = findall(ax, 'Type', 'text');
    for txt = text_label(:)'
        % If the text have the same color of the background change it accordingly
        txt.FontName = FONT;
    end
end
text_label = findall(gcf,'Tag', 'm_grid_xticklabel');
for txt = text_label(:)'
    txt.FontName = FONT;
    txt.FontSize = iif(txt.FontSize == 12, 13, 15);
end
text_label = findall(gcf,'Tag', 'm_grid_yticklabel');
for txt = text_label(:)'
    txt.FontName = FONT;
    txt.FontSize = iif(txt.FontSize == 12, 13, 15);
end
text_label = findall(gcf,'Tag', 'm_ruler_label');
for txt = text_label(:)'
    txt.FontName = FONT;
    txt.FontSize = iif(txt.FontSize == 12, 13, 15);
end
legend = findall(gcf, 'type', 'legend');
for lg = legend(:)'
    lg.FontName = FONT;
    lg.FontSize = 11;
end

if strcmp(color_mode, 'light') % ------------------------------------------------------------------- LIGHT
    fig_handle.Color = [1 1 1];
    box_list = findall(fig_handle, 'Type', 'uicontainer');
    for box = box_list(:)'
        if ~ischar(box.BackgroundColor) && all(box.BackgroundColor < 0.5)
            box.BackgroundColor = 1 - box.BackgroundColor;
        end
    end
    ui_list = findall(fig_handle, 'Type', 'uicontrol');
    for ui = ui_list(:)'
        if ~ischar(ui.BackgroundColor) && all(ui.BackgroundColor < 0.5)
            ui.ForegroundColor = 1 - ui.ForegroundColor;
            ui.BackgroundColor = 1 - ui.BackgroundColor;
        end
    end
    
    cb_list = findall(fig_handle, 'Type', 'colorbar');
    for cb = cb_list(:)'
        cb.Color = 1-[0.8 0.8 0.8];
        cbt_list = findall(cb.UserData, 'Type', 'text');
        for cbt = cbt_list(:)'
            cbt.Color = 1-[0.8 0.8 0.8];
        end
    end
    ax_list = findall(fig_handle,'type','axes');
    for ax = ax_list(:)'
        ax.Color = [1 1 1];
        ax.Title.Color = 1-[1 1 1];
        ax.XLabel.Color = 1-[0.8 0.8 0.8];
        ax.YLabel.Color = 1-[0.8 0.8 0.8];
        ax.ZLabel.Color = 1-[0.8 0.8 0.8];
        ax.XColor = 1-[0.8 0.8 0.8];
        ax.YColor = 1-[0.8 0.8 0.8];
        ax.ZColor = 1-[0.8 0.8 0.8];
        text_label = findall(ax, 'Type', 'text');
        for txt = text_label(:)'
            % If the text have the same color of the background change it accordingly
            if isnumeric(txt.BackgroundColor) && isnumeric(txt.Color) && sum(abs(txt.BackgroundColor - txt.Color)) == 0
                if ~ischar(txt.BackgroundColor) && all(txt.BackgroundColor < 0.5)
                    txt.Color = 1 - txt.Color;
                    txt.BackgroundColor = 1 - txt.BackgroundColor;
                end
            else
                if ~ischar(txt.Color) && all(txt.Color > 0.5)
                    txt.Color = 1 - txt.Color;
                end
                if ~ischar(txt.BackgroundColor) && all(txt.BackgroundColor < 0.5)
                    txt.BackgroundColor = 1 - txt.BackgroundColor;
                end
            end
        end
    end
    text_label = findall(gcf,'Tag', 'm_grid_xticklabel');
    for txt = text_label(:)'
        txt.Color = 1-[0.8 0.8 0.8];
    end
    text_label = findall(gcf,'Tag', 'm_grid_yticklabel');
    for txt = text_label(:)'
        txt.Color = 1-[0.8 0.8 0.8];
    end
    text_label = findall(gcf,'Tag', 'm_ruler_label');
    for txt = text_label(:)'
        txt.Color = 1-[0.8 0.8 0.8];
    end
    legend = findall(gcf, 'type', 'legend');
    for lg = legend(:)'
        lg.Color = [1 1 1];
        lg.Title.Color = [0 0 0];
        lg.TextColor = 1-[0.8 0.8 0.8];
        lg.EdgeColor = [0.5 0.5 0.5];
    end
end
end
