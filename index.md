---
layout: default
title: COVID-19 Italia
nav_order: 0
has_children: true
has_toc: false
---

# COVID-19 Italia
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0%201.0-lightgrey.svg)](http://creativecommons.org/publicdomain/zero/1.0/)
[![GitHub commit](https://img.shields.io/github/last-commit/covidguard/covidguard.github.io)](https://github.com/covidguard/covidguard.github.io/commits/master)


![image-title-here](/assets/img/no_covid_299x400.png){:style="float: right; height: 200px; margin-top: -30px;"}
Lo scopo della pagina è di accrescere la consapevolezza sul covid-19 grazie a semplici analisi grafiche.

Ogni giorno il sito verrà aggiornato tra le ore 18:30 e le 19:30. Se la pagina non dovesse apparire aggiornata dopo quest'ora suggeriamo di provare a svuotare la cache del proprio browser.

Tutti i grafici qui prodotti vengono generati semi automaticamente dai dati ufficiali della Protezione Civile, per ogni informazione aggiuntiva si rimanda al loro [repository ufficiale](https://github.com/pcm-dpc/COVID-19) disponibile su GitHub (fonte: [https://github.com/pcm-dpc/](https://github.com/pcm-dpc/)).

<hr>
<h2 id="table-of-contents" class="text-delta">Table of contents</h2>
<ul> 
    <li> <a href="#italia">Italia</a> </li> 
    <li> <a href="#italia-regioni">Italia: Regioni</a> </li> 
    <li> <a href="#italia-province">Italia: Province</a> </li> 
    <li> <a href="#lombardia">Lombardia</a> </li> 
</ul>
<hr>
**Attenzione**: per visualizzare correttamente il sito si consiglia l'utilizzo di Safari, Chrome o derivati, browser che non hanno pieno supporto degli ultimi standard CSS3 potrebbero non funzionare correttamente.
<hr>

## ITALIA

### Diffusione spazio-temporale
Mappa che mostra la diffusione nel tempo del virus nelle varie province italiane:
![Mappa Italia](/code/mappaProv.gif)


### Diffusione spazio-temporale: variazione giornaliera
Mappa che mostra come varia la diffusione nel tempo del virus nelle varie province italiane:
![Mappa Italia](/code/mappaProv_spl.gif)


### Andamento Italiano Regione per Regione
Animazione riassuntiva dell'andamento di diffusione del COVID-19 nelle Regioni d'Italia:
![Andamento regioni](/code/Andamento_Regioni.gif)

Nota: nella parte bassa del grafico il numero dei casi è troppo limitato perciò la sua variabilità potrebbe essere maggiore.


### Stato attuale delle Regioni
Per ogni Regione il grafico mira a valutare empiricamente l'attuale possibilità di un'adeguata ed efficace risposta alle fasi successive dell'epidemia. N.B.: le conclusioni sono puramente indicative.
![Andamento regioni1](slides/img/regioni/status.PNG)


### Andamento epidemia: confronto tra Regioni
Il grafico riporta l'andamento del numero dei casi totali di ogni Regione allineati temporalmente a partire dal caso 10/100.000 di ogni Regione.
![Andamento regioni2](slides/img/regioni/confrontoReg_casiTotali.PNG)

Il grafico riporta l'andamento del numero degli attualmente positivi di ogni Regione.
![Andamento regioni3](slides/img/regioni/confrontoReg_attualmentePositivi.PNG)

Il grafico riporta l'andamento del numero dei deceduti di ogni Regione.
![Andamento regioni4](slides/img/regioni/confrontoReg_deceduti.PNG)

Il grafico riporta l'andamento del numero dei dimessi/guariti di ogni Regione.
![Andamento regioni5](slides/img/regioni/confrontoReg_dimessi.PNG)


### Trend giorno per giorno
Andamento dei dati giornalieri per casi totali, dimessi, in isolamento domiciliare, ricoverati con sintomi, terapie intensive e deceduti, in due rappresentazioni differenti:
![Andamento Italia Grafico a Barre](slides/img/regioni/reg_Italia_bars_cumulati.PNG)
![Andamento Italia Grafico a Linee](slides/img/regioni/reg_Italia_linee_cumulati.PNG)


### Tamponi totali
Numero di tamponi analizzati giorno per giorno su tutto il territorio nazionale e test risultati effettivamente positivi:
![Tamponi totali](slides/img/regioni/ita_tamponi.PNG)


### Stima del numero cumulato di positivi
L'evolversi nel tempo di una epidemia può essere descritto da una funzione chiamata Logistica. All'interno della famiglia di funzioni Logistiche, la Legge di Gompertz viene utilizzata per popolazioni poco numerose rispetto alle risorse presenti nell'ambiente che mostrano una crescita inizialmente esponenziale che in seguito si stabilizza, rallentando fino a diventare quasi lineare una volta che la popolazione si avvicina asintoticamente ad un valore di equilibrio.
Il grafico mostra 3 curve di Gompertz (quella di due giorni fa, quella di ieri e quella odierno) fittate sul numero cumulato di positivi d'Italia.
Per la curva odierna è riportata anche l'intervallo di confidenza al 95% dei parametri.
Nell'interpretare questo grafico, ricordiamoci sempre che "non c'è nulla di più certo dell'incertezza".
![Picco Italia Totale](/slides/img/regioni/reg_stimapiccoTotaleCasi_Italia_cumulati.PNG)


### Stima del picco dei nuovi casi positivi
La modellazione del numero dei nuovi casi positivi giornalieri risulta poco accurata a causa della difformità nel tempo delle regole di somministrazione dei tamponi, del loro numero giornaliero e delle latenze nei risultati. Tuttavia può dare una informazione grossolana sul suo andamento:
![Picco Italia NuoviPositivi](/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_Italia_cumulati.PNG)


### Stima del picco degli attualmente positivi
Il grafico mostra 3 curve di Gompertz (due giorni fa, ieri e odierna) fittate sul numero di attualmente positivi d'Italia. Per la curva odierna è riportato anche l'intervallo di confidenza al 95% dei parametri.
Nell'interpretare questo grafico, ricordiamoci sempre che "non c'è nulla di più certo dell'incertezza":
![Picco Italia Positivi](/slides/img/regioni/reg_stimapiccoAttPositivi_Italia_cumulati.PNG)


### Esito
Relazione tra deceduti e dimessi/guariti:
![Esito Italia](slides/img/regioni/reg_Italia_esito.PNG)

### Casi vs Decessi
Tra i primi sintomi (tampone positivo) e il decesso trascorrono da 4 a 8 giorni. 
Di seguito due rappresentazioni: 
- correlazione tra nuovi casi giornalieri e deceduti gionalieri:
![Casi Vs Decessi2](/slides/img/regioni/ita_correlazioneCasiDeceduti_v2.PNG)

- correlazione tra i relativi incrementi percentuali:
![Casi Vs Decessi](/slides/img/regioni/ita_correlazioneCasiDeceduti.PNG)


### Controlli, denunce e sanzioni
Numero ed esisto complessivo dei controlli:
![controlliPopolazione](/slides/img/regioni/controlli_popolazione.PNG)

Andamento giornaliero delle denunce:
![controlliPopolazioneGiornalieri](/slides/img/regioni/controlli_persone_daily.PNG)

Andamento giornaliero delle numero di denunce rispetto ai controlli totali:
![controlliPopolazioneGiornalieri](/slides/img/regioni/controlli_persone_daily_percentuale.PNG)



## ITALIA Regioni

### Confronto temporale tra Regioni
![confrontoRaceTotaleCasi](/code/Andamento_Regioni_Race.gif)
![confrontoRaceAttualmentePositivi](/code/Andamento_Regioni_Race_attPositivi.gif)
![confrontoRaceTamponi](/code/Andamento_Regioni_Race_Tamponi.gif)

### Confronto Regioni
Per ogni regione Italiana qui si possono vedere i dati dei seguenti parametri osservati:

* Totale attualmente positivi
* Totale ospedalizzati
* Ricoverati con sintomi
* Terapia intensiva
* Deceduti
* Isolamento domiciliare
* Guariti dimessi
* Tamponi
* Totale casi

Grafici comparativi di tutte le regioni

<iframe class="slideshow-iframe" src="/slides/regioni_recap.html" 
style="width:100%;" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

Grafici comparativi con dati normalizzati per 100.000 abitanti

<iframe class="slideshow-iframe" src="/slides/regioni_recap_norm.html" 
style="width:100%;" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


<iframe class="slideshow-iframe" src="/slides/italia-regioni-confronto-day.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

<iframe class="slideshow-iframe" src="/slides/italia-regioni-confronto-week.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Dati giornalieri cumulati

<iframe class="slideshow-iframe" src="/slides/regioni_cum.html" 
style="width:100%;" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

### Dati giornalieri cumulati - rappresentazione alternativa

<iframe class="slideshow-iframe" src="/slides/regioni_cum_bars.html" 
style="width:100%;" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

### Progressione Giornaliera

<iframe class="slideshow-iframe" src="/slides/regioni_day.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Tamponi totali
Numero di tamponi vs numero risultati positivi

<iframe class="slideshow-iframe" src="/slides/regioni_tamponi.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Tamponi: Casi testati
Numero di tamponi testati vs numero risultati positivi

<iframe class="slideshow-iframe" src="/slides/regioni_tamponi-testati.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Esito
Percentuale dei dimessi/guariti sui casi che hanno avuto un esito.
![Esito regioni](slides/img/regioni/regioni_esito.PNG)

<iframe class="slideshow-iframe" src="/slides/regioni_esito.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

### Indice di mortalità 
Indice di mortalità calcolato sui casi totali, ovviamente il valore reale è molto più basso, i casi totali conteggiati sono solamente dati dal totale delle persone a cui un tampone è risultato positivo, come noto i casi sommersi sono molti. I valori del grafico sono quindi molto dipendenti dal numero di tamponi effettuati regione per regione:
![Indice di mortalità](slides/img/regioni/ita_mortalita.PNG)

Rapporto deceduti su casi totali:
![Rapporto decedutiCasiTotali](slides/img/regioni/regioni_deced_su_totali.PNG)





## ITALIA Province

Per le provincie di ogni regione Italiana al momento sono disponibili solo i casi positivi totali.


### Le 15 Province con più contagi negli ultimi 7 giorni
![Province con più contagi](slides/img/regioni/ita_worstProv7Day.PNG)

### Le 15 Province con meno contagi negli ultimi 7 giorni
![Province con meno contagi](slides/img/regioni/ita_bestProv7Day.PNG)


### Dati di progressione percentuale

Questi grafici permettono di osservare l'andamento percentuale di crescita (o decrescita) del numero di positivi totali

<iframe class="slideshow-iframe" src="/slides/province_prog.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Dati giornalieri cumulati

<iframe class="slideshow-iframe" src="/slides/province_cum.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


### Dati giornalieri cumulati normalizzati per popolazione

<iframe class="slideshow-iframe" src="/slides/province_norm.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>



### Progressione Giornaliera

<iframe class="slideshow-iframe" src="/slides/province_day.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>





## LOMBARDIA
La Regione Lombardia è il territorio più colpito dall'epidemia. Nei grafici seguenti si riportano gli andamenti per questa particolare Regione.


### Trend regionale giorno per giorno 
Andamento dei dati giornalieri per casi totali, dimessi, in isolamento domiciliare, ricoverati con sintomi, terapie intensive e deceduti, in due rappresentazioni differenti:
![Andamento Lombardia Grafico a Barre](slides/img/regioni/reg_Lombardia_bars_cumulati.PNG)
![Andamento Lombardia Grafico a Linee](slides/img/regioni/reg_Lombardia_linee_cumulati.PNG)


### Modellazione del numero cumulato di positivi regionale
L'evolversi nel tempo di una epidemia può essere descritto da una funzione chiamata Logistica. All'interno della famiglia di funzioni Logistiche, la Legge di Gompertz viene utilizzata per popolazioni poco numerose rispetto alle risorse presenti nell'ambiente che mostrano una crescita inizialmente esponenziale che in seguito si stabilizza, rallentando fino a diventare quasi lineare una volta che la popolazione si avvicina asintoticamente ad un valore di equilibrio.
Il grafico mostra 3 Gompertz (quella di due giorni fa, quella di ieri e quella odierno) fittati sul numero cumulato di positivi della Regione Lombardia. Per la Gompertz odierna è riportato anche l'intervallo di confidenza al 95% dei parametri.
Nell'interpretare questo grafico, ricordiamoci sempre che "non c'è nulla di più certo dell'incertezza".
![Picco Lombardia Totale](/slides/img/regioni/reg_stimapiccoTotaleCasi_Lombardia_cumulati.PNG)

Il dato giornaliero è fortemente influenzato dalle modalità relative alla sua raccolta; in particolare il numero di casi positivi è dipendente dal numero di tamponi analizzati. Al fine di omogeneizzare le misure, i dati giornalieri sono stati corretti attraverso una funzione che cerca di stimare l'effetto del numero di tamponi giornalieri. La modellazione di questa serie è riportata nella seguente figura:
![Picco Lombardia TotaleCorretto](/slides/img/regioni/reg_stimapiccoTotaleCasiCorretti_Lombardia_cumulati.PNG)


### Stima del picco dei nuovi casi positivi regionale
La modellazione del numero dei nuovi casi positivi giornalieri risulta poco accurata a causa della difformità nel tempo delle regole di somministrazione dei tamponi, del loro numero giornaliero e delle latenze nei risultati. Tuttavia può dare una informazione grossolana sul suo andamento:
![Picco Italia NuoviPositivi](/slides/img/regioni/reg_stimapiccoNuoviGiornalieri_Lombardia_cumulati.PNG)

Come per il totale di casi positivi, è stato applicato il modello di correzione per il numero di tamponi:
![Picco Italia NuoviPositiviCorretto](/slides/img/regioni/reg_stimapiccoTotaleCasiGiornalieriCorretti_Lombardia_cumulati.PNG)


### Stima del picco di attualmente positivi regionale
Il grafico mostra 3 curve di Gompertz (due giorni fa, ieri e odierna) fittate sul numero di attualmente positivi della regione Lombardia. Per la curva odierna è riportato anche l'intervallo di confidenza al 95% dei parametri.
Nell'interpretare questo grafico, ricordiamoci sempre che "non c'è nulla di più certo dell'incertezza":
![Picco Lombardia Positivi](/slides/img/regioni/reg_stimapiccoAttPositivi_Lombardia_cumulati.PNG)

Come per il totale di casi positivi, è stato applicato il modello di correzione per il numero di tamponi:
![Picco Lombardia PositiviCorretto](/slides/img/regioni/reg_stimapiccoAttualmentePositiviCorretti_Lombardia_cumulati.PNG)


### Curve epidemiche provinciali
L'interpolazione delle serie di crescita dei nuovi casi provinciali permette di valutare gli andamenti Provincia per Provincia della Regione.
Le curve soffrono ovviamente della estrema variabilità delle condizioni di rilevamento dei dati (tamponi, tipologia di persone analizzate, ...) e sono poco rappresentative nella parte di crescita, tuttavia mostrano inequivolcabilmente come, in praticolare in Provincia di Lodi ma anche nelle Province di Cremona e Pavia, l'epidemia fosse iniziata un periodo molto antecedente il primo caso ufficiale.
In particolare il caso 1 italiano (circa 20 febbraio) era in corrispondenza quasi del picco di contagi della Provincia lodigiana.
![Curva Epidemica Lombardia 1](/slides/img/province/Province_Lombardia_casiTotaliGiornalieri_gomp.PNG)
![Curva Epidemica Lombardia 2](/slides/img/province/Province_norm_Lombardia_casiTotaliGiornalieri_gomp.PNG)

### Dati comunali: totale casi
Per ogni Provincia lombarda vengono riportati i 25 Comuni con numero maggiore di casi
<iframe class="slideshow-iframe" src="/slides/lombardia-comuni-totali.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

### Dati comunali: totale casi pesati per popolazione
Per ogni Provincia lombarda vengono riportati i 25 Comuni con numero maggiore di casi in rapporto alla popolazione comunale
<iframe class="slideshow-iframe" src="/slides/lombardia-comuni-totali-pesati.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>

### Dati comunali: progressione giornaliera
Per ogni Provincia lombarda vengono riportati i 25 Comuni con numero maggiore di nuovi casi giornalieri (si noti che l'aggiornamento non avviene sempre giornalmente).
<iframe class="slideshow-iframe" src="/slides/lombardia-comuni-nuovi.html" 
style="width:100%" frameborder="0" scrolling="no" onload="resizeIframe(this)"></iframe>


<hr>
[Back to the Table of Contents](#table-of-contents)
<hr>

# Contatti

info.covidguard[at]protonmail.com
