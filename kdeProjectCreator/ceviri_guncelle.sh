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

read -r -p "Bu işlem, KDE Deposu'ndaki tüm proje dosyalarını güncelleyecek. Devam edilsin mi [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [hH]) 
        exit 0
        ;;
    *)
esac
ssh-add
echo "KDE 6 Trunk dosyaları güncelleniyor..."
cd kde6_tr_trunk
svn up
cd ..

echo "KDE 5 Stable dosyaları güncelleniyor..."
cd kde5_tr_stable
svn up
cd ..

echo "KDE 6 Trunk şablonları güncelleniyor..."
cd templates_kde6
svn up
cd ..

echo "Güncelleme tamamlandı."
