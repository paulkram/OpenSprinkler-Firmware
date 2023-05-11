#!/bin/bash

while getopts ":s" opt; do
  case $opt in
    s)
	  SILENT=true
	  command shift
      ;;
  esac
done
echo "Building OpenSprinkler..."

if [ "$1" == "demo" ]; then
	echo "Installing required libraries..."
	apt-get install -y libmosquitto-dev
	echo "Compiling firmware..."
	g++ -o OpenSprinkler -DDEMO -std=c++14 -m32 main.cpp OpenSprinkler.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp etherport.cpp mqtt.cpp -lpthread -lmosquitto
elif [ "$1" == "osbo" ]; then
	echo "Installing required libraries..."
	apt-get install -y libmosquitto-dev
	echo "Compiling firmware..."
	g++ -o OpenSprinkler -DOSBO main.cpp OpenSprinkler.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp etherport.cpp mqtt.cpp -lpthread -lmosquitto
elif [ "$1" == "opipc" ]; then
	echo "Installing required libraries..."
	#apt-get update
	#apt-get install -y libmosquitto-dev cmake
	#echo "Downloading and installing wiringOP..."
	#if [ -d "wiringOP" ]; then
  	#	echo "wiringOP folder exists, updating to latest master"
	#	cd wiringOP
	#	git checkout master
    #	git pull
	#else
	#	git clone https://github.com/orangepi-xunlong/wiringOP.git
	#	cd wiringOP	    
	#fi
	#./build clean
	#./build 
	#cd ..
	echo "Done installing wiringOP"
	if ! command -v gpio &> /dev/null
	then
		echo "Command gpio is required and is not installed"
		exit 0
	fi

	if [ "$2" == "lcd" ]; then
		echo "Building with LCD support"
		display=\-DLIBSSD1306
		if [ ! -d "lcdgfx" ]; then
		echo "Cloning libSSD1306 library"
		git clone --depth 1 https://github.com/AndrewFromMelbourne/libSSD1306.git
		fi
		echo "Building libSSD1306"
		cd libSSD1306
		cmake .
		make -j SSD1306
		cd ..
		ldisplay=\-I\ libSSD1306\/lib\ -L\ libSSD1306\/lib\ \-lSSD1306
		odisplay=SSD1306DisplayAdapter.cpp\ 
		echo "done"
	fi

	echo "Compiling firmware..."
	g++ -std=c++14 -o OpenSprinkler -DOSOPI $display main.cpp OpenSprinkler.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp etherport.cpp mqtt.cpp $odisplay -lpthread -lmosquitto $ldisplay

else
	echo "Installing required libraries..."
	apt-get update
	apt-get install -y libmosquitto-dev
	apt-get install -y raspi-gpio
	if ! command -v raspi-gpio &> /dev/null
	then
		echo "Command raspi-gpio is required and is not installed"
		exit 0
	fi
	echo "Compiling firmware..."
	g++ -o OpenSprinkler -DOSPI main.cpp OpenSprinkler.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp etherport.cpp mqtt.cpp -lpthread -lmosquitto
fi

if [ ! "$SILENT" = true ] && [ -f OpenSprinkler.launch ] && [ ! -f /etc/init.d/OpenSprinkler.sh ]; then

	read -p "Do you want to start OpenSprinkler on startup? " -n 1 -r
	echo

	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 0
	fi

	echo "Adding OpenSprinkler launch script..."

	# Get current directory (binary location)
	pushd `dirname $0` > /dev/null
	DIR=`pwd`
	popd > /dev/null

	# Update binary location in start up script
	sed -e 's,\_\_OpenSprinkler\_Path\_\_,'"$DIR"',g' OpenSprinkler.launch > OpenSprinkler.sh

	# Make file executable
	chmod +x OpenSprinkler.sh

	# Move start up script to init.d directory
	sudo mv OpenSprinkler.sh /etc/init.d/

	# Add to auto-launch on system startup
	sudo update-rc.d OpenSprinkler.sh defaults

	# Start the deamon now
	sudo /etc/init.d/OpenSprinkler.sh start

fi

echo "Done!"
