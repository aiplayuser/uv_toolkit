
setlocal enabledelayedexpansion
@echo off && chcp 65001 && cd /d !mygithub! && echo !cd! || pause && exit
set userdir & set uvtools & set cachedir & where python & where uv

call :git_clone "https://github.com/aiplayuser/index-tts" "indextts"
echo.& cd /d indextts && echo !cd! || pause && exit
call :mk_link "checkpoints" "!cachedir!\\model_tts" || pause && exit
echo.& uv venv --allow-existing -p 3.10 
echo.& uv sync --extra webui
call :down_ms "--model IndexTeam/IndexTTS-2 --local_dir checkpoints"
echo.& git lfs install & git lfs pull
echo.& pause &&  uv run webui.py

set target=http://127.0.0.1:7860
start /B %pwsl% ^
"$starttime = Get-Date; Write-Host "启动大概需要一分钟`n`n"; ^
while ($true) { $e = [int]((Get-Date) - $starttime).TotalSeconds; ^
    Write-Host "`r用时 $e 秒>>" -NoNew; sleep 3; ^
    try { $null = iwr %target%; start %target%; break } catch {} } "
echo.& pause && uv run webui.py

:mk_link
echo.& set "link_name=%~1" & set "link_path=%~2"
attrib -R -S "!link_name!" & mkdir "!link_path!"
for %%F in ("!link_name!") do set "filename=%%~nxF"
if exist "!link_name!" (ren "!link_name!" "!filename!.bak")
if exist "!link_name!.bak" (rmdir /s /q "!link_name!.bak")
mklink /j "!link_name!" "!link_path!"
exit /b

:uv_venv
set "torchurl=torchvision xformers --extra-index-url https://download.pytorch.org/whl/"
set "py_v=%~1" & set "torch_v=%~2" & set "cu_v=%~3" & set "reqfile=%~4"
echo.& echo --uv venv .venv --allow-existing --seed -q !py_v!
uv venv .venv --allow-existing --seed -q !py_v!
call :uv_pip_install "!torch_v! !torchurl!!cu_v!"
call :uv_pip_install "!reqfile!"
exit /b

:uv_pip_install
set "reqs_lib=%~1" & echo.& echo --uv pip install -p .venv --no-build-isolation -qq !reqs_lib!
uv pip install -p .venv --no-build-isolation -qq !reqs_lib!
exit /b

:git_clone
set "clone_u=%~1" && set "clone_d=%~2"
echo.& echo git clone --progress %clone_u% %clone_d%
if not exist %clone_d% (start /wait cmd /c "git clone -v --progress %clone_u% %clone_d% & pause")
exit /b

:down_ms
set "model_name=%~1" & echo.& echo --ms download !model_name!
start /wait cmd /c "ms download !model_name! & pause"
exit /b