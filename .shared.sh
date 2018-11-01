if [ -f .hostname ]; then
  HOSTNAME=$(cat "$D_R/.hostname")
else
  HOSTNAME=$1
fi

case $HOSTNAME in
  "")
    echo "You must give hostname as first param or setup .hostname file!!!"
    return 200
    ;;
esac

function echorun() {
  echo "$@"
  "$@" || return $?
}

function run() {
  echorun ssh "root@$HOSTNAME" "$@"
}

run opkg update
