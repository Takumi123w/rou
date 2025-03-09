<# : Batch portion
color 9F
mkdir build-kitchen
mkdir build-kitchen\out
del fake\tar.txt
del fake\tar.gz.txt
del fake\tar.xz.txt
del fake\7z.txt
:MENU
cls
@echo off & setlocal enabledelayedexpansion
set "menu[0]=Extract Super                   "
set "menu[1]=Build ROM                       "
set "menu[2]=Options                         "
set "menu[3]=Exit                            "

set "default=0"

powershell -noprofile "iex (gc \"%~f0\" | out-string)"

if %ERRORLEVEL% EQU 0 (
    goto SUPERMENU
)

if %ERRORLEVEL% EQU 1 (
	if exist fake\profile\super_map.txt (
	goto BUILDMENU
	) else (
	goto :PROFILEMENU
	)
)

if %ERRORLEVEL% EQU 2 (
    goto OPTIONS
)

if %ERRORLEVEL% EQU 3 (
    exit
)

if %ERRORLEVEL% GEQ 4 (
    echo Invalid menu selection or error.
)

:PROFILEMENU
@echo off
setlocal enabledelayedexpansion
cls

:MENU
echo.
echo ...............................................
echo Type Back for cancel Available Profiles :
echo ...............................................

dir /b fake\profile | sed "s/main.txt//g" | sed "s/super.txt//g"
echo.

SET /P M=Type profile and ENTER:
IF %M%==%M% GOTO NOTE
IF %M%==BACK GOTO MENU

:NOTE
copy fake\profile\!M! fake\profile\super_map.txt
if exist fake\profile\super_map.txt (
type fake\profile\super_map.txt | grep "Size:" | sed "s/Size://g" | sed "s/bytes//g" | sed "s/ //g" > fake\profile\super.txt
	powershell -NoProfile -Command "type fake\profile\super_map.txt | .\grep "Maximum" | Select-Object -Index 1" | sed "s/Maximum size://g" | sed "s/bytes//g" | sed "s/ //g" > fake\profile\main.txt
goto BUILDMENU
)

:SUPERMENU
cls
@echo off & setlocal enabledelayedexpansion
set "menu[0]=Extract from folder build       "
set "menu[1]=Back to Main menu               "
set "menu[2]="
set "menu[3]="

set "default=0"

powershell -noprofile "iex (gc \"%~f0\" | out-string)"

if %ERRORLEVEL% EQU 0 (
simg2img ./build-kitchen/super.img ./build-kitchen/super.raw.img
call cmd /c "stat build-kitchen\super.raw.img | grep "Size" | sed "s/Size://g" | sed "s/ Regular File//g" | sed "s/ //g" " > fake\temp_output.txt
set "size_var="
< fake\temp_output.txt set /p size_var=
if !size_var! GTR 2621440 (
del "build-kitchen\super.img"
move "build-kitchen\super.raw.img" "build-kitchen\super.img"
) else (
    echo no
)
if exist build-kitchen\super.img (
lpunpack -p vendor ./build-kitchen/super.img ./build-kitchen/
lpunpack -p odm ./build-kitchen/super.img ./build-kitchen/
lpunpack -p system_ext ./build-kitchen/super.img ./build-kitchen/
lpdump ./build-kitchen/super.img > fake\profile\super_map.txt
type fake\profile\super_map.txt | grep "Size:" | sed "s/Size://g" | sed "s/bytes//g" | sed "s/ //g" > fake\profile\super.txt
	powershell -NoProfile -Command "type fake\profile\super_map.txt | .\grep "Maximum" | Select-Object -Index 1" | sed "s/Maximum size://g" | sed "s/bytes//g" | sed "s/ //g" > fake\profile\main.txt
)
pause
goto MENU
)

if %ERRORLEVEL% EQU 1 (
    goto MENU
)

if %ERRORLEVEL% EQU 2 (
    goto OPTIONS
)

if %ERRORLEVEL% EQU 3 (
    exit
)

if %ERRORLEVEL% GEQ 4 (
    echo Invalid menu selection or error.
)
:OPTIONS
cls
@echo off & setlocal enabledelayedexpansion
set "menu[0]=Clear profile                   "
set "menu[1]=Back to Main menu               "
set "menu[2]="
set "menu[3]="

set "default=0"

powershell -noprofile "iex (gc \"%~f0\" | out-string)"

if %ERRORLEVEL% EQU 0 (
del fake\profile\super_map.txt
del fake\profile\super.txt
del fake\profile\main.txt
echo "Profile removed"
pause
goto OPTIONS
)

if %ERRORLEVEL% EQU 1 (
goto MENU
)

if %ERRORLEVEL% EQU 2 (
goto OPTIONS
)

if %ERRORLEVEL% EQU 3 (
exit
)

if %ERRORLEVEL% GEQ 4 (
echo Invalid menu selection or error.
)
:BUILDMODE
cls
setlocal EnableDelayedExpansion
if exist build-kitchen\odm.img (
set /p super_var=<fake\profile\super.txt
set /p main_var=<fake\profile\main.txt

forfiles /p build-kitchen /m system.img /c "cmd /c echo @fsize" > fake\system_size_raw.txt
for /f "delims=" %%A in (fake\system_size_raw.txt) do set system_var=%%A

forfiles /p build-kitchen /m odm.img /c "cmd /c echo @fsize" > fake\odm_size_raw.txt
for /f "delims=" %%A in (fake\odm_size_raw.txt) do set odm_var=%%A

forfiles /p fake /m product.img /c "cmd /c echo @fsize" > fake\product_size_raw.txt
for /f "delims=" %%A in (fake\product_size_raw.txt) do set product_var=%%A

forfiles /p build-kitchen /m vendor.img /c "cmd /c echo @fsize" > fake\vendor_size_raw.txt
for /f "delims=" %%A in (fake\vendor_size_raw.txt) do set vendor_var=%%A

echo Super Value: !super_var!
echo Main Value: !main_var!
echo System Size: !system_var!
echo ODM Size: !odm_var!
echo Product Size: !product_var!
echo Vendor Size: !vendor_var!
lpmake --metadata-size 65536 --super-name super --metadata-slots 2 ^
--device super:!super_var! --group main:!main_var! ^
--partition system:readonly:!system_var!:main --image system=build-kitchen\system.img ^
--partition vendor:readonly:!vendor_var!:main --image vendor=build-kitchen\vendor.img ^
--partition product:readonly:!product_var!:main --image product=fake\product.img ^
--partition odm:readonly:!odm_var!:main --image odm=build-kitchen\odm.img ^
--sparse --output build-kitchen\out\super.img
endlocal
)
if exist build-kitchen\system_ext.img (
set /p super_var=<fake\profile\super.txt
set /p main_var=<fake\profile\main.txt

forfiles /p build-kitchen /m system.img /c "cmd /c echo @fsize" > fake\system_size_raw.txt
for /f "delims=" %%A in (fake\system_size_raw.txt) do set system_var=%%A

forfiles /p build-kitchen /m system_ext.img /c "cmd /c echo @fsize" > fake\systemext_size_raw.txt
for /f "delims=" %%A in (fake\systemext_size_raw.txt) do set systemext_var=%%A

forfiles /p fake /m product.img /c "cmd /c echo @fsize" > fake\product_size_raw.txt
for /f "delims=" %%A in (fake\product_size_raw.txt) do set product_var=%%A

forfiles /p build-kitchen /m vendor.img /c "cmd /c echo @fsize" > fake\vendor_size_raw.txt
for /f "delims=" %%A in (fake\vendor_size_raw.txt) do set vendor_var=%%A

echo Super Value: !super_var!
echo Main Value: !main_var!
echo System Size: !system_var!
echo System_ext Size: !systemext_var!
echo Product Size: !product_var!
echo Vendor Size: !vendor_var!
lpmake --metadata-size 65536 --super-name super --metadata-slots 2 ^
--device super:!super_var! --group main:!main_var! ^
--partition system:readonly:!system_var!:main --image system=build-kitchen\system.img ^
--partition vendor:readonly:!vendor_var!:main --image vendor=build-kitchen\vendor.img ^
--partition product:readonly:!product_var!:main --image product=fake\product.img ^
--partition system_ext:readonly:!systemext_var!:main --image system_ext=build-kitchen\system_ext.img ^
--sparse --output build-kitchen\out\super.img
endlocal
)
if exist fake\tar.txt (
@echo off
setlocal enabledelayedexpansion
move build-kitchen\out\super.img %dir%
set /p "Archive=What the Archive Name: "
deb\7z\7za a -ttar build-kitchen\out\!Archive!.tar super.img
move super.img build-kitchen\out\super.img
)
if exist fake\tar.gz.txt (
@echo off
setlocal enabledelayedexpansion
move build-kitchen\out\super.img %dir%
set /p "Archive=What the Archive Name: "
deb\7z\7za a -ttar -so -an super.img | deb\7z\7za a -si build-kitchen\out\!Archive!.tar.gz
move super.img build-kitchen\out\super.img
)
if exist fake\tar.xz.txt (
@echo off
setlocal enabledelayedexpansion
move build-kitchen\out\super.img %dir%
set /p "Archive=What the Archive Name: "
deb\7z\7za a -txz build-kitchen\out\!Archive!.tar.xz super.img
move super.img build-kitchen\out\super.img
)
if exist fake\7z.txt (
@echo off
setlocal enabledelayedexpansion
move build-kitchen\out\super.img %dir%
set /p "Archive=What the Archive Name: "
deb\7z\7za a build-kitchen\out\!Archive!.7z super.img
move super.img build-kitchen\out\super.img
)
pause
goto BUILDMENU
:BUILDMENUEXTRA
del fake\tar.txt
del fake\tar.gz.txt
del fake\tar.xz.txt
del fake\7z.txt
cls
@echo off & setlocal enabledelayedexpansion
set "menu[0]=Build with tar.gz               "
set "menu[1]=Build with tar.xz               "
set "menu[2]=Build with 7z                   "
set "menu[3]=Back                            "

set "default=0"

powershell -noprofile "iex (gc \"%~f0\" | out-string)"

if %ERRORLEVEL% EQU 0 (
echo "tar" > fake\tar.gz.txt
goto BUILDMODE
)

if %ERRORLEVEL% EQU 1 (
echo "tar" > fake\tar.xz.txt
goto BUILDMODE
)

if %ERRORLEVEL% EQU 2 (
echo "zip" > fake\7z.txt
goto BUILDMODE
)

if %ERRORLEVEL% EQU 3 (
goto BUILDMENU
)

if %ERRORLEVEL% GEQ 4 (
    echo Invalid menu selection or error.
)
cls
:BUILDMENU
del fake\tar.txt
cls
@echo off & setlocal enabledelayedexpansion
set "menu[0]=Build                           "
set "menu[1]=Build IMG Only                  "
set "menu[2]=Build tar with extra archive    "
set "menu[3]=Back to Main menu               "

set "default=0"

powershell -noprofile "iex (gc \"%~f0\" | out-string)"

if %ERRORLEVEL% EQU 0 (
echo "tar" > fake\tar.txt
goto BUILDMODE
)

if %ERRORLEVEL% EQU 1 (
goto BUILDMODE
)

if %ERRORLEVEL% EQU 2 (
goto BUILDMENUEXTRA
)

if %ERRORLEVEL% EQU 3 (
goto MENU
)

if %ERRORLEVEL% GEQ 4 (
echo Invalid menu selection or error.
)
cls

goto :EOF
: end batch / begin PowerShell hybrid chimera #>

$menuprompt = " ENTER - SELECT,NEXT  "

$maxlen = $menuprompt.length + 6
$menu = gci env: | ?{ $_.Name -match "^menu\[\d+\]$" } | %{
    $_.Value.trim()
    $len = $_.Value.trim().Length + 6
    if ($len -gt $maxlen) { $maxlen = $len }
}
[int]$selection = $env:default
$h = $Host.UI.RawUI.WindowSize.Height
$w = $Host.UI.RawUI.WindowSize.Width
$test = ./stat ./build-kitchen/super.img | ./grep "Size" | ./sed "s/Size/Super size/g" | ./sed "s/ Regular File//g"
$logical = type fake\profile\main.txt
$system = ./stat ./build-kitchen/system.img | ./grep "Size" | ./sed "s/Size/System size/g" | ./sed "s/ Regular File//g"
$system_ext = ./stat ./build-kitchen/system_ext.img | ./grep "Size" | ./sed "s/Size/System ext size/g" | ./sed "s/ Regular File//g"
$odm = ./stat ./build-kitchen/odm.img | ./grep "Size" | ./sed "s/Size/Odm size/g" | ./sed "s/ Regular File//g"
$vendor = ./stat ./build-kitchen/vendor.img | ./grep "Size" | ./sed "s/Size/Vendor size/g" | ./sed "s/ Regular File//g"
$xpos = 1
$ypos = [math]::floor(($h - ($menu.Length + 4)) / 3)
$oprofile = ./stat ./fake/profile/super_map.txt | ./grep "File:" | ./sed "s/ //g" | ./sed "s/fake//g" | ./sed "s/profile//g" | ./sed "s/File:/profile_exist/g"

$offY = [console]::WindowTop;
$rect = New-Object Management.Automation.Host.Rectangle `
    0,$offY,($w - 1),($offY+$ypos+$menu.length+4)
$buffer = $Host.UI.RawUI.GetBufferContents($rect)

function destroy {
    $coords = New-Object Management.Automation.Host.Coordinates 0,$offY
    $Host.UI.RawUI.SetBufferContents($coords,$buffer)
}

function getKey {
    while (-not ((37..40 + 13 + 48..(47 + $menu.length)) -contains $x)) {
        $x = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode
    }
    $x
}

function WriteTo-Pos ([string]$str, [int]$x = 0, [int]$y = 0,
    [string]$bgc = [console]::BackgroundColor, [string]$fgc = [Console]::ForegroundColor) {
    if($x -ge 0 -and $y -ge 0 -and $x -le [Console]::WindowWidth -and
        $y -le [Console]::WindowHeight) {
        $saveY = [console]::CursorTop
        $offY = [console]::WindowTop       
        [console]::setcursorposition($x,$offY+$y)
        Write-Host $str -b $bgc -f $fgc -nonewline
        [console]::setcursorposition(0,$saveY)
    }
}

function center([string]$what) {
    $what = "    $what  "
    $lpad = " " * [math]::max([math]::floor(($maxlen - $what.length) / 2), 0)
    $rpad = " " * [math]::max(($maxlen - $what.length - $lpad.length), 0)
    WriteTo-Pos "$lpad   $what   $rpad" $xpos $line white black
}

function center2([string]$what) {
    $what = "    $what  "
    $lpad = " " * [math]::max([math]::floor(($maxlen - $what.length) / 2), 0)
    $rpad = " " * [math]::max(($maxlen - $what.length - $lpad.length), 0)
    WriteTo-Pos "$what" $xpos $line black white
}

function leftAlign([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 0 black white
}

function leftAlign2([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 1 blue yellow
}

function leftAlign3([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 2 white black
}

function leftAlign4([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 3 white black
}

function leftAlign5([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 3 white black
}

function leftAlign6([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 4 white black
}

function leftAlign7([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 5 white black
}

function leftAlign8([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 6 white black
}

function leftAlign9([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 7 white black
}

function leftAlign10([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 8 white black
}

function leftAlign11([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 9 white black
}

function leftAlign11A([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" 2 10 black white
}

function leftAlign12([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" 40 3 black white
    WriteTo-Pos "$what" 40 4 black white
    WriteTo-Pos "$what" 40 5 black white
    WriteTo-Pos "$what" 40 6 black white
    WriteTo-Pos "$what" 40 7 black white
    WriteTo-Pos "$what" 40 8 black white
    WriteTo-Pos "$what" 40 9 black white
}

function leftAlignTrial([string]$what) {
    $what = "  $what"
    WriteTo-Pos "$what" $xpos 17 black white
}

function menu {
    $line = $ypos
    leftAlign12 " "
    leftAlignTrial "$oprofile"
    leftAlign "Super Kitchen Tools GUI  "
    leftAlign2 "                                       "
    leftAlign3 "                                       "
    leftAlign4 "                                       "
    leftAlign5 "                                       "
    leftAlign6 "                                       "
    leftAlign7 "                                       "
    leftAlign8 "                                       "
    leftAlign9 "                                       "
    leftAlign10 "                                       "
    leftAlign11 "                                       "
    leftAlign11A "                                       "
    leftAlign5 "  Super size:"
    leftAlign6 "  Logical size:"
    leftAlign7 "  System size:"
    leftAlign8 "  System ext size:"
    leftAlign9 "  Odm size:"
    leftAlign10 "  Vendor size:"
    leftAlign5 "$test"
    leftAlign6 "  Logical size: $logical"
    leftAlign7 "$system"
    leftAlign8 "$system_ext"
    leftAlign9 "$odm"
    leftAlign10 "$vendor"
    $line++
    $line++
    $line++
    $line++
    $line++

    for ($i=0; $item = $menu[$i]; $i++) {
        # write-host $xpad -nonewline
        $rtpad = " " * ($maxlen - $item.length)
        if ($i -eq $selection) {
            WriteTo-Pos "  > $item <$rtpad" $xpos ($line++) yellow blue
        } else {
            WriteTo-Pos " $i`: $item  $rtpad" $xpos ($line++) blue yellow
        }
    }
    $line++
    $line++
    $line++
    center2 $menuprompt
    1
}

while (menu) {

    [int]$key = getKey

    switch ($key) {

        37 {}   # left or up
        38 { if ($selection) { $selection-- }; break }

        39 {}   # right or down
        40 { if ($selection -lt ($menu.length - 1)) { $selection++ }; break }

        # number or enter
        default { if ($key -gt 13) {$selection = $key - 48}; destroy; exit($selection) }
    }
}