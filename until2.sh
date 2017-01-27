#!/bin/bash
var1=100
until [ $var1 -gt 120 ]
do
#var1+1
var1=`expr $var1 - 1`
echo $var1
done
