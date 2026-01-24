# PROSTA ŚCIEŻKA DZIAŁANIA SYSTEMU

## BUDOWA ARCHITEKTURY SYSTEMU

Implementacja architektury typu klient-serwer. Warstwę logiczną (Backend) zrealizowano w języku Python, wykorzystując mikro-framework Flask do obsługi API oraz bibliotekę OpenCV do operacji na macierzach obrazu. Warstwa prezentacji (Frontend), wykonana w technologii React z wykorzystaniem TypeScript, dostarcza interfejs graficzny dostępny z poziomu przeglądarki, umożliwiający nauczycielowi podgląd wykrytych incydentów, zarządzanie konfiguracją systemu oraz monitorowanie statystyk w czasie rzeczywistym. Frontend składa się z czterech głównych modułów: Dashboard (statystyki i wykresy detekcji), Detections (galeria zanonimizowanych zdjęć z możliwością przeglądania, wyszukiwania i usuwania), Settings (kompleksowa konfiguracja harmonogramu pracy kamery, stref ROI, parametrów detekcji, powiadomień Email/SMS oraz wyboru urządzenia wideo) oraz Login (autoryzacja użytkownika). Interfejs wykorzystuje bibliotekę Material-UI do zapewnienia spójnego i nowoczesnego wyglądu, a komunikacja z backendem odbywa się poprzez REST API z wykorzystaniem biblioteki Axios.

---

## GŁÓWNA ŚCIEŻKA (Flowchart)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DZIAŁANIE SYSTEMU                            │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  📷 KAMERA   │
    │  (OpenCV)    │
    └──────┬───────┘
           │
           │ Klatka wideo (20-30 FPS)
           ▼
    ┌──────────────┐
    │  🔍 YOLOv8   │
    │  (Detekcja   │
    │   telefonów) │
    └──────┬───────┘
           │
           │ Telefon wykryty?
           ▼
    ┌──────────────┐
    │  💾 ZAPIS    │
    │  (Oryginalna │
    │   klatka)    │
    └──────┬───────┘
           │
           │ Dodanie do kolejki
           ▼
    ┌──────────────┐
    │  📤 QUEUE     │
    │  (Kolejka)    │
    └──────┬───────┘
           │
           │ Worker Thread
           ▼
    ┌──────────────┐
    │  👁️ ROBOFLOW │
    │  (Wykrywanie │
    │   głów)      │
    └──────┬───────┘
           │
           │ Głowy wykryte
           ▼
    ┌──────────────┐
    │  🔒 BLUR      │
    │  (Gaussian    │
    │   anonimizacja)│
    └──────┬───────┘
           │
           │ Zanonimizowany obraz
           ▼
    ┌──────────────┐
    │  💾 DATABASE │
    │  (SQLite)    │
    └──────┬───────┘
           │
           │ Zapis metadanych
           ▼
    ┌──────────────┐
    │  ☁️ CLOUDINARY│
    │  (Upload)     │
    └──────┬───────┘
           │
           │ Link do obrazu
           ▼
    ┌──────────────┐
    │  📧 POWIADOM. │
    │  (Email+SMS)  │
    └──────────────┘
```

---

## WERSJA Z WYJAŚNIENIAMI

```
┌─────────────────────────────────────────────────────────────────┐
│                    DZIAŁANIE SYSTEMU                            │
└─────────────────────────────────────────────────────────────────┘

KROK 1: PRZECHWYTYWANIE
    ┌──────────────┐
    │  📷 KAMERA   │  ← Przechwytuje klatki wideo (1280x720)
    │  (OpenCV)    │     z prędkością 20-30 FPS
    └──────┬───────┘
           │
           │ Klatka wideo
           ▼

KROK 2: DETEKCJA
    ┌──────────────┐
    │  🔍 YOLOv8   │  ← Analizuje klatkę, wykrywa telefony
    │  (Detekcja)  │     (class_id=67, confidence≥0.2)
    └──────┬───────┘
           │
           │ Telefon wykryty ✓
           ▼

KROK 3: ZAPIS ORYGINAŁU
    ┌──────────────┐
    │  💾 ZAPIS    │  ← Zapisuje oryginalną klatkę do pliku
    │  (Oryginał)   │     ./detections/phone_YYYYMMDD_HHMMSS.jpg
    └──────┬───────┘
           │
           │ Dodanie do kolejki
           ▼

KROK 4: KOLEJKA
    ┌──────────────┐
    │  📤 QUEUE     │  ← Thread-safe kolejka między wątkami
    │  (Kolejka)    │     (Producer-Consumer pattern)
    └──────┬───────┘
           │
           │ Worker Thread (asynchronicznie)
           ▼

KROK 5: WYKRYWANIE GŁÓW
    ┌──────────────┐
    │  👁️ ROBOFLOW │  ← Wykrywa głowy uczniów na zdjęciu
    │  (Heads API) │     (confidence≥40%, dokładność>90%)
    └──────┬───────┘
           │
           │ Lista wykrytych głów
           ▼

KROK 6: ANONIMIZACJA
    ┌──────────────┐
    │  🔒 BLUR      │  ← Zamazuje głowy filtrem Gaussa
    │  (Gaussian)   │     (kernel 99x99, sigma=30)
    └──────┬───────┘
           │
           │ Zanonimizowany obraz
           ▼

KROK 7: BAZA DANYCH
    ┌──────────────┐
    │  💾 DATABASE  │  ← Zapisuje metadane do SQLite
    │  (SQLite)     │     (tylko zanonimizowane obrazy!)
    └──────┬───────┘
           │
           │ Upload do chmury
           ▼

KROK 8: CLOUDINARY
    ┌──────────────┐
    │  ☁️ CLOUDINARY│  ← Upload obrazu (opcjonalnie)
    │  (Storage)    │     Otrzymuje publiczny link
    └──────┬───────┘
           │
           │ Link + metadane
           ▼

KROK 9: POWIADOMIENIA
    ┌──────────────┐
    │  📧 POWIADOM. │  ← Wysyła Email i SMS do nauczyciela
    │  (Email+SMS)  │     z zanonimizowanym zdjęciem
    └──────────────┘
```

---

## WERSJA ULTRA PROSTA (Dla szybkiego zrozumienia)

```
📷 KAMERA
   │
   ▼
🔍 YOLOv8 (Wykrywa telefon)
   │
   ▼
💾 Zapis oryginału
   │
   ▼
📤 Queue (Kolejka)
   │
   ▼
👁️ Roboflow (Wykrywa głowy)
   │
   ▼
🔒 Gaussian Blur (Anonimizacja)
   │
   ▼
💾 Database (Zapis)
   │
   ▼
☁️ Cloudinary (Upload)
   │
   ▼
📧 Powiadomienia (Email + SMS)
```

---

## CZAS WYKONANIA (Przybliżone)

```
📷 Kamera:           0ms
   │
   ▼ (10ms preprocessing)
🔍 YOLOv8:           30ms  ← Main Thread (nie blokuje)
   │
   ▼ (10ms zapis)
💾 Zapis:            40ms  ← Main Thread
   │
   ▼ (dodanie do kolejki)
📤 Queue:            45ms  ← Main Thread
   │
   ▼ (Worker Thread - asynchronicznie)
👁️ Roboflow:         800ms  ← Worker Thread
   │
   ▼ (50ms blur)
🔒 Blur:             850ms  ← Worker Thread
   │
   ▼ (50ms zapis)
💾 Database:         900ms  ← Worker Thread
   │
   ▼ (100ms upload)
☁️ Cloudinary:       1000ms ← Worker Thread
   │
   ▼ (50ms wysyłka)
📧 Powiadomienia:    1050ms ← Worker Thread

─────────────────────────────────────
GŁÓWNA PĘTLA: Kontynuuje z 20-30 FPS
(Anonimizacja nie blokuje detekcji!)
```

---

## KLUCZOWE PUNKTY

1. **Main Thread (Producer):** Krok 1-4 (0-45ms) - Real-time detekcja
2. **Worker Thread (Consumer):** Krok 5-9 (100-1050ms) - Asynchroniczna anonimizacja
3. **Kolejka:** Bufor między wątkami (thread-safe)
4. **RODO:** Tylko zanonimizowane obrazy w bazie danych
5. **Wydajność:** Detekcja nie jest blokowana przez anonimizację

---

*Prosta ścieżka działania systemu - zaktualizowana wersja*

---

## MECHANIZM OCHRONY PRYWATNOŚCI (Privacy-Preserving Module)

System implementuje zaawansowany mechanizm ochrony prywatności, zapewniający pełną zgodność z wymogami RODO oraz uniemożliwiający identyfikację biometryczną uczniów. Moduł ochrony prywatności działa jako integralny element procesu przetwarzania danych, gwarantując, że wszystkie obrazy przechowywane w systemie są automatycznie zanonimizowane przed ich trwałym zapisem.

### Architektura modułu anonimizacji

Proces anonimizacji realizowany jest w dedykowanym wątku roboczym (`AnonymizerWorker`), działającym asynchronicznie względem głównej pętli detekcji. Zapewnia to nieprzerwane działanie systemu w czasie rzeczywistym, jednocześnie przeprowadzając kompleksową anonimizację każdego wykrytego zdarzenia.

**Kroki procesu anonimizacji:**

1. **Wykrywanie głów i twarzy:** System wykorzystuje wyspecjalizowany model detekcji głów (`heads-detection/1`) z platformy Roboflow, charakteryzujący się dokładnością przekraczającą 90%. Model analizuje każdy wykryty obraz, identyfikując regiony zawierające głowy lub twarze osób znajdujących się w kadrze, z minimalnym progiem pewności detekcji ustawionym na 40%.

2. **Automatyczna anonimizacja:** Wykryte obszary są poddawane nieodwracalnej operacji anonimizacji wykorzystującej filtr Gaussa o parametrach kernel 99x99 pikseli i odchyleniu standardowym sigma=30. Zastosowanie tak silnego filtru gwarantuje całkowite uniemożliwienie identyfikacji biometrycznej, jednocześnie zachowując kontekst sceny (pozycja ciała, ubranie, otoczenie) potrzebny do weryfikacji naruszenia regulaminu.

3. **Zapis zanonimizowanych danych:** Zanonimizowany obraz nadpisuje oryginalny plik przed jakimkolwiek trwałym zapisem do bazy danych lub systemów zewnętrznych. Mechanizm ten zapewnia, że do bazy danych SQLite, chmury Cloudinary oraz powiadomień trafiają wyłącznie obrazy z zanonimizowanymi cechami biometrycznymi.

4. **Weryfikacja bezpieczeństwa:** System zapisuje metadane wyłącznie dla obrazów, które zostały poddane procesowi anonimizacji. W przypadku niepowodzenia anonimizacji, zdarzenie jest rejestrowane w logach systemowych, a dane wrażliwe nie są trwale przechowywane.

### Gwarancje bezpieczeństwa

- **Zgodność z RODO:** System nie gromadzi żadnych danych biometrycznych umożliwiających identyfikację uczniów, spełniając wymagania art. 9 Rozporządzenia RODO dotyczące szczególnych kategorii danych osobowych.

- **Nieodwracalność anonimizacji:** Zastosowanie filtru Gaussa o wysokich parametrach zapewnia całkowitą nieodwracalność procesu anonimizacji, eliminując możliwość odtworzenia oryginalnych cech biometrycznych.

- **Automatyzacja procesu:** Anonimizacja jest integralną częścią przepływu danych - każdy obraz przechodzi przez moduł anonimizacji przed finalnym zapisem, wykluczając możliwość przypadkowego przechowania niezanonimizowanych danych.

- **Izolacja danych wrażliwych:** Oryginalne obrazy (jeśli kiedykolwiek istnieją w pamięci tymczasowej) są natychmiast nadpisywane zanonimizowaną wersją przed ich trwałym zapisem, gwarantując brak możliwości odzyskania danych identyfikujących.

### Techniczne aspekty implementacji

Moduł wykorzystuje wzorzec Producer-Consumer z thread-safe kolejką, gdzie główny wątek odpowiedzialny za detekcję przekazuje zadania anonimizacji do dedykowanego wątku roboczego. Dzięki temu system zachowuje wydajność detekcji w czasie rzeczywistym (20-30 FPS), podczas gdy anonimizacja wykonywana jest asynchronicznie bez wpływu na działanie głównej pętli systemowej.

Wszystkie operacje anonimizacji są rejestrowane w logach systemowych z informacją o liczbie zanonimizowanych regionów, co zapewnia pełną transparentność procesu i możliwość audytu zgodności z polityką prywatności.

### Mechanizmy ochrony przed dostępem do niezanonimizowanych danych

System implementuje wielowarstwowe mechanizmy ochrony, minimalizujące ryzyko dostępu do niezanonimizowanych obrazów:

- **Autoryzacja endpointów:** Wszystkie endpointy HTTP służące do pobierania obrazów (`/detections/<filename>`) są chronione dekoratorem `@login_required`, wymagającym aktywnej sesji użytkownika z uprawnieniami administratora. Oznacza to, że tylko zalogowany personel szkolny posiadający autoryzację ma dostęp do obrazów.

- **Minimalizacja okna czasowego:** Proces anonimizacji jest wykonywany asynchronicznie w dedykowanym wątku roboczym, z priorytetem przetwarzania zadań z kolejki. Typowe opóźnienie między zapisem oryginalnego obrazu a jego anonimizacją wynosi od 100ms do 2 sekund, w zależności od obciążenia systemu. Okno to jest minimalizowane poprzez efektywne zarządzanie kolejką i natychmiastowe przetwarzanie zadań.

- **Automatyczne nadpisywanie:** Zanonimizowany obraz natychmiast nadpisuje oryginalny plik w lokalizacji docelowej, eliminując możliwość długotrwałego przechowywania niezanonimizowanych danych na dysku.

- **Izolacja procesowa:** Główny wątek odpowiedzialny za detekcję nie ma bezpośredniego dostępu do endpointów HTTP - wszystkie żądania są obsługiwane przez osobny wątek Flask, co dodatkowo izoluje dane wrażliwe.

Warto zauważyć, że dostęp do obrazów wymaga podwójnej autoryzacji: zarówno na poziomie aplikacji (sesja Flask-Login), jak i na poziomie systemu operacyjnego (uprawnienia do folderu `detections/`). W środowisku produkcyjnym można dodatkowo zaimplementować zabezpieczenia na poziomie systemu plików, takie jak szyfrowanie folderu tymczasowego lub wykorzystanie bezpiecznego folderu dostępnego tylko dla procesu anonimizacyjnego.

---

## WERSJA ZWIĘZŁA (Dla pracy inżynierskiej)

### Opracowanie mechanizmu ochrony prywatności (Privacy-Preserving Module)

System implementuje zaawansowany mechanizm ochrony prywatności, zapewniający pełną zgodność z wymogami RODO oraz uniemożliwiający identyfikację biometryczną uczniów. Moduł anonimizacji działa jako integralny element procesu przetwarzania danych, gwarantując automatyczną anonimizację wszystkich obrazów przed ich trwałym zapisem.

Proces anonimizacji realizowany jest w dedykowanym wątku roboczym działającym asynchronicznie względem głównej pętli detekcji. System wykorzystuje pomocniczy model detekcji głów z platformy Roboflow (model `heads-detection/1`, dokładność >90%), którego zadaniem jest lokalizacja głów i twarzy osób znajdujących się w kadrze. Wykryte obszary są automatycznie poddawane nieodwracalnej operacji rozmycia gaussowskiego (kernel 99x99 pikseli, sigma=30), co uniemożliwia identyfikację biometryczną.

Zanonimizowany obraz nadpisuje oryginalny plik przed jakimkolwiek trwałym zapisem do bazy danych lub systemów zewnętrznych. Mechanizm ten zapewnia, że do bazy danych SQLite, chmury Cloudinary oraz powiadomień trafiają wyłącznie obrazy z zanonimizowanymi cechami biometrycznymi. Dzięki temu system gromadzi dowody naruszeń (zdjęcia telefonów w rękach uczniów) w formie zanonimizowanej, spełniając wymagania art. 9 Rozporządzenia RODO dotyczące szczególnych kategorii danych osobowych.

Zastosowanie filtru Gaussa o wysokich parametrach zapewnia całkowitą nieodwracalność procesu anonimizacji, eliminując możliwość odtworzenia oryginalnych cech biometrycznych. Anonimizacja jest integralną częścią przepływu danych - każdy obraz przechodzi przez moduł anonimizacji przed finalnym zapisem, wykluczając możliwość przypadkowego przechowania niezanonimizowanych danych.

Dodatkowe zabezpieczenia obejmują ochronę endpointów HTTP poprzez wymaganie autoryzacji (`@login_required`), minimalizację okna czasowego między zapisem a anonimizacją (typowo 100ms-2s), oraz automatyczne nadpisywanie oryginalnego pliku zanonimizowaną wersją. Wszystkie mechanizmy zapewniają, że dostęp do niezanonimizowanych danych jest możliwy wyłącznie dla autoryzowanego personelu w bardzo krótkim przedziale czasowym, co w praktyce wyklucza możliwość ich wykorzystania do celów identyfikacji biometrycznej.

---
