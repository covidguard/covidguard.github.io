folder_maps = 'C:\Temp\Repo\covidguard\slides\img\mappe\nuove';
mapsList = dir(sprintf('%s/prov*n.png', folder_maps));

filename = 'mappaProv.gif';
for i = 1 : size(mapsList,1)
    imag = imread(sprintf('%s/%s', folder_maps, mapsList(i).name));
    im = image(imag);
    axis equal
    hold on
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    
    ye = str2double(mapsList(i).name(5:8));
    mo = str2double(mapsList(i).name(9:10));
    dd = str2double(mapsList(i).name(11:12));
    
    
    
    



    % Capture the plot as an image
    %set(gca,'position',[0 0 1 1],'units','normalized')
    %set(gca,'nextplot','replacechildren','visible','on')

    
    l = annotation(gcf,'textbox',...
        [0.140285714285714 0.114285714285714 0.190071428571429 0.0714285714285715],...
        'String',{datestr(datenum([ye,mo,dd]),'dd mmm')},...
        'LineStyle','none',...
        'FontSize',14,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    frame = getframe(h);
    im = frame2im(frame);
    
    
    drawnow
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if i == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',1,'DelayTime',0.15);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.15);
    end
    
    delete(l);
end

