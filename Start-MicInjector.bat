@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title MicInjector - Quest Launcher
color 0B

set "ROOT=%~dp0"
set "ADB_EXE=adb.exe"
set "ADB_DEVICE_SERIAL="
set "MICINJECTOR_STATE_DIR=%LOCALAPPDATA%\MicInjector"
if not defined LOCALAPPDATA set "MICINJECTOR_STATE_DIR=%USERPROFILE%\.micinjector"
set "MICINJECTOR_WIFI_FILE=%MICINJECTOR_STATE_DIR%\quest-wifi-ip.txt"
set "MICINJECTOR_WIFI_DIR=%MICINJECTOR_STATE_DIR%\wifi-devices"
set "QUEST_PORT=5555"
if not exist "%MICINJECTOR_WIFI_DIR%" md "%MICINJECTOR_WIFI_DIR%" >nul 2>&1
if not exist "%MICINJECTOR_STATE_DIR%" md "%MICINJECTOR_STATE_DIR%" >nul 2>&1
set "MIC_INJECTOR_PRESET=VOICE_RECOGNITION"
rem English-only interface; all launcher text is kept in this file.
set "T_ADB_NOT_FOUND=ADB WAS NOT FOUND"
set "T_ADB_HINT1=Add Android Platform Tools to PATH or place them in this folder:"
set "T_ADB_HINT2=Or enter the full path to adb.exe without quotation marks."
set "T_ADB_PROMPT=Full path to adb.exe, or press Enter to exit:"
set "T_ADB_BAD=adb.exe was not found at that location."
set "T_NODE_MISSING=Node.js 22 or newer was not found. Install it from:"
set "T_NPM_MISSING=npm was not found. Repair or reinstall Node.js with npm enabled:"
set "T_NODE_VERSION_ERROR=Could not determine the installed Node.js version."
set "T_NODE_TOO_OLD=MicInjector requires Node.js 22 or newer."
set "T_NODE_UPDATE=Your installed version is too old. Update Node.js:"
set "T_MAIN_TITLE=MICINJECTOR QUEST LAUNCHER"
set "T_MAIN_CHOOSE=Choose how your Quest connects to this PC:"
set "T_MAIN_AFTER=After that, choose your Quest device and Windows audio source."
set "T_MAIN_USB=USB connection"
set "T_MAIN_WIFI=Wi-Fi connection"
set "T_MAIN_SOFTWARE=Software and setup links"
set "T_MAIN_EXIT=Exit"
set "T_SELECT_OPTION=Select an option:"
set "T_SOFT_TITLE=SOFTWARE AND SETUP"
set "T_SOFT_REQUIRED=Required for the launcher:"
set "T_SOFT_OPTIONAL=Optional audio mixing setup:"
set "T_SOFT_BACK=Back"
set "T_SOFT_PROMPT=Open official download page:"
set "T_USB_TITLE=USB CONNECTION"
set "T_USB_INFO1=Connect your Quest with a USB-C data cable."
set "T_USB_INFO2=Put on the headset and accept the USB debugging prompt."
set "T_WIFI_TITLE=WI-FI CONNECTION"
set "T_WIFI_EXISTING=Connect to a saved Quest"
set "T_WIFI_MANAGE=Manage saved Quest connections"
set "T_WIFI_USB=Set up a new Quest using USB"
set "T_BACK=Back"
set "T_SELECT_USB=SELECT USB QUEST"
set "T_SELECT_WIFI=SELECT WI-FI QUEST"
set "T_SEARCHING=Searching for connected devices..."
set "T_NO_DEVICES=No matching ADB devices are visible."
set "T_DEVICE_HEADER=CONNECTED DEVICES:"
set "T_DEVICE_GUIDE=Select your Quest by its name. Full ADB serials are hidden."
set "T_USB_GUIDE=USB: enable Developer Mode, use a data cable, wake the headset and approve USB debugging. If missing, install Meta's USB ADB driver."
set "T_WIFI_GUIDE=Wi-Fi: choose the correct Quest by checking its IP:port beside the name. If the address or port changes, refresh through USB."
set "T_REFRESH=[R] Refresh"
set "T_CANCEL=[X] Back"
set "T_DEVICE_PROMPT=Device number:"
set "T_UNAUTHORIZED=This device has not authorized this PC. Approve USB debugging inside the headset, then refresh."
set "T_OFFLINE=This device is offline. Wake the Quest, check the same Wi-Fi network, or reconnect it through USB."
set "T_SELECTED=Selected device:"
set "T_MODEL_WARNING=The model name does not identify this as a Quest. Check that you selected the correct headset."
set "T_CONTINUE=Continue with this device anyway? 1 = Yes, 2 = No:"
set "T_START_TITLE=STARTING MICINJECTOR"
set "T_SELECTED_LABEL=Selected Quest:"
set "T_APK_MISSING=APK was not found:"
set "T_APK_PATH=APK path, or press Enter to cancel:"
set "T_APK_WARN_TITLE=SECURITY AND INSTALLATION WARNING"
set "T_APK_WARN1=You are about to install an unofficial experimental APK on the selected Quest."
set "T_APK_WARN2=It may be unstable or incompatible with your headset, Android version, or target app."
set "T_APK_WARN3=It may stop working after a headset or app software update. Only install software from a source you trust."
set "T_APK_WARN4=This project is experimental and has not been verified on every Quest model or software version."
set "T_APK_WARN5=The software is provided without warranty. Install and use it only if you understand and accept these risks."
set "T_APK_CONFIRM=Do you trust this APK and want to install it? 1 = Yes, 2 = No:"
set "T_APK_DECLINED=Installation cancelled. The APK was not installed."
set "T_APK_INSTALLING=Installing MicInjector on the Quest..."
set "T_APK_FAILED=APK installation failed. Check the Quest connection and APK."
set "T_APK_ALREADY=MicInjector is already installed on this Quest."
set "T_DEPS_CHECK=Checking and updating Windows client dependencies..."
set "T_DEPS_FAIL=Dependency installation failed. Check your internet connection."
set "T_AUDIO_HELP=Next, choose the Windows playback device to capture."
set "T_AUDIO_HELP2=For MIXLINE and VB-CABLE, choose CABLE Input."
set "T_INJECT_START=Starting the injector audio process..."
set "T_KEEP_OPEN=Keep this window open while using it."
set "T_CLIENT_ERROR=MicInjector stopped with an error. Check the message above."
set "T_CLIENT_STOP=MicInjector has stopped."
set "T_EXIT_MSG=MicInjector launcher closed."
set "T_HELP_TITLE=QUEST NOT DETECTED? CHECK THESE SETTINGS"
set "T_WIFI_EXISTING_TITLE=CONNECT TO A SAVED QUEST"
set "T_WIFI_EXISTING_INFO=Choose which saved Quest to connect to. Each entry shows its address, optional name and last connection time."
set "T_WIFI_MANAGE_TITLE=MANAGE SAVED QUESTS"
set "T_WIFI_MANAGE_INFO=Choose a Quest to edit its name or remove the saved connection."
set "T_WIFI_MANAGE_EMPTY=There are no saved Quest connections yet."
set "T_WIFI_LIST_EMPTY=No saved Quest connections were found. Set up a Quest using USB first."
set "T_WIFI_NAME_PROMPT=Optional name for this Quest (leave blank to use the default name): "
set "T_WIFI_NAME_INVALID=Name must be 1 to 32 characters and use letters, numbers, spaces, underscores or hyphens."
set "T_WIFI_EDIT_NAME=Edit display name"
set "T_WIFI_REMOVE=Remove saved connection"
set "T_WIFI_MANAGE_BACK=Back"
set "T_WIFI_NAME_CURRENT=Current custom name: "
set "T_WIFI_NAME_CLEAR=Leave blank to clear the custom name."
set "T_WIFI_REMOVE_CONFIRM=Remove this saved Quest connection? 1 = Yes, 2 = No: "
set "T_WIFI_REMOVE_DONE=Saved Quest connection removed."
set "T_WIFI_NAME_SAVED=Quest display name saved."
set "T_WIFI_LAST_UNKNOWN=Not recorded yet"
set "T_WIFI_USB_TITLE=SET UP WI-FI ADB THROUGH USB"
set "T_WIFI_USB_INFO1=Connect the Quest and PC to the same local Wi-Fi network."
set "T_WIFI_USB_INFO2=Connect the Quest to this PC with a USB-C data cable and approve USB debugging."
set "T_WIFI_USB_INFO3=The launcher reads the Quest's Wi-Fi IP automatically. You do not need to type an address."
set "T_WIFI_USB_INFO4=Default port is 5555. Advanced users can enter another TCP/IP port before the launcher saves the connection."
set "T_WIFI_SAVED_MISSING=No saved Quest Wi-Fi address was found. Choose Set up a new Quest using USB."
set "T_WIFI_SAVED_INVALID=The saved Quest Wi-Fi settings are invalid. Set up Wi-Fi again through USB."
set "T_WIFI_RECONNECTING=Connecting to the saved Quest Wi-Fi address..."
set "T_WIFI_RECONNECT_FAILED=Could not reach the saved Quest. After a restart, reconnect it through USB and choose Set up a new Quest using USB to enable TCP/IP again."
set "T_WIFI_ROUTE_READING=Reading the Quest Wi-Fi IP address through ADB..."
set "T_WIFI_ROUTE_FAILED=Could not read the Quest Wi-Fi IP. Check that Wi-Fi is connected on the headset and try again."
set "T_WIFI_TCPIP=Enabling ADB TCP/IP..."
set "T_WIFI_TCPIP_FAILED=ADB could not switch to TCP/IP. Keep USB connected and check Developer Mode and USB debugging."
set "T_WIFI_CONNECTING=Connecting to the Quest over Wi-Fi..."
set "T_WIFI_CONNECT_FAILED=Could not connect over Wi-Fi. Check the same local network and router client isolation."
set "T_WIFI_SETUP_DONE=Wi-Fi ADB is ready. Unplug USB, then press any key to continue. The Quest IP and port are saved on this PC."
set "T_WIFI_SETUP_NOTE=Reconnect later with option 1. Changing ports does not encrypt ADB; use only a trusted private Wi-Fi network, not public or guest Wi-Fi."
set "T_WIFI_PORT_TITLE=ADVANCED WI-FI PORT SETTING"
set "T_WIFI_PORT_INFO=Default port is 5555. A Quest listens on the selected TCP/IP port only; changing it makes the previous port stop responding."
set "T_WIFI_PORT_RANGE=Enter a decimal port from 1024 to 65535. Press ENTER to keep 5555."
set "T_WIFI_PORT_INVALID=Invalid port. Use a whole number from 1024 to 65535, without leading zeros."
set "T_WIFI_PORT_CONFLICT=If another service is using that port, ADB may fail. Changing ports does not create a second connection to the same Quest."

set "T_ADB_START=Starting the local ADB server..."
set "T_ADB_START_FAILED=Could not start ADB. Check the Platform Tools installation."
set "T_UNAUTHORIZED_TITLE=THIS DEVICE HAS NOT AUTHORIZED THIS PC."
set "T_UNAUTHORIZED_LINE1=Put on the Quest and accept the USB debugging prompt."
set "T_UNAUTHORIZED_LINE2=Select Always allow from this computer if shown, then refresh."
set "T_OFFLINE_TITLE=THIS DEVICE IS CURRENTLY OFFLINE."
set "T_OFFLINE_LINE=Wake it, check the same Wi-Fi network, or reconnect it through USB."
set "T_SOFT_ADB_ITEM=Android Platform Tools - ADB"
set "T_SOFT_NODE_ITEM=Node.js 22+"
set "T_SOFT_MIX_ITEM=MIXLINE"
set "T_SOFT_CABLE_ITEM=VB-Audio VB-CABLE"
set "T_VBC_TITLE=VB-CABLE installation:"
set "T_VBC_1=Download the official ZIP."
set "T_VBC_2=Extract the ZIP to a folder."
set "T_VBC_3=Run the setup program as Administrator."
set "T_VBC_4=Restart Windows after installation."
set "T_OFFICIAL_PAGE=Official page:"
set "T_REFRESHING=Refreshing connected devices..."
set "T_DEVICE_INVALID=That device number is not in the list."
set "T_DEVICE_READ_FAILED=Could not read the selected device."
set "T_DEVICE_STATUS_AUTH=Status: waiting for USB debugging approval"
set "T_DEVICE_STATUS_OFFLINE=Status: offline"
set "T_PRESET_LABEL=Capture preset:"
set "T_PACKAGE_CHECK=Checking whether the Android component is installed..."
set "T_DEPS_INFO=Using npm to run the project's pinned pnpm 10.6.5. No separate Corepack or global pnpm installation is needed."
set "T_APK_DOWNLOAD1=Download MicInjector-debug-apk.zip from the GitHub Releases page."
set "T_APK_DOWNLOAD2=Extract app-debug.apk, then enter its full path below."
set "T_APK_DOWNLOAD_LINK=https://github.com/W911D/MicInjector-Quest-VoiceRecognition/releases"
set "T_APK_PATH_EXTRA=Enter the path without surrounding quotation marks."
set "T_APK_NOT_FOUND=APK file still cannot be found. Returning to the main menu."
set "T_APK_EMPTY=The selected APK is empty. Choose a valid APK file."
where adb.exe >nul 2>&1
if errorlevel 1 (
    if exist "%ROOT%platform-tools\adb.exe" (
        set "ADB_EXE=%ROOT%platform-tools\adb.exe"
    ) else (
        cls
        echo ============================================================
        echo                  !T_ADB_NOT_FOUND!
        echo ============================================================
        echo.
        echo !T_ADB_HINT1!
        echo   %ROOT%platform-tools
        echo !T_ADB_HINT2!
        echo.
        echo !T_OFFICIAL_PAGE!
        echo https://developer.android.com/tools/releases/platform-tools
        echo.
        set "CUSTOM_ADB_PATH="
        set /p "CUSTOM_ADB_PATH=  !T_ADB_PROMPT! "
        if defined CUSTOM_ADB_PATH set "ADB_EXE=!CUSTOM_ADB_PATH!"
        if not exist "!ADB_EXE!" (
            echo.
            echo  !T_ADB_BAD!
            pause
            exit /b 1
        )
    )
)

where node.exe >nul 2>&1
if errorlevel 1 (
    echo !T_NODE_MISSING!
    echo https://nodejs.org/en/download
    pause
    exit /b 1
)

where npm.cmd >nul 2>&1
if errorlevel 1 (
    echo !T_NPM_MISSING!
    echo Keep the npm package manager feature enabled during setup.
    echo https://nodejs.org/en/download
    pause
    exit /b 1
)

set "NODE_MAJOR="
for /f "tokens=1 delims=v." %%V in ('node --version') do set "NODE_MAJOR=%%V"
if not defined NODE_MAJOR (
    echo !T_NODE_VERSION_ERROR!
    pause
    exit /b 1
)
if !NODE_MAJOR! LSS 22 (
    echo !T_NODE_TOO_OLD!
    echo !T_NODE_UPDATE!
    echo https://nodejs.org/en/download
    pause
    exit /b 1
)


:MENU
cls
echo.
echo  ============================================================
echo                  !T_MAIN_TITLE!
echo  ============================================================
echo.
echo       !T_MAIN_CHOOSE!
echo.
echo       !T_MAIN_AFTER!
echo.
echo          [1] !T_MAIN_USB!
echo.
echo          [2] !T_MAIN_WIFI!
echo.
echo          [3] !T_MAIN_SOFTWARE!
echo.
echo          [4] !T_MAIN_EXIT!
echo.
echo  ------------------------------------------------------------
choice /c 1234 /n /m "  !T_SELECT_OPTION! "
if errorlevel 4 goto END
if errorlevel 3 goto SOFTWARE_MENU
if errorlevel 2 goto WIFI_MENU
if errorlevel 1 goto USB

:SOFTWARE_MENU
cls
echo.
echo  ============================================================
echo                   !T_SOFT_TITLE!
echo  ============================================================
echo.
echo  !T_SOFT_REQUIRED!
echo    - !T_SOFT_ADB_ITEM!
echo    - !T_SOFT_NODE_ITEM!
echo.
echo  !T_SOFT_OPTIONAL!
echo    - !T_SOFT_MIX_ITEM!
echo    - !T_SOFT_CABLE_ITEM!
echo.
echo       [1] !T_SOFT_ADB_ITEM!
echo       [2] !T_SOFT_NODE_ITEM!
echo       [3] !T_SOFT_MIX_ITEM!
echo       [4] !T_SOFT_CABLE_ITEM!
echo       [5] !T_SOFT_BACK!
echo.
choice /c 12345 /n /m "  !T_SOFT_PROMPT! "
if errorlevel 5 goto MENU
if errorlevel 4 goto OPEN_VBCABLE
if errorlevel 3 goto OPEN_MIXLINE
if errorlevel 2 goto OPEN_NODE
if errorlevel 1 goto OPEN_ADB

:OPEN_ADB
start "" "https://developer.android.com/tools/releases/platform-tools"
goto SOFTWARE_MENU

:OPEN_NODE
start "" "https://nodejs.org/en/download"
goto SOFTWARE_MENU

:OPEN_MIXLINE
start "" "https://www.logitechg.com/en-eu/software/mixline"
goto SOFTWARE_MENU

:OPEN_VBCABLE
cls
echo.
echo  !T_VBC_TITLE!
echo    1. !T_VBC_1!
echo    2. !T_VBC_2!
echo    3. !T_VBC_3!
echo    4. !T_VBC_4!
echo.
echo  !T_OFFICIAL_PAGE! https://vb-audio.com/Cable/
echo.
start "" "https://vb-audio.com/Cable/"
pause
goto SOFTWARE_MENU

:USB
cls
echo.
echo  ============================================================
echo                     !T_USB_TITLE!
echo  ============================================================
echo.
echo  !T_USB_INFO1!
echo  !T_USB_INFO2!
echo.
call :PREPARE_ADB
if errorlevel 1 goto MENU
set "DEVICE_MODE=USB"
call :SELECT_DEVICE
if errorlevel 1 goto MENU
goto START_CLIENT

:WIFI_MENU
cls
echo.
echo  ============================================================
echo                    !T_WIFI_TITLE!
echo  ============================================================
echo.
echo       [1] !T_WIFI_EXISTING!
echo.
echo       [2] !T_WIFI_MANAGE!
echo.
echo       [3] !T_WIFI_USB!
echo.
echo       [4] !T_BACK!
echo.
choice /c 1234 /n /m "  !T_SELECT_OPTION! "
if errorlevel 4 goto MENU
if errorlevel 3 goto WIFI_USB_SETUP
if errorlevel 2 goto WIFI_MANAGE
if errorlevel 1 goto WIFI_EXISTING

:WIFI_EXISTING
call :PREPARE_ADB
if errorlevel 1 goto MENU
call :LOAD_SAVED_WIFI_LIST
if "!WIFI_SAVED_COUNT!"=="0" (
    echo.
    echo  !T_WIFI_LIST_EMPTY!
    pause
    goto WIFI_MENU
)
cls
echo.
echo  ============================================================
echo              !T_WIFI_EXISTING_TITLE!
echo  ============================================================
echo.
echo  !T_WIFI_EXISTING_INFO!
echo.
for /l %%I in (1,1,!WIFI_SAVED_COUNT!) do call :DISPLAY_SAVED_WIFI "%%I"
echo.
choice /c 123456789X /n /m "  Select Quest number (X = Back): "
set "WIFI_SAVED_PICK=!errorlevel!"
if "!WIFI_SAVED_PICK!"=="10" goto WIFI_MENU
if !WIFI_SAVED_PICK! GTR !WIFI_SAVED_COUNT! goto WIFI_EXISTING
call set "QUEST_IP=%%SAVED_WIFI_IP[!WIFI_SAVED_PICK!]%%"
call set "QUEST_PORT=%%SAVED_WIFI_PORT[!WIFI_SAVED_PICK!]%%"
call set "QUEST_MODEL=%%SAVED_WIFI_MODEL[!WIFI_SAVED_PICK!]%%"
call set "QUEST_NICKNAME=%%SAVED_WIFI_NAME[!WIFI_SAVED_PICK!]%%"
call set "QUEST_LAST_USED=%%SAVED_WIFI_LAST[!WIFI_SAVED_PICK!]%%"
call set "QUEST_RECORD_FILE=%%SAVED_WIFI_FILE[!WIFI_SAVED_PICK!]%%"
call :CONNECT_SAVED_WIFI
if errorlevel 1 (
    echo.
    echo  !T_WIFI_RECONNECT_FAILED!
    pause
    goto WIFI_EXISTING
)
set "QUEST_LAST_USED=%DATE% %TIME%"
call :SAVE_SAVED_WIFI_RECORD
set "ADB_DEVICE_SERIAL=!WIFI_SERIAL!"
set "DEVICE_LABEL=!QUEST_MODEL!"
set "DEVICE_MODEL=!QUEST_MODEL!"
if defined QUEST_NICKNAME set "DEVICE_LABEL=!QUEST_MODEL! - !QUEST_NICKNAME!"
set "DEVICE_MODE=WIFI"
goto START_CLIENT

:WIFI_MANAGE
call :LOAD_SAVED_WIFI_LIST
if "!WIFI_SAVED_COUNT!"=="0" (
    cls
    echo.
    echo  !T_WIFI_MANAGE_EMPTY!
    pause
    goto WIFI_MENU
)
cls
echo.
echo  ============================================================
echo                 !T_WIFI_MANAGE_TITLE!
echo  ============================================================
echo.
echo  !T_WIFI_MANAGE_INFO!
echo.
for /l %%I in (1,1,!WIFI_SAVED_COUNT!) do call :DISPLAY_SAVED_WIFI "%%I"
echo.
choice /c 123456789X /n /m "  Select Quest to manage (X = Back): "
set "WIFI_SAVED_PICK=!errorlevel!"
if "!WIFI_SAVED_PICK!"=="10" goto WIFI_MENU
if !WIFI_SAVED_PICK! GTR !WIFI_SAVED_COUNT! goto WIFI_MANAGE
call set "QUEST_IP=%%SAVED_WIFI_IP[!WIFI_SAVED_PICK!]%%"
call set "QUEST_PORT=%%SAVED_WIFI_PORT[!WIFI_SAVED_PICK!]%%"
call set "QUEST_MODEL=%%SAVED_WIFI_MODEL[!WIFI_SAVED_PICK!]%%"
call set "QUEST_NICKNAME=%%SAVED_WIFI_NAME[!WIFI_SAVED_PICK!]%%"
call set "QUEST_LAST_USED=%%SAVED_WIFI_LAST[!WIFI_SAVED_PICK!]%%"
call set "QUEST_RECORD_FILE=%%SAVED_WIFI_FILE[!WIFI_SAVED_PICK!]%%"
echo.
echo  !T_WIFI_NAME_CURRENT!!QUEST_NICKNAME!
echo  !T_WIFI_NAME_CLEAR!
echo.
choice /c 123 /n /m "  [1] !T_WIFI_EDIT_NAME!   [2] !T_WIFI_REMOVE!   [3] !T_WIFI_MANAGE_BACK!: "
if errorlevel 3 goto WIFI_MANAGE
if errorlevel 2 goto WIFI_REMOVE_SAVED
if errorlevel 1 goto WIFI_EDIT_SAVED_NAME
goto WIFI_MANAGE

:WIFI_EDIT_SAVED_NAME
echo.
set "QUEST_NICKNAME="
set /p "QUEST_NICKNAME=!T_WIFI_NAME_PROMPT!"
call :VALIDATE_WIFI_NAME
if errorlevel 1 (
    echo.
    echo  !T_WIFI_NAME_INVALID!
    pause
    goto WIFI_EDIT_SAVED_NAME
)
call :SAVE_SAVED_WIFI_RECORD
echo.
echo  !T_WIFI_NAME_SAVED!
pause
goto WIFI_MANAGE

:WIFI_REMOVE_SAVED
echo.
choice /c 12 /n /m "  !T_WIFI_REMOVE_CONFIRM!"
if errorlevel 2 goto WIFI_MANAGE
set "WIFI_SERIAL=!QUEST_IP!:!QUEST_PORT!"
"%ADB_EXE%" disconnect "!WIFI_SERIAL!" >nul 2>&1
call :DELETE_ALL_SAVED_WIFI_PROFILES_FOR_IP
echo.
echo  !T_WIFI_REMOVE_DONE!
pause
goto WIFI_MANAGE

:WIFI_USB_SETUP
call :PREPARE_ADB
if errorlevel 1 goto WIFI_MENU
cls
echo.
echo  ============================================================
echo                !T_WIFI_USB_TITLE!
echo  ============================================================
echo.
echo  !T_WIFI_USB_INFO1!
echo  !T_WIFI_USB_INFO2!
echo  !T_WIFI_USB_INFO3!
echo  !T_WIFI_USB_INFO4!
echo.
choice /c 12 /n /m "  Are both devices on the same Wi-Fi network? [1] Yes  [2] No: "
if errorlevel 2 goto WIFI_MENU

set "DEVICE_MODE=USB"
call :SELECT_DEVICE
if errorlevel 1 goto WIFI_MENU

call :ASK_WIFI_PORT
if errorlevel 1 goto WIFI_MENU

set "WIFI_ROUTE_FILE=%TEMP%\micinjector-route-%RANDOM%.txt"
"%ADB_EXE%" -s "!ADB_DEVICE_SERIAL!" shell ip -4 route get 1.1.1.1 > "!WIFI_ROUTE_FILE!" 2>nul
set "QUEST_IP="
for /f "usebackq tokens=1-16" %%A in ("!WIFI_ROUTE_FILE!") do (
    if /i "%%A"=="src" set "QUEST_IP=%%B"
    if /i "%%B"=="src" set "QUEST_IP=%%C"
    if /i "%%C"=="src" set "QUEST_IP=%%D"
    if /i "%%D"=="src" set "QUEST_IP=%%E"
    if /i "%%E"=="src" set "QUEST_IP=%%F"
    if /i "%%F"=="src" set "QUEST_IP=%%G"
    if /i "%%G"=="src" set "QUEST_IP=%%H"
    if /i "%%H"=="src" set "QUEST_IP=%%I"
    if /i "%%I"=="src" set "QUEST_IP=%%J"
    if /i "%%J"=="src" set "QUEST_IP=%%K"
    if /i "%%K"=="src" set "QUEST_IP=%%L"
    if /i "%%L"=="src" set "QUEST_IP=%%M"
    if /i "%%M"=="src" set "QUEST_IP=%%N"
    if /i "%%N"=="src" set "QUEST_IP=%%O"
    if /i "%%O"=="src" set "QUEST_IP=%%P"
)
del "!WIFI_ROUTE_FILE!" >nul 2>&1

if not defined QUEST_IP (
    echo.
    echo  !T_WIFI_ROUTE_FAILED!
    pause
    goto WIFI_MENU
)

echo.
echo  !T_WIFI_ROUTE_READING!
echo  Detected Quest IP: !QUEST_IP!
echo.
echo  !T_WIFI_TCPIP! Port: !QUEST_PORT!
echo  !T_WIFI_PORT_CONFLICT!
"%ADB_EXE%" -s "!ADB_DEVICE_SERIAL!" tcpip !QUEST_PORT!
if errorlevel 1 (
    echo.
    echo  !T_WIFI_TCPIP_FAILED!
    pause
    goto WIFI_MENU
)

timeout /t 2 /nobreak >nul
set "WIFI_SERIAL=!QUEST_IP!:!QUEST_PORT!"
echo.
echo  !T_WIFI_CONNECTING!
"%ADB_EXE%" connect "!WIFI_SERIAL!"
if errorlevel 1 (
    echo.
    echo  !T_WIFI_CONNECT_FAILED!
    pause
    goto WIFI_MENU
)

set "WIFI_STATE_FILE=%TEMP%\micinjector-state-%RANDOM%.txt"
"%ADB_EXE%" -s "!WIFI_SERIAL!" get-state > "!WIFI_STATE_FILE!" 2>nul
set "WIFI_STATE="
if exist "!WIFI_STATE_FILE!" set /p "WIFI_STATE="<"!WIFI_STATE_FILE!"
del "!WIFI_STATE_FILE!" >nul 2>&1
if /i not "!WIFI_STATE!"=="device" (
    echo.
    echo  !T_WIFI_CONNECT_FAILED!
    pause
    goto WIFI_MENU
)

set "QUEST_MODEL=!DEVICE_LABEL!"
if not defined QUEST_MODEL set "QUEST_MODEL=Meta Quest"
:WIFI_NEW_NAME_PROMPT
set "QUEST_NICKNAME="
echo.
set /p "QUEST_NICKNAME=!T_WIFI_NAME_PROMPT!"
call :VALIDATE_WIFI_NAME
if errorlevel 1 (
    echo.
    echo  !T_WIFI_NAME_INVALID!
    pause
    goto WIFI_NEW_NAME_PROMPT
)
set "QUEST_LAST_USED=%DATE% %TIME%"
set "QUEST_RECORD_FILE=%MICINJECTOR_WIFI_DIR%\!QUEST_IP!.ini"
call :SAVE_SAVED_WIFI_RECORD

echo.
echo  !T_WIFI_SETUP_DONE!
echo  !T_WIFI_SETUP_NOTE!
echo.
pause
goto WIFI_EXISTING

:PREPARE_ADB
echo.
echo  !T_ADB_START!
"%ADB_EXE%" start-server
if errorlevel 1 (
    echo.
    echo  !T_ADB_START_FAILED!
    pause
    exit /b 1
)
exit /b 0

:MIGRATE_LEGACY_WIFI
if not exist "%MICINJECTOR_WIFI_FILE%" exit /b 0
set "QUEST_IP="
set "QUEST_PORT=5555"
set "SAVED_WIFI_PORT="
set /p "QUEST_IP="<"%MICINJECTOR_WIFI_FILE%"
for /f "usebackq skip=1 delims=" %%P in ("%MICINJECTOR_WIFI_FILE%") do if not defined SAVED_WIFI_PORT set "SAVED_WIFI_PORT=%%P"
if defined SAVED_WIFI_PORT set "QUEST_PORT=!SAVED_WIFI_PORT!"
if not defined QUEST_IP exit /b 0
call :VALIDATE_WIFI_PORT
if errorlevel 1 set "QUEST_PORT=5555"
set "QUEST_MODEL=Saved Quest"
set "QUEST_NICKNAME="
set "QUEST_LAST_USED=!T_WIFI_LAST_UNKNOWN!"
set "QUEST_RECORD_FILE=%MICINJECTOR_WIFI_DIR%\!QUEST_IP!.ini"
if not exist "!QUEST_RECORD_FILE!" call :SAVE_SAVED_WIFI_RECORD
rem Remove the old single-entry file after importing it so deleting the migrated record stays deleted.
del "%MICINJECTOR_WIFI_FILE%" >nul 2>&1
exit /b 0

:LOAD_SAVED_WIFI_LIST
if not exist "%MICINJECTOR_WIFI_DIR%" md "%MICINJECTOR_WIFI_DIR%" >nul 2>&1
call :MIGRATE_LEGACY_WIFI
set "WIFI_SAVED_COUNT=0"
rem Read newest profile files first; only one saved profile is shown for each Quest IP.
for /f "delims=" %%F in ('dir /b /a-d /o-d "%MICINJECTOR_WIFI_DIR%\*.ini" 2^>nul ^| findstr /i /r "\.ini$"') do call :ADD_SAVED_WIFI_ENTRY "%MICINJECTOR_WIFI_DIR%\%%F"
exit /b 0

:ADD_SAVED_WIFI_ENTRY
if !WIFI_SAVED_COUNT! GEQ 9 exit /b 0
set "ENTRY_IP="
set "ENTRY_PORT=5555"
set "ENTRY_MODEL=Saved Quest"
set "ENTRY_NAME="
set "ENTRY_LAST=!T_WIFI_LAST_UNKNOWN!"
for /f "usebackq tokens=1,* delims==" %%A in ("%~1") do (
    if /i "%%A"=="IP" set "ENTRY_IP=%%B"
    if /i "%%A"=="PORT" set "ENTRY_PORT=%%B"
    if /i "%%A"=="MODEL" set "ENTRY_MODEL=%%B"
    if /i "%%A"=="NAME" set "ENTRY_NAME=%%B"
    if /i "%%A"=="LAST" set "ENTRY_LAST=%%B"
)
if not defined ENTRY_IP exit /b 0
rem A Quest IP identifies the saved device. Ignore older duplicate profiles for the same IP.
for /l %%I in (1,1,!WIFI_SAVED_COUNT!) do (
    call set "EXISTING_WIFI_IP=%%SAVED_WIFI_IP[%%I]%%"
    if /i "!EXISTING_WIFI_IP!"=="!ENTRY_IP!" exit /b 0
)
set "QUEST_PORT=!ENTRY_PORT!"
call :VALIDATE_WIFI_PORT
if errorlevel 1 exit /b 0
set /a WIFI_SAVED_COUNT+=1
set "SAVED_WIFI_FILE[!WIFI_SAVED_COUNT!]=%~1"
set "SAVED_WIFI_IP[!WIFI_SAVED_COUNT!]=!ENTRY_IP!"
set "SAVED_WIFI_PORT[!WIFI_SAVED_COUNT!]=!QUEST_PORT!"
set "SAVED_WIFI_MODEL[!WIFI_SAVED_COUNT!]=!ENTRY_MODEL!"
set "SAVED_WIFI_NAME[!WIFI_SAVED_COUNT!]=!ENTRY_NAME!"
set "SAVED_WIFI_LAST[!WIFI_SAVED_COUNT!]=!ENTRY_LAST!"
exit /b 0

:DISPLAY_SAVED_WIFI
set "SAVED_DISPLAY_INDEX=%~1"
call set "SAVED_DISPLAY_IP=%%SAVED_WIFI_IP[%SAVED_DISPLAY_INDEX%]%%"
call set "SAVED_DISPLAY_PORT=%%SAVED_WIFI_PORT[%SAVED_DISPLAY_INDEX%]%%"
call set "SAVED_DISPLAY_MODEL=%%SAVED_WIFI_MODEL[%SAVED_DISPLAY_INDEX%]%%"
call set "SAVED_DISPLAY_NAME=%%SAVED_WIFI_NAME[%SAVED_DISPLAY_INDEX%]%%"
call set "SAVED_DISPLAY_LAST=%%SAVED_WIFI_LAST[%SAVED_DISPLAY_INDEX%]%%"
if defined SAVED_DISPLAY_NAME (
    echo    [!SAVED_DISPLAY_INDEX!] !SAVED_DISPLAY_MODEL! - !SAVED_DISPLAY_IP!:!SAVED_DISPLAY_PORT! - !SAVED_DISPLAY_NAME! - Last connected: !SAVED_DISPLAY_LAST!
) else (
    echo    [!SAVED_DISPLAY_INDEX!] !SAVED_DISPLAY_MODEL! - !SAVED_DISPLAY_IP!:!SAVED_DISPLAY_PORT! - Last connected: !SAVED_DISPLAY_LAST!
)
exit /b 0

:SAVE_SAVED_WIFI_RECORD
rem Keep one canonical profile per Quest IP; the TCP/IP port is editable connection data.
set "QUEST_RECORD_FILE=%MICINJECTOR_WIFI_DIR%\!QUEST_IP!.ini"
if not defined QUEST_MODEL set "QUEST_MODEL=Meta Quest"
if not defined QUEST_NICKNAME set "QUEST_NICKNAME="
if not defined QUEST_LAST_USED set "QUEST_LAST_USED=!T_WIFI_LAST_UNKNOWN!"
(
    echo IP=!QUEST_IP!
    echo PORT=!QUEST_PORT!
    echo MODEL=!QUEST_MODEL!
    echo NAME=!QUEST_NICKNAME!
    echo LAST=!QUEST_LAST_USED!
) > "!QUEST_RECORD_FILE!"
call :DELETE_DUPLICATE_SAVED_WIFI_PROFILES_FOR_IP
exit /b 0

:DELETE_DUPLICATE_SAVED_WIFI_PROFILES_FOR_IP
for %%F in ("%MICINJECTOR_WIFI_DIR%\*.ini") do if exist "%%~fF" if /i not "%%~fF"=="!QUEST_RECORD_FILE!" (
    set "PROFILE_WIFI_IP="
    for /f "usebackq tokens=1,* delims==" %%A in ("%%~fF") do if /i "%%A"=="IP" set "PROFILE_WIFI_IP=%%B"
    if /i "!PROFILE_WIFI_IP!"=="!QUEST_IP!" del "%%~fF" >nul 2>&1
)
exit /b 0

:DELETE_ALL_SAVED_WIFI_PROFILES_FOR_IP
for %%F in ("%MICINJECTOR_WIFI_DIR%\*.ini") do if exist "%%~fF" (
    set "PROFILE_WIFI_IP="
    for /f "usebackq tokens=1,* delims==" %%A in ("%%~fF") do if /i "%%A"=="IP" set "PROFILE_WIFI_IP=%%B"
    if /i "!PROFILE_WIFI_IP!"=="!QUEST_IP!" del "%%~fF" >nul 2>&1
)
exit /b 0

:VALIDATE_WIFI_NAME
if not defined QUEST_NICKNAME exit /b 0
if not "!QUEST_NICKNAME:~32,1!"=="" exit /b 1
powershell.exe -NoProfile -Command "if ($env:QUEST_NICKNAME -match '^[\p{L}\p{N}][\p{L}\p{N} _-]{0,31}$') { exit 0 } else { exit 1 }" >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:REFRESH_SAVED_QUEST_MODEL
set "DETECTED_QUEST_MODEL="
for %%P in (ro.product.model ro.product.vendor.model ro.product.system.model ro.product.odm.model ro.product.product.model) do (
    if not defined DETECTED_QUEST_MODEL (
        for /f "delims=" %%M in ('"%ADB_EXE%" -s "!WIFI_SERIAL!" shell getprop %%P 2^>nul') do (
            if /i not "%%M"=="Android Device" if /i not "%%M"=="Android" if /i not "%%M"=="unknown" if not defined DETECTED_QUEST_MODEL set "DETECTED_QUEST_MODEL=%%M"
        )
    )
)
if defined DETECTED_QUEST_MODEL (
    set "QUEST_MODEL=!DETECTED_QUEST_MODEL:_= !"
    if /i "!QUEST_MODEL!"=="Quest 3S" set "QUEST_MODEL=Meta Quest 3S"
    if /i "!QUEST_MODEL!"=="Quest 3" set "QUEST_MODEL=Meta Quest 3"
    if /i "!QUEST_MODEL!"=="Quest 2" set "QUEST_MODEL=Meta Quest 2"
    if /i "!QUEST_MODEL!"=="Quest Pro" set "QUEST_MODEL=Meta Quest Pro"
    if /i "!QUEST_MODEL!"=="Quest" set "QUEST_MODEL=Meta Quest"
)
exit /b 0

:ASK_WIFI_PORT
cls
echo.
echo  ============================================================
echo                !T_WIFI_PORT_TITLE!
echo  ============================================================
echo.
echo  !T_WIFI_PORT_INFO!
echo  !T_WIFI_PORT_RANGE!
echo.
set "QUEST_PORT=5555"
set /p "QUEST_PORT=Custom TCP/IP port (ENTER = 5555): "
if not defined QUEST_PORT set "QUEST_PORT=5555"
call :VALIDATE_WIFI_PORT
if errorlevel 1 (
    echo.
    echo  !T_WIFI_PORT_INVALID!
    pause
    goto ASK_WIFI_PORT
)
exit /b 0

:VALIDATE_WIFI_PORT
if not defined QUEST_PORT exit /b 1
if not "!QUEST_PORT:~5,1!"=="" exit /b 1
echo(!QUEST_PORT!| findstr /r /x "[1-9][0-9]*" >nul
if errorlevel 1 exit /b 1
set /a QUEST_PORT_NUMBER=QUEST_PORT
if !QUEST_PORT_NUMBER! LSS 1024 exit /b 1
if !QUEST_PORT_NUMBER! GTR 65535 exit /b 1
set "QUEST_PORT=!QUEST_PORT_NUMBER!"
exit /b 0

:CONNECT_SAVED_WIFI
if not defined QUEST_IP exit /b 1
if not defined QUEST_PORT set "QUEST_PORT=5555"
set "WIFI_SERIAL=!QUEST_IP!:!QUEST_PORT!"
echo  !T_WIFI_RECONNECTING!
"%ADB_EXE%" connect "!WIFI_SERIAL!" >nul 2>&1
set "WIFI_STATE_FILE=%TEMP%\micinjector-state-%RANDOM%.txt"
"%ADB_EXE%" -s "!WIFI_SERIAL!" get-state > "!WIFI_STATE_FILE!" 2>nul
set "WIFI_STATE="
if exist "!WIFI_STATE_FILE!" set /p "WIFI_STATE="<"!WIFI_STATE_FILE!"
del "!WIFI_STATE_FILE!" >nul 2>&1
if /i "!WIFI_STATE!"=="device" (
    call :REFRESH_SAVED_QUEST_MODEL
    exit /b 0
)
exit /b 1

:SELECT_DEVICE
cls
echo.
echo  ============================================================
if /i "%DEVICE_MODE%"=="USB" (
    echo                   !T_SELECT_USB!
) else (
    echo                  !T_SELECT_WIFI!
)
echo  ============================================================
echo.
echo  !T_SEARCHING!
echo.

:REFRESH_DEVICE_LIST
set "DEVICE_COUNT=0"
for /f "skip=1 tokens=1,2,*" %%A in ('"%ADB_EXE%" devices -l') do (
    if not "%%A"=="" (
        set "DEVICE_SERIAL=%%A"
        set "DEVICE_STATE=%%B"
        set "INCLUDE_DEVICE=0"
        set "DEVICE_IS_WIFI=0"
        echo(%%A| findstr ":" >nul
        if not errorlevel 1 set "DEVICE_IS_WIFI=1"
        if /i "!DEVICE_MODE!"=="USB" (
            if "!DEVICE_IS_WIFI!"=="0" set "INCLUDE_DEVICE=1"
        ) else (
            if "!DEVICE_IS_WIFI!"=="1" set "INCLUDE_DEVICE=1"
        )
        if /i "!DEVICE_STATE!"=="device" if "!INCLUDE_DEVICE!"=="1" call :ADD_DEVICE "%%A" "%%B" "%%C"
        if /i "!DEVICE_STATE!"=="unauthorized" if "!INCLUDE_DEVICE!"=="1" call :ADD_DEVICE "%%A" "%%B" "%%C"
        if /i "!DEVICE_STATE!"=="offline" if "!INCLUDE_DEVICE!"=="1" call :ADD_DEVICE "%%A" "%%B" "%%C"
    )
)

if "!DEVICE_COUNT!"=="0" (
    echo  !T_NO_DEVICES!
    echo.
    call :SHOW_DEVICE_HELP
    echo.
    choice /c RX /n /m "  !T_REFRESH!   !T_CANCEL!: "
    if errorlevel 2 exit /b 1
    echo.
    "%ADB_EXE%" start-server
    timeout /t 2 /nobreak >nul
    cls
    echo.
    echo  ============================================================
    if /i "%DEVICE_MODE%"=="USB" (
        echo                   !T_SELECT_USB!
    ) else (
        echo                  !T_SELECT_WIFI!
    )
    echo  ============================================================
    echo.
    echo  !T_REFRESHING!
    echo.
    goto REFRESH_DEVICE_LIST
)

echo.
echo  !T_DEVICE_HEADER!
echo.
for /l %%I in (1,1,!DEVICE_COUNT!) do call :DISPLAY_DEVICE "%%I"
echo.
call :SHOW_DEVICE_HELP
echo.
choice /c 123456789RX /n /m "  !T_DEVICE_PROMPT!   !T_REFRESH!   !T_CANCEL!: "
set "DEVICE_PICK=%errorlevel%"
if "%DEVICE_PICK%"=="10" (
    echo.
    "%ADB_EXE%" start-server
    timeout /t 2 /nobreak >nul
    cls
    echo.
    echo  ============================================================
    if /i "%DEVICE_MODE%"=="USB" (
        echo                   !T_SELECT_USB!
    ) else (
        echo                  !T_SELECT_WIFI!
    )
    echo  ============================================================
    echo.
    echo  !T_REFRESHING!
    echo.
    goto REFRESH_DEVICE_LIST
)
if "%DEVICE_PICK%"=="11" exit /b 1
if %DEVICE_PICK% GTR !DEVICE_COUNT! (
    echo.
    echo  !T_DEVICE_INVALID!
    pause
    goto SELECT_DEVICE
)

call set "ADB_DEVICE_SERIAL=%%DEVICE[!DEVICE_PICK!]%%"
call set "DEVICE_LABEL=%%DEVICE_NAME[!DEVICE_PICK!]%%"
call set "DEVICE_MODEL=%%DEVICE_MODEL[!DEVICE_PICK!]%%"
call set "SELECTED_DEVICE_STATE=%%DEVICE_STATE[!DEVICE_PICK!]%%"

if /i "!SELECTED_DEVICE_STATE!"=="unauthorized" (
    echo.
    echo  !T_UNAUTHORIZED_TITLE!
    echo  !T_UNAUTHORIZED_LINE1!
    echo  !T_UNAUTHORIZED_LINE2!
    echo.
    pause
    goto SELECT_DEVICE
)
if /i "!SELECTED_DEVICE_STATE!"=="offline" (
    echo.
    echo  !T_OFFLINE_TITLE!
    echo  !T_OFFLINE_LINE!
    echo.
    pause
    goto SELECT_DEVICE
)

if not defined ADB_DEVICE_SERIAL (
    echo.
    echo  !T_DEVICE_READ_FAILED!
    pause
    goto SELECT_DEVICE
)

echo.
echo  !T_SELECTED! !DEVICE_LABEL!
set "DEVICE_CHECK_TEXT=!DEVICE_MODEL!"
if not defined DEVICE_CHECK_TEXT set "DEVICE_CHECK_TEXT=!DEVICE_LABEL!"
echo(!DEVICE_CHECK_TEXT!| findstr /i "Quest Oculus" >nul
if errorlevel 1 (
    echo.
    echo  !T_MODEL_WARNING!
    choice /c 12 /n /m "  !T_CONTINUE! "
    if errorlevel 2 goto SELECT_DEVICE
)
exit /b 0

:ADD_DEVICE
if !DEVICE_COUNT! GEQ 9 exit /b 0
set /a DEVICE_COUNT+=1
set "DEVICE[!DEVICE_COUNT!]=%~1"
set "DEVICE_STATE[!DEVICE_COUNT!]=%~2"

set "DEVICE_ADB_MODEL="
if not "%~3"=="" (
    for %%T in (%~3) do (
        for /f "tokens=1,* delims=:" %%K in ("%%T") do (
            if /i "%%K"=="model" set "DEVICE_ADB_MODEL=%%L"
        )
    )
)

set "DEVICE_MODEL="
if /i "%~2"=="device" (
    for %%P in (ro.product.model ro.product.vendor.model ro.product.system.model ro.product.odm.model ro.product.product.model ro.product.marketname) do (
        if not defined DEVICE_MODEL (
            for /f "delims=" %%M in ('"%ADB_EXE%" -s "%~1" shell getprop %%P 2^>nul') do (
                if /i not "%%M"=="Android Device" if /i not "%%M"=="Android" if /i not "%%M"=="unknown" if not defined DEVICE_MODEL set "DEVICE_MODEL=%%M"
            )
        )
    )
)

if /i "!DEVICE_MODEL!"=="Android Device" set "DEVICE_MODEL="
if /i "!DEVICE_MODEL!"=="Android" set "DEVICE_MODEL="
if /i "!DEVICE_MODEL!"=="unknown" set "DEVICE_MODEL="
if not defined DEVICE_MODEL set "DEVICE_MODEL=!DEVICE_ADB_MODEL!"
if /i "!DEVICE_MODEL!"=="Android_Device" set "DEVICE_MODEL="
if /i "!DEVICE_MODEL!"=="Android" set "DEVICE_MODEL="

set "DEVICE_NAME=!DEVICE_MODEL:_= !"
if not defined DEVICE_NAME (
    set "DEVICE_MANUFACTURER="
    for %%P in (ro.product.manufacturer ro.product.brand) do (
        if not defined DEVICE_MANUFACTURER (
            for /f "delims=" %%M in ('"%ADB_EXE%" -s "%~1" shell getprop %%P 2^>nul') do if not defined DEVICE_MANUFACTURER set "DEVICE_MANUFACTURER=%%M"
        )
    )
    echo(!DEVICE_MANUFACTURER!| findstr /i "Meta Oculus" >nul
    if not errorlevel 1 set "DEVICE_NAME=Meta Quest headset"
)
if not defined DEVICE_NAME set "DEVICE_NAME=Connected device - model unavailable"

if /i "%~2"=="unauthorized" (
    set "DEVICE_NAME=Unapproved device - allow USB debugging"
    set "DEVICE_MODEL="
)
if /i "%~2"=="offline" (
    set "DEVICE_NAME=Offline device - reconnect or refresh"
    set "DEVICE_MODEL="
)

if /i "!DEVICE_NAME!"=="Quest 3S" set "DEVICE_NAME=Meta Quest 3S"
if /i "!DEVICE_NAME!"=="Quest 3" set "DEVICE_NAME=Meta Quest 3"
if /i "!DEVICE_NAME!"=="Quest 2" set "DEVICE_NAME=Meta Quest 2"
if /i "!DEVICE_NAME!"=="Quest Pro" set "DEVICE_NAME=Meta Quest Pro"
if /i "!DEVICE_NAME!"=="Quest" set "DEVICE_NAME=Meta Quest"

set "DEVICE_NAME[!DEVICE_COUNT!]=!DEVICE_NAME!"
set "DEVICE_MODEL[!DEVICE_COUNT!]=!DEVICE_MODEL!"

exit /b 0

:DISPLAY_DEVICE
set "DISPLAY_INDEX=%~1"
call set "DISPLAY_NAME=%%DEVICE_NAME[%DISPLAY_INDEX%]%%"
call set "DISPLAY_SERIAL=%%DEVICE[%DISPLAY_INDEX%]%%"
call set "DISPLAY_STATE=%%DEVICE_STATE[%DISPLAY_INDEX%]%%"
set "DISPLAY_DUPLICATE=0"
for /l %%J in (1,1,!DEVICE_COUNT!) do (
    if not "%%J"=="!DISPLAY_INDEX!" if /i "!DEVICE_NAME[%%J]!"=="!DISPLAY_NAME!" set "DISPLAY_DUPLICATE=1"
)
if /i "!DEVICE_MODE!"=="WIFI" (
    rem The ADB serial ends with :5555 for every classic TCP/IP device,
    rem so show the IP:port, not the last four serial characters.
    echo    [!DISPLAY_INDEX!] !DISPLAY_NAME! - !DISPLAY_SERIAL!
) else if "!DISPLAY_DUPLICATE!"=="1" (
    set "DISPLAY_SUFFIX=!DISPLAY_SERIAL:~-4!"
    echo    [!DISPLAY_INDEX!] !DISPLAY_NAME! - USB ID ending !DISPLAY_SUFFIX!
) else (
    echo    [!DISPLAY_INDEX!] !DISPLAY_NAME!
)
if /i "!DISPLAY_STATE!"=="unauthorized" echo         !T_DEVICE_STATUS_AUTH!
if /i "!DISPLAY_STATE!"=="offline" echo         !T_DEVICE_STATUS_OFFLINE!
exit /b 0

:SHOW_DEVICE_HELP
echo  !T_HELP_TITLE!
if /i "%DEVICE_MODE%"=="USB" (
    echo  !T_USB_GUIDE!
) else (
    echo  !T_WIFI_GUIDE!
)
echo  !T_REFRESH!
echo  https://developers.meta.com/vr/downloads/package/oculus-adb-drivers/
exit /b 0

:START_CLIENT
cls
echo.
echo  ============================================================
echo                   !T_START_TITLE!
echo  ============================================================
echo.
echo  !T_SELECTED_LABEL! %DEVICE_LABEL%
echo  !T_PRESET_LABEL! %MIC_INJECTOR_PRESET%
echo.

if not defined MIC_INJECTOR_APK_PATH (
    set "MIC_INJECTOR_APK_PATH=%ROOT%app\build\outputs\apk\debug\app-debug.apk"
)

if not exist "%MIC_INJECTOR_APK_PATH%" (
    echo  !T_APK_MISSING!
    echo  %MIC_INJECTOR_APK_PATH%
    echo.
    echo  !T_APK_DOWNLOAD1!
    echo  !T_APK_DOWNLOAD2!
    echo  !T_APK_PATH_EXTRA!
    echo.
    set "CUSTOM_APK_PATH="
    set /p "CUSTOM_APK_PATH=  !T_APK_PATH! "
    if defined CUSTOM_APK_PATH set "MIC_INJECTOR_APK_PATH=!CUSTOM_APK_PATH!"
)
if not exist "%MIC_INJECTOR_APK_PATH%" (
    echo.
    echo  !T_APK_NOT_FOUND!
    pause
    goto MENU
)

set "APK_SIZE="
for %%F in ("%MIC_INJECTOR_APK_PATH%") do set "APK_SIZE=%%~zF"
if "!APK_SIZE!"=="0" (
    echo.
    echo  !T_APK_EMPTY!
    pause
    goto MENU
)

echo  !T_DEPS_CHECK!
echo  !T_DEPS_INFO!
echo.
pushd "%ROOT%client"
call npm exec --yes --package=pnpm@10.6.5 -- pnpm install --no-frozen-lockfile
set "INSTALL_RESULT=!errorlevel!"
popd
if not "!INSTALL_RESULT!"=="0" (
    echo.
    echo  !T_DEPS_FAIL!
    pause
    goto MENU
)

echo  !T_PACKAGE_CHECK!
set "INSTALLED_PACKAGE=0"

rem First check the installed APK path. This should return a package: line.
"%ADB_EXE%" -s "%ADB_DEVICE_SERIAL%" shell pm path moe.chensi.micinjector 2>nul | findstr /i /b /c:"package:" >nul
if not errorlevel 1 set "INSTALLED_PACKAGE=1"

rem Fallback: require an exact package-name match in Android's package list.
if "!INSTALLED_PACKAGE!"=="0" (
    "%ADB_EXE%" -s "%ADB_DEVICE_SERIAL%" shell pm list packages moe.chensi.micinjector 2>nul | findstr /i /l /x /c:"package:moe.chensi.micinjector" >nul
    if not errorlevel 1 set "INSTALLED_PACKAGE=1"
)

if "!INSTALLED_PACKAGE!"=="0" (
    cls
    color 0E
    echo.
    echo  ============================================================
    echo                  !T_APK_WARN_TITLE!
    echo  ============================================================
    echo.
    echo  !T_APK_WARN1!
    echo.
    echo  !T_APK_WARN2!
    echo.
    echo  !T_APK_WARN3!
    echo.
    echo  !T_APK_WARN4!
    echo.
    echo  !T_APK_WARN5!
    echo.
    choice /c 12 /n /m "  !T_APK_CONFIRM! "
    color 0B
    if errorlevel 2 (
        echo.
        echo  !T_APK_DECLINED!
        pause
        goto MENU
    )
    echo.
    echo  !T_APK_INSTALLING!
    echo.
    "%ADB_EXE%" -s "%ADB_DEVICE_SERIAL%" install "%MIC_INJECTOR_APK_PATH%"
    if errorlevel 1 (
        echo.
        echo  !T_APK_FAILED!
        pause
        goto MENU
    )
) else (
    echo  !T_APK_ALREADY!
)

cls
echo.
echo  ============================================================
echo                    MIC TRANSLATION NOTICE
echo  ============================================================
echo.
echo  Before starting audio, open the Quest menu that shows your apps.
echo  Then close the Quest menu again.
echo.
echo  This can make Mic Translation start working.
echo.
echo  IF THERE IS STILL NO AUDIO, CHECK VRCHAT:
echo    - Make sure your microphone is not muted.
echo    - Noise Suppression: Off.
echo    - Mic Activation Threshold: 0.
echo    - Mic Output Volume: Set it to an audible level.
echo    - Make sure VRChat has microphone permission in Quest settings.
echo.
set "MIC_TRANSLATION_NOTICE_ACK="
set /p "MIC_TRANSLATION_NOTICE_ACK=Press ENTER when done to continue: "

echo.
echo  !T_AUDIO_HELP!
echo  !T_AUDIO_HELP2!
echo.
echo  !T_INJECT_START!
echo  !T_KEEP_OPEN!
echo.
pushd "%ROOT%client"
node src/index.js
set "CLIENT_RESULT=!errorlevel!"
popd

echo.
if not "!CLIENT_RESULT!"=="0" (
    echo  !T_CLIENT_ERROR!
) else (
    echo  !T_CLIENT_STOP!
)
echo.
pause
set "ADB_DEVICE_SERIAL="
goto MENU

:END
echo.
echo  !T_EXIT_MSG!
endlocal
exit /b 0
