namespace="YOURNAMEPSACE"

for role in $(oc get roles -n $namespace -o name); do
    oc get $role -n $namespace -o json | jq '. | select(.rules[] | .verbs[] | contains("create", "delete", "update"))'
done
