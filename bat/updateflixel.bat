SET /P ANSWER=Copy git flixel to one thatll be compiled? ('yes' or no)
if /i {%ANSWER%}=={yes} (goto :yes)
goto :no

:yes
xcopy /y /e /h ..\txt\flixel C:\HaxeToolkit\haxe\lib\flixel\4,0,0\
xcopy /y  /e /h ..\txt\addons C:\HaxeToolkit\haxe\lib\flixel-addons\2,0,0\flixel\addons\tile\
::xcopy /y  /e /h ..\txt\addons\FlxTilemapExt.hx ..\txt\draft_writing\
echo Over-wrote flixel thatll be compiled.
pause
exit /b 0

:no
echo Aborting
pause
exit /b 1

