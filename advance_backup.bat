@echo off
setlocal enabledelayedexpansion

REM Direktori backup tujuan
set BACKUP_DIR=C:\Users\dylaa\Desktop\Backup_file

REM File log backup
set LOG_FILE=%BACKUP_DIR%\backup_log.txt

REM Fungsi kirim notifikasi email (menggunakan blat, harus instal blat terlebih dahulu)
REM Konfigurasi email - sesuaikan dengan SMTP server dan kredensial Anda
set SMTP_SERVER=smtp.gmail.com
set SMTP_PORT=587
set EMAIL_FROM=tanangodylaa@gmail.com
set EMAIL_TO=tanangodila@gmail.com
set EMAIL_USER=tanangodylaa@gmail.com
set EMAIL_PASS=yeyulshaayhbhxei 

REM Pilihan folder backup (Selective Backup)
echo Pilih folder yang akan di-backup:
echo 1. Folder_A
echo 2. Folder_B
echo 3. Folder_C
echo 4. Folder_D
echo 5. Folder_E
echo 6. Folder_F
echo 7. Folder_G
echo 8. Folder_H
echo 9. Folder_I
echo 10. Folder_J
set /p folderChoice=Masukkan nomor pilihan (misal 1): 

if "%folderChoice%"=="1" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_A
if "%folderChoice%"=="2" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_B
if "%folderChoice%"=="3" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_C
if "%folderChoice%"=="4" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_D
if "%folderChoice%"=="5" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_E
if "%folderChoice%"=="6" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_F
if "%folderChoice%"=="7" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_G
if "%folderChoice%"=="8" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_H
if "%folderChoice%"=="9" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_I
if "%folderChoice%"=="10" set SOURCE=%USERPROFILE%\Desktop\SimulasiDrive_D\Folder_J

if not defined SOURCE (
    echo Pilihan tidak valid.
    exit /b 1
)

REM ======= Scheduled Backup =======
set /p INTERVAL=Masukkan interval backup (menit): 
if "%INTERVAL%"=="" set INTERVAL=10

REM Membuat direktori backup jika belum ada
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Fungsi backup incremental (backup file yang berubah)
:backup_loop
set TIMESTAMP=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set CURRENT_BACKUP=%BACKUP_DIR%\backup_%TIMESTAMP%

echo Memulai backup incremental...
mkdir "%CURRENT_BACKUP%"

REM Meng-copy file dan folder berubah saja (incremental dengan struktur folder)
robocopy "%SOURCE%" "%CURRENT_BACKUP%" /MIR /R:1 /W:1 /LOG:"%LOG_FILE%" /NJH /NJS

echo Backup selesai pada %DATE% %TIME% >> "%LOG_FILE%"
echo Backup selesai pada %DATE% %TIME%
echo.

REM Kirim email dan cek status
blat -to %EMAIL_TO% -subject "Backup Selesai" -body "Backup sudah selesai pada %DATE% %TIME%." -server %SMTP_SERVER%:%SMTP_PORT% -f %EMAIL_FROM% -u %EMAIL_USER% -pw "%EMAIL_PASS%" > temp_blat.log 2>&1
if %errorlevel%==0 (
     echo Email gagal dikirim. Cek konfigurasi atau log error. >> "%LOG_FILE%"
    echo Email gagal dikirim! Error code: %errorlevel%
) else (
    echo Email berhasil dikirim ke %EMAIL_TO%. >> "%LOG_FILE%"
    echo Email berhasil dikirim!
)
del temp_blat.log 

REM Hitung detik dan tunggu
set /a SECONDS=%INTERVAL%*60
echo Menunggu %INTERVAL% menit (%SECONDS% detik) sebelum backup berikutnya...
timeout /t %SECONDS% /nobreak >nul

goto backup_loop
pause