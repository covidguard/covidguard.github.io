
if ismac
    flag_download = false;
else
    flag_download = true;
end


%% -------------------------
if ismac
    WORKroot = sprintf('/Users/Andrea/Repositories/covidguard.github.io/');
else
    WORKroot = sprintf('C:/Temp/Repo/covidguard');
end

%% download json from server
if flag_download
    delete(sprintf('%s/_json/*.json',WORKroot))    
    serverAddress = 'https://raw.githubusercontent.com';    
    command = sprintf('wget --no-check-certificate %s/italia/covid19-opendata-vaccini/master/dati/somministrazioni-vaccini-latest.json', serverAddress);
    system(command);
    movefile('somministrazioni-vaccini-latest.json',sprintf('%s/_json',WORKroot),'f');
end

%% load population
%% ---------------
filename = fullfile(WORKroot, '_json', 'popolazione_province.txt');
[pop.id, pop.name, pop.number, pop.perc, pop.superf, pop.numCom, pop.sigla]=textread(filename,'%d%s%d%f%%%d%d%s','delimiter',';');






%decode json
filename = sprintf('%s/_json/somministrazioni-vaccini-latest.json',WORKroot);
fid       = fopen(filename, 'rt');
file_scan = textscan(fid, '%s', 'delimiter', '\n', 'endOfLine', '\r\n', 'whitespace', '');
fclose(fid);
file_scan                             = file_scan{1};
file_scan=char(file_scan);

json_oneRaw='';
json_oneRaw(1:size(file_scan,1)*size(file_scan,2))=' ';
for i=1:size(file_scan,1)
    json_oneRaw(1+(i-1)*size(file_scan,2):i*size(file_scan,2))=file_scan(i,:);
    %     json_oneRaw=sprintf('%s%s',json_oneRaw,file_scan(i,:));
end
dataVax = decodeJSONvax(json_oneRaw);

save('dataVax.mat','dataVax');

regioni_tot = unique(dataVax.nome_area);

dataVax.nome_area(strcmp(dataVax.nome_area,{'Provincia Autonoma Bolzano \/ Bozen'}))={'Provincia Autonoma Bolzano'};
dataVax.nome_area(strcmp(dataVax.nome_area,{'Valle d Aosta \/ Vall\u00e9e d Aoste'}))={'Valle d Aosta'};
dataVax.nome_area(strcmp(dataVax.nome_area,{'Provincia Autonoma Bolzano'}))={'P.A. Bolzano'};
dataVax.nome_area(strcmp(dataVax.nome_area,{'Provincia Autonoma Trento'}))={'P.A. Trento'};

regioni_tot = unique(dataVax.nome_area);


load('todaydata.mat','pop')



fascia_anagrafica_tot = unique(dataVax.fascia_anagrafica);
fornitore_tot = unique(dataVax.fornitore);




%% numero vaccinati per classe d'età rispetto alla popolazione
nvax_per_eta=[];
nvax_per_eta_popol=[];
for reg = 1:length(regioni_tot)
    idx_reg = find(strcmp(dataVax.nome_area, regioni_tot(reg)));
    
    
    for classe = 1:length(fascia_anagrafica_tot)
        for fornitore = 1:length(fornitore_tot)        
            idx = find(strcmp(dataVax.nome_area, regioni_tot(reg)) & strcmp(dataVax.fascia_anagrafica, fascia_anagrafica_tot(classe))  & strcmp(dataVax.fornitore, fornitore_tot(fornitore)));
            nvax_per_eta(classe,reg,fornitore)=sum(dataVax.prima_dose(idx)+dataVax.seconda_dose(idx));
        end
    end    
    nvax_per_eta_popol(:,reg,:) = nvax_per_eta(:,reg,:)./pop.popolazioneRegioniPop(reg);
    
    
end
a1=sum(nvax_per_eta_popol,3);
a2=max(a1(:))*100000;


for reg = 1:length(regioni_tot)
    figure;
    id_f = gcf;
    set(id_f, 'Name', sprintf('%s: vaccini per fascia di età', char(regioni_tot(reg))));
    title(sprintf('%s: distribuzione vaccini per fascia di età', char(regioni_tot(reg))));
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    a=barh([nvax_per_eta_popol(:,reg,1) nvax_per_eta_popol(:,reg,2) nvax_per_eta_popol(:,reg,3)]*100000,'stacked');
    xl=get(gca,'xlim');
    xlim([0, a2]);
    grid minor
    
    id = gca;
    ylim([0.5 9.5])
    id.YTickLabel=fascia_anagrafica_tot;
    xlabel('Numero vaccinazioni ogni 100.000 abitanti')
    
    l= legend(a, fornitore_tot,'Location','SouthEast');
    
    
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
        'String',{['Fonte: https://raw.githubusercontent.com/covid19-opendata-vaccini']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    annotation(gcf,'textbox',...
        [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', sprintf('%s/slides/img/vaccini/01_%02d_%s_vaccini_eta.PNG', WORKroot,reg,char(regioni_tot(reg))));
    close(gcf);
    
end







%% numero vaccinati per categoria
nvax_per_categoria=[];
nvax_per_categoria_popol=[];
for reg = 1:length(regioni_tot)   
    
    for classe = 1:length(fascia_anagrafica_tot)
            idx = find(strcmp(dataVax.nome_area, regioni_tot(reg)) & strcmp(dataVax.fascia_anagrafica, fascia_anagrafica_tot(classe)));
            nvax_per_categoria(classe,reg,1)=sum(dataVax.categoria_operatori_sanitari_sociosanitari(idx));
            nvax_per_categoria(classe,reg,2)=sum(dataVax.categoria_personale_non_sanitario(idx));
            nvax_per_categoria(classe,reg,3)=sum(dataVax.categoria_ospiti_rsa(idx));
            nvax_per_categoria(classe,reg,4)=sum(dataVax.categoria_forze_armate(idx));
            nvax_per_categoria(classe,reg,5)=sum(dataVax.categoria_personale_scolastico(idx));
            nvax_per_categoria(classe,reg,6)=sum(dataVax.categoria_over80(idx));        
            nvax_per_categoria(classe,reg,7)=sum(dataVax.categoria_altro(idx));        
    end    
    nvax_per_categoria_popol(:,reg,:) = nvax_per_categoria(:,reg,:)./pop.popolazioneRegioniPop(reg);
    
    
end
a1=sum(nvax_per_categoria_popol,3);
a2=max(a1(:))*100000;


for reg = 1:length(regioni_tot)
    figure;
    id_f = gcf;
    set(id_f, 'Name', sprintf('%s: vaccini per fascia di età e categoria', char(regioni_tot(reg))));
    title(sprintf('%s: distribuzione vaccini per fascia di età e categoria', char(regioni_tot(reg))));
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    a=barh([nvax_per_categoria_popol(:,reg,1) nvax_per_categoria_popol(:,reg,2) nvax_per_categoria_popol(:,reg,3) nvax_per_categoria_popol(:,reg,4) nvax_per_categoria_popol(:,reg,5) nvax_per_categoria_popol(:,reg,6) nvax_per_categoria_popol(:,reg,7)]*100000,'stacked');
    xl=get(gca,'xlim');

    grid minor
    
    id = gca;
    ylim([0.5 9.5])
    id.YTickLabel=fascia_anagrafica_tot;
    xlabel('Numero vaccinazioni ogni 100.000 abitanti')
    
    l= legend(a, {'operatori sanitari sociosanitari'; 'personale non sanitario'; 'ospiti rsa'; 'forze armate'; 'personale scolastico'; 'over80'; 'altro'},'Location','SouthEast');
    
    xlim([0, a2]);
    % overlap copyright info
    datestr_now = datestr(now);
    annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
        'String',{['Fonte: https://raw.githubusercontent.com/covid19-opendata-vaccini']},...
        'HorizontalAlignment','center',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off',...
        'LineStyle','none',...
        'Color',[0 0 0]);
    
    annotation(gcf,'textbox',...
        [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
        'String',{'https://covidguard.github.io/#covid-19-italia'},...
        'LineStyle','none',...
        'HorizontalAlignment','left',...
        'FontSize',6,...
        'FontName','Verdana',...
        'FitBoxToText','off');
    
    print(gcf, '-dpng', sprintf('%s/slides/img/vaccini/02_%02d_%s_vaccini_categoria.PNG', WORKroot,reg,char(regioni_tot(reg))));
    close(gcf);
    
end









%% andamento nei giorni fornitore
lista_giorni = unique(dataVax.data_somministrazione);
nvax_per_categoria=[];
nvax_per_categoria_popol=[];
for reg = 1:length(regioni_tot)   
    
    n_vax_day = zeros(length(lista_giorni),length(fascia_anagrafica_tot), length(fornitore_tot));
    
    for day=1:length(lista_giorni)
        for classe = 1:length(fascia_anagrafica_tot)
            for fornitore = 1:length(fornitore_tot) 
                idx = find(strcmp(dataVax.nome_area, regioni_tot(reg)) & strcmp(dataVax.data_somministrazione, lista_giorni(day)) ...
                    &  strcmp(dataVax.fascia_anagrafica, fascia_anagrafica_tot(classe)) &  strcmp(dataVax.fornitore, fornitore_tot(fornitore)));
                
                   n_vax_day(day, classe, fornitore) = sum(dataVax.prima_dose(idx)+dataVax.seconda_dose(idx));
                
                
            end
        end
    end
    n_vax_day_popol = n_vax_day./pop.popolazioneRegioniPop(reg);
    
    
    figure;
    id_f = gcf;
    set(id_f, 'Name', sprintf('%s: andamento vaccini per fascia di età e categoria', char(regioni_tot(reg))));
    title(sprintf('%s: andamento vaccini per fascia di età e categoria', char(regioni_tot(reg))));
    set(gcf,'NumberTitle','Off');
    set(gcf,'Position',[26 79 967 603]);
    grid on
    hold on
    
    a=bar([sum(n_vax_day_popol(:,1,:),3) sum(n_vax_day_popol(:,2,:),3) sum(n_vax_day_popol(:,3,:),3) sum(n_vax_day_popol(:,4,:),3) sum(n_vax_day_popol(:,5,:),3) sum(n_vax_day_popol(:,6,:),3) sum(n_vax_day_popol(:,7,:),3) sum(n_vax_day_popol(:,8,:),3) sum(n_vax_day_popol(:,9,:),3)]*100000,'stacked', 'grouped');
%     xl=get(gca,'xlim');
    grid minor
    
   
    colors={};
    for k=1:9
        colors{k}=Cmap.getColor(k, 9);
    end
    
    for k=1:9
        a(k).FaceColor=colors{k};
    end
    
    
    
    
    
    
    
    
    id = get(gca);
    
    set(gca,'XTick', (1:round(length(lista_giorni)/20)   : length(lista_giorni)));
%     ylim([0.5 9.5])
    ll = char(lista_giorni(1:round(length(lista_giorni)/20): length(lista_giorni)));
    ll=ll(:,1:10);

    xticklabels(cellstr(datestr(datenum(ll),'dd-mmm')));
    set(gca,'XTickLabelRotation', 90)   
    
    
    l= legend(a, [fascia_anagrafica_tot(1); fascia_anagrafica_tot(2); fascia_anagrafica_tot(3); fascia_anagrafica_tot(4); fascia_anagrafica_tot(5); fascia_anagrafica_tot(6); fascia_anagrafica_tot(7); fascia_anagrafica_tot(8); fascia_anagrafica_tot(9)],'Location','SouthEastOutside');
    ylabel('vaccinati ogni 100.000 abitanti');
    
    ylim([0 900]);
    
%     xlim([0, a2]);
    % overlap copyright info
%     datestr_now = datestr(now);
%     annotation(gcf,'textbox',[0.0822617786970022 0.0281923714759542 0.238100000000001 0.04638],...
%         'String',{['Fonte: https://raw.githubusercontent.com/covid19-opendata-vaccini']},...
%         'HorizontalAlignment','center',...
%         'FontSize',6,...
%         'FontName','Verdana',...
%         'FitBoxToText','off',...
%         'LineStyle','none',...
%         'Color',[0 0 0]);
%     
%     annotation(gcf,'textbox',...
%         [0.715146990692874 0.0298507462686594 0.238100000000001 0.0463800000000001],...
%         'String',{'https://covidguard.github.io/#covid-19-italia'},...
%         'LineStyle','none',...
%         'HorizontalAlignment','left',...
%         'FontSize',6,...
%         'FontName','Verdana',...
%         'FitBoxToText','off');
    
    print(gcf, '-dpng', sprintf('%s/slides/img/vaccini/03_%02d_%s_vaccini_andamento.PNG', WORKroot,reg,char(regioni_tot(reg))));
    close(gcf);
    
    
    
    
    
end





% mkdir('GRAPHS');
% movefile('*.PNG','GRAPHS','f');

