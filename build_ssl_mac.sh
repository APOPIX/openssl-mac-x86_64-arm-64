#!/bin/bash
WORKING_DIR="$PWD";
ARCHS="i386 x86_64 arm64";

for ARCH in ${ARCHS}; do
    echo "================== Compling $ARCH ==================";
    echo "Building pbc for ${ARCH}";
    echo "Please stand by...";
   
    if [ -e "$WORKING_DIR/build-$ARCH" ]; then
        rm -rf "$WORKING_DIR/build-$ARCH";
    fi
    mkdir -p "$WORKING_DIR/build-$ARCH";
    if [ "${ARCH}" == "arm64" ]; then
        ./Configure darwin64-arm64-cc-mac --prefix="$WORKING_DIR/build-$ARCH" no-asm
    elif [ "${ARCH}" == "x86_64" ]; then
        ./Configure darwin64-x86_64-cc --prefix="$WORKING_DIR/build-$ARCH"
    elif [ "${ARCH}" == "i386" ]; then
        ./Configure darwin-i386-cc --prefix="$WORKING_DIR/build-$ARCH"
    fi
    make clean
    make -j8
    make install
done

cd "$WORKING_DIR";
echo "Linking and packaging library...";

if [ -e "$WORKING_DIR/result/lib" ]; then
    rm -rf "$WORKING_DIR/result/lib";
fi
mkdir -p "$WORKING_DIR/result/lib";

if [ -e "$WORKING_DIR/result/include" ]; then
    rm -rf "$WORKING_DIR/result/include";
fi
mkdir -p "$WORKING_DIR/result/include";


for LIB_NAME in "libssl.a" "libcrypto.a"; do
    LIB_FOUND=($(find build-*/lib -name $LIB_NAME));
    if [ ${#LIB_FOUND} -gt 0 ]; then
        if [ -e "prebuilt/lib/$LIB_NAME" ]; then
            rm -rf "prebuilt/lib/$LIB_NAME";
        fi
        echo "Run: lipo -create ${LIB_FOUND[@]} -output \"result/lib/$LIB_NAME\"";
        lipo -create ${LIB_FOUND[@]} -output "$WORKING_DIR/result/lib/$LIB_NAME";
        echo "lib: $LIB_NAME built.";
    fi
done


for ARCH in ${ARCHS}; do
    echo "================== Copy headers for $ARCH ==================";
    cp -rf "$WORKING_DIR/build-$ARCH/include/openssl/" "$WORKING_DIR/result/include/"
done