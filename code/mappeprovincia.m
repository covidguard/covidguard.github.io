if ismac
    folder_maps = '../slides/img/mappe800x1040';
else
    folder_maps = 'C:\Temp\Repo\covidguard\slides\img\mappe800x1040';
    folder_maps = 'C:\Temp\Repo\covidguard\slides\img\mappe_var';
end
mapsList = dir(sprintf('%s/prov*n.png', folder_maps));
mapsList = dir(sprintf('%s/prov*.png', folder_maps));


filename = 'mappaProv.gif';
fh = figure;
fh.Units = 'pixels';
% lgn = imread(fullfile(folder_maps, 'legenda.png'));
lgn = imread(fullfile(folder_maps, 'legenda_var.png'));
figure(fh); clf;
i = 1;
imag = imread(sprintf('%s/%s', folder_maps, mapsList(i).name));
im = image(imag(:,:,:));
axis equal
hold on
xlim(xlim()+100);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
ax = gca;
ax.Box = 'off';
ax.XColor = [1 1 1];
ax.YColor = [1 1 1];
fh.Color = [1 1 1];
fh.Position(3:4) = [1000 700];

ax = subplot('position', [0, 0, 0.1 , 0.1]);
ax.Units = 'pixels';
ax.Position = [715, 290, 130, 302];

Units = 'pixels';
image(lgn(50:end, :, :));
ax.Box = 'off';
ax.XColor = [1 1 1];
ax.YColor = [1 1 1];

% Capture the plot as an image
%set(gca,'position',[0 0 1 1],'units','normalized')
%set(gca,'nextplot','replacechildren','visible','on')

l = annotation(gcf,'textbox',...
    [0.24 0.13 0.19 0.07],...
    'String','DATA',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Helvetica',...
    'FitBoxToText','off');

c = annotation(gcf,'textbox',...
    [0.715 0.32 0.4 0.1],...
    'String','http://covidguard.github.io',...
    'LineStyle','none',...
    'FontSize',10,...
    'FontName','Helvetica',...
    'FitBoxToText','off');

delete(a)
a = annotation(gcf,'textbox',...
    [0.715 0.795 0.2 0.1],...
    'String', sprintf('Casi totali /\n100000 abitanti'), ...
    'LineStyle','none',...
    'FontSize',13,...
    'FontName','Helvetica',...
    'FitBoxToText','off');
drawnow
for i = 1 : size(mapsList,1)
    imag = imread(sprintf('%s/%s', folder_maps, mapsList(i).name));
    im.CData = imag;
    
    ye = str2double(mapsList(i).name(5:8));
    mo = str2double(mapsList(i).name(9:10));
    dd = str2double(mapsList(i).name(11:12));

    l.String  = {datestr(datenum([ye,mo,dd]),'dd mmm')};
    
    frame = getframe(fh);
    im_frame = frame2im(frame);
    
    drawnow
    [imind,cm] = rgb2ind(im_frame,256);
%     imind = imind(1:1250, 450:1700); % cut the bottom
    % Write to the GIF File
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.40);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.40);
    end    
end

for i = 1 : 8
    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.40);
end
