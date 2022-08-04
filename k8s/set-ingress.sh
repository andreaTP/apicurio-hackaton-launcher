
# ingress should be enabled:
# minikube addons enable ingress

# on Mac you should use localhost and minikube tunnel
sed "s/KEYCLOAK_HOST/keycloak.$(minikube ip).nip.io/"
