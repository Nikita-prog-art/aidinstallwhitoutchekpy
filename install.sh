#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")"
BASE_DIR="$(pwd)"
PACKAGES=(aria2 git unzip wget)
# Tensorflow states 3.4.0 as the minimum version.
# This is also the minimum version with venv support.
# 3.8.0 and up only includes tensorflow 2.0 and not 1.15

pip_install () {
	if [ ! -d "./venv" ]; then
		# Some distros have venv built into python so this isn't always needed.
		if is_command 'apt-get'; then
			apt-get install python3-venv
		fi
		python3 -m venv ./venv
	fi
	source "${BASE_DIR}/venv/bin/activate"
	pip install --upgrade pip setuptools
	pip install -r "${BASE_DIR}/requirements.txt"
}

is_command() {
	command -v "${@}" > /dev/null
}

system_package_install() {
	SUDO=''
	if (( $EUID != 0 )); then
		SUDO='sudo'
	fi
	
	PACKAGES=(aria2 git unzip wget)
	if is_command 'apt-get'; then
		$SUDO apt-get install ${PACKAGES[@]}
	elif is_command 'brew'; then
		brew install ${PACKAGES[@]}
	elif is_command 'yum'; then
		$SUDO yum install ${PACKAGES[@]}
	elif is_command 'dnf'; then
		$SUDO dnf install ${PACKAGES[@]}
	elif is_command 'pacman'; then
		$SUDO pacman -S ${PACKAGES[@]}
	elif is_command 'apk'; then
		$SUDO apk --update add ${PACKAGES[@]}
	else
		echo "You do not seem to be using a supported package manager."
		echo "Please make sure ${PACKAGES[@]} are installed then press [ENTER]"
		read NOT_USED
	fi
}

install_aid () {
	pip_install
	system_package_install
}

install_aid
