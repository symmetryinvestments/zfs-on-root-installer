#
# If we have a proxy in the installer, copy that config into the target
#

if [ -n "$http_proxy" ]; then
    echo "Acquire::http::Proxy \"$http_proxy\";" >/etc/apt/apt.conf.d/proxy
fi

