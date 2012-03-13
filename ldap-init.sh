#!/bin/sh

WORKSPACE="src"

LDAP_DEPLOYMENT_DIR="${WORKSPACE}/deployment/LDAP"
SLAPD_CONF="slapd.conf"
ORCHID_SCHEMA="orchid_declaration.schema"
ORCHID_LDIF="orchid_structure.ldif"

LDAP_CONF_DIR="/usr/local/etc/openldap"
LDAP_DATA_DIR="/usr/local/var/openldap-data"

if [ "$(id -u)" != "0" ]; then
    echo "You must be root to run this command." 1>&2
    exit 1
fi

cp ${LDAP_DEPLOYMENT_DIR}/${SLAPD_CONF} ${LDAP_CONF_DIR}/${SLAPD_CONF}
cp ${LDAP_DEPLOYMENT_DIR}/${ORCHID_SCHEMA} ${LDAP_CONF_DIR}/schema/${ORCHID_SCHEMA}

rm ${LDAP_DATA_DIR}/*
slapadd -v -l ${LDAP_DEPLOYMENT_DIR}/${ORCHID_LDIF}
