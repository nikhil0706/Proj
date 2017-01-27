#1/bin/bash
func1 () {
var1=$1
var2=$2
while [ $var1 -gt $var2 ]
do
#var1+=1
var1=`expr $var1 - 1`
echo $var1
done
}
func2 () {
var1=$1
until [ $var1 -gt 10 ]
do
#var1+=1
var1=`expr $var1 - 1`
echo $var1
done
}
func3 () {
func1 100 10
func2 50
}
func3


