#!/bin/bash
var1=100
while [ $var1 -gt 10 ]
do
#var1+1
var1=`expr $var1 - 1`
echo $var1
done
