@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ===== НАСТРОЙКИ =====
set REPO_URL=https://github.com/uixcherry/cobraimages.git
set COMMIT_MESSAGE=add images
REM =====================

echo.
echo === GitHub image uploader ===
echo Папка: %cd%
echo Репозиторий: %REPO_URL%
echo.

REM Проверка Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ОШИБКА: Git не установлен или не добавлен в PATH.
    echo Скачай Git: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Проверка файлов больше 100 МБ
echo Проверяю файлы больше 100 МБ...
set BIGFILE_FOUND=0

for /r %%F in (*) do (
    if /i not "%%~nxF"=="upload_to_github.bat" (
        set SIZE=%%~zF
        if !SIZE! GTR 104857600 (
            echo.
            echo ОШИБКА: Файл больше 100 МБ:
            echo %%F
            echo Размер: !SIZE! байт
            set BIGFILE_FOUND=1
        )
    )
)

if "%BIGFILE_FOUND%"=="1" (
    echo.
    echo GitHub не примет файлы больше 100 МБ.
    echo Сожми их или убери из папки.
    pause
    exit /b 1
)

REM Инициализация Git
if not exist ".git" (
    echo.
    echo Инициализирую Git-репозиторий...
    git init
)

REM Настройка ветки main
git branch -M main

REM Настройка remote origin
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo.
    echo Добавляю origin...
    git remote add origin %REPO_URL%
) else (
    echo.
    echo Обновляю origin...
    git remote set-url origin %REPO_URL%
)

REM Настройка имени, если не задано
git config user.name >nul 2>&1
if errorlevel 1 (
    git config user.name "uixcherry"
)

git config user.email >nul 2>&1
if errorlevel 1 (
    git config user.email "uixcherry@gmail.com"
)

REM Добавление файлов
echo.
echo Добавляю файлы...
git add .

REM Проверка есть ли изменения
git diff --cached --quiet
if not errorlevel 1 (
    echo.
    echo Нет новых изменений для загрузки.
    pause
    exit /b 0
)

REM Коммит
echo.
echo Создаю commit...
git commit -m "%COMMIT_MESSAGE%"

REM Попытка подтянуть remote, если там уже есть файлы
echo.
echo Проверяю удалённый репозиторий...
git pull origin main --rebase --allow-unrelated-histories

REM Push
echo.
echo Загружаю на GitHub...
git push -u origin main

if errorlevel 1 (
    echo.
    echo ОШИБКА: push не удался.
    echo Возможные причины:
    echo 1. Ты не вошёл в GitHub через Git.
    echo 2. Файл слишком большой.
    echo 3. Нет прав на репозиторий.
    echo 4. GitHub требует авторизацию через браузер или token.
    pause
    exit /b 1
)

echo.
echo ГОТОВО. Файлы загружены в GitHub.
echo.
echo CDN-ссылка будет такого вида:
echo https://cdn.jsdelivr.net/gh/uixcherry/cobraimages@main/ИМЯ_ФАЙЛА.png
echo.
pause