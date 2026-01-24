# Problem z kamerą na Azure

## Dlaczego kamera Iriun nie działa na Azure?

**Główny problem:** Azure to serwer w chmurze, który **nie ma fizycznego dostępu** do kamer na Twoim lokalnym komputerze.

### Techniczne szczegóły:

1. **Iriun Webcam wymaga:**
   - Lokalnego klienta Iriun działającego na Twoim komputerze
   - Połączenia lokalnego między aplikacją a kamerą
   - Dostępu do urządzeń wideo (VideoCapture przez OpenCV)

2. **Azure App Service:**
   - Działa w chmurze (nie na Twoim komputerze)
   - Nie ma dostępu do urządzeń sprzętowych
   - Nie może wykryć ani użyć lokalnych kamer
   - Kod próbuje użyć `cv2.VideoCapture(index)`, ale na Azure nie ma żadnych kamer

3. **Błędy w logach:**
   ```
   Camera index out of range
   Cannot open camera (Index: 0)
   ```
   Te błędy pojawiają się, ponieważ Azure nie ma żadnych dostępnych kamer.

## Rozwiązania

### Opcja 1: Uruchom aplikację lokalnie (ZALECANE)

Jeśli potrzebujesz dostępu do lokalnej kamery Iriun, aplikacja **musi działać na Twoim komputerze**, a nie na Azure.

**Konfiguracja:**
- Backend Flask uruchomiony lokalnie (lub na serwerze z dostępem do kamery)
- Frontend React można hostować na Azure lub lokalnie
- Frontend komunikuje się z backendem przez API

**Architektura:**
```
[Twój komputer] → Flask + Camera → Iriun Webcam
     ↓
[Azure/Internet] → React Frontend → API calls → Flask (lokalnie)
```

### Opcja 2: Użyj IP kamery / RTSP stream

Jeśli chcesz użyć Azure, możesz:
- Podłączyć IP kamerę (np. przez sieć)
- Użyć RTSP stream (Real-Time Streaming Protocol)
- Zmodyfikować kod, aby używał RTSP URL zamiast indeksu kamery

**Przykład:**
```python
# Zamiast:
cap = cv2.VideoCapture(0)

# Użyj:
rtsp_url = "rtsp://username:password@camera-ip:554/stream"
cap = cv2.VideoCapture(rtsp_url)
```

**Uwaga:** Iriun Webcam nie obsługuje bezpośrednio RTSP bez dodatkowej konfiguracji.

### Opcja 3: Hybrid - Backend lokalnie, Frontend na Azure

**Architektura:**
- **Frontend React** → Hostowany na Azure
- **Backend Flask** → Uruchomiony lokalnie na Twoim komputerze
- **Komunikacja** → Frontend na Azure łączy się z backendem lokalnym (przez publiczny IP/DDNS lub VPN)

**Problemy z tym rozwiązaniem:**
- Potrzebujesz statycznego publicznego IP lub DDNS
- Konfiguracja routera (port forwarding)
- Bezpieczeństwo (otwarty port)
- Backend musi być zawsze uruchomiony na Twoim komputerze

### Opcja 4: WebRTC (zaawansowane)

Można zaimplementować WebRTC do streamingu wideo z lokalnej kamery do Azure, ale to wymaga znacznych zmian w kodzie.

## Rekomendacja

**Najlepsze rozwiązanie:** Uruchom aplikację **lokalnie** na swoim komputerze.

**Dlaczego:**
- Iriun Webcam wymaga lokalnego dostępu
- Prostsze w konfiguracji
- Lepsze bezpieczeństwo (kamera nie jest dostępna z internetu)
- Lepsza wydajność (bez opóźnień sieciowych)

**Jeśli potrzebujesz dostępu z internetu:**
- Użyj VPN do połączenia z lokalną siecią
- Lub użyj Azure VPN Gateway (dla większych organizacji)

## Jak uruchomić lokalnie z dostępem do kamery

1. **Upewnij się, że Iriun Webcam działa:**
   - Zainstaluj klienta Iriun na telefonie
   - Uruchom serwer Iriun na komputerze
   - Sprawdź, czy kamera jest widoczna w systemie

2. **Uruchom backend lokalnie:**
   ```bash
   cd Detection-phone
   python app.py
   ```

3. **Zbuduj i uruchom frontend:**
   ```bash
   npm install
   npm run build
   npm start  # Frontend na localhost:3000
   ```

4. **Lub użyj zbudowanego frontendu z Flask:**
   ```bash
   npm run build
   python app.py  # Frontend serwowany przez Flask na localhost:5000
   ```

## Podsumowanie

❌ **Azure nie może używać lokalnej kamery Iriun** - brak fizycznego dostępu do urządzeń

✅ **Rozwiązanie:** Uruchom aplikację lokalnie na komputerze z dostępem do kamery

🔄 **Alternatywa:** Użyj IP kamery z RTSP stream (wymaga innej kamery niż Iriun)
