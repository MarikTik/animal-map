output=$(adb devices | awk '{ if ($1 ~ /emulator/) print $1}')

if [ -z "$output" ]; then
    emulator_list=$(flutter emulators | awk '/Pixel_/ { print $1; exit }')
    flutter emulators --launch $emulator_list
fi

output=$(adb devices | awk '{ if ($1 ~ /emulator/) print $1}')

flutter run -d $output
