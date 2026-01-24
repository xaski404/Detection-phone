# 🚀 Uruchomienie z React Dev Server

## Dla prezentacji - React w trybie development

Uruchom **dwa terminale** osobno:

---

## Terminal 1: Backend Flask

```bash
cd Detection-phone
python app.py
```

Backend będzie działał na: **http://localhost:5000**

---

## Terminal 2: Frontend React (Dev Server)

```bash
cd Detection-phone
npm start
```

Frontend automatycznie otworzy się w przeglądarce na: **http://localhost:3000**

---

## Korzyści trybu development:

✅ **Hot-reload** - zmiany w kodzie React odświeżają się automatycznie  
✅ **Lepsze debugowanie** - szczegółowe komunikaty błędów  
✅ **Szybsze rozwój** - nie trzeba budować za każdym razem  

---

## Jak działa komunikacja:

- React Dev Server (port 3000) → komunikuje się z Flask API (port 5000)
- W `package.json` jest ustawione: `"proxy": "http://localhost:5000"`
- Wszystkie zapytania do `/api/*` są przekierowywane do Flask

---

## Login:

- **Username:** `admin`
- **Password:** `admin`

---

## Ważne:

- **Upewnij się, że oba terminale są uruchomione jednocześnie!**
- Backend (Flask) musi być uruchomiony przed frontendem (React)
- Jeśli zamkniesz którykolwiek terminal, aplikacja przestanie działać
