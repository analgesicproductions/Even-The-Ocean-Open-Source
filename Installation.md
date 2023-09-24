## Installation

* This is only tested on Windows 7 and 10.
* You can *theoretically* compile this for Mac OSX, but it seems like over the  past 5-6 years, OS updates broke some esoteric thing in the build chain so I could never get the game to compile after 2016/7. If someone can figure this out that would be amazing!!
* In theory you can compile a Haxe project for Linux but for some reason I couldn't figure it out. I would love for this to run on Linux though.

### Step 1: Installing Haxe

Note that Even the Ocean requires an OLD version of haxe due to language changes that happened in Haxe 4. 

WARNING!!!

1. Install Haxe 3.4.7 64-bit and Neko 2.1.0 
	1. For this tutorial, this installs to C:\\HaxeToolkit\\, but if you're a Haxe user **you will need to make a separate folder so as not to break your current games**. Watch out! 
	2. If you do have two Haxe versions installed, make sure for the purposes of this installation that 'haxe' and 'haxelib' are pointing to the binaries in the 3.4.7 installation.

### Step 2: Install required C++ compiler stuff

If you already compile stuff with Haxe you're probably fine. If not, welcome to HELL!!! Maybe.
1. What SHOULD work is to install Visual Studio Community 2019 and click "Desktop development with C++. See https://community.haxe.org/t/how-to-fix-error-set-hxcpp-msvc-custom-manually/2934/2 for help. This will eat up like 10 GB but so it goes.
2. ALTERNATIVELY you might be able to only install these components if you already have a VS 2019 install
		1. MSVC v142 - VS 2019 C++ x64/x86 build tools
		2. Windows SDK (10.0.17763.0)

NOTE: It's possible you can modify a newer VS installation, like 2022 or something. I didn't check though.

### Step 3: Install Haxelibs
1. run 'Open Source Assets/installHaxeLibraries.bat'
2. This will install a bunch of stuff
3. open cmd and use haxelib list to verify the right libraries are installed (they should match those listed in installHaxeLibraries.bat)
4. Note you can use 'haxelib set LIBRARYNAME VERSION' to change active library versions.
### Step 4: Fix hxcpp

I think hxcpp is something related to compiling cpp code for haxe. Note that we are working with an old version - 3.4.188 - here.

1. First, try to compile it the normal way, using the README information in the hxcpp installation folder. The goal here is to produce 3 DLLs - regexp.dll, std.dll and zlib.dll, which need to show up in this folder: PATHTO\\HaxeToolkit\\haxe\\lib\\hxcpp\\3,4,188\\bin\\Windows 
2. If you CAN'T figure it out - and I can't, ha ha! - you can just copy and paste the DLLs I already somehow had from 2016. Find these in the project folder at **Open Source/hxcpp** - copy the Windows/ folder to the bin/ folder in the hxcpp path listed above.

### Step 5: Clone/Download this repo
* Easy! Maybe!
### Step 6: Install FlashDevelop

You don't have to install FlashDevelop if you already use a different IDE or the command line. You can build the game and run it from cmd like so:

haxelib run lime build "Project.xml" windows -release -Dfdb
haxelib run lime run "Project.xml" windows -release

Otherwise:
1. Install FlashDevelop, then open 'shieldhaxe.hxproj'. The correct build settings should already be applied, but
2. Set the SDK for Haxe (Project > Properties > SDK > HaxeContext > ... next to InstalledSDK\[\] Array > Add > Path > ... > C:\HaxeToolkit\haxe > OK > Close)
	1. Ignore the Haxe 3.0.0 Warning
3. Run "updateflixel.bat" in bat/, type 'yes'
	1. This is needed I made changes to the default flixel 2D game engine - it'll copy the changed files to the install directory. You can also do this manually

### Step 7: Hit "Compile" And Pray

1. The first time will take a while. If all works the game should start! Hooray!
