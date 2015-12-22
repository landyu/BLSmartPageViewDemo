#!/bin/bash
############## hell #############
if [ "$1" = "-convert" ];then
    for i in ./*; do
    case "$i" in
        *.xib)
        ibtool $i --compile $i.bin
        echo " $i convert to $i.bin"
        ;;
    esac
    done
elif [ "$1" = "-cleanbin" ];then
    for i in ./*; do
    case "$i" in
        *.xib.bin)
        rm $i
        echo " remove $i"
        ;;
    esac
    done
elif [ "$1" = "-cleanxib" ];then
    for i in ./*; do
    case "$i" in
        *.xib)
        rm $i
        echo " remove $i"
        ;;
    esac
    done
else
    echo "What?  $1"
fi

