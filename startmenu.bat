
setlocal enabledelayedexpansion
@echo off && chcp 65001 && cd /d %~dp0 && echo !cd! || pause && exit
%1 goto admin
set "userdir=D:\.userdir"
set "mygithub=E:\mygithub"
set "uvtools=!mygithub!\.uvtools"
set "cachedir=!mygithub!\.cachedir"
set "pydir=!mygithub!\.venv\Scripts"
set "uvdir=!uvtools!\uvwin"
set userdir && set mygithub && set uvtools && set cachedir && set pydir && set uvdir

echo.& echo --添加环境变量 任意键继续ESC跳过
call:chkesc && call:setxvar

echo.& echo --安装stream 任意键继续ESC跳过
call:chkesc && call:ins_stearm

echo.& echo --初始化uv环境 任意键继续ESC跳过
call:chkesc && call:ins_uvtools

echo.& echo --运行脚本程序 任意键继续ESC跳过
call:chkesc && (python mygit_manager.py)

echo.& echo --nuitka打包单文件 任意键继续ESC跳过
call:chkesc && ( python -m nuitka --onefile --include-windows-runtime-dlls=no ^
    --include-qt-plugins=platforms,imageformats ^
    --windows-console-mode=disable --enable-plugin=pyside6 --remove-output mygit_manager.py )

:admin
mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd","/c %~fs0 ::","","runas",1)(window.close)&&exit

:setxvar
setx userdir "!userdir!"
setx mygithub "!mygithub!"
setx uvtools "!uvtools!"
setx cachedir "!cachedir!"
setx MODELSCOPE_CACHE "!cachedir!\cache_ms"
setx HF_HOME "!cachedir!\cache_hf"
setx UV_CACHE_DIR "!cachedir!\cache_uv"
setx UV_PYTHON_INSTALL_DIR "!cachedir!\cache_py"
setx UV_INSTALL_DIR "!uvdir!"
setx UV_SYSTEM_CERTS ""
setx UV_DEFAULT_INDEX "https://mirrors.aliyun.com/pypi/simple/"
setx UV_PYTHON_INSTALL_MIRROR "https://registry.npmmirror.com/-/binary/python-build-standalone"
setx PIP_INDEX_URL "https://mirrors.aliyun.com/pypi/simple/"
setx HF_ENDPOINT "https://hf-mirror.com"
setx PYTHONIOENCODING "utf-8"
setx PYTHONWARNINGS "ignore"
for /f "skip=2 tokens=1,2,*" %%a in ('reg query "HKCU\Environment" /v Path') do set "userpath=%%c"
if not defined userpath pause && exit
for %%d in (!pydir!, !uvdir!, !uvtools!\7-zip, !uvtools!\ffmpeg\bin, !uvtools!\PortableGit\cmd
) do ( if "!userpath:%%d=!"=="!userpath!" set "userpath=!userpath!;%%d" )
echo.& for %%a in ("%userpath:;=" "%") do (if not "%%~a"=="" echo %%~a)
setx PATH "!userpath!" && echo.& pause && exit

:ins_stearm
call:downpack "BeyondDimension/SteamTools" "win_x64\.exe$" "!uvtools!\steam.exe"
!uvtools!\steam.exe && call:mk_link "!LOCALAPPDATA!\Steam++" "!userdir!\Steam_ini"
exit /b

:ins_uvtools
echo.& cd /d !uvtools! && echo !cd! || pause && exit

echo.& call:downpack "ip7z/7zip" "x64\.exe$" "7-zip.exe"
7-zip.exe /S /D=!uvtools!\7-zip && 7z -h >nul && where 7z

set "vc_url=https://aka.ms/vc14/vc_redist.x64.exe" 
echo.& call:downpack "!vc_url!" "vc.exe" "vc.exe"
vc.exe /passive /norestart

echo.& call:downpack "GyanD/codexffmpeg" "full_build\.7z$" "ffmpeg.7z"
if not exist ffmpeg (7z x ffmpeg.7z -aos -bso0 -bsp1 -o!uvtools! )
for /d %%d in ("ffmpeg-*-full_build") do ( ren "%%d" "ffmpeg" )
ffmpeg -version >nul && where ffmpeg

echo.& call:downpack "astral-sh/uv" "uv-x86_64-pc-windows-msvc\.zip$" "uv.zip"
if not exist !uvdir! ( 7z x uv.zip -aos -bso0 -bsp1 -o!uvdir! )
uv venv !mygithub!\.venv --allow-existing --seed -p 3.10
uv pip install -p !mygithub!\.venv Nuitka pyside6 zstandard pyyaml hf modelscope tomli
uv cache prune

echo.& call:downpack "git-for-windows/git" "-64-bit.7z\.exe$" "PortableGit.7z"
if not exist PortableGit (7z x PortableGit.7z -aos -bso0 -bsp1 -oPortableGit)
set /p gitname=请输入github用户名: 
set gitname && (git config --global user.name "!gitname!")
set /p gitemail=请输入github邮箱: 
set gitemail && (git config --global user.email "!gitemail!")
git config --global http.sslVerify false
git config --global core.autocrlf true
echo.& git config --global --get-regexp "user\."

set "vscode_u=https://update.code.visualstudio.com/latest/win32-x64/stable"
echo.& call:downpack "!vscode_u!" "vscode.exe" "vscode.exe" && vscode.exe
call:mk_link "%USERPROFILE%\.vscode" "!userdir!\vscode_ext"
call:mk_link "%APPDATA%\Code" "!userdir!\vscode_ini"

echo.& pause && goto admin

:mk_link
set "link_name=%~1" & set "link_path=%~2"
attrib -R -S "!link_name!" & mkdir "!link_path!"
for %%F in ("!link_name!") do set "filename=%%~nxF"
if exist "!link_name!" (ren "!link_name!" "!filename!.bak")
if exist "!link_name!.bak" (rmdir /s /q "!link_name!.bak")
mklink /j "!link_name!" "!link_path!"
exit /b

:downpack
set "packurl=%~1" && set "packname=%~2" && set "packfile=%~3"
echo !packurl! | findstr /i "^http" >nul && ( set packurl && if exist !packfile! exit /b ) || (
    set "gitapi=https://api.github.com/repos/!packurl!/releases/latest"
    set gitapi && if exist !packfile! exit /b
    set "ps_cmd=$r=irm !gitapi!;$t=$r.assets|?{$_.name -match '!packname!'};$t.browser_download_url"
    for /f "delims=" %%i in ('powershell -c "!ps_cmd!"') do (set "packurl=%%i")
    set packurl )
curl -#fkL !packurl! -o !packfile!
exit /b

:chkesc
powershell -c "exit([int]([Console]::ReadKey($true).Key -eq 'Escape'))"