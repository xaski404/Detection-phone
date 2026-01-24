# 🚀 Szybkie Uruchomienie Lokalne - Dla Prezentacji

## Krok 1: Zainstaluj zależności (jeśli jeszcze nie)

### Python (Backend):
```bash
cd Detection-phone
pip install -r requirements.txt
```

### Node.js (Frontend):
```bash
npm install
```

## Krok 2: Zbuduj frontend React

```bash
npm run build
```

To utworzy folder `build/` z zbudowanym frontendem.

## Krok 3: Inicjalizuj bazę danych (jeśli pierwsze uruchomienie)

```bash
python init_db.py
```

To utworzy domyślne konto administratora:
- **Username:** `admin`
- **Password:** `admin`

⚠️ **UWAGA:** Zmień hasło po pierwszym logowaniu!

## Krok 4: Uruchom aplikację

### Najprostsza metoda (zalecana dla prezentacji):

```bash
python app.py
```

Aplikacja będzie dostępna na: **http://localhost:5000**

Wszystko działa na jednym porcie - backend Flask serwuje zarówno API jak i frontend React.

---

## Alternatywna metoda (dwa osobne serwery):

Jeśli wolisz osobne serwery (React dev server + Flask):

**Terminal 1 - Backend:**
```bash
python app.py
# Lub: flask run --debug --no-reload
```

**Terminal 2 - Frontend:**
```bash
npm start
```

Wtedy:
- Backend: http://localhost:5000
- Frontend: http://localhost:3000 (otwiera się automatycznie)

---

## Sprawdzenie, czy wszystko działa:

1. Otwórz przeglądarkę: http://localhost:5000
2. Zaloguj się:
   - Username: `admin`
   - Password: `admin`
3. Przejdź do Settings → Camera Selection
4. Wybierz kamerę (np. Iriun Webcam)
5. Uruchom kamerę przez "Start Camera"

---

## Dla prezentacji - Co pokazać:

### 1. **Dashboard**
   - Statystyki detekcji
   - Ostatnie detekcje
   - Status kamery

### 2. **Settings**
   - Konfiguracja kamery (wybór kamery Iriun)
   - Harmonogram pracy
   - ROI Zones (przykład konfiguracji klas)
   - Ustawienia prywatności (blur faces)

### 3. **Detections**
   - Historia wszystkich detekcji
   - Filtrowanie po dacie
   - Podgląd zdjęć (anonimizowane)

### 4. **Funkcje do pokazania:**
   - ✅ Real-time detection (uruchom kamerę)
   - ✅ Anonimizacja twarzy (blur)
   - ✅ ROI Zones (zarządzanie strefami)
   - ✅ Harmonogram pracy
   - ✅ Historia detekcji

---

## Rozwiązywanie problemów:

### Problem: "Cannot open camera"
- Upewnij się, że Iriun Webcam jest uruchomiony
- Sprawdź, czy kamera jest widoczna w systemie Windows
- Zamknij inne aplikacje używające kamery (Zoom, Teams, OBS)

### Problem: Port 5000 zajęty
```bash
# Zmień port w app.py lub użyj zmiennej środowiskowej:
set PORT=5001
python app.py
```

### Problem: Baza danych nie istnieje
```bash
python init_db.py
```

### Problem: Frontend nie działa
```bash
# Zbuduj ponownie:
npm run build
```

### Problem: Brakuje modułów Python
```bash
pip install -r requirements.txt
```

---

## Szybkie komendy - wszystko razem:

```bash
# W katalogu Detection-phone:

# 1. Zainstaluj zależności (tylko raz):
pip install -r requirements.txt
npm install

# 2. Zbuduj frontend (tylko raz, lub po zmianach w kodzie React):
npm run build

# 3. Inicjalizuj bazę (tylko raz):
python init_db.py

# 4. Uruchom aplikację:
python app.py
```

---

## Gotowe! 🎉

Aplikacja działa na: **http://localhost:5000**

Login: `admin` / `admin`
