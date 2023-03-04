#!/bin/bash

#  Copyright (C) 2017-2021  Volkan Gezer <volkangezer@gmail.com>

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

clear
echo -e "KDE Çeviri Hazırlama Betiğine Hoş Geldiniz!\n"
echo -e "Bu betik, depoya yazma yetkisi olan veya olmayan kullanıcılar için çeviri"
echo -e "ortamını hazırlayacak. Gerekli çeviri (PO) ve şablon dosyaları (POT)"
echo -e "depolardan indirilecek, ardından KDE 6 çevirisi için Lokalize proje dosyası"
echo -e "oluşturulacak. Kurulum, bazı yardımcı betikleri kopyaladıktan sonra Lokalize"
echo -e "uygulamasını bu proje ile açacak.\n"
echo -e "Herhangi bir anda Ctrl+C ile kurulumu iptal edebilirsiniz!\n"

function checkMD5 {
        rawGitHubLink="https://raw.githubusercontent.com/bitigchi/translationTools/master/kdeProjectCreator"
        file=$1
        online_md5="$(curl -sL $rawGitHubLink/$file | md5sum | cut -d ' ' -f 1)"
        local_md5="$(md5sum "$file" | cut -d ' ' -f 1)"

        if [ "$online_md5" == "$local_md5" ]; then
            echo -e "\e[32m$1 son sürümde!\e[0m"
        else
            echo -e "\e[31m$1 indiriliyor!\e[0m"
            curl -s $rawGitHubLink/$1 --output $1
            if [ "$file" == "kde_tr_yapilandir.sh" ]; then
                echo -e "\e[31mKurulum dosyası da güncellendi. Lütfen kurulumu yeniden başlatın!\e[0m"
                exit 0
            fi
        fi
}

function checkCMD { # $1 -> komut, $2 -> görünen ad / paket adı
    if ! command -v $1 &> /dev/null
    then
        echo "$2 bulunamadı, kuruluyor..."
        sudo apt install $2 -y
    fi
}

if [ -f "kde6_tr_trunk.lokalize" ]; then
    echo -e "\n\e[31mUYARI: Daha önce kurulum yapmışsınız gibi görünüyor. Kurulumu"
    echo -e "sürdürmek, daha önceki yaptığınız; ancak göndermediğiniz çevirilerin"
    echo -e "üzerine yazabilir.\e[0m\n"
fi

read -r -p "Kurulum sürdürülsün mü [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [hH]) 
        exit 0
        ;;
    *)
esac


read -r -p "En son sürüme sahip olup olmadığınız denetlensin mi [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [eE]) 
        checkCMD curl curl
        checkMD5 "ceviri_gonder.sh"
        checkMD5 "ceviri_guncelle.sh"
        checkMD5 "ceviri_uygula.sh"
        checkMD5 "KDE.odt"
        checkMD5 "LICENSE"
        checkMD5 "README.md"
        checkMD5 "terms.tbx"
        checkMD5 "embedded-google-translate.py"
        checkMD5 "embedded-google-translate.rc"
        checkMD5 "kde_tr_yapilandir.sh"
        ;;
    *)
esac

echo -e "== KDE Yazma Yetkisi ==\n"
echo -e "KDE depolarına yazma yetkiniz yoksa çevirileri posta listesine gönderirsiniz."
echo -e "Ancak varsa kurulum işlemini kendiniz yapabilirsiniz. Ancak bunun için daha"
echo -e "öncesinden Ortak SSH anahtarınızın (RSA) KDE sunucusuna yüklenmiş olması gerekir."
echo -e "Yetkili bir kullanıcıysanız evet demeden önce ssh-keygen komutu ile anahtar"
echo -e "oluşturduğunuzdan ve Ortak Anahtarı (pubkey)"
echo -e "https://invent.kde.org/-/profile/keys adresine yüklediğinizden emin olun.\n"
echo -e "Yükleme işleminden sonra, anahtarınızın kullanılabilir olması 1 saati"
echo -e "bulabilir. Bu durumda kurulum işlemine bir süre ara verin.\n"
svnOnEk="svn://anonsvn.kde.org"
read -r -p "KDE Deposu'na yazma izniniz var mı? eE/[hH]? " cevap
cevap=${cevap:-h}
case "$cevap" in 
    [eE])
        ssh-add
        svnOnEk="svn+ssh://svn@svn.kde.org"
        ;;
    *)
esac

echo -e "Betik, gerekli uygulamalara sahip olup olmadığınızı denetleyecek."
echo -e "Aşağıdaki komutlar, Debian (Ubuntu, Linux Mint vs.) dışı bir sistem"
echo -e "kullanıyorsanız çalışmaz. Bu durumda Lokalize ve SVN (Subversion)"
echo -e "kurulumunu kendiniz yapmalısınız!\n"
echo -e "APT önbelleği güncelleniyor..."
sudo apt update

checkCMD lokalize krosspython
checkCMD lokalize lokalize
checkCMD svn subversion

echo "KDE 6 Trunk dosyaları klonlanıyor..."
svn co -q $svnOnEk/home/kde/trunk/l10n-kf6/tr/ kde6_tr_trunk
echo "KDE 5 Stable dosyaları klonlanıyor..."
svn co -q $svnOnEk/home/kde/branches/stable/l10n-kf5/tr/ kde5_tr_stable
echo "KDE 6 Trunk şablonları klonlanıyor..."
svn co -q $svnOnEk/home/kde/trunk/l10n-kf6/templates templates_kde6

echo "KDE 6 Lokalize Projesi oluşturuluyor..."
# Proje dosyasını yapılandır
echo "[General]" >> kde6_tr_trunk.lokalize
echo "BranchDir=kde5_tr_stable" >> kde6_tr_trunk.lokalize
echo "LangCode=tr" >> kde6_tr_trunk.lokalize
echo "PoBaseDir=kde6_tr_trunk" >> kde6_tr_trunk.lokalize
echo "PotBaseDir=templates_kde6" >> kde6_tr_trunk.lokalize
echo "ProjectID=KDE Türkçe" >> kde6_tr_trunk.lokalize
echo "TargetLangCode=tr" >> kde6_tr_trunk.lokalize

echo "Çeviride yardımcı olacak Lokalize betikleri kopyalanıyor..."


# Lokalize betiklerini kopyala
# https://github.com/maidis/tr-lokalize-scripts
mkdir lokalize-scripts
mv embedded-google-translate.* lokalize-scripts


# Lokalize'yi oluşturulan proje dosyası ile çalıştır
echo "KDE Çeviri Ekibine Hoş Geldiniz! Herhangi bir sorunuzda kde-l10n-tr@kde.org"
echo "adresine e-posta gönderebilirsiniz."
echo "Kurulum tamamlandı. Artık Lokalize uygulamasını açabilirsiniz... "
read -r -p "Lokalize açılsın mı [eE]/hH? " cevap
cevap=${cevap:-e}
case "$cevap" in
    [eE]) 
        echo "Enter'a bastığınızda Lokalize uygulaması otomatik olarak"
        echo "kde6_tr_trunk.lokalize projesini açar."
        read -r -p "Çeviriye başlamadan önce ilk olarak 'Ayarlar -> Lokalize Uygulamasını Yapılandır -> Kimlik' bölümünden bilgilerinizi girmeyi unutmayın!"
        lokalize --project kde6_tr_trunk.lokalize &> /dev/null &
        ;;
    *)
        echo -e "Lokalize uygulamasını elle başlattıktan sonra bu klasörde oluşturulmuş"
        echo -e "kde6_tr_trunk.lokalize proje dosyasını açın. Çeviriye başlamadan önce"
        echo -e "ilk olarak 'Ayarlar -> Lokalize Uygulamasını Yapılandır -> Kimlik'"
        echo -e "bölümünden bilgilerinizi girmeyi unutmayın!"
        ;;
esac

