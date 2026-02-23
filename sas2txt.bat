md sas
FOR /F %%B IN ('dir /b *.sas')  DO xcopy %%B "sas" /f/y
FOR /F %%B IN ('dir /b *.sas')  DO rename %%B *.txt 