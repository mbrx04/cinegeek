Il progetto CineGeek nasce con l’obiettivo di migliorare l’esperienza degli utenti durante la
visione di un film al cinema, sfruttando le potenzialità dei sensori del dispositivo e delle API di
localizzazione. L’applicazione mira a rendere il dispositivo “consapevole” del contesto in cui si
trova l’utente, offrendo suggerimenti e funzionalità utili in modo automatico e intelligente. Il
target di riferimento è costituito da appassionati di cinema e da utenti che frequentano
spesso sale cinematografiche, desiderosi di semplificare e arricchire l’esperienza prima,
durante e dopo la visione di un film.

L’aspetto context-aware rappresenta il cuore dell’applicazione. CineGeek utilizza infatti il
sensore di luminosità per rilevare se l’utente si trova in un ambiente buio, condizione tipica di
una sala cinema, e contemporaneamente i servizi di localizzazione di Google Maps per
determinare se la posizione dell’utente coincide con quella di un cinema. Quando entrambe
le condizioni sono verificate, l’app invia una notifica intelligente che invita a impostare la
modalità silenziosa e alla fine del film manda una notifica dove si chiede di scegliere il film
visto e valutarlo. In questo modo, l’app sfrutta in modo combinato i dati di contesto per offrire
un’esperienza realmente adattiva e personalizzata.

Dal punto di vista funzionale, l’app integra due API fondamentali: Google Maps e TMDB.
Google Maps viene utilizzata per individuare il cinema più vicino in base alla posizione
dell’utente, mentre TMDB fornisce informazioni sui film, permettendo di visualizzare
locandine, descrizioni e valutazioni.

L’app presenta come schermate principali:
• La home, ispirata al design delle app di streaming, mostra i film visti e non ancora
votati, quelli consigliati in base alle preferenze dell’utente e una sezione con
suggerimenti generali.
• La pagina delle recensioni consente di visualizzare e inserire recensioni proprie e degli
amici, favorendo un’interazione sociale e la condivisione dei gusti cinematografici.
• Infine, la pagina profilo raccoglie le informazioni personali e permette di aggiungere
nuovi amici. Le recensioni degli amici influenzano direttamente le raccomandazioni
dell’app: vengono infatti proposti film del genere preferito con valutazioni elevate da
parte della propria rete di amici. Inoltre, se l’utente si trova nelle vicinanze di un
cinema durante il weekend, l’app invia una notifica che suggerisce di andare al
cinema. Tutti i dati relativi a film, recensioni e preferenze vengono salvati in un
DataBase.

Per quanto riguarda l’animazione abbiamo pensato ad una nav bar dinamica che si riduce e si
ingrandisce con un effetto fluido in stile Apple. Questa animazione contribuisce a rendere
l’interfaccia moderna, reattiva e piacevole da utilizzare, migliorando sensibilmente
l’esperienza utente