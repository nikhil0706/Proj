#!/bin/bash
select alphanum in a b c d 1 2 3 4 none
do
case $alphanum in 
    a|b|c|d)
echo "this is a alphabet"
    ;;
    1|2|3|4)
echo "these are numbers"
    ;;
    none)
    break
    ;;
    *)
echo "enter valid input"
    ;;
esac
done
