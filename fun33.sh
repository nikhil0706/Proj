#1/bin/bash
func1 () {
var1=$1
while [ $var1 -gt 10 ]
do
#var1+=1
var1=`expr $var1 - 1`
echo $var1
done
}
func1 100
