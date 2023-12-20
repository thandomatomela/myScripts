#!/bin/bash

# Function to get all nodes
get_all_nodes() {
    kubectl get nodes --no-headers | awk '{print $1}'
}

# Get all nodes
ALL_NODES=($(get_all_nodes))

# Arrays to store CPU and memory usage data
declare -A CPU_USAGE
declare -A MEMORY_USAGE

for node in "${ALL_NODES[@]}"
do
    cpu=$(kubectl top node $node | awk 'NR==2 {print $3}')
    memory=$(kubectl top node $node | awk 'NR==2 {print $2}')
    
    CPU_USAGE["$node"]=$cpu
    MEMORY_USAGE["$node"]=$memory

    echo "Resource usage for $node - CPU: $cpu, Memory: $memory"
done

# Function to sort nodes by CPU or memory usage
sort_nodes_by_usage() {
    declare -n usage_array=$1

    echo "Nodes sorted by $2 usage:"
    for node in "${!usage_array[@]}"
    do
        echo "$node - $2: ${usage_array["$node"]}"
    done | sort -k4 -nr
}

# Sort nodes by CPU and memory usage separately
sort_nodes_by_usage CPU_USAGE "CPU"
sort_nodes_by_usage MEMORY_USAGE "Memory"

# Calculate combined CPU and memory usage for each node
COMBINED_USAGE=()
for node in "${ALL_NODES[@]}"
do
    cpu=${CPU_USAGE["$node"]}
    memory=${MEMORY_USAGE["$node"]}
    total=$(echo "$cpu + $memory" | bc)
    COMBINED_USAGE["$node"]=$total
done

# Sort nodes by combined CPU and memory usage
echo "Nodes sorted by combined CPU and memory usage:"
for node in "${!COMBINED_USAGE[@]}"
do
    echo "$node - Combined: ${COMBINED_USAGE["$node"]}"
done | sort -k4 -nr
