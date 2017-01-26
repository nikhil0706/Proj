#!/bin/bash
var1=$1
echo $var1
var2=$2
echo $var2
var3=`expr $var1 - $var2`
echo "Subt of two numbers:$var3" 
var4=$0
echo $var4
var5=$#
echo $var5
var6=$*
echo $var6
