#!/bin/bash
echo "enter var1:"
read var1
echo "enter var2:"
read var2
var3=`expr $var1 - $var2`
echo "Subt of two numbers:$var3" 
