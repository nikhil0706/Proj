#!/bin/bash
if [ -d abc ]
then 
   touch abc/file1
echo "abc folder is available"
ls -lrt abc
else 
echo "abc is not availabel"
fi

