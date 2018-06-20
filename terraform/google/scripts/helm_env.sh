cert_dir=./certs
cert_subject="/C=US/ST=California/L=East Palo Alto/O=Lance Vick/OU=Personal/CN=lrvick.net"
gpg_key="6B61ECD76088748C70590D55E90A401336C8AAA9"

mkdir -p "${cert_dir}"

if [ ! -f "${cert_dir}/ca.key.pem.asc" ];then
	openssl genrsa -out "${cert_dir}/ca.key.pem" 4096
	gpg -ear "${gpg_key}" "${cert_dir}/ca.key.pem"
fi

if [ ! -f "${cert_dir}/ca.cert.pem" ];then
	openssl req \
		-new -x509 \
		-days 7300 \
		-sha256 \
		-extensions v3_ca \
		-key "${cert_dir}/ca.key.pem" \
		-out "${cert_dir}/ca.cert.pem" \
		-subj "${cert_subject}"
fi

if [ ! -f "${cert_dir}/tiller.key.pem.asc" ];then
	openssl genrsa -out "${cert_dir}/tiller.key.pem" 4096
	gpg -ear "${gpg_key}" "${cert_dir}/tiller.key.pem"
fi

if [ ! -f "${cert_dir}/tiller.csr.pem" ];then
	openssl req \
		-new \
		-sha256 \
		-subj "${cert_subject}" \
		-key "${cert_dir}/tiller.key.pem" \
		-out "${cert_dir}/tiller.csr.pem"
fi

if [ ! -f "${cert_dir}/tiller.cert.pem" ];then
	openssl x509 \
		-req \
		-days 365 \
		-CAcreateserial \
		-CA "${cert_dir}/ca.cert.pem" \
		-CAkey "${cert_dir}/ca.key.pem" \
		-in "${cert_dir}/tiller.csr.pem" \
		-out "${cert_dir}/tiller.cert.pem"
fi

if [ ! -f "${cert_dir}/helm.key.pem.asc" ];then
	openssl genrsa -out "${cert_dir}/helm.key.pem" 4096
	gpg -ear "${gpg_key}" "${cert_dir}/helm.key.pem"
fi

if [ ! -f "${cert_dir}/helm.csr.pem" ];then
	openssl req \
		-new \
		-sha256 \
		-subj "${cert_subject}" \
		-key "${cert_dir}/helm.key.pem" \
		-out "${cert_dir}/helm.csr.pem"
fi

if [ ! -f "${cert_dir}/helm.cert.pem" ];then
	openssl x509 \
		-req \
		-days 365 \
		-CAcreateserial \
		-CA "${cert_dir}/ca.cert.pem" \
		-CAkey "${cert_dir}/ca.key.pem" \
		-in "${cert_dir}/helm.csr.pem" \
		-out "${cert_dir}/helm.cert.pem"
fi

if [ -f "${cert_dir}/tiller.key.pem" ]; then
	helm init \
		--service-account tiller \
		--upgrade \
		--tiller-tls \
		--tiller-tls-verify \
		--tls-ca-cert "${cert_dir}/ca.cert.pem" \
		--tiller-tls-cert "${cert_dir}/tiller.cert.pem" \
		--tiller-tls-key "${cert_dir}/tiller.key.pem"
	rm "${cert_dir}/ca.key.pem"
	rm "${cert_dir}/tiller.key.pem"
	rm "${cert_dir}/helm.key.pem"
fi

source scripts/kube_env.sh

HELM_HOME="$(mktemp -d -p /dev/shm/)"
cp "${cert_dir}/ca.cert.pem" "${HELM_HOME}/"
cp "${cert_dir}/helm.cert.pem" "${HELM_HOME}/"
gpg -d "${cert_dir}/helm.key.pem.asc" > "${HELM_HOME}/helm.key.pem"
export HELM_HOME
