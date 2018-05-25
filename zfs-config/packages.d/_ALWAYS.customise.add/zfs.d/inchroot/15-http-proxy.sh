#
# If we have a proxy in the installer, copy that config into the target
#

# shellcheck disable=SC2154
# If used, the http_proxy variable is set earlier in the installer process
if [ -n "$http_proxy" ]; then
    echo "Acquire::http::Proxy \"$http_proxy\";" >/etc/apt/apt.conf.d/proxy
fi

