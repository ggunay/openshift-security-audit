#!/bin/bash

# Define the namespace/project
namespace="YOURNAMEPSACE"

# Define overly permissive verbs to check for
verbs=("create" "delete" "update" "*")

echo "Checking for overly permissive ClusterRoles in the namespace: $namespace"

# Find RoleBindings in the namespace that reference ClusterRoles
rolebindings=$(oc get rolebindings -n $namespace -o json | jq -c '.items[] | select(.roleRef.kind=="ClusterRole") | {binding: .metadata.name, clusterRole: .roleRef.name}')

# Find ClusterRoleBindings that are applicable cluster-wide
clusterrolebindings=$(oc get clusterrolebindings -o json | jq -c '.items[] | select(.subjects[]? | .namespace=="'$namespace'") | {binding: .metadata.name, clusterRole: .roleRef.name}')

# Combine both sets of bindings
bindings="$rolebindings $clusterrolebindings"

# Loop through each binding to check associated ClusterRoles
echo "$bindings" | while read -r binding; do
    clusterRole=$(echo $binding | jq -r '.clusterRole')
    bindingName=$(echo $binding | jq -r '.binding')
    
    # For each ClusterRole, check if it contains overly permissive verbs
    for verb in "${verbs[@]}"; do
        # Extract rules that contain the overly permissive verbs
        matches=$(oc get clusterrole "$clusterRole" -o json | jq -c --arg verb "$verb" '.rules[] | select(.verbs[] | contains($verb))')
        if [[ ! -z "$matches" ]]; then
            echo "ClusterRoleBinding/RoleBinding: $bindingName refers to ClusterRole: $clusterRole which contains verb: $verb"
        fi
    done
done
