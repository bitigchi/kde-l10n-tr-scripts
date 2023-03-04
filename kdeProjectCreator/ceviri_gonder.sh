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

echo "Bu betik, değiştirilmiş dosyaları KDE depolarına işler."
read -r -p "Bu işlem, KDE depolarına yazma yetkiniz yoksa başarısız olur. Sürdürülsün mü [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [hH]) 
        exit 0
        ;;
    *)
esac


ssh-add
read -r -p "SVN deposunda görünecek ileti: " mesaj
mesaj="${mesaj:-turkish_translation_updates}"

cd kde6_tr_trunk
echo "KDE 6 Trunk içinde yeni dosyalar aranıyor..."
svn add * --force
echo "KDE 6 Trunk değişiklikleri gönderiliyor..."
svn ci -m "$mesaj"
cd ..

cd kde5_tr_stable
echo "KDE 5 Stable içinde yeni dosyalar aranıyor..."
svn add * --force
echo "KDE 5 Stable değişiklikleri gönderiliyor..."
svn ci -m "$mesaj"
cd ..
