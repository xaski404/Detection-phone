@echo off
echo ========================================
echo Uruchamianie Phone Detection System
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] Sprawdzanie czy frontend jest zbudowany...
if not exist "build\index.html" (
    echo Frontend nie jest zbudowany. Budowanie...
    call npm run build
    if errorlevel 1 (
        echo BLAD: Nie udalo sie zbudowac frontendu!
        echo Upewnij sie, ze masz zainstalowany Node.js i npm.
        pause
        exit /b 1
    )
    echo Frontend zbudowany pomyslnie!
) else (
    echo Frontend juz zbudowany - OK
)

echo.
echo [2/3] Sprawdzanie czy baza danych istnieje...
if not exist "instance\admin.db" (
    echo Baza danych nie istnieje. Inicjalizacja...
    python init_db.py
    if errorlevel 1 (
        echo BLAD: Nie udalo sie zainicjalizowac bazy danych!
        pause
        exit /b 1
    )
    echo Baza danych utworzona pomyslnie!
) else (
    echo Baza danych istnieje - OK
)

echo.
echo [3/3] Uruchamianie aplikacji...
echo.
echo ========================================
echo Aplikacja bedzie dostepna na:
echo http://localhost:5000
echo.
echo Login: admin / admin
echo ========================================
echo.

python app.py

pause
