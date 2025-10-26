# implement ensure_apt function

function ensure_apt() {
	pack=$1

	if apt list 2>/dev/null | grep -q $pack
	then
		echo "$pack is already installed"
	else
		echo "Installing $pack"
		apt install -y $pack
	fi
}
