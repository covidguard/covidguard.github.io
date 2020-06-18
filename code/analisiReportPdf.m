%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download report pdf
flag_download_1=0;
if flag_download_1    
    tim_curr = now;
    for k=1
        try
        mm=datestr(tim_curr-k,'mm');
        dd=datestr(tim_curr-k,'dd');
        yy=datestr(tim_curr-k,'yyyy');
        
        mm_1 = str2double(mm);
        dd_1 = str2double(dd);
       
        serverAddress='https://www.interno.gov.it';         
        websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_%s.%s.%s.pdf', serverAddress,dd,mm,yy),'timeout',1);
%         websave(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd), sprintf('%s/sites/default/files/modulistica/monitoraggio_serviz_controllo_giornaliero_dal_%d.%d.%s.pdf', serverAddress,dd_1,mm_1,yy),'timeout',1);
        movefile(sprintf('PDF_%s-%s-%s.PDF', yy,mm,dd),sprintf('%s/_json/Report_PDF',WORKroot),'f');
        catch
        end
    end
    
    % analise report pdf
    fileDir = dir(sprintf('%s/_json/Report_PDF/*.pdf',WORKroot));
    for i = size(fileDir,1)-2: size(fileDir,1)
        command = sprintf('cd %s/_json/Report_PDF && extractPDFText %s',WORKroot, fileDir(i).name);
        system(command);
    end


end



fileDir = dir(sprintf('%s/_json/Report_PDF/*.txt',WORKroot));

controlli=struct;
controlli.personeControllate=NaN(size(fileDir,1),1);
controlli.personeDenunciateExArt650=NaN(size(fileDir,1),1);
controlli.personeDenunciateExArt495496=NaN(size(fileDir,1),1);
controlli.personeDenunciateExArt260=NaN(size(fileDir,1),1);
controlli.personeSanzionate=NaN(size(fileDir,1),1);
controlli.eserciziCommercialiControllati=NaN(size(fileDir,1),1);
controlli.titolariEserciziCommercialiDenunciati=NaN(size(fileDir,1),1);
controlli.chiusuraProvvisoriaAttivita=NaN(size(fileDir,1),1);
controlli.chiusuraAttivita=NaN(size(fileDir,1),1);

for i = 16: size(fileDir,1)
    filename=sprintf('%s/_json/Report_PDF/%s', WORKroot, fileDir(i).name);
    fid       = fopen(filename, 'rt');
    file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
    fclose(fid);
    file_scan                             = file_scan{1};
    
    filename_i = fileDir(i).name;    
    controlli.time(i,1)=datenum(sprintf('%s-%s-%s', filename_i(5:8),filename_i(10:11), filename_i(13:14)));    
    pattern = 'PERSONE CONTROLLATE';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            idx1=k;
            k=k+1;
            while isempty(char(file_scan(k))) || strcmp(char(file_scan(k)),' ')
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.personeControllate(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end
    
    pattern = 'PERSONE DENUNCIATE EX ART. 650 C.P. ';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            idx1=k;
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.personeDenunciateExArt650(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end
    
    pattern = 'PERSONE SANZIONATE';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.personeSanzionate(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end    
    
    pattern = 'PERSONE DENUNCIATE EX ART. 495 E 496';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.personeDenunciateExArt495496(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end   
    
    pattern = 'ESERCIZI COMMERCIALI CONTROLLATI';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.eserciziCommercialiControllati(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end   
    
    pattern = 'ATTIVITA’ O ESERCIZI CONTROLLATI';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.eserciziCommercialiControllati(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end       
    
    
    pattern = 'TITOLARI ESERCIZI COMMERCIALI DENUNCIATI';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.titolariEserciziCommercialiDenunciati(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end       
    
    pattern = 'TITOLARI DI ATTIVITA’ O ESERCIZI SANZIONATI';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.titolariEserciziCommercialiDenunciati(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end  
    
    
    pattern = 'PERSONE DENUNCIATE ex art. 260';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.personeDenunciateExArt260(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end         
    
    
    pattern = 'CHIUSURA PROVVISORIA DI ATTIVITA';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.chiusuraProvvisoriaAttivita(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end      
    
     pattern = 'CHIUSURA DI ATTIVITA’ O ESERCIZI';
    k=0;
    while k<size(file_scan,1)
        k=k+1;
        idx=strfind(char(file_scan(k)), pattern);        
        if idx>0
            k=k+1;
            while isnan(str2double(char(file_scan(k)))+1)
                k=k+1;
            end
            temp = char(file_scan(k));
            temp=strrep(temp,'.','');
            controlli.chiusuraAttivita(i,1)=str2double(temp);
            k=size(file_scan,1);            
        end        
    end         
end


%% plot controllo persone
h = figure;
set(h,'NumberTitle','Off');
% title('Andamento epidemia per Regioni: casi totali')
set(h,'Position',[26 79 967 603]);
ax1=subplot(1,2,1);

labels = {'Denunciate','Sanzionate','Regolari'};

x1=[sum(controlli.personeDenunciateExArt650(isfinite(controlli.personeDenunciateExArt650))) + ...
    sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496))) + ...
    sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260))) ...
    sum(controlli.personeSanzionate(isfinite(controlli.personeSanzionate))) ... 
    sum(controlli.personeControllate(isfinite(controlli.personeControllate))) - sum(controlli.personeDenunciateExArt650(isfinite(controlli.personeDenunciateExArt650))) ...
    - sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496)))- sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260)))-  ...
    sum(controlli.personeSanzionate(isfinite(controlli.personeSanzionate)))];

x1=[sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496))) + ...
    sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260))) ...
    sum(controlli.personeSanzionate(isfinite(controlli.personeSanzionate))) ... 
    sum(controlli.personeControllate(isfinite(controlli.personeControllate))) ...
    - sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496)))- sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260)))-  ...
    sum(controlli.personeSanzionate(isfinite(controlli.personeSanzionate)))];


p1 = pie(ax1,x1, [1 1 0], labels);

p1(2).HorizontalAlignment='left';
p1(4).HorizontalAlignment='right';
colormap([0 0 0.7; 1 0 0 ; 0 0.7 0])

p1(2).String = sprintf('%s\n(%d - %.2f%%)',p1(2).String, x1(1), x1(1)/sum(x1)*100); 
p1(4).String = sprintf('%s\n(%d - %.2f%%)',p1(4).String, x1(2), x1(2)/sum(x1)*100); 
p1(6).String = sprintf('%s\n(%d - %.2f%%)',p1(6).String, x1(3), x1(3)/sum(x1)*100); 

ax2=subplot(1,2,2);
labels2 = {'Ex Art 650','Ex Art 495-496','Ex Art 260'};
labels2 = {'Ex Art 495-496','Ex Art 260'};
x2 = [sum(controlli.personeDenunciateExArt650(isfinite(controlli.personeDenunciateExArt650)))...
    sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496))) ...
    sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260)))];
x2 = [sum(controlli.personeDenunciateExArt495496(isfinite(controlli.personeDenunciateExArt495496))) ...
    sum(controlli.personeDenunciateExArt260(isfinite(controlli.personeDenunciateExArt260)))];

p2 = pie(ax2, x2, [1 1], labels2);
% colormap([1 0 0.7; 1 0.7 0 ; 0 0.7 0.4])

p2(2).HorizontalAlignment='right';
p2(4).HorizontalAlignment='left';
% p2(6).HorizontalAlignment='right';

p2(2).String = sprintf('%s\n(%d - %.1f%%)',p2(2).String,x2(1), x2(1)/sum(x2)*100); 
p2(4).String = sprintf('%s\n(%d - %.1f%%)',p2(4).String,x2(2), x2(2)/sum(x2)*100); 
% p2(6).String = sprintf('%s\n(%d - %.1f%%)',p2(6).String,x2(3), x2(3)/sum(x2)*100); 

% a=title(ax1, 'Controlli persone fisiche'); 
% l=legend('Ex Art 650: Inosservanza dei provvedimenti dell''Autorità', 'Ex Art 495-496: Falsa attestazione o dichiarazione a P.U.', 'Ex Art 260: inosservanza del divieto assoluto di allontanarsi dalla propria abitazione');
l=legend('Ex Art 495-496: Falsa attestazione o dichiarazione a P.U.', 'Ex Art 260: inosservanza del divieto assoluto di allontanarsi dalla propria abitazione');

set(l,'Position',[0.486728734556703 0.0782200240706659 0.501551175561292 0.0878938616409427]);
% 

annotation(gcf,'textbox',[0.355271085832472 0.940298507462687 0.314842668045501 0.04638],...
    'String',{sprintf('Controlli sulla popolazione (al %s)', datestr(controlli.time(end),'dd/mm/yyyy'))},...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Verdana',...
    'FitBoxToText','off');

datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://www.interno.gov.it/']},...
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
    [0.141206970010343 0.840796019900498 0.314842668045501 0.0463800000000001],...
    'String',{'Controlli'},...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName','Verdana',...
    'FitBoxToText','off');

annotation(gcf,'textbox',...
    [0.57760821096174 0.840796019900498 0.314842668045501 0.0463800000000001],...
    'String',{'Denunce'},...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',10,...
    'FontName','Verdana',...
    'FitBoxToText','off');

print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/controlli_popolazione.PNG']);
close(gcf);



%% plot controllo persone
h = figure;
set(h,'NumberTitle','Off');
% title('Andamento epidemia per Regioni: casi totali')
set(h,'Position',[26 79 967 603]);
labels = {'Denunciate','Sanzionate','Regolari'};
title(sprintf(['Denunce: persone \\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

b=bar([controlli.personeDenunciateExArt495496, controlli.personeDenunciateExArt260],'stacked');
set(b(1),'FaceColor',[0.8 0 0]);
set(b(2),'FaceColor',[0.200000002980232 0.600000023841858 1]);

y_lim=ylim;

set(gca,'XTick',16:length(controlli.time));
set(gca,'XTickLabel',datestr(controlli.time(16:end),'dd mmm'));
set(gca,'XLim',[15.5,size(controlli.time,1)+0.5]);
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax=gca;

ylabel('Numero denunce', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ax(1) = gca;
set(ax, 'FontName', 'Verdana');
ylim(y_lim);

l=legend([b(1),b(2)],'Persone Denunciate Ex Art495-496: falsa attestazione o dichiarazione a P.U.','personeDenunciate Ex Art 260: inosservanza del divieto assoluto di allontanarsi dalla propria abitazione');
set(l,'Location','SouthOutside')

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://www.interno.gov.it/']},...
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/controlli_persone_daily.PNG']);
close(gcf);




%% plot controllo persone
h = figure;
set(h,'NumberTitle','Off');
% title('Andamento epidemia per Regioni: casi totali')
set(h,'Position',[26 79 967 603]);
labels = {'Denunciate','Sanzionate','Regolari'};
title(sprintf(['Andamento denunce/controlli: persone \\fontsize{5}\n ']))


set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
grid on
hold on

b=[];
b(1)=plot(controlli.time(16:end), controlli.personeDenunciateExArt495496(16:end)./controlli.personeControllate(16:end)*10000,'LineWidth', 2.0,'color',[0.8 0 0]);
b(2)=plot(controlli.time(16:end), controlli.personeDenunciateExArt260(16:end)./controlli.personeControllate(16:end)*10000,'LineWidth', 2.0,'color',[0.200000002980232 0.600000023841858 1]);


y_lim=ylim;
xlim([controlli.time(16),controlli.time(end)]);
get(gca,'Xtick');
set(gca,'XTick',controlli.time(16:end));
set(gca,'XTickLabel',datestr(controlli.time(16:end),'dd mmm'));
set(gca,'XTickLabelRotation',53,'FontSize',6.5);

ylabel('Numero denunce ogni 100.000 controlli', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
ax(1) = gca;
set(ax, 'FontName', 'Verdana');
ylim(y_lim);

l=legend([b(1),b(2)],'Persone Denunciate Ex Art495-496: falsa attestazione o dichiarazione a P.U.','personeDenunciate Ex Art 260: inosservanza del divieto assoluto di allontanarsi dalla propria abitazione');
set(l,'Location','SouthOutside')

% overlap copyright info
datestr_now = datestr(now);
annotation(gcf,'textbox',[0.72342 0.00000 0.2381 0.04638],...
    'String',{['Fonte: https://www.interno.gov.it/']},...
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


print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/controlli_persone_daily_percentuale.PNG']);
close(gcf);