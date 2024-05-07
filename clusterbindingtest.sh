# Loop through ClusterRoles with extensive permissions
namespace="YOURNAMEPSACE"
for role in $(oc get clusterroles -n $namespace -o name | sed 's/clusterrole\///'); do
    echo "Checking ClusterRoleBindings for ClusterRole: $role"
    # Find ClusterRoleBindings that reference the ClusterRole
    rolebindings=$(oc get clusterrolebindings -o json | jq -r --arg role "$role" '.items[] | select(.roleRef.name==$role) | .metadata.name')
    if [ ! -z "$rolebindings" ]; then
        for rb in $rolebindings; do
            # Display the subjects of the ClusterRoleBinding
            echo "ClusterRoleBinding: $rb has the following subjects:"
            oc get clusterrolebinding $rb -o json | jq '.subjects'
        done
    else
        echo "No ClusterRoleBindings found for ClusterRole: $role"
    fi
done
