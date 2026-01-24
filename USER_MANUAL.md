# 📱 Instrukcja Obsługi - Phone Detection System

## 🎯 Przewodnik Użytkownika

Ten dokument zawiera szczegółową instrukcję obsługi interfejsu webowego systemu wykrywania telefonów.

---

## 🔐 Logowanie

### Pierwsze uruchomienie

1. Otwórz przeglądarkę (Chrome, Firefox, Edge)
2. Przejdź do adresu: `http://localhost:3000`
3. Zobaczysz ekran logowania

**Domyślne dane logowania:**
- **Login**: `admin`
- **Hasło**: `admin`

4. Kliknij **"Zaloguj się"**

⚠️ **Ważne**: Zmień hasło po pierwszym logowaniu w sekcji ustawień!

---

## 📊 Dashboard (Strona Główna)

Po zalogowaniu zobaczysz **Dashboard** z przeglądem systemu.

### Widżety na Dashboard:

#### 1. **Total Detections** (Łączna liczba detekcji)
- Pokazuje całkowitą liczbę wykrytych telefonów od początku
- Zielona strzałka ↗ = wzrost w porównaniu do poprzedniego tygodnia
- Czerwona strzałka ↘ = spadek

#### 2. **Today's Detections** (Dzisiejsze detekcje)
- Liczba detekcji z dzisiejszego dnia
- Resetuje się o północy

#### 3. **Camera Status** (Status kamery)
- **Online** (zielony) = Kamera działa
- **Offline** (pomarańczowy) = Kamera wyłączona
- Pokazuje czy jesteś w harmonogramie

#### 4. **Detections Over Time** (Wykres detekcji)
- Wykres liniowy pokazujący detekcje z ostatnich 7 dni
- Pomaga zobaczyć trendy

#### 5. **Recent Detections** (Ostatnie detekcje)
- Lista 5 najnowszych detekcji
- Pokazuje: czas, lokalizację, pewność detekcji
- Kliknij "View All" aby zobaczyć wszystkie

---

## 📸 Detections (Historia Detekcji)

Sekcja z pełną historią wszystkich wykrytych telefonów.

### Jak korzystać:

#### 1. **Przeglądanie detekcji:**
- Galeria zdjęć z wykrytymi telefonami
- **Głowy są zamazane** (anonimizacja)
- Każde zdjęcie pokazuje:
  - 📅 Data i godzina
  - 📍 Lokalizacja (nazwa strefy ROI lub kamery)
  - 📊 Pewność detekcji (%)
  - 🏷️ Status (Pending, Reviewed, etc.)

#### 2. **Filtrowanie:**
- **Data**: Wybierz zakres dat
- **Lokalizacja**: Filtruj po strefie (np. "Ławka 1")
- **Status**: Pending / Reviewed / Archived

#### 3. **Sortowanie:**
- Kliknij nagłówek kolumny aby posortować:
  - Data (najnowsze/najstarsze)
  - Pewność (najwyższa/najniższa)
  - Lokalizacja (alfabetycznie)

#### 4. **Akcje na detekcjach:**

**Pojedyncza detekcja:**
- 🔍 **Podgląd**: Kliknij zdjęcie aby powiększyć
- ✏️ **Edycja**: Zmień status (Pending → Reviewed)
- 🗑️ **Usuń**: Usuń pojedynczą detekcję

**Wiele detekcji:**
- ☑️ Zaznacz checkboxy przy zdjęciach
- Kliknij **"Delete Selected"** aby usunąć zaznaczone
- Przydatne do czyszczenia false positives

#### 5. **Paginacja:**
- Domyślnie: 20 detekcji na stronę
- Użyj strzałek ← → na dole aby przejść do kolejnych stron
- Lub wybierz liczbę na stronę: 10 / 20 / 50 / 100

---

## ⚙️ Settings (Ustawienia)

Główna sekcja konfiguracji systemu. Podzielona na kilka kategorii:

### 📅 1. Weekly Schedule (Harmonogram Tygodniowy)

**Cel**: Automatyczne włączanie/wyłączanie kamery w określonych godzinach.

**Jak skonfigurować:**

1. Kliknij **"Weekly Schedule"** aby rozwinąć sekcję
2. Dla każdego dnia tygodnia:
   - ✅ **Enabled**: Zaznacz aby włączyć kamerę w tym dniu
   - 🕐 **Start Time**: Godzina rozpoczęcia (np. 07:00)
   - 🕐 **End Time**: Godzina zakończenia (np. 16:00)

**Przykład - Szkoła (Pon-Pt, 7:00-16:00):**
```
Poniedziałek:  ✅ Enabled  07:00 - 16:00
Wtorek:        ✅ Enabled  07:00 - 16:00
Środa:         ✅ Enabled  07:00 - 16:00
Czwartek:      ✅ Enabled  07:00 - 16:00
Piątek:        ✅ Enabled  07:00 - 16:00
Sobota:        ❌ Disabled
Niedziela:     ❌ Disabled
```

3. Kliknij **"Save Settings"** na dole strony

**Wskazówki:**
- Kamera włączy się automatycznie o 07:00 i wyłączy o 16:00
- Możesz ręcznie włączyć/wyłączyć kamerę przyciskami Start/Stop (nadpisuje harmonogram)
- Harmonogram wznowi działanie następnego dnia

---

### 🎛️ 2. Detection Settings (Ustawienia Detekcji)

**Cel**: Kontrola czułości wykrywania telefonów.

#### **Blur Faces** (Zamazywanie Głów)
- ✅ **Włączone**: Głowy są zamazywane (ZALECANE!)
- ❌ **Wyłączone**: Głowy NIE są zamazywane (NIEZGODNE Z RODO!)

⚠️ **Ważne**: Zawsze pozostaw włączone dla ochrony prywatności!

#### **Confidence Threshold** (Próg Pewności)
- Suwak: 0% - 100%
- **Domyślnie**: 20%
- **Niższa wartość** (10-20%): Więcej detekcji, więcej false positives
- **Wyższa wartość** (30-50%): Mniej detekcji, mniej false positives

**Jak ustawić:**
1. Przesuń suwak
2. Obserwuj liczbę detekcji przez kilka dni
3. Jeśli za dużo false positives → zwiększ próg
4. Jeśli za mało detekcji → zmniejsz próg

**Przykład:**
```
Próg 20%: 50 detekcji/dzień (10 false positives)
Próg 30%: 35 detekcji/dzień (2 false positives) ← Lepiej!
Próg 40%: 20 detekcji/dzień (0 false positives, ale może przegapić)
```

---

### 📹 3. Camera Selection (Wybór Kamery)

**Cel**: Wybór której kamery użyć (jeśli masz kilka).

**Jak wybrać kamerę:**

1. Rozwiń sekcję **"Camera Selection"**
2. Zobaczysz listę dostępnych kamer:
   ```
   Camera 0: Integrated Webcam (640x480, 30 FPS)
   Camera 1: Iriun Webcam (1280x720, 30 FPS)
   Camera 2: USB Camera (1920x1080, 30 FPS)
   ```
3. Wybierz kamerę z listy rozwijanej
4. Kliknij **"Save Settings"**
5. **Restartuj kamerę** (Stop → Start) aby zastosować zmiany

**Wskazówki:**
- Wyższa rozdzielczość = lepsza detekcja, ale wolniejsze
- 1280x720 to dobry kompromis
- Sprawdź podgląd kamery w sekcji ROI Zones

---

### 🎯 4. ROI Zones (Strefy Detekcji)

**Cel**: Zaznaczenie konkretnych obszarów gdzie telefony mają być wykrywane.

**Dlaczego warto:**
- ✅ Wykrywaj tylko na ławkach uczniów
- ✅ Ignoruj biurko nauczyciela
- ✅ Zmniejsz false positives z tła
- ✅ Każda strefa ma osobne wyciszenie alertów (5 min)

#### **Krok 1: Załaduj Zdjęcie Konfiguracyjne**

1. Rozwiń sekcję **"ROI Zones"**
2. Kliknij **"Load Config Photo"**
3. Poczekaj 2-3 sekundy
4. Zobaczysz aktualne zdjęcie z kamery

**Wskazówka**: Upewnij się, że kamera jest włączona i widok jest prawidłowy!

#### **Krok 2: Wybierz Tryb Rysowania**

**Opcja A: Single Zone (Pojedyncza Strefa)**
- Dla nieregularnych układów
- Rysujesz każdą strefę osobno
- Nadajesz nazwę ręcznie

**Opcja B: Grid Generator (Generator Siatki)** ⭐ ZALECANE DLA KLAS
- Dla regularnych układów (rzędy ławek)
- Rysujesz JEDEN prostokąt
- System automatycznie tworzy siatkę

#### **Krok 3A: Rysowanie Pojedynczej Strefy**

1. Wybierz **"Single Zone"**
2. **Kliknij i przeciągnij** na zdjęciu aby narysować prostokąt
3. Puść przycisk myszy
4. Wpisz nazwę strefy (np. "Ławka 1")
5. Kliknij **"Save Zone"**
6. Powtórz dla kolejnych stref

#### **Krok 3B: Generator Siatki** (Zalecane!)

**Przykład: Klasa z 4 rzędami × 5 ławek = 20 stref**

1. Wybierz **"Grid Generator"**
2. **Narysuj JEDEN duży prostokąt** obejmujący wszystkie ławki
3. Ustaw parametry:
   - **Rows** (Rzędy): `4`
   - **Columns** (Kolumny): `5`
   - **Naming Mode** (Tryb nazewnictwa):
     - **Sequential**: "Ławka 1", "Ławka 2", ..., "Ławka 20"
     - **Grid**: "R1-M1", "R1-M2", ..., "R4-M5"
   - **Prefix** (Opcjonalnie): `Ławka` (da "Ławka 1", "Ławka 2", ...)
4. Kliknij **"Generate Grid"**
5. ✨ **Gotowe!** System utworzył 20 stref automatycznie!

**Wizualizacja:**
```
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│ Ławka 1 │ Ławka 2 │ Ławka 3 │ Ławka 4 │ Ławka 5 │  ← Rząd 1
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Ławka 6 │ Ławka 7 │ Ławka 8 │ Ławka 9 │ Ławka10 │  ← Rząd 2
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Ławka11 │ Ławka12 │ Ławka13 │ Ławka14 │ Ławka15 │  ← Rząd 3
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Ławka16 │ Ławka17 │ Ławka18 │ Ławka19 │ Ławka20 │  ← Rząd 4
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

#### **Krok 4: Edycja Stref**

**Przesuwanie strefy:**
- Kliknij na strefę (zostanie zaznaczona - niebieska ramka)
- Przeciągnij w nowe miejsce

**Zmiana rozmiaru:**
- Kliknij na strefę
- Zobaczysz **4 uchwyty w rogach** (małe kwadraty)
- Przeciągnij uchwyt aby zmienić rozmiar

**Zmiana nazwy:**
- Kliknij ikonę **✏️ (Edit)** obok nazwy strefy
- Wpisz nową nazwę
- Kliknij ✅ (Save)

**Usunięcie strefy:**
- Kliknij ikonę **🗑️ (Delete)** obok nazwy strefy
- Potwierdź usunięcie

#### **Krok 5: Auto-Save**

- Strefy są **automatycznie zapisywane** po 2 sekundach od ostatniej zmiany
- Zobaczysz zielone powiadomienie: "Ustawienia zapisane automatycznie"
- Nie musisz klikać "Save Settings"!

---

### 📧 5. Notifications (Powiadomienia)

**Cel**: Otrzymywanie alertów gdy telefon zostanie wykryty.

#### **Email Notifications**

**Wymagania:**
- Konto Gmail
- Gmail App Password (16 znaków)

**Konfiguracja:**
1. Zaznacz ✅ **"Email Notifications"**
2. Skonfiguruj `.env` file (patrz: EMAIL_NOTIFICATIONS_SETUP.md)
3. Kliknij **"Save Settings"**

**Co otrzymasz:**
- Email z tematem: "Wykryto Telefon! (Ławka 5)"
- **Osadzony obraz** (zanonimizowany - głowy zamazane)
- Załącznik ze zdjęciem
- Czas, lokalizacja, pewność detekcji
- Link do obrazu w chmurze (Cloudinary)

#### **SMS Notifications**

**Wymagania:**
- Konto Vonage (dawniej Nexmo)
- API Key i API Secret

**Konfiguracja:**
1. Zaznacz ✅ **"SMS Notifications"**
2. Skonfiguruj `.env` file (patrz: SMS_NOTIFICATIONS_SETUP.md)
3. Kliknij **"Save Settings"**

**Co otrzymasz:**
- SMS na podany numer
- Treść:
  ```
  Phone Detection Alert!
  Time: 2025-11-23 14:30:15
  Location: Ławka 5
  Confidence: 85%
  Image: https://cloudinary.com/...
  ```

#### **Throttling (Wyciszanie Alertów)**

⚠️ **Ważne**: Każda strefa ROI ma **niezależne 5-minutowe wyciszenie**!

**Przykład:**
```
14:00 - Telefon w "Ławka 1" → Email + SMS wysłane
14:01 - Telefon w "Ławka 1" → ZIGNOROWANE (wyciszone)
14:02 - Telefon w "Ławka 5" → Email + SMS wysłane (inna strefa!)
14:06 - Telefon w "Ławka 1" → Email + SMS wysłane (wyciszenie wygasło)
```

**Dlaczego 5 minut?**
- Zapobiega spamowi (uczeń może trzymać telefon przez dłuższy czas)
- Każda strefa ma osobne wyciszenie (pełne pokrycie klasy)

---

## 🎮 Sterowanie Kamerą

### Ręczne Włączanie/Wyłączanie

W prawym górnym rogu Dashboard znajdziesz przyciski:

#### **▶️ Start Camera** (Włącz Kamerę)
- Włącza kamerę **natychmiast**
- Ignoruje harmonogram
- Kamera będzie działać do ręcznego wyłączenia

**Kiedy użyć:**
- Chcesz włączyć kamerę poza harmonogramem
- Testowanie systemu
- Specjalne wydarzenia

#### **⏹️ Stop Camera** (Wyłącz Kamerę)
- Wyłącza kamerę **natychmiast**
- Blokuje automatyczne włączenie przez harmonogram
- Kamera pozostanie wyłączona do ręcznego włączenia

**Kiedy użyć:**
- Przerwa w zajęciach
- Konserwacja
- Chcesz wyłączyć mimo harmonogramu

### Status Kamery

**🟢 Online (Zielony)**
- Kamera działa
- Wykrywanie aktywne
- Detekcje są zapisywane

**🟠 Offline (Pomarańczowy)**
- Kamera wyłączona
- Brak wykrywania
- Czeka na harmonogram lub ręczne włączenie

**Wskaźnik "Within Schedule":**
- ✅ Jesteś w harmonogramie (kamera powinna działać)
- ❌ Poza harmonogramem (kamera może być wyłączona)

---

## 📊 Podgląd Kamery (Video Feed)

### Gdzie znaleźć:
- Dashboard → Widżet "Live Camera Feed"
- Lub dedykowana zakładka "Camera"

### Co widzisz:
- **Obraz Canny Edge Detection** (kontury)
- **NIE** widzisz oryginalnego obrazu (prywatność!)
- Pokazuje że kamera działa

### Dlaczego Canny Edge?
- 🔒 **Prywatność**: Nie widać twarzy ani szczegółów
- ✅ **Weryfikacja**: Sprawdzasz czy kamera działa
- ✅ **Pozycjonowanie**: Widzisz czy kamera jest dobrze ustawiona

---

## 💡 Najlepsze Praktyki

### 1. **Pierwsze Uruchomienie**
```
✅ Zaloguj się (admin/admin123)
✅ Zmień hasło
✅ Ustaw harmonogram (Pon-Pt, 7:00-16:00)
✅ Wybierz kamerę
✅ Załaduj Config Photo
✅ Narysuj ROI zones (Grid Generator!)
✅ Włącz Email notifications
✅ Ustaw confidence threshold (zacznij od 20%)
✅ Testuj przez tydzień
✅ Dostosuj threshold jeśli potrzeba
```

### 2. **Codzienne Użytkowanie**
- Sprawdź Dashboard rano (czy kamera włączona?)
- Przeglądaj Detections wieczorem
- Usuń false positives (zaznacz + Delete Selected)
- Monitoruj liczbę detekcji (trend)

### 3. **Optymalizacja**
- Za dużo false positives? → Zwiększ confidence threshold
- Za mało detekcji? → Zmniejsz confidence threshold
- Detekcje poza ławkami? → Doprecyzuj ROI zones
- Za dużo alertów? → Throttling działa automatycznie (5 min)

### 4. **Konserwacja**
- Co tydzień: Sprawdź czy kamera jest czysta
- Co miesiąc: Przejrzyj i usuń stare detekcje
- Co kwartał: Zweryfikuj ROI zones (czy ławki się nie przesunęły?)

---

## ❓ FAQ (Często Zadawane Pytania)

### Q: Czy mogę mieć różne harmonogramy dla różnych dni?
**A**: Tak! Każdy dzień ma osobny harmonogram. Możesz np. Poniedziałek 7-16, Wtorek 8-15, etc.

### Q: Co jeśli kamera nie włącza się automatycznie?
**A**: Sprawdź:
1. Czy dzień jest enabled w harmonogramie?
2. Czy jesteś w przedziale czasowym?
3. Czy nie kliknąłeś "Stop Camera" (blokuje auto-start)
4. Spróbuj ręcznie "Start Camera"

### Q: Jak zmienić hasło?
**A**: Obecnie tylko przez backend (reset_admin_password.py). Funkcja zmiany hasła w UI będzie dodana wkrótce.

### Q: Czy mogę mieć więcej niż jednego użytkownika?
**A**: Obecnie system ma jednego użytkownika (admin). Multi-user będzie w przyszłych wersjach.

### Q: Jak długo przechowywane są detekcje?
**A**: Bez limitu. Możesz ręcznie usuwać stare detekcje w sekcji Detections.

### Q: Czy mogę eksportować detekcje do Excel/CSV?
**A**: Obecnie nie, ale funkcja będzie dodana w przyszłości.

### Q: Co jeśli mam 2 kamery w różnych salach?
**A**: Obecnie system obsługuje 1 kamerę. Dla 2 sal potrzebujesz 2 instancji systemu.

### Q: Czy system działa offline?
**A**: Częściowo:
- ✅ Detekcja telefonów: TAK (YOLOv8 lokalnie)
- ❌ Anonimizacja głów: NIE (wymaga Roboflow API)
- ❌ Powiadomienia: NIE (wymaga internetu)

---

## 🆘 Pomoc i Wsparcie

### Problemy?

1. **Sprawdź konsole przeglądarki** (F12 → Console)
2. **Sprawdź logi backendu** (terminal z `flask run`)
3. **Przeczytaj sekcję Troubleshooting** w README.md

### Kontakt:
- GitHub Issues: [link do repo]
- Email: [twój email]

---

**Wersja dokumentu**: 1.0  
**Data**: 2025-11-23  
**System**: Phone Detection System v1.0
