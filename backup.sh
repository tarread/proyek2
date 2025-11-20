#!/bin/bash

# ===========================================================
# 1. DEFINISI VARIABEL
# ==========================================================

# Direktori sumber
SOURCE_DIR="$HOME/proyek2/backup_project/data_penting"

# Direktori Tujuan backup
DEST_DIR="$HOME/proyek2/backup_project/backup_otomatis"

# Timestamp untuk nama file backup dan log
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Nama file backup akhir
BACKUP_FILE="backup_$TIMESTAMP.tar.gz"

# Nama file log harian
LOG_FILE="$DEST_DIR/log_backup_$(date +%Y%m%d).txt"

mkdir -p "$DEST_DIR/logs"


# =============================================================
# 2. MULAI LOGGING
# =============================================================
echo "--- backup dimulai pada: $TIMESTAMP ---" >> "%LOG_FILE"
echo "Mencari file di: $SOURCE_DIR" >> "$LOG_FILE"


# ============================================================
# 3. MENCARI FILE BERDASARKAN KRITERIA
# ===========================================================

TEMP_FILE_LIST="/tmp/files_to_backup_$$"
find "$SOURCE_DIR" -type f -mtime -30 \( -name "*.pdf" -o -name "*.docx" -o -name "*.txt" \)  >  "$TEMP_FILE_LIST"
 

# Hitung jumlah file yang ditemukan
FILE_COUNT=$(wc -l < "$TEMP_FILE_LIST")

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "Tidak ada file baru yang ditemukan untuk di backup." >> "$LOG_FILE"
    STATUS="GAGAL"
else
    echo "Ditemukan $FILE_COUNT file untuk di backup." >> "$LOG_FILE"
    STATUS="BERHASIL"
fi

   # ===========================================================
   # 4. KOMPRESI FILE DAN PEMINDAHAN
   # ===========================================================
   echo "Membuat dan mengompres file: $BACKUP_FILE" >> "$LOG_FILE"

   # Perintah tar: c (create), z (gzip), f (file name), T (ambil daftar dari file)
   tar -czf "$DEST_DIR/$BACKUP_FILE" -T "$TEMP_FILE_LIST" 2>> "$LOG_FILE"

   if [ $? -eq 0 ]; then
       STATUS="BERHASIL"
else
       STATUS="GAGAL"
   fi


#Hapus file sementara
rm -f "$TEMP_FILE_LIST"



# ============================================================
# 5. NOTIFIKASI DAN FINALISASI
# ============================================================
echo "--- Status akhir backup: $STATUS ---" >> "$LOG_FILE"
echo "backup selesai pada: $(date +%Y%m%d_%H%M%S)" >> "$LOG_FILE"

if [ "$STATUS" == "BERHASIL" ]; then
    echo "NOTIFIKASI:backup data berhasil dibuat di $DEST_DIR/$BACKUP_FILE"
    FILE_SIZE=$(du -h "$DEST_DIR/$BACKUP_FILE" | cut -f1) 
    echo "Ukuran file: $FILE_SIZE" >> "$LOG_FILE"
else
    echo "NOTIFIKASI:backup GAGAL! Periksa $LOG_FILE untuk detail."
fi

echo "---" >> "$LOG_FILE"

