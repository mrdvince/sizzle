#!/bin/bash

SCHEME_NAME="sizzle"
BUNDLE_ID="me.mrdvince.sizzle"
WATCH_DIRS="sizzle sizzleTests"

# Function to get the simulator ID
get_simulator_id() {
    xcrun simctl list devices | grep 'iPhone 15 Pro (' | awk -F '[()]' '{print $2}'
}

# Function to build the app
build_app() {
    echo "Building the app..."
    xcodebuild -scheme "$SCHEME_NAME" -destination "platform=iOS Simulator,id=$SIMULATOR_ID" build
}

# Function to install and launch the app
install_and_launch() {
    # Find the path to the built app
    BUILD_DIR=$(xcodebuild -scheme "$SCHEME_NAME" -showBuildSettings | grep -m 1 ' BUILD_DIR' | sed 's/.*= //')
    APP_PATH="$BUILD_DIR/Debug-iphonesimulator/$SCHEME_NAME.app"

    echo "Build directory: $BUILD_DIR"
    echo "App path: $APP_PATH"

    if [ ! -d "$APP_PATH" ]; then
        echo "Error: App not found at $APP_PATH"
        return 1
    fi

    # Install the app on the simulator
    echo "Installing the app on the simulator..."
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

    # Launch the app if it's not already running
    if ! xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID" &> /dev/null; then
        echo "Launching the app..."
        xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"
    else
        echo "App is already running. Updating..."
    fi
}

# Function to update the app without restarting
update_app() {
    echo "Updating the app..."
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH" --replacingApp
}

# Main function to build and run the app
build_and_run() {
    SIMULATOR_ID=$(get_simulator_id)
    
    if [ -z "$SIMULATOR_ID" ]; then
        echo "Error: Could not find iPhone 15 Pro simulator."
        return 1
    fi

    # Boot the simulator if it's not already booted
    echo "Booting the simulator..."
    xcrun simctl bootstatus "$SIMULATOR_ID" -b

    build_app
    if [ $? -ne 0 ]; then
        echo "Build failed. Exiting."
        return 1
    fi

    install_and_launch
}

# Function to check if only Swift files were changed
only_swift_files_changed() {
    echo "$1" | grep -q "\.swift$"
    return $?
}

# Initial build and run
build_and_run

# Watch for file changes and trigger updates
echo "Watching for file changes in $WATCH_DIRS..."
fswatch -o $WATCH_DIRS | while read -r line; do
    echo "File change detected: $line"
    if only_swift_files_changed "$line"; then
        echo "Swift file changed. Performing hot reload..."
        build_app && update_app
    else
        echo "Non-Swift file changed. Rebuilding and relaunching..."
        build_and_run
    fi
done