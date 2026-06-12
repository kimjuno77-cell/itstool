@echo off
chcp 65001 > nul
title Engineering Tools - 오프라인 패키지 빌더

echo ==============================================================
echo  Engineering Tools Portal - 오프라인 패키지 자동 구축 스크립트
echo ==============================================================
echo.
echo 이 스크립트는 6개의 계산기 HTML 파일 내에 포함된 온라인 CDN 의존성
echo (React, Tailwind CSS, Lucide Icons, PDF.js 등)을 로컬로 다운로드하고,
echo 각 HTML 파일의 스크립트 경로를 로컬 상대 경로로 자동 수정합니다.
echo.
echo 완료된 후 폴더 전체를 ZIP으로 압축하여 팀원에게 전달하면,
echo 인터넷이 전혀 되지 않는 오프라인 환경에서도 100%% 정상 작동합니다.
echo.
echo [준비 작업] 다운로드를 시작합니다. 인터넷 연결이 유지되어야 합니다.
echo.
pause

:: 1. libs 폴더 생성
if not exist "libs" (
    echo [정보] libs 폴더를 생성합니다...
    mkdir "libs"
)

:: 2. CDN 라이브러리 다운로드 (Windows 기본 탑재 curl 사용)
echo.
echo [1/6] React Core 다운로드 중...
curl -L -s -o "libs\react.production.min.js" "https://unpkg.com/react@18/umd/react.production.min.js"
if %errorlevel% neq 0 (echo [오류] React 다운로드 실패 && goto error)

echo [2/6] React DOM 다운로드 중...
curl -L -s -o "libs\react-dom.production.min.js" "https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"
if %errorlevel% neq 0 (echo [오류] React DOM 다운로드 실패 && goto error)

echo [3/6] Babel Standalone 다운로드 중 (용량이 커 수 초가 소요될 수 있습니다)...
curl -L -s -o "libs\babel.min.js" "https://unpkg.com/@babel/standalone/babel.min.js"
if %errorlevel% neq 0 (echo [오류] Babel 다운로드 실패 && goto error)

echo [4/6] Tailwind CSS CDN 다운로드 중...
curl -L -s -o "libs\tailwind.js" "https://cdn.tailwindcss.com"
if %errorlevel% neq 0 (echo [오류] Tailwind 다운로드 실패 && goto error)

echo [5/6] Lucide Icons 다운로드 중...
curl -L -s -o "libs\lucide.min.js" "https://unpkg.com/lucide@latest"
if %errorlevel% neq 0 (echo [오류] Lucide 다운로드 실패 && goto error)

echo [6/6] PDF.js 라이브러리 다운로드 중...
curl -L -s -o "libs\pdf.min.js" "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.min.js"
if %errorlevel% neq 0 (echo [오류] PDF.js 다운로드 실패 && goto error)

echo.
echo [성공] 모든 핵심 외부 라이브러리 로컬 다운로드 완료!
echo.

:: 3. HTML 파일 내 온라인 주소를 로컬 상대 경로로 치환 (PowerShell 연동)
echo [작업] HTML 파일들의 온라인 CDN 경로를 로컬 경로로 자동 변경합니다...

powershell -Command ^
    "$files = Get-ChildItem -Filter '*.html' -Recurse;" ^
    "foreach ($f in $files) {" ^
        "$content = Get-Content $f.FullName -Encoding UTF8 -Raw;" ^
        "$modified = $false;" ^
        "if ($content -match 'https://unpkg.com/react@18/umd/react.production.min.js') {" ^
            "$content = $content -replace 'https://unpkg.com/react@18/umd/react.production.min.js', 'libs/react.production.min.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($content -match 'https://unpkg.com/react-dom@18/umd/react-dom.production.min.js') {" ^
            "$content = $content -replace 'https://unpkg.com/react-dom@18/umd/react-dom.production.min.js', 'libs/react-dom.production.min.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($content -match 'https://unpkg.com/@babel/standalone/babel.min.js') {" ^
            "$content = $content -replace 'https://unpkg.com/@babel/standalone/babel.min.js', 'libs/babel.min.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($content -match 'https://cdn.tailwindcss.com') {" ^
            "$content = $content -replace 'https://cdn.tailwindcss.com', 'libs/tailwind.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($content -match 'https://unpkg.com/lucide@latest') {" ^
            "$content = $content -replace 'https://unpkg.com/lucide@latest', 'libs/lucide.min.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($content -match 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.min.js') {" ^
            "$content = $content -replace 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.min.js', 'libs/pdf.min.js';" ^
            "$modified = $true;" ^
        "}" ^
        "if ($modified) {" ^
            "Set-Content -Path $f.FullName -Value $content -Encoding UTF8;" ^
            "Write-Host '[수정 완료]' $f.Name;" ^
        "}" ^
    "}"

echo.
echo ==============================================================
echo  [빌드 성공] 완벽한 오프라인 통합 패키지가 구축되었습니다!
echo ==============================================================
echo.
echo [배포 가이드]
echo 1. 이제 현재 폴더에 있는 모든 파일과 폴더(libs 포함)를 하나의 .ZIP으로 압축합니다.
echo    (단, 'setup_offline.bat' 파일은 배포용이 아니므로 제외하셔도 좋습니다.)
echo 2. 압축된 .ZIP 파일을 팀원들에게 배포합니다.
echo 3. 팀원은 압축을 해제한 후 'index.html'을 더블 클릭해 브라우저에서 실행하면 끝!
echo.
pause
exit

:error
echo.
echo [오류] 다운로드 중 네트워크 에러 또는 권한 에러가 발생했습니다.
echo 인터넷 연결 및 폴더 쓰기 권한을 확인한 후 다시 실행해 주십시오.
echo.
pause
exit
