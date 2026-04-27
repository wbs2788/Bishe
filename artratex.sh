#!/bin/bash
set -e

#---------------------------------------------------------------------------#
#-                       LaTeX Automated Compiler                          -#
#-                          <By Huangrui Mo>                               -#
#- Copyright (C) Huangrui Mo <huangrui.mo@gmail.com>                       -#
#- This is free software: you can redistribute it and/or modify it         -#
#- under the terms of 、、、、he GNU General Public License as published by       -#
#- the Free Software Foundation, either version 3 of the License, or       -#
#- (at your option) any later version.                                     -#
#---------------------------------------------------------------------------#

#---------------------------------------------------------------------------#
#->> Preprocessing·
#---------------------------------------------------------------------------#
#-
#-> Get source filename
#-
if [[ "$#" == "1" ]]; then
    FileName=`echo *.tex`
elif [[ "$#" == "2" ]]; then
    FileName="$2"
else
    echo "---------------------------------------------------------------------------"
    echo "Usage: "$0"  <l|p|x>< |a|b>  <filename>"
    echo "TeX engine parameters: <l:lualatex>, <p:pdflatex>, <x:xelatex>"
    echo "Bib engine parameters: < :none>, <a:bibtex>, <b:biber>"
    echo "---------------------------------------------------------------------------"
    exit
fi
FileName=${FileName/.tex}
#-
#-> Get tex compiler
#-
if [[ $1 == *'l'* ]]; then
    TexCompiler="lualatex"
else
    if [[ $1 == *'p'* ]]; then
        TexCompiler="pdflatex"
    else
        TexCompiler="xelatex"
    fi
fi
#-
#-> Get bib compiler
#-
if [[ $1 == *'a'* ]]; then
    BibCompiler="bibtex"
elif [[ $1 == *'b'* ]]; then
    BibCompiler="biber"
else
    BibCompiler=""
fi
#-
#-> Set compilation out directory resembling the inclusion hierarchy
#-
Tmp="Tmp"
Tex="Tex"
if [[ ! -d $Tmp/$Tex ]]; then
    mkdir -p $Tmp/$Tex
fi
#-
#-> Set LaTeX environmental variables to add subdirs into search path
#-
export TEXINPUTS=".//:$TEXINPUTS" # paths to locate .tex 
export BIBINPUTS=".//:$BIBINPUTS" # paths to locate .bib
export BSTINPUTS=".//:$BSTINPUTS" # paths to locate .bst
#---------------------------------------------------------------------------#
#->> Compiling
#---------------------------------------------------------------------------#
#-
#-> Build textual content and auxiliary files
#-
$TexCompiler -output-directory=$Tmp $FileName || exit
#-
#-> Build references and links
#-
if [[ -n $BibCompiler ]]; then
    #- fix the inclusion path for hierarchical auxiliary files
    sed -i -e "s|\@input{|\@input{$Tmp/|g" $Tmp/"$FileName".aux
    #- extract and format bibliography database via auxiliary files
    $BibCompiler $Tmp/$FileName
    #- insert reference indicators into textual content
    $TexCompiler -output-directory=$Tmp $FileName || exit
    #- refine citation references and links
    $TexCompiler -output-directory=$Tmp $FileName || exit
fi
#---------------------------------------------------------------------------#
#->> Postprocessing
#---------------------------------------------------------------------------#
#-
#-> Set PDF viewer
#-
System_Name=`uname`
if [[ $System_Name == "Linux" ]]; then
    PDFviewer="xdg-open"
elif [[ $System_Name == "Darwin" ]]; then
    PDFviewer="open"
else
    PDFviewer="open"
fi
#-
#-> Open the compiled file
#-
$PDFviewer ./$Tmp/"$FileName".pdf || exit
echo "---------------------------------------------------------------------------"
echo "$TexCompiler $BibCompiler "$FileName".tex finished..."
echo "---------------------------------------------------------------------------"

#---------------------------------------------------------------------------#
#->> Word Count (Added)
#---------------------------------------------------------------------------#
if command -v texcount >/dev/null 2>&1; then
    echo "正在进行全文字数统计 (Character Count)..."
    # -chinese: 统计中文字符
    # -inc: 递归统计所有 \include 和 \input 的子文件
    # -total: 汇总结果
    # -utf8: 强制编码
    # -brief: 简明输出
    
    texcount -chinese -inc -total -utf8 -brief "$FileName".tex
else
    echo "提示: 系统未找到 texcount，请确保已安装 TeX Live 或 MiKTeX 全量版。"
fi