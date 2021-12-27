-include secret.mk

SHELL=bash

repo-update:
	set -e; \
	helm repo add k8s-at-home https://k8s-at-home.com/charts; \
	helm repo add k8s-at-home-library https://library-charts.k8s-at-home.com; \
        helm repo add grafana https://grafana.github.io/helm-charts; \
	helm repo add influxdata https://helm.influxdata.com/; \
	helm repo add metallb https://metallb.github.io/metallb; \
	helm repo update

install-metallb:
	helm upgrade --install metallb metallb/metallb -f config/metallb.yaml

install-traefik-forward-auth:
	helm upgrade --install traefik-forward-auth k8s-at-home/traefik-forward-auth -f config/traefik-forward-auth.yaml --set providers.oidc.clientSecret="$$GOOGLE_AUTH_SECRET",restrictions.whitelist="$$ALLOWED_EMAILS"

install-zigbee2mqtt:
	helm upgrade --install zigbee2mqtt k8s-at-home/zigbee2mqtt -f config/zigbee2mqtt.yaml

install-mosquitto:
	helm upgrade --install mosquitto k8s-at-home/mosquitto

install-home-assistant:
	helm upgrade --install home-assistant k8s-at-home/home-assistant -f config/home-assistant.yaml

install-mqtt2influx:
	helm upgrade --install mqtt2influx influxdata/telegraf -f config/mqtt2influx.yaml

install-grafana:
	helm upgrade --install grafana grafana/grafana -f config/grafana.yaml

dependency-whoami:
	helm dependency build whoami

install-whoami: dependency-whoami
	helm upgrade --install whoami whoami -f config/whoami.yaml

install-photoprism:
	helm upgrade --install photoprism k8s-at-home/photoprism --set env.PHOTOPRISM_ADMIN_PASSWORD="$$PHOTOPRISM_ADMIN_PASSWORD" -f config/photoprism.yaml

dependency-http-static:
	helm dependency build http-static

install-http-static:
	helm upgrade --install http-static http-static -f config/http-static.yaml --set "$$HTTP_STATIC_EXTRA"

install-unifi-controller:
	# Hack to patch services to not allocate NodePorts, but still use k8s-at-home implementation
	kubectl apply -f <(helm template unifi k8s-at-home/unifi -f config/unifi.yaml | yq e '(select(.spec.type == "LoadBalancer") | .spec.allocateLoadBalancerNodePorts) = false' -)

install-infra: install-metallb install-traefik-forward-auth
install-iot: install-zigbee2mqtt install-mosquitto install-home-assistant install-mqtt2influx install-grafana
install-all: install-infra install-iot install-whoami install-photoprism install-http-static
