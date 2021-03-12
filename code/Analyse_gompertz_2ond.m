% if ismac
%     flag_download = false;
% else
%     flag_download = true;
% end
% 
% 
% %% -------------------------
% if ismac
%     WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
% else
%     WORKroot = sprintf('C:/Temp/Repo/covidguard');
% end
% % 
% % %% download json from server
% % if flag_download
% %     delete(sprintf('%s/_json/*.json',WORKroot))
% %     
% %     serverAddress = 'https://raw.githubusercontent.com';
% %     
% %     command = sprintf('wget --no-check-certificate %s/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-province.json', serverAddress);
% %     system(command);
% %     
% %     command = sprintf('wget --no-check-certificate %s/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni.json', serverAddress);
% %     system(command);
% %     
% %     movefile('dpc-covid19-ita-province.json',sprintf('%s/_json',WORKroot),'f');
% %     movefile('dpc-covid19-ita-regioni.json',sprintf('%s/_json',WORKroot)),'f';
% % end
% 
% 
% %% load population
% %% ---------------
% filename = fullfile(WORKroot, '_json', 'popolazione_province.txt');
% [pop.id, pop.name, pop.number, pop.perc, pop.superf, pop.numCom, pop.sigla]=textread(filename,'%d%s%d%f%%%d%d%s','delimiter',';');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Regioni
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% filename = sprintf('%s/_json/dpc-covid19-ita-regioni.json',WORKroot);
% fid       = fopen(filename, 'rt');
% file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
% fclose(fid);
% file_scan                             = file_scan{1};
% file_scan=char(file_scan);
% 
% json_oneRaw='';
% json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
% for i=1:size(file_scan,1)
%     json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
%     %     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
% end
% dataReg = decodeJSON1(json_oneRaw);
% dataReg.dataa = char(dataReg.data);
% dataReg.dataa(:,11)=' ';
dataReg.data=cellstr(dataReg.dataa);
regioni_tot = unique(dataReg.denominazione_regione);
% 



timeTot_datenum=datenum(unique(dataReg.data));
id_inizio2ondata=215;
id_inizio2ondata=305;


%% ITALIA
italia = struct;
italia.datanum=timeTot_datenum;
italia.totale_casi = [];
italia.nuovi_positivi = [];

dataReg.datanum=datenum(dataReg.data);
for k = 1:size(timeTot_datenum,1)
    index = find(dataReg.datanum==timeTot_datenum(k));
    italia.totale_casi(k)=sum(dataReg.totale_casi(index));
    italia.nuovi_positivi(k)=sum(dataReg.nuovi_positivi(index));
    italia.ti(k)=sum(dataReg.terapia_intensiva(index));
    italia.deceduti(k)=sum(dataReg.deceduti(index));
    italia.ricoverati(k)=sum(dataReg.ricoverati_con_sintomi(index));
end

for k=8:size(timeTot_datenum,1)
    italia.progSett(k)=(italia.totale_casi(k)-italia.totale_casi(k-7))/italia.totale_casi(k-7)*100;
    italia.progSett_n(k)=(italia.nuovi_positivi(k)-italia.nuovi_positivi(k-7))/italia.nuovi_positivi(k-7)*100;
    italia.progSett_terapia_intensiva(k)=(italia.ti(k)-italia.ti(k-7))/italia.ti(k-7)*100;
    italia.progSett_deceduti(k)=(italia.deceduti(k)-italia.deceduti(k-7))/italia.deceduti(k-7)*100;
    italia.progSett_ricoverati(k)=(italia.ricoverati(k)-italia.ricoverati(k-7))/italia.ricoverati(k-7)*100;
end

regione='Italia';

datetickFormat = 'dd mmm';
figure;
id_f = gcf;

set(id_f, 'Name', [regione ': incrementi settimanali']);
title(sprintf([regione ': incrementi settimanali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on
subplot(2,2,1)
grid on
hold on
inc = round(size(timeTot_datenum,1)-150)/18;
a=bar(timeTot_datenum,italia.progSett);
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale casi totali');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);

subplot(2,2,2)
grid on
hold on
a=bar(timeTot_datenum,italia.progSett_ricoverati);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale ricoverati con sintomi');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);

subplot(2,2,3)
grid on
hold on
a=bar(timeTot_datenum,italia.progSett_terapia_intensiva);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale terapie intensive');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);

subplot(2,2,4)
grid on
hold on
a=bar(timeTot_datenum,italia.progSett_deceduti);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale deceduti');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);


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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_increm_settimanale.PNG']);
close(gcf);













italia2O = struct;
italia2O.datanum=italia.datanum(id_inizio2ondata:end);
italia2O.totale_casi=italia.totale_casi(id_inizio2ondata:end);
italia2O.nuovi_positivi=italia.nuovi_positivi(id_inizio2ondata:end);


% totale casi
fout=fopen('testIn_gauss.txt','wt');
data6= italia2O.totale_casi' - italia2O.totale_casi(1);
for i=1:size(data6,1)
   fprintf(fout,'%f;%d\n',italia2O.datanum(i),data6(i,1));
end
fclose(fout);  
command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

data_interpTemp=data_interpTemp+italia2O.totale_casi(1);
    

datetickFormat = 'dd mmm';
figure;
id_f = gcf;
regione = 'Italia';
set(id_f, 'Name', [regione ': casi totali']);
title(sprintf([regione ': casi totali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t,a4'+italia2O.totale_casi(1),a5'+italia2O.totale_casi(1),[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum,italia.totale_casi,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>=italia.datanum(id_inizio2ondata)),data_interpTemp(t>=italia.datanum(id_inizio2ondata)),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_tot.PNG']);
close(gcf);



%% casi giornalieri
figure;
id_f = gcf;
regione = 'Italia';
set(id_f, 'Name', [regione ': casi giornalieri']);
title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t(2:end),diff(a4)',diff(a5)',[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum(2:end),diff(italia.totale_casi),'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>italia.datanum(id_inizio2ondata)+1),diff(data_interpTemp(t>=italia.datanum(id_inizio2ondata))),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_giorn.PNG']);
close(gcf);






























id_inizio2ondata=215;



%% LOMBARDIA
lombardia = struct;
lombardia.datanum=timeTot_datenum;
lombardia.totale_casi = [];
lombardia.nuovi_positivi = [];

regione = 'Lombardia';
% regione = 'Liguria';

dataReg.datanum=datenum(dataReg.data);
for k = 1:size(timeTot_datenum,1)
    index = find(dataReg.datanum==timeTot_datenum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
    lombardia.totale_casi(k)=sum(dataReg.totale_casi(index));
    lombardia.nuovi_positivi(k)=sum(dataReg.nuovi_positivi(index));
    lombardia.ti(k)=sum(dataReg.terapia_intensiva(index));
    lombardia.deceduti(k)=sum(dataReg.deceduti(index));
    lombardia.ricoverati(k)=sum(dataReg.ricoverati_con_sintomi(index));
end

for k=150:size(timeTot_datenum,1)
    lombardia.progSett(k)=(lombardia.totale_casi(k)-lombardia.totale_casi(k-7))/(lombardia.totale_casi(k-7)-lombardia.totale_casi(k-13))*100-100;
    lombardia.progSett_n(k)=(lombardia.nuovi_positivi(k)-lombardia.nuovi_positivi(k-7))/(lombardia.nuovi_positivi(k-7)-lombardia.nuovi_positivi(k-13))*100-100;
    lombardia.progSett_terapia_intensiva(k)=(lombardia.ti(k)-lombardia.ti(k-7))/(lombardia.ti(k-7)-lombardia.ti(k-13))*100-100;
    lombardia.progSett_deceduti(k)=(lombardia.deceduti(k)-lombardia.deceduti(k-7))/(lombardia.deceduti(k-7)-lombardia.deceduti(k-13))*100-100;
    lombardia.progSett_ricoverati(k)=(lombardia.ricoverati(k)-lombardia.ricoverati(k-7))/(lombardia.ricoverati(k-7)-lombardia.ricoverati(k-13))*100-100;
end


datetickFormat = 'dd mmm';
figure;
id_f = gcf;

set(id_f, 'Name', [regione ': incrementi settimanali']);
title(sprintf([regione ': incrementi settimanali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on
subplot(2,2,1)
grid on
hold on
inc = round(size(timeTot_datenum,1)-150)/18;
a=bar(timeTot_datenum,lombardia.progSett);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale casi totali');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);

subplot(2,2,2)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_ricoverati);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale ricoverati con sintomi');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);

subplot(2,2,3)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_terapia_intensiva);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale terapie intensive');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);

subplot(2,2,4)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_deceduti);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale deceduti');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);

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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_increm_settimanale.PNG']);
close(gcf);













id_inizio2ondata=335;
lombardia2O = struct;
lombardia2O.datanum=lombardia.datanum(id_inizio2ondata:end);
lombardia2O.totale_casi=lombardia.totale_casi(id_inizio2ondata:end);
lombardia2O.nuovi_positivi=lombardia.nuovi_positivi(id_inizio2ondata:end);


% totale casi
fout=fopen('testIn_gauss.txt','wt');
data6= lombardia2O.totale_casi' - lombardia2O.totale_casi(1);
for i=1:size(data6,1)
   fprintf(fout,'%f;%d\n',lombardia2O.datanum(i),data6(i,1));
end
fclose(fout);  
command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

data_interpTemp=data_interpTemp+lombardia2O.totale_casi(1);
    

datetickFormat = 'dd mmm';
figure;
id_f = gcf;

set(id_f, 'Name', [regione ': casi totali']);
title(sprintf([regione ': casi totali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t,a4'+lombardia2O.totale_casi(1),a5'+lombardia2O.totale_casi(1),[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum,lombardia.totale_casi,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>=lombardia.datanum(id_inizio2ondata)),data_interpTemp(t>=lombardia.datanum(id_inizio2ondata)),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_tot.PNG']);
close(gcf);



%% casi giornalieri
figure;
id_f = gcf;
regione = 'lombardia';
set(id_f, 'Name', [regione ': casi giornalieri']);
title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t(2:end),diff(a4)',diff(a5)',[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum(2:end),diff(lombardia.totale_casi),'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>lombardia.datanum(id_inizio2ondata)+1),diff(data_interpTemp(t>=lombardia.datanum(id_inizio2ondata))),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_giorn.PNG']);
close(gcf);










%% EMILIA
lombardia = struct;
lombardia.datanum=timeTot_datenum;
lombardia.totale_casi = [];
lombardia.nuovi_positivi = [];

regione = 'Emilia-Romagna';
% regione = 'Liguria';

dataReg.datanum=datenum(dataReg.data);
for k = 1:size(timeTot_datenum,1)
    index = find(dataReg.datanum==timeTot_datenum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
    lombardia.totale_casi(k)=sum(dataReg.totale_casi(index));
    lombardia.nuovi_positivi(k)=sum(dataReg.nuovi_positivi(index));
    lombardia.ti(k)=sum(dataReg.terapia_intensiva(index));
    lombardia.deceduti(k)=sum(dataReg.deceduti(index));
    lombardia.ricoverati(k)=sum(dataReg.ricoverati_con_sintomi(index));
end

for k=150:size(timeTot_datenum,1)
    lombardia.progSett(k)=(lombardia.totale_casi(k)-lombardia.totale_casi(k-7))/(lombardia.totale_casi(k-7)-lombardia.totale_casi(k-13))*100-100;
    lombardia.progSett_n(k)=(lombardia.nuovi_positivi(k)-lombardia.nuovi_positivi(k-7))/(lombardia.nuovi_positivi(k-7)-lombardia.nuovi_positivi(k-13))*100-100;
    lombardia.progSett_terapia_intensiva(k)=(lombardia.ti(k)-lombardia.ti(k-7))/(lombardia.ti(k-7)-lombardia.ti(k-13))*100-100;
    lombardia.progSett_deceduti(k)=(lombardia.deceduti(k)-lombardia.deceduti(k-7))/(lombardia.deceduti(k-7)-lombardia.deceduti(k-13))*100-100;
    lombardia.progSett_ricoverati(k)=(lombardia.ricoverati(k)-lombardia.ricoverati(k-7))/(lombardia.ricoverati(k-7)-lombardia.ricoverati(k-13))*100-100;
end


datetickFormat = 'dd mmm';
figure;
id_f = gcf;

set(id_f, 'Name', [regione ': incrementi settimanali']);
title(sprintf([regione ': incrementi settimanali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on
subplot(2,2,1)
grid on
hold on
inc = round(size(timeTot_datenum,1)-150)/18;
a=bar(timeTot_datenum,lombardia.progSett);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale casi totali');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);

subplot(2,2,2)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_ricoverati);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale ricoverati con sintomi');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);

subplot(2,2,3)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_terapia_intensiva);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale terapie intensive');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);

subplot(2,2,4)
grid on
hold on
a=bar(timeTot_datenum,lombardia.progSett_deceduti);
a.BarWidth=1;
set(gca,'XTick',timeTot_datenum(1:inc:end))
set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',90,'FontSize',6.5);
ylabel('% incremento settimanale deceduti');
xlim([timeTot_datenum(150) timeTot_datenum(end)]);
ylim([-1000 1000]);


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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_increm_settimanale.PNG']);
close(gcf);














lombardia2O = struct;
lombardia2O.datanum=lombardia.datanum(id_inizio2ondata:end);
lombardia2O.totale_casi=lombardia.totale_casi(id_inizio2ondata:end);
lombardia2O.nuovi_positivi=lombardia.nuovi_positivi(id_inizio2ondata:end);


% totale casi
fout=fopen('testIn_gauss.txt','wt');
data6= lombardia2O.totale_casi' - lombardia2O.totale_casi(1);
for i=1:size(data6,1)
   fprintf(fout,'%f;%d\n',lombardia2O.datanum(i),data6(i,1));
end
fclose(fout);  
command=sprintf('gomp_estim testIn_gauss.txt');system(command);
[t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_gomp_fit.txt','%f%f%f%f%f%f','delimiter',';');
% command=sprintf('gauss_estim testIn_gauss.txt');system(command);
% [t,data_interpTemp,a2,a3,a4,a5]=textread('testIn_gauss_fit.txt','%f%f%f%f%f%f','delimiter',';');

data_interpTemp=data_interpTemp+lombardia2O.totale_casi(1);
    

datetickFormat = 'dd mmm';
figure;
id_f = gcf;

set(id_f, 'Name', [regione ': casi totali']);
title(sprintf([regione ': casi totali\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t,a4'+lombardia2O.totale_casi(1),a5'+lombardia2O.totale_casi(1),[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum,lombardia.totale_casi,'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>=lombardia.datanum(id_inizio2ondata)),data_interpTemp(t>=lombardia.datanum(id_inizio2ondata)),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi totali', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_tot.PNG']);
close(gcf);



%% casi giornalieri
figure;
id_f = gcf;
regione = 'Emilia-Romagna';
set(id_f, 'Name', [regione ': casi giornalieri']);
title(sprintf([regione ': casi giornalieri\\fontsize{5}\n ']))
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[26 79 967 603]);
hold on
grid minor; grid on

grid on
hold on
shadedplot(t(2:end),diff(a4)',diff(a5)',[0.9 0.9 1]);  hold on
% d=plot(t,a3,'-b','LineWidth', 2.0,'color',[0.600000023841858 0.600000023841858 0.600000023841858]);
% c=plot(t,a2,'-g','LineWidth', 2.0,'color',[0.800000011920929 0.800000011920929 0]);

a=plot(timeTot_datenum(2:end),diff(lombardia.totale_casi),'.b','markersize',14,'color',[0 0.200000002980232 0.600000023841858]);
b=plot(t(t>lombardia.datanum(id_inizio2ondata)+1),diff(data_interpTemp(t>=lombardia.datanum(id_inizio2ondata))),'-r','LineWidth', 2.0,'color',[1 0.400000005960464 0.400000005960464]);



font_size=8;
ax = gca;
code_axe = get(id_f, 'CurrentAxes');
set(code_axe, 'FontName', 'Verdana');
set(code_axe, 'FontSize', font_size);
ylimi=get(gca,'ylim');
set(gca,'ylim',([0,ylimi(2)]));
ax.YTickLabel = mat2cell(ax.YTick, 1, numel(ax.YTick))';
ax.YTickLabel = num2str(str2double(ax.YTickLabel));

ylabel('Casi giornalieri', 'FontName', 'Verdana', 'FontWeight', 'Bold','FontSize',8);
datetick('x', datetickFormat, 'keepticks') ;
set(gca,'XTickLabelRotation',53,'FontSize',6.5);
ax.FontSize = font_size;
 
  
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
    
    

% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_',regione, '_extrap-casi_giorn.PNG']);
close(gcf);























































%% tabellone incrementi

start_t=300;
regione_list = (unique(dataReg.denominazione_regione));
dataReg.data_num=datenum(dataReg.data);
% for reg=1:size(unique(dataReg.codice_regione),1)
%     
%     regione_reg = struct;
%     regione_reg.datanum=timeTot_datenum;
%     regione_reg.totale_casi = [];
%     regione_reg.nuovi_positivi = [];
%     
%     regione = regione_list(reg);
%     
%     regione_reg.datanum=unique(datenum(dataReg.data));
%     for k = 1:size(regione_reg.datanum,1)
%         index = find(dataReg.data_num==regione_reg.datanum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
%         regione_reg.totale_casi(k)=sum(dataReg.totale_casi(index));
%         regione_reg.nuovi_positivi(k)=sum(dataReg.nuovi_positivi(index));
%         regione_reg.ti(k)=sum(dataReg.terapia_intensiva(index));
%         regione_reg.deceduti(k)=sum(dataReg.deceduti(index));
%         regione_reg.ricoverati(k)=sum(dataReg.ricoverati_con_sintomi(index));
%     end
%     
%     for k=start_t:size(regione_reg.datanum,1)
%         regione_reg.progSett(k)=(regione_reg.totale_casi(k)-regione_reg.totale_casi(k-7))/(regione_reg.totale_casi(k-7)-regione_reg.totale_casi(k-13))*100-100;
%         regione_reg.progSett_n(k)=(regione_reg.nuovi_positivi(k)-regione_reg.nuovi_positivi(k-7))/(regione_reg.nuovi_positivi(k-7)-regione_reg.nuovi_positivi(k-13))*100-100;
%         regione_reg.progSett_terapia_intensiva(k)=(regione_reg.ti(k)-regione_reg.ti(k-7))/(regione_reg.ti(k-7)-regione_reg.ti(k-13))*100-100;
%         regione_reg.progSett_deceduti(k)=(regione_reg.deceduti(k)-regione_reg.deceduti(k-7))/(regione_reg.deceduti(k-7)-regione_reg.deceduti(k-13))*100-100;
%         regione_reg.progSett_ricoverati(k)=(regione_reg.ricoverati(k)-regione_reg.ricoverati(k-7))/(regione_reg.ricoverati(k-7)-regione_reg.ricoverati(k-13))*100-100;
%     end
%     
% end

    



%% incremento casi 7-giorni /100000 abitanti
figure
datetickFormat = 'dd mmm';
id_f = gcf;
set(id_f, 'Name', ['Incrementi settimanali']);
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[73 82 1812 966]);

for reg=1:size(unique(dataReg.codice_regione),1)   
    regione_reg = struct;
    regione_reg.datanum=timeTot_datenum;
    regione_reg.totale_casi = [];
    regione_reg.nuovi_positivi = [];
    
    regione = regione_list(reg);
    
    regione_reg.datanum=unique(datenum(dataReg.data));
    for k = 1:size(regione_reg.datanum,1)
        index = find(dataReg.data_num==regione_reg.datanum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
        regione_reg.totale_casi(k)=sum(dataReg.totale_casi(index));
    end
    
    for k=start_t:size(regione_reg.datanum,1)
        regione_reg.progSett(k)=(regione_reg.totale_casi(k)-regione_reg.totale_casi(k-7));
    end
    regione_reg.progSett=regione_reg.progSett./pop.popolazioneRegioniPop(reg)*100000;

    subplot(7,3,reg)
    hold on
    grid on

    inc = round(size(regione_reg.datanum,1)-start_t)/25;
    
    a=bar(timeTot_datenum,regione_reg.progSett);
    a.BarWidth=1.1;
    set(gca,'XTick',timeTot_datenum(1:inc:end))
    set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    ylabel(regione);
    xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
    ylim([0,600]);
    
end
annotation(gcf,'textbox',...
    [0.377379690949227 0.955486542443065 0.349441501103753 0.0351966873706017],...
    'String','Incremento 7 giorni dei Nuovi Casi Positivi su 100.000 abitanti',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Tahoma',...
    'FitBoxToText','off');

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
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleNuoviPositivi7g.PNG']);
close(gcf);





%% nuovi positivi
figure
datetickFormat = 'dd mmm';
id_f = gcf;
set(id_f, 'Name', ['Incrementi settimanali']);
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[73 82 1812 966]);

for reg=1:size(unique(dataReg.codice_regione),1)   
    regione_reg = struct;
    regione_reg.datanum=timeTot_datenum;
    regione_reg.totale_casi = [];
    regione_reg.nuovi_positivi = [];
    
    regione = regione_list(reg);
    
    regione_reg.datanum=unique(datenum(dataReg.data));
    for k = 1:size(regione_reg.datanum,1)
        index = find(dataReg.data_num==regione_reg.datanum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
        regione_reg.totale_casi(k)=sum(dataReg.totale_casi(index));
    end
    
    for k=start_t:size(regione_reg.datanum,1)
        regione_reg.progSett(k)=(regione_reg.totale_casi(k)-regione_reg.totale_casi(k-7))/(regione_reg.totale_casi(k-7)-regione_reg.totale_casi(k-13))*100-100;
    end


    subplot(7,3,reg)
    hold on
    grid on

    inc = round(size(regione_reg.datanum,1)-start_t)/25;
    
    a=bar(timeTot_datenum,regione_reg.progSett);
    a.BarWidth=1.1;
    set(gca,'XTick',timeTot_datenum(1:inc:end))
    set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    ylabel(regione);
    xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
    ylim([-50,200]);
    
end
annotation(gcf,'textbox',...
    [0.377379690949227 0.955486542443065 0.349441501103753 0.0351966873706017],...
    'String','Incremento percentuale a 7 giorni dei Nuovi Casi Positivi',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Tahoma',...
    'FitBoxToText','off');

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
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleNuoviPositivi.PNG']);
close(gcf);





%terapie intensive
figure
datetickFormat = 'dd mmm';
id_f = gcf;
set(id_f, 'Name', ['Incrementi terapie intensive']);
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[73 82 1812 966]);

for reg=1:size(unique(dataReg.codice_regione),1)   
    regione_reg = struct;
    regione_reg.datanum=timeTot_datenum;
    regione_reg.totale_casi = [];
    regione_reg.nuovi_positivi = [];
    
    regione = regione_list(reg);
    
    regione_reg.datanum=unique(datenum(dataReg.data));
    for k = 1:size(regione_reg.datanum,1)
        index = find(dataReg.data_num==regione_reg.datanum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
        regione_reg.ti(k)=sum(dataReg.terapia_intensiva(index));
    end
    
    for k=start_t:size(regione_reg.datanum,1)
        regione_reg.progSett_terapia_intensiva(k)=(regione_reg.ti(k)-regione_reg.ti(k-7))/(regione_reg.ti(k-7)-regione_reg.ti(k-13))*100-100;
    end
    
 
    subplot(7,3,reg)
    hold on
    grid on

    inc = round(size(regione_reg.datanum,1)-start_t)/25;
    
    a=bar(timeTot_datenum,regione_reg.progSett_terapia_intensiva);
    a.BarWidth=1.1;
    set(gca,'XTick',timeTot_datenum(1:inc:end))
    set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    ylabel(regione);
    xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
    ylim([-500,1000]);
    
end
annotation(gcf,'textbox',...
    [0.377379690949227 0.955486542443065 0.349441501103753 0.0351966873706017],...
    'String','Incremento percentuale a 7 giorni delle T.I.',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Tahoma',...
    'FitBoxToText','off');

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
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleTI.PNG']);
close(gcf);





%ricoverati
figure
datetickFormat = 'dd mmm';
id_f = gcf;
set(id_f, 'Name', ['Incrementi ricoverati']);
set(gcf,'NumberTitle','Off');
set(gcf,'Position',[73 82 1812 966]);

for reg=1:size(unique(dataReg.codice_regione),1)   
    regione_reg = struct;
    regione_reg.datanum=timeTot_datenum;
    regione_reg.totale_casi = [];
    regione_reg.nuovi_positivi = [];
    
    regione = regione_list(reg);
    
    regione_reg.datanum=unique(datenum(dataReg.data));
    for k = 1:size(regione_reg.datanum,1)
        index = find(dataReg.data_num==regione_reg.datanum(k) & strcmp(dataReg.denominazione_regione,cellstr(regione)));
        regione_reg.ricoverati(k)=sum(dataReg.ricoverati_con_sintomi(index));
    end
    
    for k=start_t:size(regione_reg.datanum,1)
        regione_reg.progSett_ricoverati(k)=(regione_reg.ricoverati(k)-regione_reg.ricoverati(k-7))/(regione_reg.ricoverati(k-7)-regione_reg.ricoverati(k-13))*100-100;
    end
    
 
    subplot(7,3,reg)
    hold on
    grid on

    inc = round(size(regione_reg.datanum,1)-start_t)/25;
    
    a=bar(timeTot_datenum,regione_reg.progSett_ricoverati);
    a.BarWidth=1.1;
    set(gca,'XTick',timeTot_datenum(1:inc:end))
    set(gca,'XTickLabel',datestr(timeTot_datenum(1:inc:end),'dd mmm'))
    datetick('x', datetickFormat, 'keepticks') ;
    set(gca,'XTickLabelRotation',90,'FontSize',6.5);
    ylabel(regione);
    xlim([timeTot_datenum(start_t) timeTot_datenum(end)]);
    ylim([-500,1000]);
    
end
annotation(gcf,'textbox',...
    [0.377379690949227 0.955486542443065 0.349441501103753 0.0351966873706017],...
    'String','Incremento percentuale a 7 giorni dei ricoverati',...
    'LineStyle','none',...
    'FontSize',14,...
    'FontName','Tahoma',...
    'FitBoxToText','off');

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
% %     cd([WORKroot,'/assets/img/regioni']);
print(gcf, '-dpng', [WORKroot,'/slides/img/regioni/2ond_reg_increm_settimanaleRicoverati.PNG']);
close(gcf);









