#!/bin/bash
echo "enter date"
read var1 
if [[ ($var1 == "sunday") || ($var1=="SUNDAY") ]]
then 
echo "sunday is a holiday"
elif [ $var1 == "monday" ]
then
echo "monday is a working day"
elif [ $var1 == "tuesday"  ]
then
echo "tuesday is a working day"
elif [ $var1 == "wednesday" ]
then
echo "wednesday is a working day"

elif [ $var1 == "thursday" ]
then
echo "thursday is a working day"
elif [ $var1 == "friday" ]
then
echo "friday is a working day"
elif [ $var1 == "saturday" ]
then
echo "saturday is a holiday"
else
echo "enter valid day"
fi
