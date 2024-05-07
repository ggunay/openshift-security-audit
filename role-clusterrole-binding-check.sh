#!/bin/bash

NAMESPACE="YOURNAMEPSACE"

# Loop through all pods in the namespace
for POD in $(oc get pods -n $NAMESPACE -o=jsonpath='{.items[*].metadata.name}'); do
    echo "Pod: $POD"

    SERVICE_ACCOUNT=$(oc get pod $POD -n $NAMESPACE -o=jsonpath='{.spec.serviceAccountName}')
    echo "  ServiceAccount: $SERVICE_ACCOUNT"

    # Attempt to find RoleBindings or ClusterRoleBindings
    ROLEBINDINGS=$(oc get rolebindings -n $NAMESPACE -o=json | jq -r --arg SA "$SERVICE_ACCOUNT" '.items[] | select(.subjects[]? | .kind == "ServiceAccount" and .name == $SA) | .metadata.name' 2>/dev/null)
    
    if [ -z "$ROLEBINDINGS" ]; then
        ROLEBINDINGS=$(oc get clusterrolebindings -o=json | jq -r --arg SA "$SERVICE_ACCOUNT" --arg NS "$NAMESPACE" '.items[] | select(.subjects[]? | .kind == "ServiceAccount" and .name == $SA and .namespace == $NS) | .metadata.name' 2>/dev/null)
    fi

    # Check if ROLEBINDINGS is empty; continue to next pod if it is
    if [ -z "$ROLEBINDINGS" ]; then
        echo "    No explicit RoleBindings or ClusterRoleBindings found."
        continue
    fi

    for ROLEBINDING in $ROLEBINDINGS; do
        echo "    RoleBinding: $ROLEBINDING"

        # Fetch Role or ClusterRole name and kind
        ROLE_INFO=$(oc get rolebinding $ROLEBINDING -n $NAMESPACE -o=jsonpath='{.roleRef.kind} {.roleRef.name}' 2>/dev/null)
        if [ -z "$ROLE_INFO" ]; then
            ROLE_INFO=$(oc get clusterrolebinding $ROLEBINDING -o=jsonpath='{.roleRef.kind} {.roleRef.name}' 2>/dev/null)
        fi
        
        ROLE_KIND=$(echo $ROLE_INFO | cut -d' ' -f1)
        ROLE_NAME=$(echo $ROLE_INFO | cut -d' ' -f2)
        echo "      Role/ClusterRole: $ROLE_NAME (Kind: $ROLE_KIND)"

        # Correctly processing verbs as arrays and avoiding '*' issue
        if [[ "$ROLE_KIND" == "Role" ]]; then
            VERBS=$(oc get role $ROLE_NAME -n $NAMESPACE -o=json | jq -r '.rules[].verbs | @csv' 2>/dev/null)
        else
            VERBS=$(oc get clusterrole $ROLE_NAME -o=json | jq -r '.rules[].verbs | @csv' 2>/dev/null)
        fi

        echo "        Verbs: $VERBS"
    done
done
