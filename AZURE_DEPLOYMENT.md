# Instrukcja wdrożenia na Azure

## Problem: Strona zwraca 404

Aplikacja Flask działa, ale zwraca 404 dla głównej strony, ponieważ:
1. Brakuje zbudowanego frontendu React
2. Brakuje tras do serwowania frontendu

## Rozwiązanie

### 1. Zbuduj frontend React

Na serwerze Azure (lub lokalnie przed wdrożeniem) uruchom:

```bash
cd Detection-phone
npm install
npm run build
```

To utworzy folder `build/` z zbudowanym frontendem React.

### 2. Konfiguracja zmiennych środowiskowych

Utwórz plik `.env` lub ustaw zmienne środowiskowe na Azure:

```env
# Port (domyślnie 5000, dla Azure użyj 80 lub PORT z Azure)
PORT=80

# CORS - dodaj domenę Azure (np. https://twoja-aplikacja.azurewebsites.net)
CORS_ORIGINS=http://localhost:3000,https://twoja-aplikacja.azurewebsites.net

# Flask
FLASK_SECRET_KEY=twoj-secret-key
FLASK_DEBUG=False

# Baza danych (dla Azure użyj Azure SQL lub PostgreSQL)
DATABASE_URI=sqlite:///admin.db

# Opcjonalne - jeśli używasz
VONAGE_API_KEY=...
VONAGE_API_SECRET=...
VONAGE_TO_NUMBER=...
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
GMAIL_USER=...
GMAIL_APP_PASSWORD=...
EMAIL_RECIPIENT=...
```

### 3. Uruchomienie aplikacji

#### Opcja A: Bezpośrednio przez Python

```bash
cd Detection-phone
python app.py
```

Aplikacja będzie dostępna na porcie określonym w zmiennej `PORT` (domyślnie 5000).

#### Opcja B: Użyj Gunicorn (zalecane dla produkcji)

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:80 app:app
```

### 4. Konfiguracja Azure App Service

Jeśli używasz Azure App Service:

1. **Ustaw zmienne środowiskowe** w Azure Portal:
   - `PORT` - Azure automatycznie ustawi to, ale możesz ustawić ręcznie
   - `CORS_ORIGINS` - dodaj domenę Azure
   - `FLASK_SECRET_KEY` - ustaw silne hasło
   - `FLASK_DEBUG=False` - dla produkcji

2. **Startup Command** (w Azure Portal → Configuration → General settings):
   ```
   gunicorn -w 4 -b 0.0.0.0:8000 app:app
   ```
   Lub jeśli używasz Python bezpośrednio:
   ```
   python app.py
   ```

3. **Upewnij się, że folder `build/` jest wdrożony** - dodaj go do repozytorium lub skopiuj na serwer.

### 5. Obsługa błędów kamery

Błędy kamery na serwerze Azure są normalne - serwer nie ma dostępu do kamery. Aplikacja obsługuje to automatycznie:
- Błędy są logowane, ale nie przerywają działania
- Aplikacja będzie działać bez kamery (możesz użyć zewnętrznej kamery przez RTSP lub IP)

### 6. Testowanie

Po wdrożeniu sprawdź:
- `http://twoja-domena/` - powinien zwrócić frontend React
- `http://twoja-domena/api/login` - endpoint API (wymaga POST)
- `http://twoja-domena/api/camera/status` - status kamery (wymaga logowania)

### 7. Troubleshooting

**Problem: Nadal 404**
- Sprawdź, czy folder `build/` istnieje i zawiera `index.html`
- Sprawdź logi aplikacji
- Upewnij się, że trasy są poprawnie zdefiniowane

**Problem: CORS errors**
- Dodaj domenę Azure do `CORS_ORIGINS` w zmiennych środowiskowych
- Format: `https://twoja-domena.azurewebsites.net`

**Problem: Port nie działa**
- Azure App Service automatycznie mapuje porty
- Użyj zmiennej `PORT` z Azure lub ustaw `0.0.0.0:8000` dla Gunicorn

## Struktura plików po zbudowaniu

```
Detection-phone/
├── app.py                 # Backend Flask
├── build/                 # ← Zbudowany frontend React (utworzony przez npm run build)
│   ├── index.html
│   ├── static/
│   │   ├── css/
│   │   └── js/
│   └── ...
├── src/                   # Kod źródłowy React
├── public/                # Pliki publiczne React
└── ...
```

## Uwagi

- **Nie używaj Flask development server w produkcji** - użyj Gunicorn lub innego WSGI servera
- **Zabezpiecz zmienne środowiskowe** - nie commituj `.env` do repozytorium
- **Użyj Azure SQL lub PostgreSQL** zamiast SQLite dla produkcji (SQLite nie działa dobrze w środowisku wielowątkowym)
