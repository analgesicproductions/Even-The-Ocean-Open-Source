For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b%%cc)
cd export\windows\cpp
if not exist logs\NUL mkdir logs\
cd bin\
"EventheOcean.exe" > ../logs/log_%mydate%_%mytime%.txt 2>&1
cd ..
exit