#!/bin/bash

# Target directory and Zip file paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/XCConfig"
ZIP_FILE="$SCRIPT_DIR/XCConfig.zip"

echo "=== Local XCConfig Setup Script ==="

# 1. Check if XCConfig.zip exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: Berkas '$ZIP_FILE' tidak ditemukan!"
    echo "Silakan copy-paste berkas 'XCConfig.zip' ke folder yang sama dengan script ini terlebih dahulu."
    exit 1
fi

# 2. Check if TARGET_DIR already exists
BACKUP_DIR=""
if [ -d "$TARGET_DIR" ]; then
    echo "Folder XCConfig sudah ada secara lokal."
    read -p "Apakah Anda ingin menggantinya dengan yang baru dari ZIP? (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo "Menyiapkan penggantian folder XCConfig lama..."
            # Create a backup directory using timestamp
            BACKUP_DIR="${TARGET_DIR}_backup_$(date +%s)"
            mv "$TARGET_DIR" "$BACKUP_DIR"
            echo "Folder lama telah dibackup sementara ke: $(basename "$BACKUP_DIR")"
            ;;
        *)
            echo "Proses dibatalkan. Menggunakan konfigurasi yang sudah ada."
            exit 0
            ;;
    esac
fi

# 3. Create a temporary folder for unzipping
TEMP_DIR="${TARGET_DIR}_temp_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "Mengekstrak berkas XCConfig.zip..."
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"
UNZIP_STATUS=$?

if [ $UNZIP_STATUS -ne 0 ]; then
    echo "Error: Gagal mengekstrak berkas ZIP!"
    # 4. Rollback / recover if failed
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo "Mengembalikan folder XCConfig lama..."
        mv "$BACKUP_DIR" "$TARGET_DIR"
    fi
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 5. Find the folder containing .xcconfig files inside TEMP_DIR
CONFIG_SRC_FILE=$(find "$TEMP_DIR" -name "*.xcconfig" -print -quit 2>/dev/null)

if [ -n "$CONFIG_SRC_FILE" ]; then
    CONFIG_FOLDER=$(dirname "$CONFIG_SRC_FILE")
    mkdir -p "$TARGET_DIR"
    mv "$CONFIG_FOLDER"/* "$TARGET_DIR"/ 2>/dev/null
    echo "Berkas .xcconfig berhasil diekstrak ke: $TARGET_DIR"
else
    echo "Error: Tidak ada file .xcconfig yang ditemukan di dalam ZIP!"
    # Rollback / recover if failed
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        echo "Mengembalikan folder XCConfig lama..."
        mv "$BACKUP_DIR" "$TARGET_DIR"
    fi
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup temp folder and backup folder
rm -rf "$TEMP_DIR"
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
    echo "Backup lama berhasil dihapus."
fi

echo "Sukses! Berkas XCConfig berhasil dipasang dan siap digunakan di Xcode."
