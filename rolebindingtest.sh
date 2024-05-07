# Replace <namespace> with your specific namespace/project name
namespace="YOURNAMEPSACE"

# Loop through roles with extensive permissions
for role in $(oc get roles -n $namespace -o name | sed 's/role\///'); do
    echo "Checking RoleBindings for role: $role"
    # Find RoleBindings that reference the role
    rolebindings=$(oc get rolebindings -n $namespace -o json | jq -r --arg role "$role" '.items[] | select(.roleRef.name==$role) | .metadata.name')
    if [ ! -z "$rolebindings" ]; then
        for rb in $rolebindings; do
            # Display the subjects of the RoleBinding
            echo "RoleBinding: $rb has the following subjects:"
            oc get rolebinding $rb -n $namespace -o json | jq '.subjects'
        done
    else
        echo "No RoleBindings found for role: $role"
    fi
done
