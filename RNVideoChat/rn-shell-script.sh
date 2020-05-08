#!/bin/bash

# * Description:
# *   Script for React-Native Commands i.e. run pakcakge, run on platform or reload app
# *
# * Usage:
# *   $ ./run.sh [param1 [param2 [param3]]]
# *
# * param1 (optional):
# *     - 'r' or 'p' for silent run [if passed script will run in silent mode]
# *     - 'rr' to reload app [for now supported on android device only]
# *     - 'rd' to open react-devtools
# * param2 (optional):
# *     - 'a' or 'A' for android & 'i' or 'I' for ios [can pass if param1='r']
# *
# * param3 (optional):
# *     - 'deviceName' for ios [can pass if param1='r' & param2='i' or 'I']
# *
# * EXAMPLE:
# *     - "./run.sh rr" or "./run.sh RR" [will reload app]
# *     - "./run.sh rd" or "./run.sh RD" [will open react-devtools]
# *     - "./run.sh p" [will run packager]
# *     - "./run.sh r" [will run app on default platform android]
# *     - "./run.sh r a" or "./run.sh r A" [will run app on android platform]
# *     - "./run.sh r i" or "./run.sh r I" [will run app on ios platform]
# *     - "./run.sh r i iPad" or "./run.sh r I iPad" [will run app on ios device named in param3]

ERR_WDDTH() {
  echo ""
  echo "Sorry, We Don't do that here !"
  echo ""
}

checkAndSetPlatform() {
  case $1 in
    a|A)
      platform="android"
      ;;
    i|I)
      platform="ios"
      ;;
    *)
      ERR_WDDTH
      exit
      ;;
  esac
}

installReactDevtools() {
  if [ -z "${install}" ] || [ "${install}" == "y" ] || [ "${install}" == "Y" ]
  then

      read -p 'global [ g ] or local [ l ] (G/l): ' -r installType

      if [ -z "${installType}" ] || [ "${installType}" == 'g' ] || [ "${installType}" == 'G' ]
      then
        npm i -g react-devtools
      else
        npm i react-devtools
      fi

  elif [ "${install}" == "n" ] || [ "${install}" == "N" ]
  then
    echo ""
    echo "  *** Exiting ***"
    echo ""
  fi
  exit
}

runOnPlatform() {
  clear
  echo "Running On Platform" $platform
  if [ "${platform}" == "ios" ]
  then
    react-native run-$platform --device "$3"
  else
    react-native run-$platform
  fi
}

runPackagerAndExit() {
  if [ "${platform}" == "p" ] || [ "${platform}" == "P" ]
  then
    clear
    react-native start -- --chache-reset
    exit
  fi
}

runReactDevtools() {
  clear
  echo "ADB Reverse List"
  adb reverse tcp:8097 tcp:8097
  adb reverse --list

  if [ -x "$(command -v react-devtools)" ]
  then
    echo ""
    echo "  *** Running React-Devtools ***"
    echo ""
    echo "[Please enable Remote JS Debugging and Reload app to connect]"
    react-devtools
    exit
  fi

  echo ""
  echo ' *** Error: React-Devtools is not installed. ***'
  echo ""
  read -p 'install: npm i -g react-devtools (Y/n): ' -r install

  installReactDevtools
}

setPlatformValue() {
  if [ -z "${1}" ]
  then
    platform=$2
  else
    platform=$1
  fi
}

reloadApp() {
  echo ""
  echo "  *** Reloading App ***"
  echo ""
  adb shell input keyevent 46 46
}


runMenu() {
  clear
  echo ""
  echo "Run Menu: "
  echo ""
  echo "[ Run on Platform (default) ]:[ r ]"
  echo "[ Run Packager ]:[ p ]"
  echo ""
  read -p "Enter Value: " -r platform

  setPlatformValue "$platform" "r"

  runPackagerAndExit

  clear
  echo ""
  echo "Platform Selector: "
  echo ""
  echo "[ android (default) ]:[ a ]"
  echo "[ iOS ]:[ i ]"
  echo ""
  read -p "Enter Value: " -r platform

  setPlatformValue "$platform" "a"

  checkAndSetPlatform "$platform"

  runOnPlatform "$@"
}

debugMenu() {

  clear
  echo ""
  echo "Debug Menu: "
  echo ""
  echo "[ Reload Application (default) ]:[ rr ]"
  echo "[ Open React-Devtools ]:[ rd ]"
  echo ""

  read -p "Enter Value: " -r platform

  if [ -z "${platform}" ] || [ "${platform}" == "rr" ] || [ "${platform}" == "RR" ]
  then
    reloadApp
    exit
  elif [ "${platform}" == "rd" ] || [ "${platform}" == "RD" ]
  then
    runReactDevtools
  else
    ERR_WDDTH
  fi
}

if [ "${1}" == "rr" ] || [ "${1}" == "RR" ]
then
  reloadApp
  exit
elif [ "${1}" == "rd" ] || [ "${1}" == "RD" ]
then
  runReactDevtools
elif [ "${1}" == "r" ] || [ "${1}" == "R" ]
then
  setPlatformValue "$2" "a"
  checkAndSetPlatform "$platform"
  runOnPlatform "$@"
  exit
elif [ "${1}" == "p" ] || [ "${1}" == "P" ]
then
  setPlatformValue "$1" "p"
  runPackagerAndExit
  exit
elif [ -n "${1}" ]
then
  ERR_WDDTH
  echo "Try other options Maybe (as given below): "
fi

  clear
  echo ""
  echo "Menu Selector: "
  echo ""
  echo "[ Open Run Menu (default) ]:[ r ]"
  echo "[ Open Debug Menu ]:[ d ]"
  echo ""
  read -p "Enter Value: " -r menu

if [ -z "${menu}" ] || [ "${menu}" == 'r' ] || [ "${menu}" == 'R' ]
then
  runMenu "$@"
elif [ "${menu}" == 'd' ] || [ "${menu}" == 'D' ]
then
  debugMenu
else
  ERR_WDDTH
fi