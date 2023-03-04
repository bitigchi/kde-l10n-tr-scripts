#!/bin/bash

#  Copyright (C) 2017-2020  Volkan Gezer <volkangezer@gmail.com>

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


read -r -p "Bu işlem, projedeki tüm PO dosyalarını sistemdeki dosyalarla değiştirip çevirileri hemen kullanmanızı sağlar. Sürdürülsün mü [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [hH]) 
        exit 0
        ;;
    *)
esac

cd kde6_tr_trunk

echo -e "PO dosyalarını bul, her birini msgfmt ile işle ve sonuçları MO dosyası"
echo -e "olarak yap... Bu işlem biraz sürebilir."

for file in `find messages -name "*.po"` ; do msgfmt -o `echo $file | sed 's/\.po$/.mo/'` $file ; done

echo "Şimdi, dönüştürülen tüm MO dosyaları uygulama dizinine aktarılacak."
echo "Bu işlem için istenirse yönetici parolasını girmeniz gerekir."

sudo find . -iname '*.mo' -exec mv '{}' /usr/share/locale/tr/LC_MESSAGES/ \;

echo "İşlem tamamlandı. Bazı metinleri görmek için oturumu kapatıp yeniden açmanız"
echo "gerekebilir. Kullanılan uygulama biçimine bağlı olarak bazı çeviriler"
echo "görünemeyebilir."
