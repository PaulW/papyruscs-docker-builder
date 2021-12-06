#!/bin/bash
set -e
echo "Building Papyrus..."
echo "Cleaning any temporary files from previous builds..."
if [ -d "/source/build/.tmp" ]; then
  rm -rf /source/build/.tmp
fi

if [ -z ${BUILD_ENV} ]; then
  echo "Don't run this directly!  Let Docker handle it."
  exit 1
fi

mkdir /source/build/.tmp

echo "Cloning Repository..."
git clone https://github.com/papyrus-mc/papyruscs.git
cd papyruscs
echo "Pulling any PR's & such..."
echo "Please refer to the file git-patches.sh for info."
../git-patches.sh

echo "Building for ${BUILD_ENV^}..."
if [ "${BUILD_ENV}" == "linux" ]; then
  dotnet publish PapyrusCs -c Debug --self-contained --runtime linux-x64
  BUILT_EXT=".tar.gz"
elif [ "${BUILD_ENV}" == "windows" ]; then
  dotnet publish PapyrusCs -c Release --self-contained --runtime win-x64
  BUILT_EXT=".zip"
else
  echo "How did we get this far..."
  exit 1
fi

echo "Packaging..."

built_image="/source/build/papyruscs-$(date +%s)-${BUILD_ENV}-x64${BUILT_EXT}"

if [ "${BUILD_ENV}" == "linux" ]; then
  cp -aR /source/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish /source/build/.tmp/papyruscs
  tar czf ${built_image} --directory=/source/build/.tmp papyruscs
elif [ "${BUILD_ENV}" == "windows" ]; then
  cp -aR /source/papyruscs/PapyrusCs/bin/Release/netcoreapp3.1/win-x64/publish /source/build/.tmp/papyruscs
  cd /source/build/.tmp && zip -qr ${built_image} papyruscs && cd -
fi

rm -rf /source/build/.tmp

echo "Running Tests..."
../run-tests.sh

echo "Image compiled.  It has been saved as '${built_image}' and"
echo "is available in the output-linux folder."
