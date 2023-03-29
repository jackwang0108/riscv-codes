#! /bin/sh

if [ -n "$1" ]; then
    folder=$1
else
    read -r -p "Name: " folder
    if [ -n "$folder" ]; then
        echo "----------------"
    else
        echo "Name of the folder cannot be empty!"
        exit
    fi
fi


echo "Name of the folder:" "$folder"
echo "Creating folder..."
cwd=$(cd "$(dirname "$0")" || exit; pwd)
echo "$cwd"/"$folder"
mkdir -p "$cwd"/"$folder"

echo "Creating files..."
touch "$cwd"/"$folder"/test.s
echo "Copying..."
cp "$cwd"/lui/Makefile "$cwd"/"$folder"

echo "Opening..."
code -r "$cwd"/"$folder"/test.s

echo "Changing working directory..."
cd "$cwd"/"$folder" ||exit 
