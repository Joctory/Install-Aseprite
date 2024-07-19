#!/bin/bash

# Must have git, homebrew, and xcode to install
# Install brew using this command /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install git using this command (brew install git)


# Make sure to change line 29 according to your mac OS

# Install ninja compiler
brew install ninja

# Install CMake for makefile
brew install cmake

# Install prebuilt version of Skia for 2D graphic libraries
cd $HOME
mkdir deps
cd deps
mkdir skia
cd skia
curl -L https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-macOS-Release-arm64.zip | tar zx

# Install aseprite at $HOME/aseprite
cd $HOME
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite
mkdir build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.1 \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-arm64 \
  -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-arm64/libskia.a \
  -DPNG_ARM_NEON:STRING=on \
  -G Ninja \
  ..
  ninja aseprite

# Start aseprite
$HOME/aseprite/build/bin/aseprite

# Merge the data into Aseprite trial
mkdir bundle
cd bundle
curl -O -J "https://www.aseprite.org/downloads/trial/Aseprite-v1.3.6-trial-macOS.dmg"
mkdir mount
yes qy | hdiutil attach -quiet -nobrowse -noverify -noautoopen -mountpoint mount Aseprite-v1.3.4-trial-macOS.dmg
cp -rf mount/Aseprite.app .
hdiutil detach mount
rm -rf Aseprite.app/Contents/MacOS/aseprite
cp -rf ../aseprite/build/bin/aseprite Aseprite.app/Contents/MacOS/aseprite
rm -rf Aseprite.app/Contents/Resources/data
cp -rf ../aseprite/build/bin/data Aseprite.app/Contents/Resources/data
cd ..

# Install on /Applications
sudo cp bundle/Aseprite.app /Applications/
