% function animated_gif_reg(path_mat_file,gif_filename)
function animated_gif_reg(data)
    
    
    
% data=load(path_mat_file);
filename = 'out.gif';

regioni_tot = unique(data.dataReg.denominazione_regione);
y_data = zeros(length(data.dataReg.codice_regione)/size(regioni_tot,1)-6,size(regioni_tot,1));
x_data = zeros(length(data.dataReg.codice_regione)/size(regioni_tot,1)-6,size(regioni_tot,1));
for reg=1:size(regioni_tot,1)
    regione = char(regioni_tot(reg,1));
    index = find(strcmp(data.dataReg.denominazione_regione,cellstr(regione)));
    y_data(:,reg) = data.dataReg.totale_casi(index(7:end));
    y_data_tot = data.dataReg.totale_casi(index);
    
    for q=7:size(y_data_tot,1)
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
xlim([-0.1 1.1])
rectangle('Position',[0.6 100 0.4 110000])
rectangle('Position',[0 70 0.2 110000])
%markers = {'+','o','*','.','x','v','>'};
colors={[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.3010 0.7450 0.9330],[0.6350 0.0780 0.1840]};


x_data_int=[];
y_data_int=[];
%interpolation piecewise
for i = 1:size(x_data,1)-1
    [~, ~, ~, x_data_int(:,i)] = splinerMat(1:size(x_data,1),x_data(:,i),4,0,1:0.2:size(x_data,1));
    [~, ~, ~, y_data_int(:,i)] = splinerMat(1:size(x_data,1),y_data(:,i),4,0,1:0.2:size(x_data,1));
end

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

x_data=x_data_int;
y_data=y_data_int;

for n = 1:size(x_data,1)
    % Draw plot for y = x.^n
    x = x_data(n,:);
    y = y_data(n,:);
    hold off
    l=1;
    delete(findall(gcf,'type','text'))
    for q=1:length(x)
        %plot(x(q)',y(q)',markers{l},'w')
        if q==12 || q==13
            text(x(q),y(q),regioni_tot{q}(6:8),'Color', colors{l},'fontsize',8,'FontWeight','bold')
        else
            text(x(q),y(q),regioni_tot{q}(1:3),'Color', colors{l},'fontsize',8)
            hold on
            l=l+1;
            if l==7
                l=1;
            end
        end
    end
    %legend(regioni_tot,'Location', 'NorthEastOutside'
    grid on
    %title()
    text(0.6, 260000, {'alto tasso di crescita e','  alto numero di casi'},'Color','k','fontsize',10)
    text(0, 260000, {'epidemia sotto','   controllo'},'Color','k','fontsize',10)
    ylabel('Numero di casi totali')
    xlabel('incremento settimanale di casi totali')
    set(gcf,'color','w');
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
        imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.01);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.01);
    end
end
close all

end