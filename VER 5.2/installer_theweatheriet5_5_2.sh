#!/bin/sh

# ==========================================================
# SCRIPT : DOWNLOAD AND INSTALL ENIGMA2 PLUGIN
# ==========================================================
# This installer detects the image, device, architecture,
# Python version, installed old version, and installs the
# correct package for Dreambox and open-source Enigma2 images.
#
# Telnet command:
# wget -O - "https://raw.githubusercontent.com/Saiedf/TheWeatherIet5/main/VER%205.1/installer_theweatheriet5_5_2.sh" | /bin/sh
#
# Alternative command (download then run):
# wget -O /tmp/installer_theweatheriet5_5_2.sh "https://raw.githubusercontent.com/Saiedf/TheWeatherIet5/main/VER%205.1/installer_theweatheriet5_5_2.sh" && chmod 755 /tmp/installer_theweatheriet5_5_2.sh && /bin/sh /tmp/installer_theweatheriet5_5_2.sh
# ==========================================================

########################################################################################################################
# Plugin ... Enter Manually
########################################################################################################################

# Package name used to detect, remove and install the plugin.
PACKAGE_NAME='enigma2-plugin-extensions-theweatheriet5'

# Display name used in messages only.
PLUGIN_TITLE='TheWeatherIet5'

# Plugin folder name inside Enigma2 plugin directories.
# Example: /usr/lib/enigma2/python/Plugins/Extensions/TheWeatherIet5
# Example: /usr/lib/enigma2/python/Plugins/SystemPlugins/TheWeatherIet5
PLUGIN_FOLDER='TheWeatherIet5'

# GitHub repository settings.
REPO_USER='Saiedf'
REPO_NAME='TheWeatherIet5'
REPO_BRANCH='main'

# IMPORTANT:
# Use URL encoding for spaces in GitHub raw paths.
# Example: VER 5.1  =>  VER%205.1
RELEASE_DIR='VER%205.1'

# Package folders inside the selected release directory.
# Packages are stored in the same folder as this installer.
DEB_DIR=''
IPK_DIR=''

# --------------------------------------------------------------
# DREAMBOX / DREAMOS (.deb) packages
# --------------------------------------------------------------
# Use the DM920 specific names if you have dedicated builds.
# If you have one common DreamOS package only, fill *_DEFAULT and leave the others empty.
DEB_DM920_PY2=''
DEB_DM920_PY3=''
DEB_DREAMBOX_PY2=''
DEB_DREAMBOX_PY3=''
DEB_DREAMOS_DEFAULT='enigma2-plugin-extensions-theweatheriet5_5.1_all.deb'

# --------------------------------------------------------------
# VU+ / VTi (.ipk) packages
# --------------------------------------------------------------
# Use the VTi specific names if you have dedicated builds.
# If you have one common VTi package only, fill *_DEFAULT and leave the others empty.
IPK_VTI_VUPLUS_PY2=''
IPK_VTI_VUPLUS_PY3=''
IPK_VTI_PY2=''
IPK_VTI_PY3=''
IPK_VTI_DEFAULT=''

# --------------------------------------------------------------
# OPENATV (.ipk) packages
# --------------------------------------------------------------
IPK_OPENATV_VUPLUS_PY2=''
IPK_OPENATV_VUPLUS_PY3=''
IPK_OPENATV_DM920_PY2=''
IPK_OPENATV_DM920_PY3=''
IPK_OPENATV_PY2=''
IPK_OPENATV_PY3=''
IPK_OPENATV_DEFAULT=''

# --------------------------------------------------------------
# OPEN SOURCE / OTHER IMAGES (.ipk) packages
# --------------------------------------------------------------
# Images covered here: OpenPLI / OpenSPA / OpenVIX / OpenBH / OpenHDF / OpenVision / Egami / TeamBlue / PurE2 / generic OE images.
IPK_OPENSOURCE_VUPLUS_PY2=''
IPK_OPENSOURCE_VUPLUS_PY3=''
IPK_OPENSOURCE_DM920_PY2=''
IPK_OPENSOURCE_DM920_PY3=''
IPK_OPENSOURCE_PY2=''
IPK_OPENSOURCE_PY3=''
IPK_OPENSOURCE_DEFAULT='enigma2-plugin-extensions-theweatheriet5_5.1_all.ipk'

# --------------------------------------------------------------
# Optional architecture-specific fallbacks (.ipk)
# --------------------------------------------------------------
IPK_ARM64=''
IPK_ARMHF=''
IPK_MIPS32EL=''
IPK_GENERIC=''

########################################################################################################################
# Auto ... Do not change
########################################################################################################################

say() {
	echo "$@"
}

have() {
	command -v "$1" >/dev/null 2>&1
}

to_lower() {
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

read_first_line() {
	for f in "$@"; do
		if [ -r "$f" ]; then
			sed -n '1p' "$f"
			return 0
		fi
	done
	return 1
}

detect_image_type() {
	INFO=''
	[ -r /etc/issue ] && INFO="$INFO $(cat /etc/issue 2>/dev/null)"
	[ -r /etc/image-version ] && INFO="$INFO $(cat /etc/image-version 2>/dev/null)"
	[ -r /etc/os-release ] && INFO="$INFO $(cat /etc/os-release 2>/dev/null)"
	[ -r /etc/vtiversion.info ] && INFO="$INFO $(cat /etc/vtiversion.info 2>/dev/null)"
	[ -r /etc/issue.net ] && INFO="$INFO $(cat /etc/issue.net 2>/dev/null)"

	INFO=$(to_lower "$INFO")

	case "$INFO" in
		*dreambox*|*dreamos*|*oe2.5*|*oe2.6*)
			echo 'dreamos'
			;;
		*vti*)
			echo 'vti'
			;;
		*openatv*)
			echo 'openatv'
			;;
		*openpli*)
			echo 'openpli'
			;;
		*openspa*)
			echo 'openspa'
			;;
		*openvix*)
			echo 'openvix'
			;;
		*openbh*|*blackhole*)
			echo 'openbh'
			;;
		*openhdf*)
			echo 'openhdf'
			;;
		*openvision*)
			echo 'openvision'
			;;
		*egami*)
			echo 'egami'
			;;
		*teamblue*)
			echo 'teamblue'
			;;
		*pure2*)
			echo 'pure2'
			;;
		*)
			if have dpkg; then
				echo 'dreamos'
			else
				echo 'opensource'
			fi
			;;
	esac
}

detect_box_model() {
	MODEL=''
	[ -z "$MODEL" ] && MODEL=$(read_first_line /proc/stb/info/boxtype)
	[ -z "$MODEL" ] && MODEL=$(read_first_line /proc/stb/info/model)

	if [ -z "$MODEL" ] && [ -r /proc/device-tree/model ]; then
		MODEL=$(tr -d '\000' < /proc/device-tree/model 2>/dev/null)
	fi

	[ -z "$MODEL" ] && MODEL=$(hostname 2>/dev/null)
	[ -z "$MODEL" ] && MODEL='unknown'

	echo "$MODEL" | tr ' ' '_' | tr '[:upper:]' '[:lower:]'
}

detect_device_family() {
	case "$BOX_MODEL" in
		dm920*|dm9*|dream*|dreambox*|one|two)
			echo 'dreambox'
			;;
		vu*|solo*|uno*|zero*|duo*|ultimo*)
			echo 'vuplus'
			;;
		*)
			echo 'generic'
			;;
	esac
}

detect_arch() {
	ARCH=''

	if have dpkg; then
		ARCH=$(dpkg --print-architecture 2>/dev/null)
	fi

	if [ -z "$ARCH" ] && have opkg; then
		ARCH=$(opkg print-architecture 2>/dev/null | awk '{print $2}' | tail -n 1)
	fi

	[ -z "$ARCH" ] && ARCH=$(uname -m 2>/dev/null)
	[ -z "$ARCH" ] && ARCH='unknown'

	echo "$ARCH" | tr '[:upper:]' '[:lower:]'
}

detect_python_cmd() {
	if have python3; then
		echo 'python3'
		return 0
	fi
	if have python2; then
		echo 'python2'
		return 0
	fi
	if have python; then
		echo 'python'
		return 0
	fi
	echo ''
}

detect_python_series() {
	if [ -z "$PYTHON_CMD" ]; then
		echo 'unknown'
		return 0
	fi

	PY_MAJOR=$($PYTHON_CMD -c 'import sys; sys.stdout.write(str(sys.version_info[0]))' 2>/dev/null)
	case "$PY_MAJOR" in
		2) echo 'py2' ;;
		3) echo 'py3' ;;
		*) echo 'unknown' ;;
	esac
}

detect_python_version() {
	if [ -z "$PYTHON_CMD" ]; then
		echo 'not-found'
		return 0
	fi

	$PYTHON_CMD -c 'import sys; sys.stdout.write("%d.%d" % (sys.version_info[0], sys.version_info[1]))' 2>/dev/null
}

is_opensource_image() {
	case "$IMAGE_TYPE" in
		openatv|openpli|openspa|openvix|openbh|openhdf|openvision|egami|teamblue|pure2|opensource)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

pick_deb_file() {
	# Dreambox DM920 specific selection.
	if [ "$BOX_MODEL" = 'dm920' ] || [ "$BOX_MODEL" = 'dm920uhd' ]; then
		if [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$DEB_DM920_PY2" ]; then
			echo "$DEB_DM920_PY2"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$DEB_DM920_PY3" ]; then
			echo "$DEB_DM920_PY3"
			return 0
		fi
	fi

	# Generic Dreambox / DreamOS selection.
	if [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$DEB_DREAMBOX_PY2" ]; then
		echo "$DEB_DREAMBOX_PY2"
		return 0
	fi
	if [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$DEB_DREAMBOX_PY3" ]; then
		echo "$DEB_DREAMBOX_PY3"
		return 0
	fi

	echo "$DEB_DREAMOS_DEFAULT"
}

pick_ipk_file() {
	# --------------------------------------------------------------
	# VTi image rules
	# --------------------------------------------------------------
	if [ "$IMAGE_TYPE" = 'vti' ]; then
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_VTI_VUPLUS_PY2" ]; then
			echo "$IPK_VTI_VUPLUS_PY2"
			return 0
		fi
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_VTI_VUPLUS_PY3" ]; then
			echo "$IPK_VTI_VUPLUS_PY3"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_VTI_PY2" ]; then
			echo "$IPK_VTI_PY2"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_VTI_PY3" ]; then
			echo "$IPK_VTI_PY3"
			return 0
		fi
		if [ -n "$IPK_VTI_DEFAULT" ]; then
			echo "$IPK_VTI_DEFAULT"
			return 0
		fi
	fi

	# --------------------------------------------------------------
	# OpenATV image rules
	# --------------------------------------------------------------
	if [ "$IMAGE_TYPE" = 'openatv' ]; then
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENATV_VUPLUS_PY2" ]; then
			echo "$IPK_OPENATV_VUPLUS_PY2"
			return 0
		fi
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENATV_VUPLUS_PY3" ]; then
			echo "$IPK_OPENATV_VUPLUS_PY3"
			return 0
		fi
		if { [ "$BOX_MODEL" = 'dm920' ] || [ "$BOX_MODEL" = 'dm920uhd' ]; } && [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENATV_DM920_PY2" ]; then
			echo "$IPK_OPENATV_DM920_PY2"
			return 0
		fi
		if { [ "$BOX_MODEL" = 'dm920' ] || [ "$BOX_MODEL" = 'dm920uhd' ]; } && [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENATV_DM920_PY3" ]; then
			echo "$IPK_OPENATV_DM920_PY3"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENATV_PY2" ]; then
			echo "$IPK_OPENATV_PY2"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENATV_PY3" ]; then
			echo "$IPK_OPENATV_PY3"
			return 0
		fi
		if [ -n "$IPK_OPENATV_DEFAULT" ]; then
			echo "$IPK_OPENATV_DEFAULT"
			return 0
		fi
	fi

	# --------------------------------------------------------------
	# Other open source image rules
	# --------------------------------------------------------------
	if is_opensource_image; then
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENSOURCE_VUPLUS_PY2" ]; then
			echo "$IPK_OPENSOURCE_VUPLUS_PY2"
			return 0
		fi
		if [ "$DEVICE_FAMILY" = 'vuplus' ] && [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENSOURCE_VUPLUS_PY3" ]; then
			echo "$IPK_OPENSOURCE_VUPLUS_PY3"
			return 0
		fi
		if { [ "$BOX_MODEL" = 'dm920' ] || [ "$BOX_MODEL" = 'dm920uhd' ]; } && [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENSOURCE_DM920_PY2" ]; then
			echo "$IPK_OPENSOURCE_DM920_PY2"
			return 0
		fi
		if { [ "$BOX_MODEL" = 'dm920' ] || [ "$BOX_MODEL" = 'dm920uhd' ]; } && [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENSOURCE_DM920_PY3" ]; then
			echo "$IPK_OPENSOURCE_DM920_PY3"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py2' ] && [ -n "$IPK_OPENSOURCE_PY2" ]; then
			echo "$IPK_OPENSOURCE_PY2"
			return 0
		fi
		if [ "$PYTHON_SERIES" = 'py3' ] && [ -n "$IPK_OPENSOURCE_PY3" ]; then
			echo "$IPK_OPENSOURCE_PY3"
			return 0
		fi
		if [ -n "$IPK_OPENSOURCE_DEFAULT" ]; then
			echo "$IPK_OPENSOURCE_DEFAULT"
			return 0
		fi
	fi

	# --------------------------------------------------------------
	# Architecture-based fallback
	# --------------------------------------------------------------
	case "$ARCH" in
		aarch64|arm64)
			[ -n "$IPK_ARM64" ] && { echo "$IPK_ARM64"; return 0; }
			;;
		arm*|cortexa*)
			[ -n "$IPK_ARMHF" ] && { echo "$IPK_ARMHF"; return 0; }
			;;
		mips*|mipsel|mips32el)
			[ -n "$IPK_MIPS32EL" ] && { echo "$IPK_MIPS32EL"; return 0; }
			;;
	esac

	# --------------------------------------------------------------
	# Final fallback
	# --------------------------------------------------------------
	if [ -n "$IPK_GENERIC" ]; then
		echo "$IPK_GENERIC"
		return 0
	fi

	echo "$IPK_OPENSOURCE_DEFAULT"
}

build_url() {
	BASE_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$REPO_BRANCH/$RELEASE_DIR"
	if [ -n "$PKG_SUBDIR" ]; then
		PKG_URL="$BASE_URL/$PKG_SUBDIR/$PKG_FILE"
	else
		PKG_URL="$BASE_URL/$PKG_FILE"
	fi
}

has_deb_support() {
	if have dpkg || have apt-get || have apt; then
		return 0
	fi
	return 1
}

has_ipk_support() {
	if have opkg; then
		return 0
	fi
	return 1
}

detect_installed_package() {
	OLD_VERSION=''
	OLD_MANAGER=''

	if have dpkg-query; then
		OLD_VERSION=$(dpkg-query -W -f='${Status} ${Version}\n' "$PACKAGE_NAME" 2>/dev/null | awk '/install ok installed/ {print $4}')
		if [ -n "$OLD_VERSION" ]; then
			OLD_MANAGER='dpkg'
			return 0
		fi
	fi

	if have opkg; then
		OLD_VERSION=$(opkg list-installed 2>/dev/null | awk -F ' - ' -v p="$PACKAGE_NAME" '$1==p {print $2; exit}')
		if [ -n "$OLD_VERSION" ]; then
			OLD_MANAGER='opkg'
			return 0
		fi
	fi

	return 1
}

normalize_answer() {
	printf '%s' "$1" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]'
}

find_old_plugin_paths() {
	FOUND_PATHS=''
	PLUGIN_EXTENSIONS_PATH="/usr/lib/enigma2/python/Plugins/Extensions/$PLUGIN_FOLDER"
	PLUGIN_SYSTEM_PATH="/usr/lib/enigma2/python/Plugins/SystemPlugins/$PLUGIN_FOLDER"

	if [ -d "$PLUGIN_EXTENSIONS_PATH" ]; then
		FOUND_PATHS="$FOUND_PATHS $PLUGIN_EXTENSIONS_PATH"
	fi

	if [ -d "$PLUGIN_SYSTEM_PATH" ]; then
		FOUND_PATHS="$FOUND_PATHS $PLUGIN_SYSTEM_PATH"
	fi

	echo "$FOUND_PATHS" | sed 's/^ *//'
}

remove_installed_package() {
	REMOVED_BY_MANAGER=0

	if [ -z "$OLD_VERSION" ]; then
		return 0
	fi

	if [ "$OLD_MANAGER" = 'dpkg' ] && have dpkg; then
		dpkg -r "$PACKAGE_NAME"
		REMOVED_BY_MANAGER=$?
	elif [ "$OLD_MANAGER" = 'opkg' ] && have opkg; then
		opkg remove "$PACKAGE_NAME"
		REMOVED_BY_MANAGER=$?
	elif have dpkg; then
		dpkg -r "$PACKAGE_NAME"
		REMOVED_BY_MANAGER=$?
	elif have opkg; then
		opkg remove "$PACKAGE_NAME"
		REMOVED_BY_MANAGER=$?
	else
		REMOVED_BY_MANAGER=1
	fi

	if [ $REMOVED_BY_MANAGER -ne 0 ]; then
		return $REMOVED_BY_MANAGER
	fi

	return 0
}

remove_old_plugin_paths() {
	PATH_REMOVE_RET=0
	OLD_PLUGIN_PATHS="$(find_old_plugin_paths)"

	if [ -z "$OLD_PLUGIN_PATHS" ]; then
		return 0
	fi

	for OLD_PLUGIN_PATH in $OLD_PLUGIN_PATHS; do
		if [ -d "$OLD_PLUGIN_PATH" ]; then
			say "Removing old plugin path: $OLD_PLUGIN_PATH"
			rm -rf "$OLD_PLUGIN_PATH"
			RET=$?
			if [ $RET -ne 0 ]; then
				PATH_REMOVE_RET=$RET
			fi
		fi
	done

	return $PATH_REMOVE_RET
}

confirm_old_version_removal() {
	OLD_PLUGIN_PATHS="$(find_old_plugin_paths)"

	if [ -z "$OLD_VERSION" ] && [ -z "$OLD_PLUGIN_PATHS" ]; then
		return 0
	fi

	say ''
	say '============================================================='
	say 'Old installed version or old plugin files detected.'
	say "Package : $PACKAGE_NAME"
	if [ -n "$OLD_VERSION" ]; then
		say "Version : $OLD_VERSION"
	else
		say 'Version : package manager entry not found'
	fi
	if [ -n "$OLD_PLUGIN_PATHS" ]; then
		say 'Old plugin paths found:'
		for OLD_PLUGIN_PATH in $OLD_PLUGIN_PATHS; do
			say " - $OLD_PLUGIN_PATH"
		done
	fi
	say '============================================================='

	while true; do
		printf 'Do you want to remove the old version and continue? [y/N]: '
		read ANSWER
		ANSWER=$(normalize_answer "$ANSWER")
		case "$ANSWER" in
			y|yes)
				say ''
				say 'Removing old version ...'
				remove_installed_package
				REMOVE_RET=$?
				if [ $REMOVE_RET -ne 0 ]; then
					say 'Failed to remove the old package. Installation aborted.'
					exit 1
				fi
				remove_old_plugin_paths
				REMOVE_PATH_RET=$?
				if [ $REMOVE_PATH_RET -ne 0 ]; then
					say 'Failed to remove old plugin files. Installation aborted.'
					exit 1
				fi
				return 0
				;;
			''|n|no)
				say 'Installation cancelled by user.'
				exit 0
				;;
			*)
				say 'Please answer with y or n.'
				;;
		esac
	done
}

download_package() {
	rm -f "$MY_TMP_FILE" >/dev/null 2>&1

	if have wget; then
		wget -T 20 -O "$MY_TMP_FILE" "$PKG_URL"
		return $?
	fi

	if have curl; then
		curl -L --connect-timeout 20 -o "$MY_TMP_FILE" "$PKG_URL"
		return $?
	fi

	say 'No downloader found. Please install wget or curl.'
	return 1
}

install_package() {
	if [ "$PKG_TYPE" = 'deb' ]; then
		if have dpkg; then
			dpkg -i --force-overwrite "$MY_TMP_FILE"
			INSTALL_RET=$?
			if have apt-get; then
				apt-get install -f -y >/dev/null 2>&1
			elif have apt; then
				apt install -f -y >/dev/null 2>&1
			fi
			return $INSTALL_RET
		fi

		if have apt-get; then
			apt-get install -y "$MY_TMP_FILE" >/dev/null 2>&1
			return $?
		fi

		if have apt; then
			apt install -y "$MY_TMP_FILE" >/dev/null 2>&1
			return $?
		fi

		return 1
	fi

	if have opkg; then
		opkg install --force-reinstall "$MY_TMP_FILE"
		return $?
	fi

	return 1
}

restart_enigma2() {
	if have systemctl; then
		sleep 2
		systemctl restart enigma2
	else
		init 4
		sleep 4 >/dev/null 2>&1
		init 3
	fi
}

# Detect image, hardware and Python runtime.
IMAGE_TYPE=$(detect_image_type)
BOX_MODEL=$(detect_box_model)
DEVICE_FAMILY=$(detect_device_family)
ARCH=$(detect_arch)
PYTHON_CMD=$(detect_python_cmd)
PYTHON_SERIES=$(detect_python_series)
PYTHON_VERSION=$(detect_python_version)

# Decide which package type to use.
PKG_TYPE=''
PKG_FILE=''
PKG_SUBDIR=''

# DreamOS / Dreambox images prefer .deb packages.
if [ "$IMAGE_TYPE" = 'dreamos' ] || [ "$DEVICE_FAMILY" = 'dreambox' ]; then
	if has_deb_support && [ -n "$(pick_deb_file)" ]; then
		PKG_TYPE='deb'
		PKG_FILE=$(pick_deb_file)
		PKG_SUBDIR="$DEB_DIR"
	elif has_ipk_support && [ -n "$(pick_ipk_file)" ]; then
		PKG_TYPE='ipk'
		PKG_FILE=$(pick_ipk_file)
		PKG_SUBDIR="$IPK_DIR"
	fi
else
	if has_ipk_support && [ -n "$(pick_ipk_file)" ]; then
		PKG_TYPE='ipk'
		PKG_FILE=$(pick_ipk_file)
		PKG_SUBDIR="$IPK_DIR"
	elif has_deb_support && [ -n "$(pick_deb_file)" ]; then
		PKG_TYPE='deb'
		PKG_FILE=$(pick_deb_file)
		PKG_SUBDIR="$DEB_DIR"
	fi
fi

# Validate package selection.
if [ -z "$PKG_FILE" ] || [ -z "$PKG_TYPE" ]; then
	say ''
	say 'No matching package was found for this image/device/Python combination.'
	say "Image         : $IMAGE_TYPE"
	say "Model         : $BOX_MODEL"
	say "Device family : $DEVICE_FAMILY"
	say "Architecture  : $ARCH"
	say "Python        : $PYTHON_VERSION"
	exit 1
fi

build_url
MY_TMP_FILE="/tmp/$PKG_FILE"
detect_installed_package
MY_SEP='============================================================='

say ''
say '************************************************************'
say '**                         STARTED                        **'
say '************************************************************'
say "** Plugin        : $PLUGIN_TITLE"
say "** Package       : $PACKAGE_NAME"
say "** Image         : $IMAGE_TYPE"
say "** Model         : $BOX_MODEL"
say "** Device family : $DEVICE_FAMILY"
say "** Architecture  : $ARCH"
say "** Python        : $PYTHON_VERSION"
say "** Package type  : $PKG_TYPE"
say "** Package file  : $PKG_FILE"
say '************************************************************'
say ''

# Search for a previously installed version and ask the user before removing it.
confirm_old_version_removal

# Remove previous downloaded file from /tmp.
rm -f "$MY_TMP_FILE" >/dev/null 2>&1

# Download package file.
say "$MY_SEP"
say "Downloading $PKG_FILE ..."
say "$PKG_URL"
say "$MY_SEP"
say ''

download_package
DOWNLOAD_RET=$?

# Check download.
if [ $DOWNLOAD_RET -eq 0 ] && [ -s "$MY_TMP_FILE" ]; then
	# Install selected package.
	say ''
	say "$MY_SEP"
	say 'Installation started'
	say "$MY_SEP"
	say ''

	install_package
	MY_RESULT=$?

	# Result.
	say ''
	say ''
	if [ $MY_RESULT -eq 0 ]; then
		say '>>>> SUCCESSFULLY INSTALLED <<<<'
		say ''
		say '>>>> RESTARTING ENIGMA2    <<<<'
		restart_enigma2
	else
		say '>>>> INSTALLATION FAILED! <<<<'
	fi
	say ''
	say '**************************************************'
	say '**                   FINISHED                   **'
	say '**************************************************'
	say ''
	exit $MY_RESULT
else
	say ''
	say 'Download failed!'
	say "URL: $PKG_URL"
	exit 1
fi
