# uv_toolkit
custom install uv, steam++, 7-zip, vc_redist, ffmpeg, vscode, PortableGit...

## uv简介
`https://github.com/astral-sh/uv.git`, 是由 Astral 团队使用 Rust 语言编写的下一代 Python 包与环境管理工具，旨在替代传统的 pip和python管理方法，高效管理虚拟环境, 目前已经成为很多 Python 项目的首选。

## uv亮点
消除了 Python 解释器的启动开销。多线程并行处理比传统 pip 快几十倍。全局缓存与硬链接技术，跨项目依赖去重，节省磁盘空间。基于 PubGrub 先进解析器，高效处理复杂依赖冲突。兼容 requirements.txt 和 pyproject.toml 规范，平滑过渡。  

## 硬链接和缓存机制
uv包管理器通过硬链接和缓存机制避免重复安装依赖，所有依赖都在缓存内，只有一份拷贝，无论创建多少个虚拟环境，仅仅是对缓存文件创建了一个硬链接，几乎不会占用额外的空间。

进入任意一个环境的任意一个依赖库，打开cmd窗口，输入`fsutil hardlink list __init__.py`，会看到该文件的所有硬链接，实际文件则只有一份。

`E:\mygithub\ComfyUI\.venv\Lib\site-packages\torch>fsutil hardlink list __init__.py`  
`\mygithub\.cachedir\cache_uv\archive-v0\Mfwg3R_1P0EficBh\torch\__init__.py`  
`\mygithub\ComfyUI\.venv\Lib\site-packages\torch\__init__.py`  

## 脚本简介
uv默认安装在系统盘，并且缓存和python环境必须在同一个盘内才能使用，这就不太方便，此脚本自定义uv到非系统盘，系统重装只需添加环境变量即可，绿色免安装。

## 安装方法
打包下载该仓库解压到任意位置，双击startmenu.bat即可自动安装uv和常用工具，推荐D盘使用双硬盘的镜像卷，只保存个人数据和一些小文件，硬盘损坏可方便恢复，不丢失重要数据，在其他盘简单卷创建mygithub文件夹，用来保存常用工具缓存文件和git项目，这些可以从网络下载恢复的文件，虽然有时候下载困难，但能减少数据备份，节省硬盘数量。

## 目录结构
`set "userdir=D:\.userdir"`  
`set "mygithub=E:\mygithub"`  
`set "uvtools=!mygithub!\.uvtools"`  
`set "cachedir=!mygithub!\.cachedir"`  
`set "pydir=!mygithub!\.venv\Scripts"`  
`set "uvdir=!uvtools!\uvwin"`  
`setx MODELSCOPE_CACHE "!cachedir!\cache_ms"`  
`setx HF_HOME "!cachedir!\cache_hf"`  
`setx UV_CACHE_DIR "!cachedir!\cache_uv"`  
`setx UV_PYTHON_INSTALL_DIR "!cachedir!\cache_py"`  

## 自定义项目
start_comfyui.bat和start_indextts.bat是两个自定义项目的模板，你可以根据模板构建自己的任意项目。