% function animated_gif_reg(path_mat_file,gif_filename)
function animated_gif_reg_Andrea_fase2(data,regions)
    
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
        filename = ['Andamento_Regioni_fase2_',regions,'.gif'];
    end
catch
end




y_data = zeros(length(data.dataReg.codice_regione)/size(regioni_tot,1)-6-1,size(regioni_tot,1));
x_data = zeros(length(data.dataReg.codice_regione)/size(regioni_tot,1)-6-1,size(regioni_tot,1));



for reg=1:size(regioni_tot,1)  
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(data.dataReg.denominazione_regione,cellstr(regione)));
    y_data(:,reg) = diff(data.dataReg.totale_casi(index(7:end)));
    y_data_tot = diff(data.dataReg.totale_casi(index));
    
    for q=8:size(y_data_tot,1)
        if y_data_tot(q)==0
            x_data(q-6,reg) = 0;
        elseif (y_data_tot(q)-y_data_tot(q-6))<0
            x_data(q-6,reg) = (y_data_tot(q-1)-y_data_tot(q-1-6))/y_data_tot(q-1);
        else
            x_data(q-6,reg) = (y_data_tot(q)-y_data_tot(q-6))/y_data_tot(q);
        end
    end
end

h = figure;
set(h,'NumberTitle','Off');
set(h,'Position',[26 79 967 603]);
grid minor
axis tight manual % this ensures that getframe() returns a consistent size
set(gca,'yscale','log')
ylim([1 1000000])
xlim([-110 110])
rectangle('Position',[60 100 40 110000])
rectangle('Position',[0 70 20 110000])
%markers = {'+','o','*','.','x','v','>'};
colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};
colors={};
for k=1:size(regioni_tot,1)
    colors{k}=Cmap.getColor(k, size(regioni_tot,1));
end

x_data_int=[];
y_data_int=[];

x_data(x_data==inf | x_data==-inf)=nan;
%interpolation piecewise
tmp = x_data;
tmp(tmp == 0) = 1;
step = 0.2;
for i = 1:size(x_data,2)
    [~, ~, ~, x_data_int(:,i)] = splinerMat(1:size(x_data,1),tmp(:,i),2,0,1:step:size(x_data,1));
    [~, ~, ~, y_data_int(:,i)] = splinerMat(1:size(x_data,1),y_data(:,i),2,0,1:step:size(x_data,1));
end
clear tmp

% 
% 
% n_fit=5;
% x_data_int = NaN((size(x_data,1)-1)*n_fit,size(x_data,2));
% y_data_int = NaN((size(y_data,1)-1)*n_fit,size(y_data,2));
% for i = 1:size(x_data,1)-1
%     for j = 1:size(x_data,2)
%         x_data_int((i-1)*n_fit+1:(i)*n_fit,j)= ((x_data(i+1,j)-x_data(i,j))/n_fit*(0:n_fit-1)+x_data(i,j));
%         y_data_int((i-1)*n_fit+1:(i)*n_fit,j)= ((y_data(i+1,j)-y_data(i,j))/n_fit*(0:n_fit-1)+y_data(i,j));
%     end
%     
% end
% x_data_int(x_data_int <= 0) = 0;
% y_data_int(y_data_int <= 1) = nan;
days = (datenum(unique(data.dataReg.data)));
days = floor(interp1q((1:size(days,1))', days, 7 + (1:step:size(x_data,1))'));

%%
x_data=x_data_int;
y_data=y_data_int;

% Init labels
l=1;
x = x_data(1,:);
y = y_data(1,:);
clear lbl;
hdate = text(-8, 1.5, datestr(days(1), 'dd mmm'), 'Color', [0.5 0.5 0.5],'fontsize',20,'FontWeight','bold');
hold on;
fontsize=10;
for q=1:length(x)
    %plot(x(q)',y(q)',markers{l},'w')
    try
        if ~strcmp(regions,'A')
            lbl(q) = text(x(q) * 100,y(q), upper(regioni_tot{q}(:))','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
        else
            if strcmp('P.A. Bolzano',regioni_tot{q})
                lbl(q) = text(x(q) * 100,y(q), 'BOLZ','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
            elseif strcmp('P.A. Trento',regioni_tot{q})
                lbl(q) = text(x(q) * 100,y(q), 'TREN','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
            elseif strcmp('Valle d Aosta',regioni_tot{q})
                lbl(q) = text(x(q) * 100,y(q), 'VDAO','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
            else
                lbl(q) = text(x(q) * 100,y(q), upper(regioni_tot{q}(1:4)),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
            end
        end
    catch
        if strcmp('P.A. Bolzano',regioni_tot{q})
            lbl(q) = text(x(q) * 100,y(q), 'BOLZ','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
        elseif strcmp('P.A. Trento',regioni_tot{q})
            lbl(q) = text(x(q) * 100,y(q), 'TREN','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
        elseif strcmp('Valle d Aosta',regioni_tot{q})
            lbl(q) = text(x(q) * 100,y(q), 'VDAO','Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
        else
            lbl(q) = text(x(q) * 100,y(q), upper(regioni_tot{q}(1:4)),'Color', colors{l},'fontsize',fontsize,'FontWeight','bold');
        end
    end
    l=l+1;
    if l==size(colors,2)
        l=1;
    end
end

grid on
text(60, 260000, {'alto tasso di crescita e','  alto numero di casi'},'Color','k','fontsize',14)
text(0, 260000, {'epidemia sotto','   controllo'},'Color','k','fontsize',14)
ylabel('Numero di casi totali')
xlabel('Incremento settimanale percentuale di casi totali')
set(gcf,'color','w');

fh = gcf; beautifyFig(fh);
plot(x_data(:,9),y_data(:,9),'-r');
for n = 1:size(x_data,1)
    % Draw plot for y = x.^n
    x = x_data(n,:)*100;
    y = y_data(n,:);
    
    
    hold off
    hdate.String = datestr(days(n), 'dd mmm');
    for q=1:length(x)
        %plot(x(q)',y(q)',markers{l},'w')
        lbl(q).Position(1:2) = [x(q) * 100, y(q)];
    end
    %legend(regioni_tot,'Location', 'NorthEastOutside'
    %title()
    %title('')
    drawnow
    % Capture the plot as an image
    %set(gca,'position',[0 0 1 1],'units','normalized')
    %set(gca,'nextplot','replacechildren','visible','on')
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
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
