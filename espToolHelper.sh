#! /bin/bash

#program meta information
authorX="Anthony G. Kerr"
contactX="a2kerr@hotmail.com"
dateOG="July 08, 2018"
dateX="January 16, 2020"
productX="Flasher and Erase Helper Program"
statementX="A little \"esptool\" helper script for:\nESP82666 and ESP32 "
references="\n- http://docs.micropython.org/en/latest/esp8266/tutorial/intro.html#deploying-the-firmware
\n- https://micropython.org/download#esp8266\n\n"

#set argument list globally
declare -A config_meta 
config_meta[port]=$1
config_meta[baud]=$2
config_meta[firmware]=$3
config_meta[fail]="Make sure your MCU is plugged in"
config_meta[flash]="0x1000"
config_meta[chip]="???"

if [[ ${config_meta[port]} = "" ]]; then config_meta[port]="???"; fi 
if [[ ${config_meta[baud]} = "" ]]; then config_meta[baud]="115200"; fi 
if [[ ${config_meta[firmware]} = "" ]]; then config_meta[firmware]="???"; fi 

#greeting
function show_Greeting(){
	printf "Free-ware: ${productX}\n"
	printf "Author: ${authorX}\n"
	printf "email: ${contactX}\n"
	printf "Date: ${dateX}\n"
	printf "${statementX}\n"
	printf "\nReferences:\n${references}"
}

#ask user decision to continue, quit or start again?
function get_UserContinue(){
	printf "\nTo CONTINUE enter y?\n"
	printf "To RESTART enter r?\n"
	printf "To Quit enter q?\n"
	read continueY
	if [ "$continueY" == "y" ]
		then return 0
	elif [ "$continueY" == "q" ]
    	then show_Exit
	else
		return 1
	fi
}

#general error message for invalid file parameter
show_InvalidMessage(){
	commandX=$1
	argumentX=$2
	printf "${commandX}: invalid argument: ${argumentX}\n
			Valid arguments are:
		  	- ‘115200’
		  	- ‘19200’
		  	- ‘9600’
			Try '${commandX} --help' for more information."
}

# show user instruction message on how to put the device in flash mode
function show_FlashModeInstuction(){
	local callbackX=$1
	printf "\nYOU MUST PUT DEVICE IN FLASH MODE:\n"
	printf "\n1) Hold FLASH button/pin down while...\n"
	printf "\n2) Toggling REST button/pin\n"
	printf "\nNote) The RED Led will dim indicating FLASH MODE set\n"
	get_UserContinue
	local continueY=$?
	if [ "$continueY" == 0 ]
		then
			return 0
	else
		clear
		#get_chipInfo
		# $callbackX
	fi
}

#get system information as needed
function get_SysInfo(){
	printf "\nLast program's return value: $?"
	printf "\nScript's PID: $$"
	printf "\nNumber of arguments passed to script: $#"
	printf "\nAll arguments passed to script: $@"
	printf "\nScript's arguments separated into different variables: $1 $2..."
}

#generic header to be used for user feedback
function show_header(){
#TODO: implement auto formating
	printf "\n**************************
	        \n** ${1:-"Hello World!"} **
	        \n**************************\n"
}

#get the work directory information and other file related stuff
function get_DirInfo(){
	holdX=$1
	#dataX=$($holdX) | grep "\.bin"
	printf "\nIN get_DirInfo():\n"
	printf "\nRUNNING: $holdX\n$($holdX | grep "\.bin")"
	printf "\nthe directory is: $(pwd)"
	printf "\nthe directory is: $PWD\n"
	#printf "\nRUNNING: $holdX\n$dataX"
}

# run flasher tool to wipe clean memory before flashing new data
function run_Erase(){
	show_header "STARTING ERASE PROCESS!"
	#echo -e "esptool.py --port ${portX} --baud 115200 erase_flash\n"
	printf "\nesptool.py --port ${portX_Meta[port]} --baud 115200 erase_flash\n"
	printf "\nPUT DEVICE IN FLASH MODE:\n"
	printf "\n1) Hold FLASH button/pin down while toggling REST button\n"
	printf "\n2) Toggling REST button/pin\n"
	printf "\nNote) RED Led should dim when in FLASH MODE\n"
	printf "\nTO CONTINUE ENTER y?\n"
	read continueY
	if [ "$continueY" != "y" ]
	then
    	printf "\nExitting good bye\n"
	   	exit
	else
    	printf "\nERASE STARTING!\n"
		#TODO: add logging file: esptool.py --port ${portX} --baud 115200 erase_flash > "flasherLog.log" 2>&1
		# esptool.py --port ${portX} --baud 115200 erase_flash
		if [[ ${config_meta[chip]} == "esp32" ]]; then
			printf "Erasing ESP32!!!"
			esptool.py --chip esp32 --port ${config_meta[port]} erase_flash
			# esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} write_flash --flash_size=detect 0x0 ${config_meta[firmware]}
		else
			printf "Erasing ESP8266!!!"
			esptool.py --port ${config_meta[port]} erase_flash
			show_header "Erase Completed :)"
			# esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} write_flash -z 0x1000 ${config_meta[firmware]}
		fi
	fi
}

# Erase MCU Flash
function get_EraseFlash(){
	printf "\nDo you want to erase flash memory y/n?"
	read eraseFlashY #note no need to declare new variable
	if [ "$eraseFlashY" != "y" ]
	then
    	printf "\nDo Not Erase Bye :)\n"
	   	# get_DirChange
		return 0
	else
    	printf "\nERASE STARTING!\n"
     	run_Erase
		return 0
	fi
}

# Use subshells to work across directories
function get_DirChange(){
	(printf "First, I'm here: $PWD\n") && (cd ~/Sandbox; printf "Then, I'm here: $PWD\n")
	pwd # still in first directory
}

#get chip information
function get_chipInfo(){
	show_header "Menu: Getting Chip Information"
	# show_FlashModeInstuction get_chipInfo
	esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} chip_id
}

#get USB Port
function get_usbPort(){
	local -A meta 
		meta[menu]=$1
		meta[header]="Menu: Configure Port"
		meta[search]="/dev/ttyUSB*"
		meta[pass]="\nPort is now set too: "
		meta[fail]="No port found!\nMake sure your MCU is plugged in\n"
	show_header "${meta[header]}"
	usbPortList=( $(ls -1 ${meta[search]} 2> /dev/null))
	getLastCommandStatus=$(echo $?)
	if [ $getLastCommandStatus != 0 ]; then
			printf "${meta[fail]}"
			return
		else 
		for indexX in ${!usbPortList[@]}; do
			printf "$indexX) ${usbPortList[$indexX]}\n"
		done
	fi
	printf "\nSelect Port: "
	read selectionY
	config_meta[port]=${usbPortList[$selectionY]}
	if [ "${config_meta[port]}" != "" ]
	then
		printf "${meta[pass]}${config_meta[port]}"
		return ${selectionY}
	else
		config_meta[port]="???"
		printf "\n*** Something went wrong! Check your selection"
		return 255
	fi
}

# Get Baud rate of MCU 
function get_Baud(){
	show_header "Getting Baud Rate"
	# usbPortX="./*.bin"
	usbPortList=( 1500000 921600 460800 230400 115200 74880 9600)
	# getLastCommandStatus=$(echo $?)
	# if [ $getLastCommandStatus != 0 ]; then
			# printf "\nNO PORT NOT FOUND"
		# else 
	for indexX in ${!usbPortList[@]}; do
		printf "$indexX) ${usbPortList[$indexX]}\n"
	done
	# fi
	read selectionY
	#if [ $selectionY == "q" ] || [ $selectionY -le 5 ]
	if [ "$selectionY" != "" ];	then
		config_meta[baud]=${usbPortList[$selectionY]}
		printf "Buad = ${config_meta[baud]}" 
		return ${selectionY}
	else
		config_meta[baud]="???"
		printf "Invalid argument: ${config_meta[baud]}\n
The baud rate is limited to 115200 when esptool.py establishes the initial connection, higher speeds are only used for data transfers.\n
Most hardware configurations will work with -b 230400, some with -b 460800, -b 921600 and/or -b 1500000 or higher.\n
If you have connectivity problems then you can also set baud rates below 115200. You can also choose 74880, which is the usual baud rate used by the ESP8266 to output boot log information.\n"
		return 255
	fi
}

#Get firmware
function get_Firmware(){
	# local selectionY=""
	local -A meta 
		meta[menu]=$1
		meta[header]="Menu: Getting Firmware"
		meta[search]="./bin/*.bin"
		meta[pass]="\nFirmware is now set too: "
		meta[fail]="No firmware found!\nMake sure you are in the correct directory\n"
	show_header "${meta[header]}"
	usbPortList=($(ls -1 ${meta[search]} 2> /dev/null))
	getLastCommandStatus=$(echo $?)
	if [ $getLastCommandStatus != 0 ]; then
			printf "${meta[fail]}"
			return
		else 
		for indexX in ${!usbPortList[@]}; do
			printf "$indexX) ${usbPortList[$indexX]}\n"
		done
	fi
	printf "\nSelect Firmware: "
	read selectionY
	if [[ "${selectionY}" != "" ]]; then
	config_meta[firmware]=${usbPortList[$selectionY]}
		printf "${meta[pass]}${config_meta[firmware]}"
		return 0
	else
		config_meta[firmware]="???"
		printf "\n*** Something went wrong! Check your selection"
		return 255
	fi
}

# Get config status
function get_configuration_status(){
	show_header "Menu: Configuration Status"
	if [ "${config_meta[port]}" = "???" ]; then 
		printf "Check Port ${config_meta[port]}"
		# returnX=1 
		return 1
	elif [ "${config_meta[baud]}" = "" ]; then 
		printf "Check Baud Rate ${config_meta[baud]}"
		# returnX=2
		return 2
	elif [ "${config_meta[firmware]}" = "???" ]; then 
		printf "Check Firmware ${config_meta[firmware]}"
		# returnX=3
		return 3
	else 
		printf "All Good"
		# returnX=0
		return 0
	fi
	# printf "\nreturn this ${returnX}"
	# return $returnX 
}

#graceful exit
function show_Exit(){
	clear
	show_header "Hit ANY! key to exit"
	#read exitY
	exit
}
#esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin
#printf "hello \n${portX},    ${test2} and ${test3}\n"

#initialize code, add as needed
function set_Init(){
	printf "IN set_Init: "
}



#parse batch file arguments and process code flow, low level state machine
function get_State(){
	if [[ "$baudX" =~ ^- && ! "$baudX" == "--" ]]
	then 
		case $baudX in
	    	#List patterns for the conditions you want to meet
	    	-V | --version) echo "paremeter ${baudX} selected!";;
	    	2) echo "There is a 2.";;
	    	*) show_InvalidMessage "test.sh" $baudX;;
		esac
	else
		show_InvalidMessage "test.sh" "NO PARAMETER FOUND"
	fi
}

#Flash 4mb continious
function flash4mbCombine(){
	show_header "IN: flash4mbCombine"
	#esptool.py --port ${portX} --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin 
	# esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 ./bin/espruino_1v93_esp8266_4mb_combined_4096.bin
	if [[ ${config_meta[chip]} == "esp8266" ]]; then
		printf "\nFlash ESP8266!!!\n"
		esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} --chip ${config_meta[chip]} write_flash --flash_size=detect 0x0 ${config_meta[firmware]}
	elif [[ ${config_meta[chip]} == "esp32" ]]; then
		printf "\nFlash ESP32!!!\n"
		esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} --chip ${config_meta[chip]} write_flash -z 0x1000 ${config_meta[firmware]}
	else 
		printf "Exiting no Chip ID found!"
	fi
	# esptool.py --port ${config_meta[port]} --baud ${config_meta[baud]} write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0 ${config_meta[firmware]}
}

#Flash 4mb segment
function flash4mbSegment(){
	show_header "IN: flash4mbSegment()"
	#esptool.py --port ${portX} --baud 115200 write_flash --flash_freq 80m --flash_mode qio --flash_size 4MB 0x0000 espruino_1v93_esp8266_4mb_combined_4096.bin 
}

#**** Main Menu ****
function show_MainMenu(){
	show_header "MAIN MENU"
	printf "\nPort = ${config_meta[port]}"
	printf "\nBaud = ${config_meta[baud]}"
	printf "\nFirmware = ${config_meta[firmware]}"
	printf "\nChip ID = ${config_meta[chip]}"
	printf "\n\nPlease make a selection\n"
	printf "\n1) Device information: "
	printf "\n2) Erase Flash:"
	printf "\n3) Program Flash: Combine 4MB"
	printf "\n4) Program Flash: Segment 4MB"
	printf "\n5) Program Flash: BLANK!"
	printf "\n6) List Files: *.bin"
	printf "\n7) Set Chip: "
	printf "\n8) Set USB Port: "
	printf "\n9) Set Baud Rate: "
	printf "\n10) Set Firmware: "
	printf "\n *** HIT q TO QUIT! ***\n"
	read selectionY
	#if [ $selectionY == "q" ] || [ $selectionY -le 5 ]
	if [ "$selectionY" != "q" ]
	then 
		return ${selectionY}
	else
		return 255
	fi
}

# Test Function
function test(){
	for i in ????:??:??.? ; do
		printf "$i"
  	done
}

# Set Chip ID
function set_chip(){
	local -A meta 
		meta[menu]=$1
		meta[header]="Menu: Set Chip ID"
		meta[search]=""
		meta[pass]="\nChip ID is now set too: "
		meta[fail]="No Chip ID found!\nMake sure you datasheet\n"
	show_header "${meta[header]}"
	usbPortList=(esp8266 esp32)
	# getLastCommandStatus=$(echo $?)
	# if [ $getLastCommandStatus != 0 ]; then
			# printf "${meta[fail]}"
			# return
		# else 
	for indexX in ${!usbPortList[@]}; do
		printf "$indexX) ${usbPortList[$indexX]}\n"
	done
	# fi
	printf "\nSelect Chip ID: "
	read selectionY
	if [[ "${selectionY}" != "" ]]; then
	config_meta[chip]=${usbPortList[$selectionY]}
		printf "${meta[pass]}${config_meta[chip]}"
		return 0
	else
		config_meta[chip]="???"
		printf "\n*** Something went wrong! Check your selection"
		return 255
	fi

}

#Parse Menu
function set_ParseMenu(){
	clear
	local selectionY=$1
	#show_header "IN: set_ParseMenu($selectionY)"
	case $selectionY in
		1)	printf "1) Device information:\n" #1) Device information:
			get_configuration_status
			local returnX=$?
			if (( ${returnX} == 0 )); then 
				get_chipInfo
			else 
				# read continueY
				return 255
			fi;; 
		2)  printf "2) Erase Flash:\n" #2) Erase Flash:
			printf "= ${selectionY}\n"
			get_EraseFlash;; 
		3)  printf "3) Program Flash: Combine 4MB\n" #3) Program Flash: Combine 4MB
			printf "= ${selectionY}\n"
			flash4mbCombine;; 
		4)  printf "Program Flash: Segment 4MB\n" #4) Program Flash: Segment 4MB
			printf "= ${selectionY}\n"
			flash4mbSegment\n;; 
		5)  printf "Program Flash: BLANK!\n" #5) Program Flash: BLANK!
			printf "= ${selectionY}\n";; 
		6)  printf "List Files: *.bin\n" #6) List Files: *.bin\n
			printf "= ${selectionY}\n"
			ls -1 ./bin
			;;
		7)  printf "Set Chip\n" #7) used as test function
			printf "= ${selectionY}\n"
			set_chip
			;; 
		8)  printf "Set USB Port:\n" #8) list available USB ports
			printf "= ${selectionY}\n"
			get_usbPort
			;; 
		9)  printf "Set Baud Rate:\n" #8) list available USB ports
			printf "= ${selectionY}\n"
			get_Baud
			;; 
		10)  printf "Set Firmware:\n" #8) list available USB ports
			printf "= ${selectionY}\n"
			get_Firmware
			;; 
	  255) 	printf "Goodbye :)\n" #q) quit/exit
			printf "= ${selectionY}\n"
			show_Exit;; 			
	esac
}

#main function where it all starts
function main(){
	show_header "HAPPY ENGINEERING :)"
	show_Greeting
	show_MainMenu
	local selectionY=$? #get the value of the last returned, i.e. function()
	show_header "SELECTION = ${selectionY}"
	set_ParseMenu $selectionY
	printf "\nContinue ?\n"
	read continueY
	#get_State
	#get_SysInfo
	#get_DirInfo "ls -1"
	#get_EraseFlash
	#hold=$(get_EraseFlash)
	#printf hold

}

#RUN *******************************************************************
	while [ 1 ] 
	do
		clear
		main
	done
#on Asus Tinker
#from git