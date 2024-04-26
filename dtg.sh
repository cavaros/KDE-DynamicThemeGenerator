#!/bin/sh
echo "---------- Dynamic Theme Generator ----------"

## Select images and store it to variables
kdialog --title "Dynamic Theme Generator - Light Theme" --msgbox "A file picker will open and you'll need to select the LIGHT image"
lightImagePath=$(kdialog --getopenfilename $HOME)
lightImageExtension=$(echo "${lightImagePath##*.}")

kdialog --title "Dynamic Theme Generator - Dark Theme" --msgbox "A file picker will open and you'll need to select the DARK image"
darkImagePath=$(kdialog --getopenfilename $HOME)
darkImageExtension=$(echo "${darkImagePath##*.}")

## Show input to user to write the theme name
while [ ! "$themeName" ]
do
    themeName=$(kdialog --title "Dynamic Theme Generator - Theme name" --inputbox "What name would you like to use?" "DynamicTheme")
    if [ ! "$themeName" ]; then
        kdialog --error "Name should not be empty!"
    fi
done

## Get screen resolution
screenResolution=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')

## Show progressbar - First step
dbusRef=`kdialog --title "Dynamic Theme Generator - Generating Files" --progressbar "Generating the metadata file" 3`
qdbus $dbusRef Set "" value 1

## Remove old wallpaper if wallpaper with same name exists
wallpaperPath="/usr/share/wallpapers/$themeName"

## Show input to user to write the password
while [ ! "$password" ]
do
    password=$(kdialog --title "Dynamic Theme Generator - Password" --password "Please enter the password")
    if [ ! "$password" ]; then
        kdialog --error "Password should not be empty!"
    fi
done
## Create Metadata file
echo $password | sudo -S rm -rf $wallpaperPath
echo $password | sudo -S mkdir -p "$wallpaperPath"
echo $password | sudo -S touch "$wallpaperPath/metadata.json"

## Write in Metadata file
echo $password | sudo -S tee "$wallpaperPath/metadata.json" > /dev/null <<EOT
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "Dynamic Theme Generator"
            }
        ],
        "Id": "$themeName",
        "License": "GPLv2",
        "Name": "$themeName"
    }
}
EOT


## Show progressbar - Second step
qdbus $dbusRef setLabelText "Creating folders and copying the LIGHT image"
qdbus $dbusRef Set "" value 2

## Copy LIGHT image
lightImageFolder="$wallpaperPath/contents/images"
echo $password | sudo -S mkdir -p "$lightImageFolder"
echo $password | sudo -S cp "$lightImagePath" "$lightImageFolder/$screenResolution.$lightImageExtension"

## Show progressbar - Third step
qdbus $dbusRef setLabelText "Creating folders and copying the DARK image"
qdbus $dbusRef Set "" value 3

## Copy DARK image
darkImageFolder="$wallpaperPath/contents/images_dark"
echo $password | sudo -S mkdir -p "$darkImageFolder"
echo $password | sudo -S cp "$darkImagePath" "$darkImageFolder/$screenResolution.$darkImageExtension"

## Close progressbar
qdbus $dbusRef close

### Final message
kdialog --title "Dynamic Theme Generator - Final" --msgbox "The wallpaper was successfully generated."
