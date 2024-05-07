#!/bin/bash

# Specify your namespace here
NAMESPACE="YOURNAMEPSACE"

# Commands to check inside the container
commands_to_check=("python" "python3" "wget" "curl" "socat" "nc" "netcat")

# Possible shells to try
shells=("/bin/sh" "/bin/bash")

# Get all pods in the namespace
pods=$(oc get pods -n $NAMESPACE -o=jsonpath='{.items[*].metadata.name}')

for pod in $pods; do
    echo "Inspecting pod: $pod"
    containers=$(oc get pod "$pod" -n $NAMESPACE -o=jsonpath='{.spec.containers[*].name}')

    for container in $containers; do
        echo "  Container: $container"

        # Try to connect using different shells
        for shell in "${shells[@]}"; do
            if oc exec "$pod" -n "$NAMESPACE" -c "$container" -- $shell -c 'echo shell_success' 2>/dev/null; then
                echo "    Success with shell: $shell"

                # Check for specific commands
                for cmd in "${commands_to_check[@]}"; do
                    if oc exec "$pod" -n "$NAMESPACE" -c "$container" -- $shell -c "command -v $cmd" 2>/dev/null; then
                        echo "      Command available: $cmd"
                    fi
                done
                
                # Break the loop after successful shell connection
                break
            else
                echo "    Failed to connect with $shell"
            fi
        done
    done
done
