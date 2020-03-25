function export2Plotly(fh, flag_offline, new_rate)
    % Export figure on plotly managing time axes
    %
    % SYNTAX
    %   export2Plotly(fig_handle, flag_offline, new_rate);
    %
    % NOTE
    %   to use this function you must install plotly API:
    %       https://plot.ly/matlab/getting-started/#installation
    
    
    if nargin < 3
        new_rate = [];
    end
    
    if nargin < 2 || isempty(flag_offline)
        flag_offline = true;
    end
    
    if nargin > 1 && ~isempty(fh)
        figure(fh);
    else
        fh = gcf;
    end
    
    % Prepare times for plotly
    ax = findall(fh, 'type', 'axes');
    last = struct();
    last.mode = {};
    for i = 1 : numel(ax)
        last.mode{i} = ax(i).XTickLabelMode;
        ax(i).XTickLabelMode = 'auto';
    end
    
    line = findall(fh, 'type', 'line');
    last.flag_date = [];
    for i = 1 : numel(line)
        if ~isempty(new_rate)
            time = line(i).XData * 86400;
            rate = median(round(diff(time), 3));
            [~, id_ok] = ismember((unique(round(time ./ new_rate)) .* new_rate), (round(time ./ (2*rate)) .* (2*rate)));
            line(i).XData = line(i).XData(noZero(id_ok));
            line(i).YData = line(i).YData(noZero(id_ok));
        end
        
        if all(line(i).XData > datenum('1970-01-01') & line(i).XData < datenum('2070-01-01'))
            line(i).XData = convertDate(line(i).XData);
            last.flag_date(i) = true;
        else
            last.flag_date(i) = false;
        end
    end
    
    % Export to plotly
    try
        fig_name = fh.UserData.fig_name;
    catch
        fig_name = 'temp_unknown';
    end
    plotlyfig = fig2plotly(gcf, 'filename', fig_name, 'offline', flag_offline);
    
    if any(last.flag_date)
        for i = 1 : numel(ax)
            plotlyfig.layout.(sprintf('xaxis%d', i)).type = 'date';
        end
        plotlyfig.PlotOptions.FileOpt = 'overwrite';
        plotly(plotlyfig);
    end
    
    for i = 1 : numel(line)
        if last.flag_date(i)
            funToMatTime = @(date) (date/(1000*60*60*24) + datenum(1969,12,31,19,00,00));
            line(i).XData = funToMatTime(line(i).XData);
        end
    end    
end
