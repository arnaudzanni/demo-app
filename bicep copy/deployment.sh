az deployment group create -n container-app \
-g planetscore \
--template-file ./main.bicep \
-p containerImage=demo-app:2025 \
containerPort=8080