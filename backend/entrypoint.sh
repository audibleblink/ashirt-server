#!/bin/bash

set -eo pipefail
shopt -s nullglob


# logging functions
log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}
note() {
	log Note "$@"
}
warn() {
	log Warn "$@" >&2
}
error() {
	log ERROR "$@" >&2
	exit 1
}


# usage: file_env <VAR> [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		error "Both $var and $fileVar are set (but are exclusive)"
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}


# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}


_main() {
	note "Entrypoint script for MySQL Server ${MYSQL_VERSION} started."
	file_env DB_URI
	file_env APP_CSRF_AUTH_KEY
	file_env APP_SESSION_STORE_KEY
	exec "$@"
}

# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi
