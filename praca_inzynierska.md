\documentclass[12pt, a4paper]{report}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[polish]{babel}
\usepackage{geometry}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{hyperref}
\usepackage{csquotes}
\usepackage{amsmath}
\usepackage{listings}
\usepackage{xcolor}
\usepackage{float}
\usepackage{caption}
\usepackage{tabularx}
\usepackage[hidelinks]{hyperref} % hidelinks usuwa brzydkie ramki wokół linków

\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.92}

\lstdefinestyle{mystyle}{
    backgroundcolor=\color{backcolour},   
    commentstyle=\color{codegreen},
    keywordstyle=\color{magenta},
    numberstyle=\tiny\color{codegray},
    stringstyle=\color{codepurple},
    basicstyle=\ttfamily\footnotesize, % Czcionka maszynowa
    breakatwhitespace=false,         
    breaklines=true,                 
    captionpos=b,                    % Podpis na dole (jak w PDF)
    keepspaces=true,                 
    numbers=left,                    % Numery linii po lewej
    numbersep=5pt,                  
    showspaces=false,                
    showstringspaces=false,
    showtabs=false,                  
    tabsize=4,
    frame=single,                    % Ramka dookoła
    inputencoding=utf8,
    extendedchars=true,
    literate={ą}{{\k{a}}}1 {ć}{{\'c}}1 {ę}{{\k{e}}}1 {ł}{{\l{}}}1 {ń}{{\'n}}1 {ó}{{\'o}}1 {ś}{{\'s}}1 {ź}{{\'z}}1 {ż}{{\.z}}1
}

\lstset{style=mystyle}
% -----------------------------
% ------------------------------------------------

% Konfiguracja bibliografii
\usepackage[backend=biber, style=numeric, sorting=none]{biblatex}
\addbibresource{bibliografia.bib}

% Ustawienia marginesów
\geometry{
 a4paper,
 left=30mm,
 right=20mm,
 top=25mm,
 bottom=25mm,
}

% Interlinia 1.5
\onehalfspacing
\usepackage{graphicx}
\begin{document}

% -------------------------------------------------------------------
% STRONA TYTUŁOWA
% -------------------------------------------------------------------
\begin{titlepage}
    \centering
    {\large UNIWERSYTET ŚLĄSKI W KATOWICACH \\ WYDZIAŁ NAUK ŚCISŁYCH I TECHNICZNYCH \par}
    \vspace{2cm}
    {\large Jakub Łaski \par}
    {\large NR ALBUMU: 349509 \par}
    \vspace{3cm}
    {\LARGE \bfseries Zastosowanie uczenia  głębokiego do 
automatycznej detekcji korzystania ze 
smartfonów  w przestrzeniach 
monitorowanych  \par}
    \vspace{3cm}
    {\Large PRACA DYPLOMOWA INŻYNIERSKA \par}
    \vspace{3cm}
    \begin{flushright}
        \begin{minipage}{0.5\textwidth}
            \centering
            Promotor: dr Katarzyna Schmidt, prof. UŚ
        \end{minipage}
    \end{flushright}
    \vfill
    {\large Chorzów 2026 \par}
\end{titlepage}

% -------------------------------------------------------------------
% SPIS TREŚCI
% -------------------------------------------------------------------
\tableofcontents
\newpage

% -------------------------------------------------------------------
% ROZDZIAŁ 1 - WSTĘP
% -------------------------------------------------------------------
\chapter{Wstęp}

Rozwój technologii mobilnych sprawił, że smartfony stały się nieodłącznym elementem życia codziennego, co rodzi nowe wyzwania w zarządzaniu przestrzeniami wymagającymi szczególnego nadzoru. W wielu środowiskach – takich jak zakłady przemysłowe, strefy o podwyższonym rygorze bezpieczeństwa czy laboratoria – korzystanie z urządzeń mobilnych może stanowić zagrożenie dla bezpieczeństwa danych, procesów technologicznych lub efektywności pracy. Tradycyjne systemy monitoringu wizyjnego, opierające się na manualnej obserwacji przez operatora, stają się niewystarczające w obliczu rosnącej skali zjawiska oraz ograniczeń ludzkiej percepcji. W odpowiedzi na te wyzwania, współczesne systemy nadzoru coraz częściej integrowane są z algorytmami sztucznej inteligencji, umożliwiającymi automatyczną detekcję niepożądanych obiektów w czasie rzeczywistym.

Szczególnym przykładem przestrzeni monitorowanej, w której problem ten przybiera na sile, są placówki edukacyjne. Szkoła, jako instytucja powołana do kształcenia, zmaga się z problemem dekoncentracji uczniów wynikającym z niekontrolowanego dostępu do smartfonów. Choć kontekst ten różni się od przemysłowego, istota problemu pozostaje ta sama: konieczność skutecznego wykrywania naruszeń regulaminu w zdefiniowanej strefie, bez angażowania pełnej uwagi osoby nadzorującej.

Niniejsza praca koncentruje się na technicznym aspekcie tego zagadnienia, proponując rozwiązanie oparte na metodach głębokiego uczenia (ang. \textit{Deep Learning}). Z tego względu, w dalszej części pracy skupiono się na środowisku szkolnym, traktując je jako reprezentatywny przykład przestrzeni monitorowanej, na którym zaprezentowano i zweryfikowano działanie zaprojektowanego systemu. Rozwiązanie to stanowi nowoczesną alternatywę dla fizycznych blokad czy manualnego nadzoru.

\section{Cel pracy}

Celem pracy jest zaprojektowanie i zbudowanie systemu, który automatycznie wykrywa smartfony w przestrzeni monitorowanej (na przykładzie sali lekcyjnej). Rozwiązanie to monitoruje obraz z kamery w czasie rzeczywistym, wykorzystując algorytmy sztucznej inteligencji w architekturze klient-serwer.

Projekt skupia się na skutecznym wykrywaniu smartfona w zmiennych warunkach, przy zachowaniu ochrony prywatności osób w niej przebywających. Opracowany system łączy technologię głębokiego uczenia (ang. \textit{Deep Learning}) z mechanizmami anonimizacji danych.

Realizacja celu głównego wymagała osiągnięcia następujących celów szczegółowych w obszarze technicznym:

\begin{itemize}
    \item \textbf{Implementacja modułu detekcji obiektów:} Wykorzystanie sieci neuronowej YOLOv8 (ang. \textit{You Only Look Once}) \cite{ultralytics_yolo}. Wybór modelu podyktowany był wymogiem przetwarzania obrazu w czasie rzeczywistym. Wykorzystano model wstępnie wytrenowany (pre-trained), co pozwoliło na optymalizację procesu uczenia i redukcję wymagań sprzętowych przy zachowaniu wysokiej precyzji.
    
    \item \textbf{Opracowanie mechanizmu ochrony prywatności (Privacy-Preserving Module):} Zaprojektowanie i wdrożenie algorytmu anonimizacji wizerunku. Wykorzystano w tym celu pomocniczy model detekcji (z repozytorium Roboflow \cite{roboflow_heads}), którego zadaniem jest lokalizacja głów osób znajdujących się w kadrze. Obszary te są automatycznie poddawane operacji rozmycia gaussowskiego (ang. \textit{Gaussian Blur}) \cite{opencv_library}. Dzięki temu system gromadzi dowody naruszeń (zdjęcia przedstawiające widoczne smartfony) w formie zanonimizowanej, uniemożliwiającej identyfikację biometryczną konkretnej osoby.
    
    \item \textbf{Budowa architektury systemu:} Implementacja w modelu klient-serwer. Warstwę logiczną (Backend) zrealizowano w języku Python \cite{python_docs}, integrując framework Flask \cite{flask_docs} (obsługa API) oraz bibliotekę OpenCV \cite{opencv_library} do przetwarzania macierzy obrazu. Warstwa prezentacji (Frontend), wykonana w technologii React \cite{react_docs} z wykorzystaniem TypeScript \cite{typescript_docs}, stanowi interfejs webowy służący do weryfikacji incydentów, konfiguracji systemu, analizy statystyk oraz obsługi powiadomień w czasie rzeczywistym.
\end{itemize}

\section{Motywacja}

Decyzja o realizacji projektu wynika z faktu, że młodzi ludzie mają biologiczne trudności z samodzielnym ograniczeniem korzystania z telefonów \cite{casey2008adolescent}. Metody administracyjne, zakazy oraz fizyczne depozyty często generują problemy logistyczne lub są trudne do wyegzekwowania w dużych grupach. Ponadto, manualna obserwacja monitoringu przez człowieka jest obarczona błędem wynikającym ze zmęczenia i podzielności uwagi.

Głównym uzasadnieniem realizacji projektu jest zatem konieczność automatyzacji procesu wykrywania naruszeń. Zastosowanie algorytmów widzenia maszynowego (ang. \textit{Computer Vision}) pozwala na ciągły monitoring zdefiniowanej strefy, eliminując czynnik ludzki z procesu detekcji. System działa w tle, powiadamiając operatora tylko w momencie wystąpienia incydentu i dostarczając dokumentację zdarzenia. Zastosowanie AI nie tylko wspiera operatora, ale pełni też funkcję odstraszającą. Wiedza o tym, że monitoring jest zautomatyzowany i niepodatny na zmęczenie, sama w sobie ogranicza liczbę incydentów, czyniąc system bardziej szczelnym.

\section{Zakres pracy}

Praca przedstawia kompletny proces projektowania i implementacji systemu: od analizy problemu i doboru narzędzi, przez programowanie, aż po testy gotowego rozwiązania. Treść została podzielona na sześć rozdziałów:

\begin{itemize}
    \item \textbf{Rozdział 2: Teoretyczne podstawy problemu.} Rozdział ten wyjaśnia, dlaczego smartfony stanowią wyzwanie w edukacji. Opisano w nim biologiczne i psychologiczne uwarunkowania korzystania z technologii mobilnych (m.in. teoria obciążenia poznawczego), skuteczność administracyjnych metod nadzoru oraz ograniczenia uwagi wynikające z wielozadaniowości.
    
    \item \textbf{Rozdział 3: Technologie widzenia maszynowego.} Opisano zasadę działania Konwolucyjnych Sieci Neuronowych (CNN) oraz uzasadniono wybór architektury modelu specyfiką działania w czasie rzeczywistym. Rozdział prezentuje również zastosowane algorytmy przetwarzania obrazu oraz definiuje metryki ewaluacyjne, które posłużyły do oceny skuteczności systemu.
    
    \item \textbf{Rozdział 4: Implementacja systemu.} Rozdział zawiera dokumentację techniczną zbudowanej aplikacji. Rozpoczyna się od charakterystyki środowiska programistycznego. Następnie opisano architekturę systemu, projekt bazy danych oraz szczegóły implementacji kluczowych modułów, takich jak asynchroniczna anonimizacja czy obsługa strumienia wideo.
    
    \item \textbf{Rozdział 5: Konfiguracja i środowisko testowe.} W tej części przedstawiono proces uruchomienia systemu oraz jego kalibrację. Opisano sposób doboru parametrów detekcji (np. progu pewności), tak aby system skutecznie wykrywał telefony, ale minimalizował liczbę fałszywych alarmów.
    
    \item \textbf{Rozdział 6: Wyniki badań i ewaluacja.} Rozdział prezentuje wyniki przeprowadzonych testów. Zweryfikowano wydajność przetwarzania w czasie rzeczywistym, skuteczność wykrywania telefonów w zróżnicowanych scenariuszach (odległość, ruch, ułożenie) oraz poprawność działania mechanizmów anonimizacji.
    
    \item \textbf{Podsumowanie:} Praca kończy się wnioskami z realizacji projektu, oceną, w jakim stopniu udało się zrealizować założone cele, oraz propozycjami, jak można w przyszłości rozwinąć system o nowe funkcje.
\end{itemize}
% -------------------------------------------------------------------
% ROZDZIAŁ 2
% -------------------------------------------------------------------
\chapter{Teoretyczne podstawy problemu}

Problem dekoncentracji wywołanej przez urządzenia mobilne dotyczy wielu obszarów życia społecznego i zawodowego – od obniżonej wydajności w biurach po zagrożenia bezpieczeństwa w przemyśle. Jednak to środowisko edukacyjne stanowi obszar, w którym negatywny wpływ tej technologii jest najlepiej udokumentowany i niesie ze sobą najpoważniejsze skutki długofalowe. Powszechna cyfryzacja zmienia warunki pracy dydaktycznej, wprowadzając do sal lekcyjnych urządzenia, które konkurują o uwagę uczniów. Rozdział ten analizuje przyczyny, dla których smartfony stanowią wyzwanie dla systemu edukacji, traktując go jako reprezentatywny przykład przestrzeni wymagającej nadzoru. Opisano tu teorie kognitywistyczne, mechanizmy neurobiologiczne oraz dane statystyczne, a także przeanalizowano skuteczność dotychczas stosowanych metod monitoringu.

\section{Ograniczenia procesów poznawczych}

Z perspektywy psychologii poznawczej, kluczowym problemem obecności smartfonów jest konflikt o zasoby uwagi. Teoria Obciążenia Poznawczego (ang. \textit{Cognitive Load Theory}) \cite{sweller2024clt} wskazuje, że pamięć operacyjna człowieka ma ściśle określone granice. W przeciwieństwie do architektur komputerowych, ludzki system poznawczy nie przetwarza wielu złożonych informacji jednocześnie bez utraty jakości. W sytuacji, gdy w polu widzenia ucznia znajduje się telefon, część zasobów poznawczych zużywana jest na ignorowanie tego bodźca, zamiast na proces uczenia się. Generuje to zbędne obciążenie poznawcze.

Istotnym czynnikiem jest zjawisko drenażu mózgu (ang. \textit{brain drain hypothesis}). Badania eksperymentalne wykazują, że sama fizyczna obecność telefonu – nawet wyciszonego i odwróconego ekranem w dół – obniża sprawność procesów myślowych \cite{ward2017brain}. Mózg użytkownika pozostaje w stanie ciągłego, podświadomego czuwania, próbując przewidzieć nadejście powiadomienia. Stan ten redukuje dostępną pamięć operacyjną i płynną inteligencję, co bezpośrednio utrudnia rozwiązywanie zadań logicznych i zapamiętywanie nowego materiału.

Kolejnym negatywnym aspektem jest koszt przełączania uwagi (ang. \textit{context switching}). Wielozadaniowość medialna (ang. \textit{media multitasking}) jest zjawiskiem pozornym – mózg nie wykonuje czynności równolegle, lecz szybko przełącza się między nimi \cite{uncapher2018multitask}. Badania dowodzą, że po oderwaniu wzroku w celu weryfikacji powiadomienia, powrót do pełnego skupienia na zadaniu pierwotnym zajmuje średnio ponad 25 minut \cite{mark2005notask}. Wynika to z faktu, że uwaga ucznia po przerwaniu czynności często mimowolnie kieruje się ku innym aktywnościom pośrednim. W praktyce pojedyncze rozproszenie może zaburzyć proces przyswajania wiedzy na znaczną część jednostki lekcyjnej.

\section{Neurobiologiczne i behawioralne mechanizmy uzależnień}

Trudności z zachowaniem dyscypliny cyfrowej mają swoje źródło w biologii rozwoju oraz specyfice projektowania aplikacji. U nastolatków układ w mózgu odpowiedzialny za emocje i nagrody (układ limbiczny) jest już bardzo aktywny, podczas gdy obszar odpowiedzialny za samokontrolę, hamowanie impulsów i planowanie (kora przedczołowa) wciąż dojrzewa i rozwija się aż do wczesnej dorosłości \cite{casey2008adolescent}.

Twórcy oprogramowania wykorzystują tę dysproporcję rozwojową, stosując mechanizmy psychologiczne znane z gier hazardowych. Aplikacje projektowane są w oparciu o schematy nieregularnych wzmocnień (ang. \textit{variable ratio reinforcement schedule}). Kluczowa jest tu niepewność nagrody (np. brak wiedzy o tym, kto napisał, czy zdjęcie otrzymało nowe "lajki"). Taka niepewność stymuluje wydzielanie dopaminy silniej niż sama nagroda \cite{haynes2018dopamine}. Celem tych mechanizmów jest maksymalizacja czasu spędzonego przed ekranem, co czyni walkę o uwagę ucznia nierówną – szkoła rywalizuje z algorytmami precyzyjnie zoptymalizowanymi pod kątem uzależniania użytkownika \cite{freed2018war, jancarz2023skutecznosc}.

\section{Wpływ na wyniki edukacyjne – analiza danych}

Problem dekoncentracji cyfrowej znajduje potwierdzenie w międzynarodowych badaniach ilościowych. Raport PISA 2022 wskazuje na bezprecedensowy spadek wyników w nauce, szczególnie z matematyki i czytania. Regres ten statystycznie odpowiada stracie trzech czwartych roku nauki \cite{pisa2022vol1}.

Zjawisko to ma charakter systemowy. W krajach OECD średnio co czwarty uczeń zgłasza, że na większości lekcji matematyki jest rozpraszany przez urządzenia cyfrowe \cite{pisa2022vol2}. Co istotne, problem nie dotyczy tylko posiadacza telefonu – około jedna czwarta uczniów wskazuje, że jest dekoncentrowana przez urządzenia używane przez innych uczniów. Analizy wykazują silną korelację: uczniowie doświadczający dystrakcji cyfrowej uzyskują z matematyki wyniki średnio o 15 punktów niższe niż ich rówieśnicy wolni od zakłóceń \cite{pisa2022vol2}.

Badania potwierdzają również, że restrykcje w dostępie do telefonów przynoszą wymierne efekty, pod warunkiem ich skutecznego egzekwowania. Analiza przeprowadzona w szkołach brytyjskich wykazała, że wprowadzenie zakazu telefonów przełożyło się na poprawę wyników egzaminacyjnych średnio o 6,41\% odchylenia standardowego \cite{beland2015ill}. Korzyść ta jest najbardziej widoczna w grupie uczniów o niższych osiągnięciach (wzrost o 14,23\% odchylenia standardowego), podczas gdy uczniowie najzdolniejsi nie odczuli istotnej różnicy. Wskazuje to, że obecność smartfonów może pogłębiać nierówności edukacyjne, wpływając najbardziej negatywnie na uczniów wymagających wsparcia.

Wnioski te znajdują odzwierciedlenie w polityce wielu państw. Francja testuje procedury całkowitej fizycznej separacji urządzeń (depozyty przed wejściem do szkoły) \cite{guardian2024france, france2024pilot}, a Szwecja strategicznie powraca do analogowych nośników wiedzy (papierowych podręczników), uznając cyfryzację za jeden z czynników obniżających jakość kształcenia \cite{sweden2024government}.

\section{Niska skuteczność tradycyjnych metod nadzoru}

Analiza problemu wskazuje, że tradycyjne metody nadzoru wykazują niską skuteczność niezależnie od specyfiki otoczenia – czy jest to sala lekcyjna, czy zakład pracy. W obliczu przedstawionych wyzwań, metody oparte wyłącznie na czynniku ludzkim okazują się niewystarczające.

Manualna kontrola przez nauczyciela (lub operatora w systemach przemysłowych) jest nieefektywna i generuje obciążenia organizacyjne. W kontekście szkolnym nauczyciel, zamiast realizować materiał dydaktyczny, zmuszony jest do pełnienia roli nadzorcy, co dezorganizuje przebieg zajęć \cite{lynch2019theft}. Analogiczny problem dotyczy systemów monitoringu wizyjnego. Wymóg jednoczesnej analizy obrazu z wielu kamer przekracza naturalne możliwości przetwarzania informacji przez człowieka. W rezultacie, wraz z upływem czasu obserwacji, zdolność operatora do wykrywania anomalii gwałtownie spada, czyniąc manualną weryfikację metodą wysoce zawodną. 

Również rozwiązania mechaniczne napotykają na problemy. Systemy takie jak zamykane etui (np. Yondr) czy pudełka depozytowe wiążą się ze skomplikowaną logistyką (kolejki, dystrybucja). Co więcej, użytkownicy szybko znajdują sposoby na obejście zabezpieczeń fizycznych, korzystając z instrukcji dostępnych w sieci \cite{mirror2024lausd}.

Niska skuteczność metod administracyjnych i fizycznych uzasadnia konieczność poszukiwania nowych rozwiązań technologicznych. System automatycznej detekcji, będący przedmiotem niniejszej pracy, eliminuje słabości percepcji ludzkiej, zapewniając ciągły i obiektywny monitoring. Jest to techniczna odpowiedź na ograniczenia, z którymi nie radzą sobie tradycyjne metody manualne.
% ROZDZIAŁ 3
% -------------------------------------------------------------------
\chapter{Technologie przetwarzania i analizy obrazu}

Realizacja systemu detekcji wymagała zastosowania zaawansowanych metod widzenia maszynowego (ang. \textit{Computer Vision}). Rozdział przedstawia teoretyczne podstawy działania sieci neuronowych oraz szczegółową charakterystykę wykorzystanej architektury i algorytmów przetwarzania wstępnego.

\section{Konwolucyjne Sieci Neuronowe (CNN)}

Tradycyjne algorytmy przetwarzania obrazu opierają się na ręcznie definiowanych cechach, co ogranicza ich skuteczność w złożonych środowiskach. Rozwiązaniem tego problemu są Konwolucyjne Sieci Neuronowe (ang. \textit{Convolutional Neural Network}), które umożliwiają automatyczną ekstrakcję cech bezpośrednio z danych wejściowych. Ich architektura jest inspirowana hierarchiczną strukturą kory wzrokowej ssaków \cite{goodfellow2016deep}.

Fundamentem działania CNN jest operacja splotu (konwolucji). Polega ona na przesuwaniu filtra (jądra splotu) po macierzy obrazu i wykonywaniu operacji iloczynu skalarnego. Proces ten pozwala na wykrywanie lokalnych wzorców:
\begin{itemize}
    \item \textbf{Warstwy płytkie} odpowiadają za detekcję niskopoziomowych cech geometrycznych, takich jak krawędzie, linie czy zmiany kontrastu.
    \item \textbf{Warstwy głębokie} agregują te informacje, tworząc reprezentacje bardziej złożonych, semantycznych struktur (np. kształt telefonu, dłoń).
\end{itemize}

Istotnym elementem architektury są również warstwy łączące (ang. \textit{Pooling}). Ich zadaniem jest redukcja wymiarowości danych (ang. \textit{downsampling}), co zmniejsza zapotrzebowanie na moc obliczeniową i zapobiega przeuczeniu się modelu (ang. \textit{overfitting}), wymuszając na sieci naukę cech ogólnych, niezależnych od drobnych przesunięć obiektu. Ogólny schemat omawianej architektury przedstawiono na Rysunku \ref{fig:cnn_structure}.

\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{cnn_schema.png} % Tu twoja nazwa pliku
    \caption{Ogólny schemat architektury Konwolucyjnej Sieci Neuronowej. Źródło: \cite{dnn_overview_img}.}
    \label{fig:cnn_structure}
\end{figure}

\section{Architektura detekcji obiektów – YOLOv8}

W systemach monitoringu czasu rzeczywistego kluczowym parametrem, obok precyzji, jest czas inferencji. Klasyczne detektory dwuetapowe (np. R-CNN) oferują wysoką dokładność, lecz są zbyt wolne dla dynamicznych zastosowań szkolnych. Z tego względu w projekcie wykorzystano architekturę jednostadialną YOLO (You Only Look Once).

W ramach implementacji zdecydowano się na wariant \textbf{YOLOv8m (medium)}, zapewniający równowagę między dokładnością detekcji a czasem inferencji. System wyposażono również w mechanizm \textit{fallbacku}, który weryfikuje dostępność pliku wag modelu domyślnego. W przypadku jego braku (np. błędu wdrożeniowego), aplikacja automatycznie inicjuje lżejszy wariant \textbf{YOLOv8s (small)}, zapewniając ciągłość działania systemu bez konieczności ręcznej rekonfiguracji.

Model YOLO traktuje problem detekcji jako pojedyncze zadanie regresji, przewidując jednocześnie ramki ograniczające (ang. \textit{bounding boxes}) oraz prawdopodobieństwo przynależności do klasy \cite{yolov8docs}. Wybrana wersja, YOLOv8, wprowadza istotną zmianę w stosunku do poprzedników – jest to model typu \textit{anchor-free} \cite{terven2023yolo}. Oznacza to rezygnację ze sztywno zdefiniowanych ramek kotwiczących na rzecz bezpośredniej predykcji środka obiektu. Jest to szczególnie istotne w kontekście detekcji smartfonów, które mogą być trzymane pod niestandardowymi kątami, co utrudniałoby dopasowanie do predefiniowanych wzorców. Szczegółowy schemat omawianej architektury zaprezentowano na Rysunku \ref{fig:yolov8_arch}.

\clearpage % Wymusza nową stronę dla dużego schematu
\newgeometry{margin=1cm} % Zmniejsza marginesy, aby schemat był czytelny

\begin{figure}[H]
    \centering
    % Obrazek zajmie maksymalną dostępną przestrzeń
    \includegraphics[width=1.0\textwidth, height=0.9\textheight, keepaspectratio]{yolov8_arch.png} 
    \caption{Szczegółowy schemat architektury modelu YOLOv8. Źródło: \cite{yolov8_rangeking}.}
    \label{fig:yolov8_arch}
\end{figure}

\restoregeometry % Przywraca normalne marginesy dla reszty tekstu

Struktura modelu składa się z trzech głównych modułów (widocznych na powyższym schemacie):
\begin{enumerate}
    \item \textbf{Backbone (Szkielet):} Oparta na architekturze CSPDarknet część sieci odpowiedzialna za ekstrakcję map cech z obrazu wejściowego.
    \item \textbf{Neck (Szyja):} Wykorzystuje strukturę PANet (Path Aggregation Network) do łączenia cech z różnych poziomów skali, co pozwala na skuteczną detekcję obiektów o zróżnicowanych rozmiarach.
    \item \textbf{Head:} Część wyjściowa, realizująca w sposób odseparowany zadania klasyfikacji obiektu oraz regresji jego współrzędnych.
\end{enumerate}
\section{Przetwarzanie wstępne i ochrona prywatności}

Skuteczność detekcji w przestrzeniach monitorowanych jest często ograniczona przez zmienne oświetlenie. Aby zminimalizować wpływ zacienienia (np. czarny telefon na tle ciemnej odzieży), zastosowano dwuetapowy preprocessing obrazu przed przekazaniem go do modelu detekcji.

\paragraph{Etap 1: CLAHE (ang. \textit{Contrast Limited Adaptive Histogram Equalization})} \cite{opencv_clahe}.
Operacja ta nie jest wykonywana bezpośrednio na obrazie RGB, lecz po uprzedniej konwersji do przestrzeni barw \textbf{Lab}. Przestrzeń ta rozdziela informację o jasności (kanał \textbf{L}) od informacji o barwie, reprezentowanej przez dwa kanały chrominancji: \textbf{a} (zakres barw od zieleni do czerwieni) oraz \textbf{b} (zakres od błękitu do żółci). Operacja adaptacyjnego wyrównania histogramu aplikowana jest wyłącznie na kanale jasności (\textbf{L}). Pozwala to na wydobycie szczegółów z cienia poprzez poprawę lokalnego kontrastu, bez ingerencji w wartości kanałów barwnych (\textbf{a} i \textbf{b}), co zapobiega powstawaniu nienaturalnych przekłamań kolorystycznych.

\paragraph{Etap 2: Unsharp Masking (wyostrzanie krawędzi).}
Oprócz wyrównania kontrastu, zastosowano również technikę wyostrzania przez odjęcie rozmycia (zastosowano filtr Gaussa) \cite{opencv_arithmetic}. Matematycznie metoda ta polega na dodaniu do oryginalnego obrazu maski krawędziowej, przemnożonej przez wagę $\alpha=0.5$. Wzór wyjściowy ma postać: $Output = Original + 0.5 \cdot (Original - Blurred)$. Po opuszczeniu nawiasów i zsumowaniu wartości dla obrazu oryginalnego ($1 + 0.5$), otrzymujemy ostateczną formę równania. Równanie (\ref{eq:unsharp}) przedstawia wynikową zależność zaimplementowaną w algorytmie:

\begin{equation}
    \label{eq:unsharp}
    \text{output} = 1.5 \cdot \text{original} - 0.5 \cdot \text{blurred}
\end{equation}

Dzięki temu telefony trzymane w ręku mają wyraźniejsze kontury, co ułatwia ich wykrycie przez model nawet przy niskim kontraście między urządzeniem a tłem.

\subsection{Ochrona prywatności}

Istotnym wymaganiem niefunkcjonalnym systemu była ochrona wizerunku osób monitorowanych. Detekcja samej twarzy jest niewystarczająca z punktu widzenia anonimizacji, gdyż nie obejmuje osób odwróconych tyłem lub bokiem. W systemie zaimplementowano dwuetapowy potok przetwarzania:
\begin{enumerate}
    \item \textbf{Detekcja głów:} Wykorzystanie pomocniczego modelu (z repozytorium Roboflow \cite{roboflow_heads}) do lokalizacji obszaru głowy, niezależnie od jej orientacji.
    \item \textbf{Nieodwracalna anonimizacja:} Na wykryty obszar nakładany jest filtr Gaussa o wysokim promieniu rozmycia. Jest to operacja matematycznie nieodwracalna, co uniemożliwia rekonstrukcję wizerunku i identyfikację biometryczną osób.
\end{enumerate}

Z punktu widzenia architektury oprogramowania, proces anonimizacji został odseparowany od głównego wątku detekcji. Realizowany jest on asynchronicznie w dedykowanym wątku roboczym. Takie podejście gwarantuje, że kosztowna obliczeniowo operacja rozmycia obrazu nie wpływa na wydajność głównej pętli programu, umożliwiając zachowanie płynności detekcji w czasie rzeczywistym.

\section{Metodyka ewaluacji modelu}

W celu obiektywnej oceny skuteczności zaimplementowanego rozwiązania, przyjęto zestaw standardowych metryk stosowanych w zadaniach detekcji obiektów \cite{sklearn_metrics}. Pozwalają one na ilościowe określenie, jak dobrze system radzi sobie z rozróżnianiem telefonów od tła oraz innych przedmiotów szkolnych.

Podstawą analizy jest macierz pomyłek (ang. \textit{Confusion Matrix})\cite{sklearn_metrics}, interpretowana w kontekście detekcji w następujący sposób:

\begin{itemize}
    \item \textbf{True Positive (TP):} Prawidłowe wykrycie telefonu. System wygenerował ramkę otaczającą rzeczywisty smartfon.
    \item \textbf{False Positive (FP):} Fałszywy alarm. System błędnie oznaczył jako telefon inny obiekt (np. piórnik) lub wykrył obiekt w pustym miejscu.
    \item \textbf{False Negative (FN):} Przeoczenie. Telefon znajdował się w kadrze, ale system go nie wykrył.
\end{itemize}

Na podstawie powyższych wartości wyznaczane są dwa kluczowe wskaźniki jakości:

\begin{enumerate}
    \item \textbf{Precyzja (ang. \textit{Precision}):}
    Określa prawdopodobieństwo, że wykryty obiekt faktycznie należy do poszukiwanej klasy. Wyraża się wzorem (\ref{eq:precision}):
    
    \begin{equation}
        \label{eq:precision}
        \text{Precision} = \frac{TP}{TP + FP}
    \end{equation}
    
    W kontekście nadzoru wysoka precyzja jest priorytetem, aby zminimalizować liczbę fałszywych alarmów, które mogłyby podważyć wiarygodność systemu.

    \item \textbf{Czułość (ang. \textit{Recall}):}
    Określa zdolność systemu do wykrywania wszystkich wystąpień obiektu w kadrze. obliczana jest z zależności (\ref{eq:recall}):
    
    \begin{equation}
        \label{eq:recall}
        \text{Recall} = \frac{TP}{TP + FN}
    \end{equation}
    
    Wysoka czułość oznacza, że system rzadko przepuszcza incydenty, co jest kluczowe dla skuteczności monitoringu.
\end{enumerate}

Kryterium decydującym o tym, czy dana detekcja zostanie zaklasyfikowana jako poprawna (TP) czy błędna (FP), jest metryka \textbf{IoU} (ang. \textit{Intersection over Union})\cite{rezatofighi2019giou}. Mierzy ona stopień nakładania się ramki przewidzianej przez sieć z ramką referencyjną (oznaczoną ręcznie) obliczana ze wzoru (\ref{eq:iou}):

\begin{equation}
    \label{eq:iou}
    \text{IoU} = \frac{\text{Obszar części wspólnej (Intersection)}}{\text{Obszar sumy (Union)}}
\end{equation}

W projekcie przyjęto standardowy próg $IoU \geq 0.5$. Oznacza to, że detekcja uznawana jest za trafną tylko wtedy, gdy wyznaczony obszar pokrywa się z rzeczywistym położeniem telefonu w co najmniej 50\%.

% ROZDZIAŁ 4
% -------------------------------------------------------------------
\chapter{Implementacja systemu}

W niniejszym rozdziale przedstawiono szczegóły implementacyjne systemu detekcji smartfonów. Na wstępie omówiono wykorzystany stos technologiczny, uzasadniając dobór narzędzi do przetwarzania obrazu oraz budowy interfejsu webowego. Następnie zaprezentowano ogólną architekturę rozwiązania oraz projekt struktury bazy danych. W dalszej części rozdziału skoncentrowano się na kluczowych mechanizmach systemu, takich jak wielowątkowe przetwarzanie potoku wideo, obsługa snapshotów obrazu do konfiguracji stref nadzoru oraz implementacja modułów zapewniających anonimizację i ochronę prywatności.

\section{Środowisko programistyczne i biblioteki}

System łączy technologie uczenia maszynowego po stronie serwera z interfejsem użytkownika. Taki wybór architektury umożliwia efektywne przetwarzanie obrazu w czasie rzeczywistym przy zachowaniu responsywnego interfejsu. Dobór stosu technologicznego podyktowany był koniecznością zapewnienia niskich opóźnień.

\subsection{Warstwa serwerowa (ang. \textit{Backend})}
Jako podstawowy język implementacji logiki biznesowej wybrano Python. Wybór podyktowany był dostępnością zoptymalizowanych bibliotek do obsługi sieci neuronowych (Torch \cite{pytorch_neurips}, OpenCV) oraz łatwością integracji warstwy logicznej z API. Do kluczowych komponentów tej warstwy należą:

\begin{itemize}
    \item \textbf{Flask:} Mikroramowy framework webowy, wykorzystany do stworzenia serwera aplikacji. W przeciwieństwie do rozbudowanych rozwiązań typu Django \cite{django_docs}, Flask pozwolił na implementację wyłącznie niezbędnych funkcjonalności (obsługa routingu HTTP, streaming wideo), co zminimalizowało narzut wydajnościowy.
    \item \textbf{OpenCV (Open Source Computer Vision Library):} Biblioteka odpowiedzialna za niskopoziomowe operacje na macierzach obrazu. W projekcie wykorzystano ją do akwizycji klatek z kamery, konwersji przestrzeni barw oraz wstępnego przetwarzania obrazu.
    \item \textbf{Ultralytics YOLO:} Biblioteka zapewniająca interfejs programistyczny do modelu detekcji YOLOv8m. Umożliwia ona bezpośrednią inferencję na klatkach obrazu oraz obsługę mechanizmów optymalizacyjnych, takich jak automatyczny fallback do lżejszego modelu.
    \item \textbf{Threading i Queue:} Standardowe moduły biblioteki standardowej Pythona wykorzystane do implementacji współbieżności. Były niezbędne do odseparowania procesu pobierania obrazu od operacji zapisu na dysku.
\end{itemize}

\subsection{Warstwa prezentacji (ang. \textit{Frontend})}
Interfejs użytkownika został zrealizowany jako aplikacja typu SPA (Single Page Application), co zapewnia płynność działania bez konieczności przeładowywania strony. Wykorzystano następujące technologie:

\begin{itemize}
    \item \textbf{React:} Biblioteka języka JavaScript służąca do budowy reaktywnych interfejsów. Pozwoliła na podział widoku na niezależne komponenty (np. panel podglądu, lista logów).
    \item \textbf{TypeScript:} Nadzbiór języka JavaScript wprowadzający statyczne typowanie. Jego zastosowanie pozwoliło na wyeliminowanie błędów związanych z niezgodnością typów danych na etapie kompilacji, co jest kluczowe przy obsłudze struktur JSON pobieranych z API.
    \item \textbf{Material UI (MUI):} Biblioteka gotowych komponentów graficznych \cite{mui_docs}, zapewniająca spójny i ergonomiczny wygląd aplikacji (zgodny z wytycznymi Material Design) oraz responsywność interfejsu.
    \item \textbf{Axios:} Klient HTTP oparty na obietnicach (ang. \textit{Promises}) \cite{axios_docs}, służący do asynchronicznej komunikacji z serwerem Flask (pobieranie historii zdarzeń).
\end{itemize}

\section{Architektura systemu}

System zaprojektowano w architekturze klient-serwer, gdzie komunikacja odbywa się poprzez protokół HTTP (REST API) do wymiany danych sterujących oraz przesyłu obrazu wideo (snapshoty do konfiguracji stref nadzoru).

Serwer (Backend) pełni rolę zarządcy zasobów sprzętowych – inicjalizuje kamerę, ładuje modele AI do pamięci i udostępnia końcówki (endpoints) dla aplikacji webowej. Aplikacja webowa (Frontend) działa w przeglądarce internetowej, wizualizując stan systemu i umożliwiając konfigurację stref nadzoru. Schemat architektury rozwiązania przedstawiono na Rysunku \ref{fig:architecture}.

% [OBRAZEK 1: Diagram architektury]
\begin{figure}[H]
    \centering
    \includegraphics[width=0.9\textwidth]{system_architecture_diagram.png} % Pamiętaj o ścieżce images/
    \caption{Schemat architektury systemu z uwzględnieniem przepływu danych między modułami Backend i Frontend. Źródło: Opracowanie własne.}
    \label{fig:architecture}
\end{figure}

\section{Projekt bazy danych}

Ze względu na lokalny charakter wdrożenia oraz potrzebę łatwej migracji, jako silnik bazy danych wybrano SQLite \cite{sqlite_docs}. Jest to rozwiązanie bezserwerowe, w którym cała baza przechowywana jest w jednym pliku na dysku. Wykorzystano technologię mapowania obiektowo-relacyjnego (ORM \cite{fowler_orm}) za pośrednictwem biblioteki SQLAlchemy \cite{sqlalchemy_docs}.

System operuje na trzech głównych encjach, których strukturę przedstawiono na diagramie (Rys. \ref{fig:db_schema}).

% [OBRAZEK 2: Schemat Bazy Danych]
\begin{figure}[h]
    \centering
    \includegraphics[width=1\textwidth]{database_schema.png}
    \caption{Diagram encji (ERD) uwzględniający rzeczywistą strukturę tabel i typy danych. Źródło: Opracowanie własne.}
    \label{fig:db_schema}
\end{figure}

Szczegółowa charakterystyka tabel:

\begin{itemize}
    \item \textbf{User:} Przechowuje dane operatorów systemu. Ze względów bezpieczeństwa hasła nie są zapisywane tekstem jawnym, lecz jako hash (biblioteka Werkzeug \cite{werkzeug_docs}). Tabela zawiera unikalną nazwę użytkownika oraz klucz główny.
    
    \item \textbf{Settings:} Tabela konfiguracyjna przechowująca ustawienia w formacie JSON. Takie podejście zapewnia elastyczność – zmiana struktury danych (np. dodanie nowego parametru do harmonogramu) nie wymaga migracji schematu bazy SQL.
    \begin{itemize}
        \item \texttt{schedule}: Harmonogram pracy kamer (godziny aktywności).
        \item \texttt{roi\_zones}: Tablica współrzędnych stref, w których detekcja smartfonów jest włączona.
        \item \texttt{config}: Ogólne parametry systemowe.
        \item \texttt{created\_at / updated\_at}: Znaczniki czasowe utworzenia i ostatniej modyfikacji ustawień.
    \end{itemize}

    \item \textbf{Detection:} Główna tabela logująca incydenty. Składa się z 7 kluczowych atrybutów:
    \begin{itemize}
        \item \texttt{id}: Unikalny identyfikator zdarzenia.
        \item \texttt{timestamp}: Czas wystąpienia (UTC).
        \item \texttt{location}: Nazwa strefy ROI.
        \item \texttt{confidence}: Poziom pewności modelu YOLOv8 (0.0 - 1.0).
        \item \texttt{image\_path}: Ścieżka do dowodowego pliku graficznego.
        \item \texttt{status}: Status obsługi zgłoszenia (np. 'Pending').
        \item \texttt{user\_id}: Klucz obcy powiązany z operatorem (wartość opcjonalna/nullable).
    \end{itemize}
\end{itemize}

\section{Implementacja kluczowych modułów}

W tej sekcji omówiono szczegóły techniczne rozwiązań, które miały krytyczny wpływ na wydajność i bezpieczeństwo systemu.

\subsection{Asynchroniczna anonimizacja (Klasa AnonymizerWorker)}

Operacje zapisu na dysku oraz wywołania zewnętrznych API (np. Roboflow) są czasochłonne. Wykonywanie ich w głównym wątku aplikacji powodowałoby zamrożenie obrazu wideo, co uniemożliwiłoby płynną detekcję w czasie rzeczywistym.

Aby rozwiązać ten problem, zaimplementowano klasę \texttt{AnonymizerWorker} dziedziczącą po \texttt{threading.Thread}. Klasa działa w osobnym wątku zgodnie ze wzorcem Producer-Consumer, pobierając zadania z kolejki FIFO (\texttt{queue.Queue}). Dzięki temu główny wątek odpowiedzialny za detekcję nie jest blokowany przez operacje anonimizacji.

Implementację kluczowej metody \texttt{run}, która przetwarza zadania asynchronicznie, przedstawiono na Listingu \ref{lst:worker_code}.

\begin{lstlisting}[language=Python, caption={Implementacja pętli głównej wątku anonimizacji (AnonymizerWorker).}, label={lst:worker_code}]
class AnonymizerWorker(threading.Thread):
    def run(self):
        """ Glowna petla workera - przetwarza zadania z kolejki """
        while self.is_running:
            try:
                # Pobranie zadania z kolejki (timeout zapobiega blokadzie)
                task_data = self.detection_queue.get(timeout=1)

                if task_data is None:
                    self.detection_queue.task_done()
                    break

                filepath = task_data.get('filepath')
                confidence = task_data.get('confidence', 0.0)
                zone_name = task_data.get('zone_name')
                should_blur = task_data.get('should_blur', True)

                # 1. Wywolanie zewnetrznego API do detekcji glow
                # 2. Aplikacja rozmycia (Gaussian Blur)
                if should_blur:
                    success = self._anonymize_faces(filepath)

                # 3. Zapis dowodu na dysk i dodanie wpisu do DB
                self._save_to_database(task_data)

                self.detection_queue.task_done()

            except Exception as e:
                logging.error(f"Blad w watku roboczym: {e}")
                try:
                    self.detection_queue.task_done()
                except:
                    pass
\end{lstlisting}

\subsection{Obsługa strumienia wideo i prywatność w podglądzie}

Przesyłanie obrazu do przeglądarki w celu konfiguracji stref ROI zrealizowano za pomocą dedykowanego punktu końcowego API (\texttt{/api/camera/config\_snapshot}). Endpoint ten zwraca pojedynczy snapshot obrazu z kamery w formacie JPEG.

Ze względów prywatności, przed wysłaniem obraz jest przetwarzany przez metodę \texttt{anonymize\_frame\_logic}, która wykrywa głowy uczniów za pomocą modelu Roboflow i zamazuje je filtrem Gaussa (kernel 99x99, sigma=30). Dzięki temu użytkownik może zaznaczać strefy nadzoru na już zanonimizowanym obrazie, co zapewnia ochronę prywatności uczniów podczas konfiguracji systemu, jeszcze przed rozpoczęciem monitoringu. Implementację tego mechanizmu przedstawiono na Listingu \ref{lst:config_snapshot}.

\begin{lstlisting}[language=Python, caption={Implementacja endpointu konfiguracji ROI z wbudowaną anonimizacją.}, label={lst:config_snapshot}]
@app.route('/api/camera/config_snapshot', methods=['GET'])
@login_required
def config_snapshot():
    """Endpoint zwracajacy zanonimizowany snapshot do konfiguracji ROI"""
    try:
        frame = camera_controller.get_last_frame()
        
        if frame is None:
            return jsonify({
                'error': 'Kamera jest zatrzymana. Uruchom kamere i sprobuj ponownie.'
            }), 409
        
        # Anonimizacja glow przed wyslaniem (Roboflow + Gaussian blur)
        anonymized_frame = camera_controller.anonymize_frame_logic(frame)
        
        # Kodowanie do formatu JPEG
        ret, buffer = cv2.imencode('.jpg', anonymized_frame, 
                                   [cv2.IMWRITE_JPEG_QUALITY, 85])
        if not ret:
            raise Exception("Nie udalo sie zakodowac obrazu na JPEG.")
        
        return Response(buffer.tobytes(), mimetype='image/jpeg')
        
    except Exception as e:
        logger.error(f"Error in config_snapshot: {e}")
        return jsonify({'error': str(e)}), 500
\end{lstlisting}

\subsection{Moduł powiadomień i obsługa zdarzeń}

System obsługi incydentów zaprojektowano w architekturze dwuwarstwowej. Każde zatwierdzone wykrycie (po przejściu filtrów pewności i blokad czasowych) skutkuje równoległym uruchomieniem procedury rejestracji wewnętrznej oraz wysyłki powiadomień zewnętrznych.

\subsubsection{Warstwa rejestracji i powiadamiania}

Realizację techniczną kanałów komunikacji oparto na dedykowanych bibliotekach Pythona, integrując system z zewnętrznymi dostawcami usług (SaaS):

\begin{enumerate}
    \item \textbf{Baza danych i Dashboard:} Jest to podstawowy kanał informacyjny. Dane o incydencie (czas, strefa, pewność) trafiają do tabeli \texttt{Detection} (obsługiwanej przez silnik SQLAlchemy), a interfejs webowy pobiera je w czasie rzeczywistym.

    \item \textbf{Cloudinary (przechowywanie w chmurze):} System opcjonalnie wykorzystuje usługę Cloudinary \cite{cloudinary_docs} do przechowywania zanonimizowanych obrazów w chmurze. Po zakończeniu procesu anonimizacji, obraz jest automatycznie przesyłany poprzez metodę \texttt{\_upload\_to\_cloudinary}. Usługa zwraca publiczny link HTTPS, który jest następnie dołączany do wiadomości SMS oraz e-mail, umożliwiając nauczycielowi szybki dostęp do dowodowego obrazu bez konieczności logowania się do systemu lokalnego.

    \item \textbf{SMS (Vonage):} Integracja z bramką SMS została zrealizowana przy użyciu klienta \texttt{vonage} \cite{vonage_api}. Jeśli opcja jest aktywna, metoda \texttt{\_send\_sms\_notification} wysyła alert na zdefiniowany numer. Wiadomość SMS zawiera: czas wykrycia, lokalizację (strefę ROI), poziom pewności detekcji oraz link do obrazu w chmurze:

\begin{verbatim}
Phone Detection Alert!
Time: 2025-11-23 14:30:15
Location: Lawka 5
Confidence: 85.00%
Image: https://res.cloudinary.com/...
\end{verbatim}
    
    \item \textbf{E-mail (Gmail + Yagmail):} Do obsługi poczty wykorzystano bibliotekę \textbf{yagmail} \cite{yagmail_repo}. W przeciwieństwie do standardowego \texttt{smtplib}, biblioteka ta automatycznie zarządza bezpiecznym połączeniem (TLS). Wiadomości e-mail są hybrydowe: zawierają zarówno link do Cloudinary, jak i obraz osadzony bezpośrednio w treści (inline), co zapewnia niezawodność dostępu do dowodów.
\end{enumerate}

\subsubsection{Mechanizm ograniczania częstotliwości}

Aby zapobiec zjawisku "zalewania" systemu powiadomieniami (np. gdy uczeń trzyma telefon w ręku przez dłuższą chwilę), zaimplementowano mechanizm dławienia (ang. \textit{throttling}). Działa on niezależnie dla każdej strefy nadzoru.

W sterowniku kamery zdefiniowano słownik \texttt{alert\_mute\_until}, chroniony blokadą wątku (\texttt{threading.Lock}). Logika filtracji przebiega następująco:

\begin{itemize}
    \item Po wykryciu obiektu, system sprawdza, czy dla danej strefy istnieje aktywna blokada czasowa.
    \item \textbf{Jeśli blokada jest aktywna:} Całe zdarzenie jest ignorowane. System nie zapisuje rekordu w bazie danych ani nie wysyła powiadomień, logując jedynie informację techniczną o pominięciu klatki. Zapobiega to redundancji danych.
    \item \textbf{Jeśli blokada nie istnieje (lub wygasła):} System przetwarza zgłoszenie (upload do Cloudinary, zapis do bazy, wysyłka SMS/Email) i ustawia nową blokadę na okres \textbf{5 minut} dla tej konkretnej strefy.
\end{itemize}
% ROZDZIAŁ 5
% -------------------------------------------------------------------
\chapter{Konfiguracja i środowisko testowe}

Celem niniejszego rozdziału jest zdefiniowanie warunków, w jakich uruchomiono i przetestowano system detekcji. Precyzyjne określenie specyfikacji sprzętowej oraz parametrów programowych pozwala na powtarzalność badań i rzetelną ocenę uzyskanych wyników.

\section{Platforma sprzętowa}

Środowisko testowe uruchomiono na laptopie marki Asus, który odpowiadał za analizę obrazu w czasie rzeczywistym. Strumień wideo dostarczany był bezprzewodowo przy użyciu smartfona iPhone 14 Pro, wykorzystanego w charakterze kamery sieciowej.

Specyfikacja jednostki obliczeniowej:
\begin{itemize}
    \item \textbf{Model komputera:} Asus X515JA-BQ1991W
    \item \textbf{Procesor (CPU):} Intel Core i5-1035G1
    \item \textbf{Pamięć RAM:} 16 GB
    \item \textbf{System operacyjny:} Windows 11 Home
\end{itemize}

Specyfikacja układu wizyjnego:
\begin{itemize}
    \item \textbf{Urządzenie rejestrujące:} Apple iPhone 14 Pro
    \item \textbf{Transmisja danych:} Oprogramowanie \textit{Iriun Webcam} (transmisja wideo po sieci Wi-Fi/USB).
    \item \textbf{Rozdzielczość wejściowa:} \textbf{1280x720 pikseli (HD)}. Aplikacja programowo wymusza tryb 720p jako priorytetowy, zachowując kompatybilność w dół do rozdzielczości VGA (640x480) w przypadku starszego sprzętu.
\end{itemize}
Zastosowanie smartfona wysokiej klasy zamiast standardowej kamery internetowej pozwoliło na uzyskanie obrazu o wysokiej dynamice tonalnej (HDR) i ostrości, co jest kluczowe przy detekcji małych obiektów z większej odległości.

\section{Środowisko programistyczne}

Aplikacja została uruchomiona w środowisku wirtualnym języka Python. Zgodnie z plikiem konfiguracyjnym projektu, wykorzystano kluczowe biblioteki w wersjach, które zestawiono w Tabeli \ref{tab:software_versions}.

\begin{table}[H]
    \centering
    \caption{Wersje kluczowych komponentów programowych.}
    \label{tab:software_versions}
    \begin{tabular}{|l|l|l|}
    \hline
    \textbf{Komponent} & \textbf{Wersja} & \textbf{Zastosowanie} \\ \hline
    Python & 3.12 & Język interpretera (Backend) \\ \hline
    Flask  & 3.0.2 & Serwer aplikacji webowej \\ \hline
    OpenCV-Python  & 4.9.0 & Przetwarzanie macierzy obrazu \\ \hline
    Ultralytics  & 8.1.2 & Implementacja modelu YOLOv8 \\ \hline
    SQLAlchemy  & 2.0.43 & Obsługa bazy danych (ORM) \\ \hline
    \end{tabular}
\end{table}

\section{Proces uruchomienia systemu}

Przed rozpoczęciem testów, system wymagał wstępnej konfiguracji środowiska. Proces instalacji i uruchomienia składał się z następujących kroków:

\subsection{Instalacja zależności}

System wymaga zainstalowania zależności dla obu warstw aplikacji:

\begin{enumerate}
    \item \textbf{Backend (Python):} Instalacja bibliotek z pliku \texttt{requirements.txt} poprzez polecenie \texttt{pip install -r requirements.txt}. W środowisku testowym wykorzystano wirtualne środowisko Pythona, co zapewnia izolację zależności projektu.
    
    \item \textbf{Frontend (React):} Instalacja pakietów Node.js poprzez polecenie \texttt{npm install}. Wszystkie zależności frontendowe są zdefiniowane w pliku \texttt{package.json}.
\end{enumerate}

\subsection{Inicjalizacja bazy danych}

Przed pierwszym uruchomieniem, system wymaga inicjalizacji bazy danych SQLite. Proces ten realizowany jest poprzez skrypt \texttt{init\_db.py}, który tworzy strukturę tabel (User, Settings, Detection) oraz domyślne konto administratora:
\begin{itemize}
    \item Nazwa użytkownika: \texttt{admin}
    \item Hasło: \texttt{admin}
\end{itemize}

\subsection{Uruchomienie aplikacji}

System składa się z dwóch niezależnych procesów, które muszą być uruchomione równolegle w osobnych terminalach:

\begin{itemize}
    \item \textbf{Backend (Flask):} Uruchamiany poprzez polecenie \texttt{flask run --debug --no-reload}, działający na porcie 5000. Serwer inicjalizuje kamerę, ładuje modele AI (YOLOv8, Roboflow) oraz udostępnia endpointy REST API.
    
    \item \textbf{Frontend (React):} Uruchamiany poprzez polecenie \texttt{npm start}, działający na porcie 3000 i automatycznie przekierowujący żądania API do backendu. Interfejs jest dostępny pod adresem \texttt{http://localhost:3000}.
\end{itemize}

Po uruchomieniu obu procesów, użytkownik loguje się do panelu administracyjnego, gdzie może skonfigurować parametry systemu.

\section{Konfiguracja modelu detekcyjnego}

W projekcie zastosowano model \textbf{YOLOv8m} (wariant \textit{Medium}), który oferuje kompromis między szybkością działania a precyzją detekcji. System wyposażono w mechanizm \textit{fallback}, który w przypadku braku pliku wag modelu średniego automatycznie ładuje lżejszą wersję \textit{YOLOv8s} (\textit{Small}).

Parametry detekcji skonfigurowano następująco:
\begin{itemize}
    \item \textbf{Rozmiar wejściowy (imgsz):} 640 pikseli (automatyczne skalowanie przez bibliotekę Ultralytics).
    \item \textbf{Próg IoU (NMS):} 0.7 (standardowa wartość dla eliminacji nakładających się ramek).
    \item \textbf{Próg pewności (Confidence Threshold):} \textbf{0.20}.
\end{itemize}

Domyślny próg detekcji w YOLOv8 wynosi 0.25. W toku eksperymentów zdecydowano się na programowe obniżenie efektywnego progu do wartości \textbf{0.20}. Szczegółowy proces doboru tej wartości oraz uzasadnienie decyzji przedstawiono w sekcji 5.5.

Poniższy fragment kodu (Listing \ref{lst:threshold_config}) prezentuje implementację filtru pewności w klasie sterownika kamery:

\begin{lstlisting}[language=Python, caption={Konfiguracja niestandardowego progu detekcji i flagi anonimizacji w CameraController.}, label={lst:threshold_config}]
# Ustawienia detekcji w klasie CameraController
self.settings = {
    'confidence_threshold': 0.2,  # Obnizony prog (20%) dla trudnych warunkow
    'blur_faces': True            # Domyslnie wlaczona anonimizacja (zmienna blur_faces)
}
# ID klasy 'cell phone' w modelu COCO (definiowane jako stala)
self.phone_class_id = 67

# (...)
# Zastosowanie filtru w petli przetwarzania:
if class_id == self.phone_class_id and confidence >= self.settings['confidence_threshold']:
    # Akceptacja detekcji i obsluga zdarzenia
    self._handle_detection(frame_copy, confidence, matched_zone)
\end{lstlisting}

\section{Kalibracja parametrów detekcji}

Kluczowym etapem przygotowania systemu do pracy był dobór optymalnych parametrów detekcji, które zapewniają wysoką skuteczność wykrywania telefonów przy jednoczesnym minimalizowaniu fałszywych alarmów.

\subsection{Proces doboru progu pewności}

Początkowo system wykorzystywał domyślny próg pewności YOLOv8 (0.25). W toku eksperymentów przetestowano różne wartości progu w zakresie od 0.10 do 0.50, analizując wpływ tego parametru na liczbę detekcji oraz eliminację fałszywych alarmów generowanych przez obiekty zakłócające (np. przybory szkolne).

Wyniki testów wykazały, że:
\begin{itemize}
    \item \textbf{Próg 0.05-0.15:} Zbyt niski – system generował liczne fałszywe alarmy, myląc telefony z kalkulatorami oraz piórnikami.
    
    \item \textbf{Próg 0.20:} Optymalny kompromis – system skutecznie wykrywał telefony w trudnych warunkach (nisko pod ławką, częściowo zasłonięte dłonią), przy akceptowalnej liczbie przypadków fałszywie pozytywnych. Podniesienie progu do 0.20 zmniejszyło wskaźnik błędnej klasyfikacji kalkulatorów, przy jednoczesnym zachowaniu wysokiej czułości na prawdziwe telefony.
    
    \item \textbf{Próg 0.30-0.50:} Zbyt wysoki – system pomijał wiele prawdziwych detekcji telefonów, szczególnie gdy urządzenie było trzymane pod niestandardowym kątem lub znajdowało się w dużej odległości od kamery.
\end{itemize}

\section{Interfejs konfiguracyjny systemu}

Integralną częścią systemu jest panel administracyjny (Rys. \ref{fig:settings_ui}), który umożliwia operatorowi pełną kontrolę nad parametrami pracy aplikacji. Interfejs został zaprojektowany w sposób modułowy, gdzie każda część odpowiada za konfigurację odrębnego aspektu systemu.

% Przeniesiono rysunek tutaj, aby był pierwszy (Fig 5.1)
\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{settings_page.png} % Upewnij się co do ścieżki images/
    \caption{Panel konfiguracyjny systemu. Widoczny podział na 7 modułów funkcjonalnych.}
    \label{fig:settings_ui}
\end{figure}

Na podstawie widoku panelu sterowania, wyróżnić można następujące grupy ustawień:

\begin{enumerate}
    \item \textbf{Camera Control:} Główny moduł sterujący, pozwalający na ręczne uruchamianie (\textit{Start Camera}) i zatrzymywanie (\textit{Stop Camera}) kamery. Widoczna dioda statusu informuje o bieżącym stanie procesu.
    
    \item \textbf{Camera Schedule:} Moduł harmonogramu, umożliwiający zdefiniowanie godzin, w których monitoring ma być aktywny automatycznie (np. tylko w trakcie trwania zajęć lekcyjnych), co pozwala na oszczędność zasobów obliczeniowych.
    
    \item \textbf{Detection Settings:} Sekcja kluczowa dla skuteczności systemu. Pozwala na regulację progu pewności (\textit{Confidence Threshold}). To tutaj ustawiono eksperymentalną wartość \textbf{0.20}, opisaną w sekcji 5.5.
    
    \item \textbf{Definiowanie Stref ROI:} Zaawansowany interfejs graficzny umożliwiający precyzyjne wyznaczenie obszarów objętych analizą. Funkcja ta pełni potrójną rolę:
    \begin{itemize}
        \item \textbf{Eliminacja obszarów zbędnych:} Wyłączenie z analizy ścian, okien czy podłogi w celu optymalizacji mocy obliczeniowej.
        \item \textbf{Zarządzanie wyjątkami:} Wyeliminowanie alarmów z miejsc, gdzie użycie telefonu jest dozwolone, np. \textbf{biurko prowadzącego} lub stanowisko ucznia korzystającego ze smartfona ze \textbf{względów zdrowotnych} (np. monitoring glikemii).
        \item \textbf{Logika powiadomień:} Zdefiniowane strefy są powiązane z mechanizmem \textit{throttlingu}. System rozpoznaje incydent w konkretnej strefie (np. Ławka 5) i wycisza powiadomienia dla tego konkretnego miejsca na 5 minut, nie blokując alertów z innych ławek.
    \end{itemize}
    
    Zrzut ekranu (Rys. \ref{fig:roi_interface}) prezentuje interfejs konfiguracji stref ROI uruchomiony w środowisku deweloperskim. Przedstawiona funkcjonalność automatycznego generowania siatki (grid) została zaprojektowana w celu szybkiego mapowania układu ławek w docelowej sali lekcyjnej. Widoczna na ilustracji siatka 21 stref demonstruje elastyczność konfiguratora, a zanonimizowana sylwetka operatora potwierdza poprawne działanie modułu ochrony prywatności w czasie rzeczywistym, jeszcze na etapie kalibracji systemu.
    
    % Ten rysunek będzie teraz drugi (Fig 5.2)
    \begin{figure}[H]
        \centering
        \includegraphics[width=0.95\textwidth]{moj_pokoj.png} 
        \caption{Interfejs konfiguracji stref ROI. Prezentacja funkcji generowania siatki stref oraz mechanizmu anonimizacji operatora w strumieniu wideo czasu rzeczywistego.}
        \label{fig:roi_interface}
    \end{figure}
    
    \item \textbf{Privacy Settings:} Zarządzanie modułem ochrony danych osobowych. Umożliwia globalne włączenie lub wyłączenie algorytmu anonimizacji.
    
    \item \textbf{Camera Selection:} Menu wyboru źródła sygnału wideo. Pozwala na łatwe przełączanie się między wbudowaną kamerą laptopa a zewnętrznym strumieniem z urządzenia mobilnego.
    
    \item \textbf{Notification Settings:} Konfiguracja kanałów alertowych. Moduł służy do aktywacji powiadomień zewnętrznych (SMS, E-mail).
\end{enumerate}

Zaprojektowany interfejs graficzny pełni rolę demonstracyjną (\textit{Proof of Concept}), weryfikując możliwość integracji zaawansowanych algorytmów AI z prostym panelem sterowania. Stanowi on bazę do dalszych prac rozwojowych nad systemem docelowym dla placówek edukacyjnych.

% -------------------------------------------------------------------
% SEKCJA 5.7
% -------------------------------------------------------------------
\section{Charakterystyka środowiska fizycznego}
\label{sec:env_char}

Aby w pełni zweryfikować działanie systemu, testy zrealizowano w dwóch różnych środowiskach, odmiennych pod względem wielkości, warunków oświetleniowych oraz przeznaczenia. Pozwoliło to sprawdzić działanie algorytmu zarówno w sali wykładowej, jak i w sali wyciszenia. Stanowiska badawcze przedstawiono na Rysunku \ref{fig:test_environments}.

Charakterystyka wykorzystanych pomieszczeń:

\begin{enumerate}
    \item \textbf{Środowisko A: Sala Wykładowa (Układ rzędowy)}
    \begin{itemize}
        \item \textbf{Charakterystyka:} Duże pomieszczenie dydaktyczne o układzie rzędowym.
        \item \textbf{Oświetlenie:} Mieszane – silne światło dzienne (okna po prawej stronie) oraz oświetlenie sufitowe.
        \item \textbf{Scenariusz:} Studenci zajmowali miejsca w rzędach oddalonych od kamery o ok. 3 metry (pierwszy plan) oraz 5 metrów (drugi plan). Tło stanowiła ściana sali oraz inni studenci.
    \end{itemize}

    \item \textbf{Środowisko B: Sala Wyciszenia (Układ grupowy)}
    \begin{itemize}
        \item \textbf{Charakterystyka:} Mniejsze pomieszczenie przystosowane do pracy indywidualnej lub w małych zespołach.
        \item \textbf{Oświetlenie:} Światło boczne (okno po lewej) oraz sztuczne.
        \item \textbf{Scenariusz:} Symulacja pracy wspólnej przy jednym stole. Kamera ustawiona była w odległości ok. 2 metrów, co pozwoliło na precyzyjne testy zasłaniania telefonu dłonią oraz weryfikację detekcji detali na tle jasnych ścian i sprzętu elektronicznego.
    \end{itemize}
\end{enumerate}

W obu lokalizacjach na stołach znajdowały się naturalne obiekty zakłócające (laptopy, butelki), co miało na celu sprawdzenie odporności detektora na tzw. szum wizualny (ang. \textit{visual clutter}).

\begin{figure}[H]
    \centering
    % Obrazek 1: Sala wykładowa
    \includegraphics[width=1.0\textwidth]{sala.png} 
    \caption*{a) Sala wykładowa} 
    
    \vspace{1em} 

    % Obrazek 2: Sala Wyciszenia
    \includegraphics[width=1.0\textwidth]{Igor1233.png}
    \caption*{b) Sala wyciszenia} 
    
    % Główny podpis
    \caption{Zróżnicowane środowiska testowe wykorzystane w badaniach: a) układ rzędowy w dużej sali, b) układ grupowy w mniejszej sali. Źródło: Opracowanie własne.}
    \label{fig:test_environments}
\end{figure}
% -------------------------------------------------------------------
% ROZDZIAŁ 6
% -------------------------------------------------------------------
\chapter{Wyniki badań i weryfikacja w środowisku rzeczywistym}

Rozdział przedstawia wyniki testów walidacyjnych, przeprowadzonych w warunkach rzeczywistych. W odróżnieniu od testów laboratoryjnych, badania zrealizowano podczas zajęć dydaktycznych w środowisku dydaktycznym (sala wykładowa oraz sala wyciszenia), co pozwoliło na weryfikację odporności algorytmu na zmienne oświetlenie, perspektywę oraz dynamikę sceny.

Badania przeprowadzono przy udziale grupy studentów oraz prowadzącego, którzy zostali poinformowani o celu eksperymentu oraz zasadach działania mechanizmu anonimizacji.

\section{Metodyka i scenariusze testowe}

Weryfikacja skuteczności detekcji została przeprowadzona w oparciu o skalibrowany model YOLOv8 z progiem pewności ustawionym na poziomie 20\% ($Confidence \geq 0.20$). Zdefiniowano cztery scenariusze badawcze, mające na celu sprawdzenie działania systemu w zróżnicowanych warunkach oświetleniowych i przestrzennych:

\begin{enumerate}
    \item \textbf{Scenariusz A:} Detekcja bliskiego zasięgu.
    \item \textbf{Scenariusz B:} Detekcja obiektu statycznego w średnim planie (trudne tło).
    \item \textbf{Scenariusz C:} Detekcja obiektu oddalonego z elementem ruchu (Motion Blur).
    \item \textbf{Scenariusz D:} Weryfikacja logiki biznesowej i odporności na okluzję.
\end{enumerate}

\section{Analiza wizualna detekcji (Scenariusze A-C)}

Poniżej przedstawiono szczegółową analizę wyników uzyskanych dla poszczególnych stref sali wykładowej.

\subsection{Scenariusz A: Detekcja bliskiego zasięgu}
Prowadzący zajęcia, znajdujący się w strefie ,,Ławka 11'' (pierwszy rząd), trzymał telefon w dłoni w sposób naturalny. Odległość od kamery wynosiła około 2 metry.

\textbf{Wynik:} Ze względu na wyraźny kontur obiektu i brak zakłóceń, system osiągnął wysoki wskaźnik pewności detekcji wynoszący \textbf{51.5\%}. Potwierdza to, że dla obiektów pierwszoplanowych model działa z dużym zapasem pewności, co zilustrowano na Rysunku \ref{fig:res_close}.

\begin{figure}[H]
    \centering
    \includegraphics[width=1\textwidth]{prowadzacyyy.png} 
    \caption{Scenariusz A: Prowadzący w pierwszym rzędzie. Wysoka pewność detekcji (51.5\%). Źródło: Opracowanie własne.}
    \label{fig:res_close}
\end{figure}

\subsection{Scenariusz B: Obiekt statyczny na tle otoczenia}
W tym scenariuszu zweryfikowano zdolność modelu do wyodrębniania obiektów z tła. Telefon został położony płasko na blacie ławki (Strefa: Ławka 3), nie będąc trzymanym w dłoni.

\textbf{Wynik:} Mimo że obiekt zlewał się kolorystycznie z otoczeniem i był widoczny pod ostrym kątem, sieć neuronowa poprawnie go sklasyfikowała (zob. Rysunek \ref{fig:res_static}). Wskaźnik pewności wyniósł \textbf{30.1\%}. Jest to wynik niższy niż w Scenariuszu A, lecz wystarczający do aktywacji alarmu (przy progu 20\%).

\begin{figure}[H]
    \centering
    \includegraphics[width=1\textwidth]{lawka_3.png}
    \caption{Scenariusz B: Telefon leżący płasko na ławce. System poprawnie identyfikuje obiekt statyczny (30.1\%). Źródło: Opracowanie własne.}
    \label{fig:res_static}
\end{figure}

\subsection{Scenariusz C: Obiekt dynamiczny w dalekim planie}
Najtrudniejszym testem była próba detekcji w ostatnim rzędzie (Strefa: Ławka 2, ok. 5 metrów od kamery). Student uniósł telefon, wykonując szybki ruch ręką.

\textbf{Obserwacja (Motion Blur):} Zauważono, że w trakcie szybkiego ruchu kamera nie rejestrowała ostrego obrazu, co uniemożliwiło detekcję. System zadziałał w ułamku sekundy, w którym ręka została zatrzymana w górze.

\textbf{Wynik:} Pewność detekcji wyniosła \textbf{26.6\%}. Wynik ten oscyluje zaledwie 1.6 punktu procentowego powyżej domyślnego progu modelu YOLO (25\%). Tak niewielki zapas potwierdza zasadność decyzji o obniżeniu progu do 0.20, co gwarantuje utrzymanie bezpiecznego marginesu błędu w przypadku wystąpienia nieznacznie gorszych warunków. Wizualizację tego granicznego przypadku przedstawiono na Rysunku \ref{fig:res_far_motion}.

\begin{figure}[H]
    \centering
    \includegraphics[width=1\textwidth]{uniesiony.png}
    \caption{Scenariusz C: Detekcja na końcu sali w momencie stabilizacji ruchu. Wynik graniczny (26.6\%). Źródło: Opracowanie własne.}
    \label{fig:res_far_motion}
\end{figure}

\section{Scenariusz D: Weryfikacja logiki biznesowej}
\label{sec:scenario_d} % Etykieta dla tej sekcji

Oprócz samej skuteczności detekcji wizyjnej, kluczowym elementem testów była weryfikacja logiki backendu. Testy przeprowadzono w \textbf{Środowisku B (Sala Wyciszenia)}, opisanym w sekcji \ref{sec:env_char}, co pozwoliło na symulację pracy grupowej przy jednym stole oraz weryfikację detekcji w warunkach bliskiego zasięgu (ok. 2 metry od kamery). Przeanalizowano logi systemowe pod kątem poprawności zarządzania incydentami w czasie.

Dzięki zarejestrowaniu serii zdarzeń z udziałem dwóch użytkowników w krótkim odstępie czasu, uzyskano dowód na poprawne działanie mechanizmu \textbf{separacji stref}, \textbf{odporności na okluzję} (zasłonięcie) oraz \textbf{czasowej blokady powiadomień}. Poniżej przedstawiono chronologiczną analizę trzech kluczowych wpisów w bazie danych.

\vspace{0.5cm}
\textbf{Krok 1: Inicjacja blokady (Godzina 12:33:53)}

Pierwsze zdarzenie dotyczy strefy ,,Studenta B''. System wykrywa telefon z bardzo wysoką pewnością (\textbf{77.6\%}), co pokazano na Rysunku \ref{fig:logic_step1}. W tym momencie następuje wysłanie powiadomienia, a dla tej konkretnej strefy zostaje uruchomiony licznik czasu blokady (zapobiegający duplikacji zgłoszeń).

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{Igor1233.png}
    \caption{Zdarzenie T0 (12:33:53). Wyraźna detekcja w strefie ,,Studenta B'' uruchamiająca mechanizm wyciszania. Źródło: Opracowanie własne.}
    \label{fig:logic_step1}
\end{figure}

\vspace{0.5cm}
\textbf{Krok 2: Niezależność stref i okluzja (Godzina 12:34:05)}

Zaledwie 12 sekund później system wykrywa telefon w strefie sąsiedniej (,,Student A''), co uwidoczniono na Rysunku \ref{fig:logic_step2}.
\begin{itemize}
    \item \textbf{Separacja logiczna:} Mimo że strefa ,,Studenta B'' jest w trybie wyciszenia, system \textbf{prawidłowo przepuszcza alert dla Studenta A}. Jest to dowód na to, że każda strefa ROI posiada niezależny wątek logiczny.
    \item \textbf{Odporność na okluzję:} Student trzyma telefon w sposób, który w znacznym stopniu zasłania urządzenie dłonią. Wynik pewności \textbf{27.4\%} potwierdza, że przyjęta kalibracja (0.20) jest niezbędna. Przy domyślnym progu modelu YOLOv8 (0.25) zdarzenie to zostałoby wykryte, jednak margines bezpieczeństwa wynoszący zaledwie 2.4 punktu procentowego jest zbyt mały, aby zagwarantować stabilność działania. Obniżenie progu do 0.20 zapewnia niezbędny bufor.
\end{itemize}

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{Oskar.png}
    \caption{Zdarzenie T1 (12:34:05). Detekcja w strefie ,,Student A''. Widoczny spadek pewności detekcji (27.4\%) spowodowany okluzją. Źródło: Opracowanie własne.}
    \label{fig:logic_step2}
\end{figure}

\vspace{0.5cm}
\textbf{Krok 3: Ponowna aktywacja po czasie (Godzina 12:38:30)}

Kolejne zgłoszenie w strefie ,,Student B'' pojawia się po upływie blisko 5 minut od pierwszego incydentu (różnica 4 min 37 sek). Jak widać na Rysunku \ref{fig:logic_step3}, system poprawnie odfiltrował detekcje pośrednie, rejestrując dopiero nowe zdarzenie po upływie okresu oczekiwania.

\begin{figure}[H]
    \centering
    \includegraphics[width=1.0\textwidth]{igor.png}
    \caption{Zdarzenie T2 (12:38:30). Ponowna rejestracja incydentu w strefie ,,Student B'' w nowym oknie czasowym. Źródło: Opracowanie własne.}
    \label{fig:logic_step3}
\end{figure}

\section{Analiza ilościowa}

Podczas sesji testowej system zarejestrował łącznie \textbf{6 kluczowych zdarzeń}, których zbiorcze statystyki przedstawiono w Tabeli \ref{tab:wyniki_detekcji}.

\begin{table}[h!]
    \centering
    \caption{Podsumowanie skuteczności detekcji w badanej próbie. Źródło: Opracowanie własne.}
    \label{tab:wyniki_detekcji}
    % Ustawiamy szerokość tabeli na szerokość tekstu (\textwidth)
    % Kolumna 'X' automatycznie zawija tekst
    \begin{tabularx}{\textwidth}{|l|c|X|}
        \hline
        \textbf{Parametr} & \textbf{Wartość} & \textbf{Komentarz} \\
        \hline
        Trafienia (True Positives) & 6 (100\%) & Wykryto wszystkie telefony użyte w teście. \\
        \hline
        Błędy (False Positives) & 0 & W analizowanej próbie testowej nie wystąpiły fałszywe alarmy. \\
        \hline
        % Dodane wiersze, o które prosiła promotorka:
        Precyzja (Precision) & 100\% & Brak fałszywych detekcji oznacza maksymalną precyzję modelu. \\
        \hline
        Czułość (Recall) & 100\% & System nie pominął żadnego obiektu. \\
        \hline
        Zakres pewności & 26.6\% - 77.6\% & Zależny od odległości i stopnia przysłonięcia. \\
        \hline
    \end{tabularx}
\end{table}

\section{Wydajność sprzętowa i optymalizacja}

Testy przeprowadzono na standardowym laptopie (Intel Core i5-1035G1, brak dedykowanego GPU). 

Uzyskane parametry pracy:
\begin{itemize}
    \item \textbf{Czas inferencji (ang. \textit{Inference Time}):} Średnio 30-45 ms na klatkę.
    \item \textbf{Efektywny FPS:} Dzięki technice \textit{frame skipping} (analiza co 3. klatki) utrzymano płynność na poziomie \textbf{7-10 FPS}, co jest wartością wystarczającą dla monitoringu edukacyjnego.
    \item \textbf{Stabilność:} Zastosowanie architektury wielowątkowej zapobiegło utracie płynności obrazu podczas zapisu zdjęć na dysk (operacje wejścia/wyjścia).
\end{itemize}

\section{Wnioski końcowe z badań}

Przeprowadzone testy potwierdziły poprawność przyjętych założeń projektowych. 
\begin{enumerate}
    \item \textbf{Skuteczność detekcji:} Potwierdzono zasadność kalibracji progu do 0.20, co pozwoliło wykryć telefon na końcu sali oraz ten częściowo zasłonięty dłonią (przypadek Studenta A).
    \item \textbf{Logika biznesowa:} Analiza logów systemowych potwierdziła, że system skutecznie eliminuje duplikaty powiadomień, nie blokując przy tym detekcji z sąsiednich ławek.
    \item \textbf{Ochrona prywatności:} We wszystkich analizowanych przypadkach (w tym przy wysokim wyniku pewności 77.6\%) twarze studentów zostały poprawnie zanonimizowane.
\end{enumerate}
% -------------------------------------------------------------------
% ROZDZIAŁ 7
% -------------------------------------------------------------------
\chapter{Podsumowanie i wnioski końcowe}

Celem niniejszej pracy inżynierskiej było zaprojektowanie i implementacja systemu wizyjnego, którego zadaniem jest automatyczna detekcja telefonów komórkowych w przestrzeni monitorowanej. Bezpośrednią motywacją do realizacji projektu stał się narastający problem dekoncentracji i naruszeń regulaminu, szczególnie widoczny w środowisku szkolnym. System zaprojektowano jednak jako uniwersalne narzędzie techniczne, wspomagające operatora w zarządzaniu bezpieczeństwem w dowolnej zdefiniowanej strefie. Jako reprezentatywne środowisko do weryfikacji przyjętych założeń wybrano placówkę edukacyjną.

\section{Ocena stopnia realizacji celu}

Na podstawie przeprowadzonych prac projektowych, implementacyjnych oraz testów walidacyjnych w środowisku rzeczywistym (opisanych w Rozdziale 6), można stwierdzić, że założone cele pracy zostały zrealizowane.

Osiągnięto następujące rezultaty w zakresie funkcjonalnym:
\begin{itemize}
    \item \textbf{Skuteczność detekcji w zróżnicowanym środowisku:} Model YOLOv8 poprawnie identyfikuje telefony zarówno w dużej Sali Wykładowej (detekcja dalekiego zasięgu), jak i w mniejszej Sali Wyciszenia. W przeprowadzonych scenariuszach testowych system wykazał wysoką skuteczność (brak pominięć w badanej próbie) oraz odporność na trudne warunki, takie jak okluzja (częściowe zasłonięcie dłonią) czy niejednorodne tło.
    
    \item \textbf{Ochrona prywatności (ang. \textit{Privacy by Design}):} Zaimplementowano moduł anonimizacji, który w czasie rzeczywistym wykrywa i zamazuje twarze osób na zapisywanym materiale dowodowym, co realizuje techniczne założenia ochrony wizerunku.
    
    \item \textbf{Implementacja logiki sterującej:} Projekt integruje analizę obrazu z warstwą zarządzania incydentami. Potwierdzono poprawne działanie mechanizmu separacji stref (niezależne alarmy dla sąsiadujących ławek) oraz throttlingu czasowego (eliminacja duplikatów zgłoszeń).
\end{itemize}

Powstałe rozwiązanie ma charakter prototypu (Proof of Concept), który pomyślnie przeszedł weryfikację w warunkach rzeczywistych.

\section{Wnioski z realizacji projektu}

Podczas testów przeprowadzonych w obu lokalizacjach sformułowano kluczowe wnioski, które definiują ograniczenia i wymagania dla tego typu systemów:

\begin{enumerate}
    \item \textbf{Wpływ fizyki sensora (ang. \textit{Motion Blur}):} Wyzwaniem w warunkach oświetleniowych typowych dla wnętrz użytkowych nie jest sama skuteczność algorytmu AI, lecz czas naświetlania kamery. Szybki ruch ręką powoduje rozmycie obrazu, co chwilowo utrudnia detekcję. System wymaga momentu stabilizacji obiektu, co zaobserwowano w Scenariuszu C.
    
    \item \textbf{Kalibracja jako element krytyczny:} Domyślne parametry modelu detekcyjnego (próg 0.25) zapewniały \textbf{niewystarczający margines bezpieczeństwa} dla obiektów trudnych do wykrycia. Wyniki rzędu 26-27\% oscylowały na granicy wykrywalności. Obniżenie progu detekcji do wartości 0.20 pozwoliło uzyskać niezbędną stabilność działania w warunkach słabszego oświetlenia oraz przy detekcji z większej odległości.
    
    \item \textbf{Optymalizacja programowa:} Do obsługi pojedynczej kamery i logiki biznesowej standardowy procesor laptopa (CPU) jest wystarczający. Kluczem do płynności działania (7-10 FPS) okazało się zastosowanie wielowątkowości, co wyeliminowało zatory przy operacjach zapisu na dysk.
\end{enumerate}

\section{Kierunki dalszego rozwoju}

Zaprojektowany system stanowi podstawę do dalszych prac rozwojowych. Aby przekształcić go w rozwiązanie klasy produkcyjnej, proponuje się następujące ścieżki rozwoju:

\subsection{Modernizacja warstwy sprzętowej}
Testy wykazały, że głównym ograniczeniem obecnej wersji jest jakość obrazu wejściowego oraz pole widzenia.
\begin{itemize}
    \item \textbf{Kamery z migawką Global Shutter:} Aby wyeliminować problem rozmycia w ruchu (Motion Blur) i poprawić detekcję dynamiczną, zalecane jest zastąpienie standardowych kamer internetowych kamerami przemysłowymi typu Global Shutter.
    
    \item \textbf{System wielokamerowy:} Pojedyncza kamera nie jest w stanie pokryć całej przestrzeni bez martwych stref. Docelowe rozwiązanie powinno integrować strumienie z co najmniej czterech kamer (zapewniając widok z różnych perspektyw), co zagwarantuje pełne pokrycie monitorowanego obszaru.
    
    \item \textbf{Wyższa rozdzielczość i akceleracja GPU:} Wdrożenie kamer 4K oraz obsługa wielu strumieni wideo wiąże się ze znacznym wzrostem zapotrzebowania na moc obliczeniową. Wymusza to migrację z obliczeń na CPU na dedykowane akceleratory graficzne (np. NVIDIA CUDA).
\end{itemize}

\subsubsection{Rozwój architektury i integracja}

\begin{itemize}
    \item \textbf{Centralizacja i ochrona danych (Local Server):} Zamiast instalacji oprogramowania na stacjach roboczych w każdej strefie, docelowe rozwiązanie powinno opierać się na architekturze klient-serwer uruchomionej w \textbf{lokalnej sieci (LAN)}. Zapewnia to, że \textbf{zarejestrowane zdjęcia dowodowe} nie trafiają do chmury publicznej, co jest kluczowe dla bezpieczeństwa i poufności danych wrażliwych.

    \item \textbf{Wizualizacja detekcji (ang. \textit{Bounding Boxes}):} Aby ułatwić weryfikację zgłoszenia, system powinien automatycznie nanosić na zarejestrowane zdjęcie kontrastową ramkę otaczającą wykryty obiekt. Pozwoli to operatorowi na szybką weryfikację poprawności detekcji na zdjęciu.

    \item \textbf{Rozbudowa modelu (ang. \textit{Multi-Class}):} Rozszerzenie detekcji o inne klasy obiektów (np. smartwatche, tablety) oraz dotrenowanie modelu na zbiorze danych specyficznym dla docelowego środowiska wdrożenia.

    \item \textbf{Integracja z systemami zewnętrznymi (API):} Możliwość połączenia systemu z zewnętrznymi bazami danych lub systemami raportowania w modelu „człowiek w pętli decyzyjnej” (ang. \textit{Human-in-the-loop}). System generowałby jedynie wstępne powiadomienie z dowodem, a ostateczna decyzja o podjęciu interwencji należałaby zawsze do osoby nadzorującej.
\end{itemize}

Podsumowując, zrealizowany projekt udowadnia, że automatyzacja detekcji urządzeń mobilnych w przestrzeniach monitorowanych jest technicznie wykonalna i może skutecznie wspierać procesy nadzoru, pod warunkiem odpowiedniej kalibracji oprogramowania i doboru sprzętu wizyjnego.
% -------------------------------------------------------------------
% BIBLIOGRAFIA
% -------------------------------------------------------------------
\printbibliography[title={Bibliografia}]

\end{document}

