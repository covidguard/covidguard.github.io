if ismac
    folder_maps = '../slides/img/mappe/nuove';
else
    folder_maps = 'C:\Temp\Repo\covidguard\slides\img\mappe\nuove';
end
mapsList = dir(sprintf('%s/prov*n.png', folder_maps));

filename = 'mappaProv.gif';
fh = figure;
fh.Units = 'pixels';
lgn = imread(fullfile(folder_maps, 'legenda.png'));
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

ax = subplot('position', [0, 0, 0.1 , 0.1]);
ax.Units = 'pixels';
ax.Position = [400, 80, 130, 302];
Units = 'pixels';
image(lgn(50:end, :, :));
ax.Box = 'off';
ax.XColor = [1 1 1];
ax.YColor = [1 1 1];

% Capture the plot as an image
%set(gca,'position',[0 0 1 1],'units','normalized')
%set(gca,'nextplot','replacechildren','visible','on')

l = annotation(gcf,'textbox',...
    [0.140285714285714 0.114285714285714 0.190071428571429 0.0714285714285715],...
    'String','DATA',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Helvetica',...
    'FitBoxToText','off');

annotation(gcf,'textbox',...
    [0.715 0.1 0.4 0.1],...
    'String','http://covidguard.github.io',...
    'LineStyle','none',...
    'FontSize',10,...
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
