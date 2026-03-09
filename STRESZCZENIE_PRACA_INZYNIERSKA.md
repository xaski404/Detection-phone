# Streszczenie – Praca inżynierska

## Tytuł tematu
**Zastosowanie uczenia głębokiego do automatycznej detekcji korzystania ze smartfonów w przestrzeniach monitorowanych**  
*(Application of Deep Learning for Automatic Detection of Smartphone Use in Monitored Spaces)*

---

## Streszczenie (ok. 1 strony A4)

Praca dotyczy projektu i implementacji systemu automatycznej detekcji korzystania ze smartfonów w przestrzeniach monitorowanych, opartego na uczeniu głębokim. System analizuje strumień wideo z kamer i wykrywa użycie telefonów komórkowych w czasie zbliżonym do rzeczywistego; przykładowym zastosowaniem są sale lekcyjne w szkołach podstawowych, gdzie nieodpowiednie korzystanie z telefonów utrudnia koncentrację i dyscyplinę.

**Cel pracy**  
Głównym celem było opracowanie aplikacji webowej wykorzystującej modele uczenia głębokiego do automatycznej detekcji korzystania ze smartfonów w przestrzeniach monitorowanych (np. sale lekcyjne, open space). System rejestruje zdarzenia, powiadamia operatorów oraz zachowuje prywatność osób na nagraniach dzięki anonimizacji wizerunku zgodnej z RODO.

**Zakres realizacji**  
Zaimplementowano pełny system składający się z:
- **Backendu** (Python, Flask) – obsługa kamery, detekcja obiektów, anonimizacja, baza danych, API REST oraz powiadomienia (e-mail, SMS).
- **Frontendu** (React, TypeScript, Material-UI) – panel użytkownika z dashboardem, listą detekcji, ustawieniami (harmonogram, kamera, ROI, powiadomienia) oraz podglądem obrazu z kamery.

**Metody i technologie**  
Do detekcji telefonów wykorzystano model **uczenia głębokiego YOLOv8** (Ultralytics) w wersji medium (YOLOv8m) z datasetu COCO (klasa „cell phone”, class_id = 67). Przetwarzanie obrazu realizowane jest w bibliotece **OpenCV** (preprocessing: CLAHE, unsharp masking, wymuszenie rozdzielczości HD 1280×720). Wykrywanie głów do anonimizacji odbywa się za pomocą **Roboflow API** (model oparty na uczeniu głębokim, heads-detection); anonimizacja polega na nieodwracalnym rozmyciu Gaussa (jądro 99×99, sigma = 30). Architektura oparta jest na wzorcu **Producer–Consumer**: wątek główny przechwytuje klatki, wykrywa telefony i zapisuje klatki do kolejki; wątek workera asynchronicznie wykrywa głowy, anonimizuje je, nadpisuje plik i zapisuje dane do bazy (SQLite, SQLAlchemy). Dzięki temu detekcja działa w czasie zbliżonym do rzeczywistego (ok. 20–30 FPS), a czasochłonna anonimizacja nie blokuje pętli kamery.

**Funkcjonalności systemu**  
- Detekcja smartfonów w czasie rzeczywistym z konfigurowalnym progiem pewności (confidence threshold).  
- Harmonogram pracy kamery (dni tygodnia, godziny start/koniec) dostosowany do planu lekcji.  
- Strefy ROI (Region of Interest) – definiowanie obszarów w klasie (np. ławki, rzędy) z możliwością generowania siatki stref i per-strefowego wyciszania alertów (muting 5 min).  
- Anonimizacja głów przed zapisem do bazy i przed wysyłką powiadomień; w bazie przechowywane są wyłącznie zanonimizowane obrazy.  
- Powiadomienia: e-mail (yagmail) i SMS (Vonage) z linkiem do zdjęcia w chmurze (Cloudinary).  
- Logowanie użytkowników (Flask-Login), sesje, ochrona endpointów API.

**Wyniki**  
Uzyskano działający system spełniający założenia: automatyczna detekcja korzystania ze smartfonów w przestrzeniach monitorowanych w czasie zbliżonym do rzeczywistego (oparta na uczeniu głębokim), trwała anonimizacja zgodna z RODO, elastyczna konfiguracja (harmonogram, ROI, powiadomienia) oraz czytelny panel webowy dla operatora/administratora. System może być uruchamiany lokalnie (Flask + React) i jest przygotowany do wdrożenia m.in. w szkołach, biurach lub innych monitorowanych pomieszczeniach.

**Słowa kluczowe:** uczenie głębokie, detekcja obiektów, YOLOv8, smartfony, przestrzenie monitorowane, RODO, anonimizacja, OpenCV, Flask, React, Producer–Consumer, Roboflow.

---

## Krótkie streszczenie (ok. ½ strony – np. na okładkę / do metadanych)

System webowy wykorzystujący uczenie głębokie do automatycznej detekcji korzystania ze smartfonów w przestrzeniach monitorowanych. Model YOLOv8 wykrywa telefony w strumieniu z kamery, Roboflow – głowy do anonimizacji; filtr Gaussa zapewnia nieodwracalną anonimizację (RODO). Architektura Producer–Consumer (Flask, Python) umożliwia detekcję w czasie zbliżonym do rzeczywistego. Frontend w React służy do konfiguracji harmonogramu, stref ROI i powiadomień (e-mail, SMS). Zastosowanie: sale lekcyjne, biura, inne pomieszczenia z monitoringiem wizyjnym.

---

*Plik wygenerowany na podstawie analizy projektu Detection-phone (TRESC_DO_PRACY_INZYNIERSKIEJ.md, README.md, app.py, models.py, camera_controller).*
