#!/bin/bash
# String Manipulation (Satrlar bilan ishlash) amaliyoti

text="DevOps Engineering Bootcamp"

echo "Asl matn: $text"
echo "Uzunligi: ${#text}"

# Substring (kesib olish)
echo "Dastlabki 6 ta belgi: ${text:0:6}"
echo "Bootcamp so'zi: ${text:19:8}"

# Replace (almashtirish)
echo "Birinchi 'e' -> 'E': ${text/e/E}"
echo "Barcha 'e' -> 'E': ${text//e/E}"

# Katta / kichik harflar
echo "Barchasi katta: ${text^^}"
echo "Barchasi kichik: ${text,,}"
