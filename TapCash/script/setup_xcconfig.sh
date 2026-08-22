#!/bin/bash

# Emojis/Colors for beautiful terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Target directory and Zip file paths (relative to script location, going up one level to TapCash)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$PARENT_DIR/XCConfig"
ZIP_FILE="$PARENT_DIR/XCConfig.zip"

echo -e "${BOLD}${BLUE}===================================================${NC}"
echo -e "${BOLD}${BLUE}           LOCAL XCCONFIG SETUP SCRIPT             ${NC}"
echo -e "${BOLD}${BLUE}===================================================${NC}"

# 1. Check if XCConfig.zip exists
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${BOLD}${RED}Error: Berkas 'XCConfig.zip' tidak ditemukan!${NC}"
    echo -e ""
    echo -e "${YELLOW}Panduan Peletakan Berkas ZIP:${NC}"
    echo -e "  1. Cari berkas ${BOLD}XCConfig.zip${NC} yang Anda miliki."
    echo -e "  2. Letakkan berkas tersebut sejajar dengan file proyek ${BOLD}TapCash.xcodeproj${NC}."
    echo -e "     Target lokasi: ${BOLD}$PARENT_DIR/XCConfig.zip${NC}"
    echo -e "  3. Jalankan kembali script ini."
    echo -e ""
    echo -e "${BOLD}${BLUE}===================================================${NC}"
    exit 1
fi

# 2. Check if TARGET_DIR already exists
BACKUP_DIR=""
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Pemberitahuan: Folder XCConfig sudah ada secara lokal.${NC}"
    read -p "Apakah Anda ingin menggantinya dengan yang baru dari ZIP? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo -e "${BLUE}▶ Menyiapkan penggantian folder XCConfig lama...${NC}"
            # Create a backup directory using timestamp
            BACKUP_DIR="${TARGET_DIR}_backup_$(date +%s)"
            mv "$TARGET_DIR" "$BACKUP_DIR"
            echo -e "  ${GREEN}✓ Folder lama berhasil dicadangkan ke: $(basename "$BACKUP_DIR")${NC}"
            ;;
        *)
            echo -e "${GREEN}Proses dibatalkan. Menggunakan konfigurasi yang sudah ada.${NC}"
            echo -e "${BOLD}${BLUE}===================================================${NC}"
            exit 0
            ;;
    esac
fi

# 3. Create a temporary folder for unzipping
TEMP_DIR="${TARGET_DIR}_temp_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo -e "${BLUE}▶ Mengekstrak berkas XCConfig.zip...${NC}"
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"
UNZIP_STATUS=$?

if [ $UNZIP_STATUS -ne 0 ]; then
    echo -e "${BOLD}${RED}✗ Error: Gagal mengekstrak berkas ZIP!${NC}"
    # 4. Rollback / recover if failed
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}▶ Mengembalikan folder XCConfig lama...${NC}"
        mv "$BACKUP_DIR" "$TARGET_DIR"
    fi
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    echo -e "${BOLD}${BLUE}===================================================${NC}"
    exit 1
fi

# 5. Find the folder containing .xcconfig files inside TEMP_DIR (ignoring macOS __MACOSX metadata)
CONFIG_SRC_FILE=$(find "$TEMP_DIR" -not -path "*/__MACOSX*" -name "*.xcconfig" ! -name "._*" -print -quit 2>/dev/null)

if [ -n "$CONFIG_SRC_FILE" ]; then
    CONFIG_FOLDER=$(dirname "$CONFIG_SRC_FILE")
    mkdir -p "$TARGET_DIR"
    mv "$CONFIG_FOLDER"/* "$TARGET_DIR"/ 2>/dev/null
    echo -e "  ${GREEN}✓ Berkas .xcconfig berhasil diekstrak ke: $TARGET_DIR${NC}"
else
    echo -e "${BOLD}${RED}✗ Error: Tidak ada file .xcconfig yang ditemukan di dalam ZIP!${NC}"
    # Rollback / recover if failed
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}▶ Mengembalikan folder XCConfig lama...${NC}"
        mv "$BACKUP_DIR" "$TARGET_DIR"
    fi
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    echo -e "${BOLD}${BLUE}===================================================${NC}"
    exit 1
fi

# Cleanup temp folder and backup folder
rm -rf "$TEMP_DIR"
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
    echo -e "  ${GREEN}✓ File backup sementara berhasil dibersihkan.${NC}"
fi

# 6. Cleaning Xcode Caches and Derived Data
echo -e "${BLUE}▶ Membersihkan cache Xcode dan Derived Data...${NC}"

# Clear Derived Data selectively to prevent SPM checkout conflicts
DERIVED_DATA_DIR=~/Library/Developer/Xcode/DerivedData
if [ -d "$DERIVED_DATA_DIR" ]; then
    echo -e "  - Menghapus Build & Indexing cache untuk TapCash..."
    rm -rf "$DERIVED_DATA_DIR"/TapCash-*/Build
    rm -rf "$DERIVED_DATA_DIR"/TapCash-*/Index.noindex
    echo -e "  ${GREEN}✓ Cache build berhasil dibersihkan.${NC}"
else
    echo -e "  - Folder Derived Data tidak ditemukan. Lewati."
fi

# Clean Build Folder and Resolve Package Dependencies
if command -v xcodebuild &> /dev/null; then
    echo -e "${BLUE}▶ Memperbarui dan menyelesaikan Package Dependencies...${NC}"
    xcodebuild -project "$PARENT_DIR/TapCash.xcodeproj" -resolvePackageDependencies -quiet
    echo -e "  ${GREEN}✓ Package Dependencies selesai diselaraskan.${NC}"

    echo -e "${BLUE}▶ Melakukan Clean Build Folder di Xcode...${NC}"
    xcodebuild -project "$PARENT_DIR/TapCash.xcodeproj" -alltargets clean -quiet
    echo -e "  ${GREEN}✓ Clean Build Folder selesai.${NC}"
else
    echo -e "${YELLOW}Pemberitahuan: Perintah 'xcodebuild' tidak ditemukan. Lewati clean build dan resolve packages.${NC}"
fi

echo -e ""
echo -e "${BOLD}${GREEN}===================================================${NC}"
echo -e "${BOLD}${GREEN}   SUKSES: XCConfig Siap Digunakan di Xcode!       ${NC}"
echo -e "${BOLD}${GREEN}===================================================${NC}"
