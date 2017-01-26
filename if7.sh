#!/bin/bash
if [ -d abc ]

then 
 #  touch abc/file{2..100}
if [ -f abc/file1 ]
then
echo "file1 is a file"
else
echo " file1 is not a file"
fi 
echo "abc folder is available"
#ls -lrt abc
else 
echo "abc is not availabel"
fi

