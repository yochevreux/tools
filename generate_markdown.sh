#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 branch1 branch2 [filter]"
    echo "filter options: A (additions), D (deletions), U (updates), or ALL (all changes)"
    echo "Optional: You can add an additional string to filter lines."
    exit 1
fi

# Example:
# ./generate_markdown.sh main feature-branch U "GC_CONS"

branch1=$1
branch2=$2
filter=$3
string_filter=$4

# Redirect output to a file
output_file="filtered_changes_in_branch2.md"

# Add the header for the markdown table
echo "| TYPE | COMPOSANT | ACTION (CUD) | COMMENTAIRE |" > $output_file
echo "| --- | --- | --- | --- |" >> $output_file

# Determine the git diff filter based on the user input
case "$filter" in
    A)
        diff_filter="A"
        ;;
    D)
        diff_filter="D"
        ;;
    U)
        diff_filter="M"
        ;;
    ALL)
        diff_filter="ADM"
        ;;
    *)
        echo "Invalid filter option. Use A, D, U, or ALL."
        exit 1
        ;;
esac

# Get the list of files that match the filter in branch2 relative to branch1
git diff --name-status "$branch1" "$branch2" | grep -E "^[$diff_filter]" | while read status file; do
    # Apply additional string filtering if provided
    if [ -n "$string_filter" ] && [[ "$file" != *"$string_filter"* ]]; then
        continue
    fi

    # Determine the component type and format the component name
    if [[ "$file" == *".cls"* ]]; then
        TYPE="Apex Class"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".field-meta.xml"* ]]; then
        TYPE="Custom Field"
        object_name=$(basename "$(dirname "$(dirname "$file")")")
        field_name=$(basename "$file")
        COMPONENT="$object_name - $field_name"
    elif [[ "$file" == *".layout-meta.xml" ]]; then
        TYPE="Layout"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".email"* ]]; then
        TYPE="Email"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".flexipage-meta.xml" ]]; then
        TYPE="Flexipage"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".app-meta.xml" ]]; then
        TYPE="Application"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".md-meta.xml" ]]; then
        TYPE="Custom Metadata"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".flow-meta.xml" ]]; then
        TYPE="Flow"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".globalValueSet-meta.xml" ]]; then
        TYPE="Global Value Set"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".object-meta.xml" ]]; then
        TYPE="Custom Object"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".listView-meta.xml" ]]; then
        TYPE="List View"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".validationRule-meta.xml" ]]; then
        TYPE="Validation Rule"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".compactLayout-meta.xml" ]]; then
        TYPE="Compact Layout"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".recordType-meta.xml" ]]; then
        TYPE="Record Type"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".permissionset-meta.xml" ]]; then
        TYPE="Permission Set"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".tab-meta.xml" ]]; then
        TYPE="Custom Tab"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".profile-meta.xml" ]]; then
        TYPE="Profile"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".trigger"* ]]; then
        TYPE="Trigger"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".standardValueSet-meta.xml" ]]; then
        TYPE="Standard Value Set"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *"/lwc/"* ]]; then
        TYPE="Lightning Web Component"
        lwc_name=$(basename "$(dirname "$file")")
        lwc_file=$(basename "$file")
        COMPONENT="$lwc_name - $lwc_file"
    elif [[ "$file" == *".page"* ]]; then
        TYPE="Visualforce Page"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".permissionsetgroup-meta.xml" ]]; then
        TYPE="Permission Set Group"
        COMPONENT=$(basename "$file")
    elif [[ "$file" == *".webLink-meta.xml" ]]; then
        TYPE="Web Link"
        COMPONENT=$(basename "$file")
    # Add more conditions for other types as needed
    else
        TYPE="Other"
        COMPONENT=$(basename "$file")
    fi

    # Determine the action based on the git diff status
    if [[ "$status" == "A" ]]; then
        ACTION="C" # Created in branch2
    elif [[ "$status" == "M" ]]; then
        ACTION="U" # Modified in branch2
    elif [[ "$status" == "D" ]]; then
        ACTION="D" # Deleted in branch2
    fi

    # Print the formatted Markdown table row to the output file
    echo "| $TYPE | $COMPONENT | $ACTION | |" >> $output_file
done

echo "Markdown table generated in $output_file"
