# implement ensure_apt function

function ensure_apt() {
	pack=$1

	if dpkg -l "$pack" 2>/dev/null | grep -q "^ii"
	then
		echo "$pack is already installed"
	else
		echo "Installing $pack"
		apt install -y $pack
	fi
}
