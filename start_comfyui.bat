
setlocal enabledelayedexpansion
@echo off && chcp 65001 && cd /d !mygithub! && echo !cd! || pause && exit
set userdir & set uvtools & set cachedir & where python & where uv

call :git_clone "https://github.com/comfyanonymous/ComfyUI" "ComfyUI"
echo.& cd /d ComfyUI && echo !cd! || pause && exit
call :mk_link "models" "!cachedir!\\model_sd" || pause && exit
call :mk_link "models\\loras" "models\\lora" || pause && exit
call :mk_link "models\\checkpoints" "models\\Stable-diffusion" || pause && exit
call :mk_link "user" "!userdir!\\comfyui_user" || pause && exit
call :mk_link "custom_nodes" "!userdir!\\comfyui_ext" || pause && exit
call :uv_venv "-p 3.10" "torch==2.9.1 torchaudio==2.9.1" "cu130" "-r requirements.txt"
for /d %%d in ("custom_nodes\\*") do (
    if exist "%%d\\requirements.txt" ( call :uv_pip_install "-r %%d\\requirements.txt"
    ) else if exist "%%d\\pyproject.toml" ( call :uv_pip_install "-r %%d\\pyproject.toml" ) )
call :uv_pip_install "triton-windows"
call :uv_pip_install "llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu130"
echo.& pause && uv run main.py --windows-standalone-build --fast fp16_accumulation --dont-print-server --verbose WARNING

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