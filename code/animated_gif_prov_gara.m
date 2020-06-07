% function animated_gif_reg(path_mat_file,gif_filename)
function animated_gif_prov_gara(data,pop,regions)

% data=load(path_mat_file);
filename = 'Andamento_Province_Race.gif';


k=find(strcmp(data.denominazione_provincia,'Forlì-Cesena'));
data.denominazione_provincia(k)=cellstr('Forli-Cesena');

province_tot=unique(data.denominazione_provincia);
province_tot=setdiff(province_tot,'In fase di definizione/aggiornamento');

day_list = unique(data.data);
x_data = nan(numel(day_list), size(province_tot,1));


for prov=1:size(province_tot,1)
    provincia = char(province_tot(prov,1));
    index = find(strcmp(data.denominazione_provincia,cellstr(provincia)));    
    sigla_prov=data.sigla_provincia(index(end));
    idx_pop=find(strcmp(pop.sigla,sigla_prov));
    x_data(:,prov) = data.totale_casi(index)./pop.number(idx_pop)*100000;
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
days = (datenum(unique(data.data)));
ylabel('Totale casi / 100.000 ab.', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize', 7);
set(gcf,'color','w');

ann=annotation(gcf,'textbox',[0.721351747673216 0.135986733001659 0.2381 0.0463800000000001],...
    'String',datestr(days(1), 'dd mmm'),...
    'HorizontalAlignment','center',...
    'FontSize',20,...
    'FontName','Verdana',...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0.5 .5 0.5]);

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


n_prov=30;

colors_prov=[];
for k=1:size(province_tot,1)
    colors_prov(k,:)=  Cmap.getColor(k, size(province_tot,1)) ;
end
for i=1:size(y_data_int,1)
    i
    [x_data_i, idx_i] = sort(y_data_int(i,:), 'descend');
    
    prov_worst = province_tot(idx_i);
    a=barh([1 2],[(x_data_i(n_prov:-1:1)); (x_data_i(n_prov:-1:1))]);
    grid minor
    ann.String = datestr(x_data_int(i), 'dd mmm');

    for k=1:n_prov
        idx_col=find(strcmp(prov_worst(k),province_tot));
        set(a(n_prov-k+1),'FaceColor',colors_prov(idx_col,:));
    end
    
    hT=[];              % placeholder for text object handles
    for k=1:length(a)  % iterate over number of bar objects
        hT=[hT,text(a(k).YData+5,a(k).XData+a(k).XOffset,char(prov_worst(length(a) -k+1)), ...
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










end