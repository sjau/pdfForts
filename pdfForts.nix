{stdenv, fetchgit, kate, pdftk, imagemagick, zip, unzip, libreoffice, unoconv, tesseract, recode, cuneiform, poppler_utils, ghostscript, zenity }:
stdenv.mkDerivation {
  name = "pdfForts-git";
# Switch between local testing and using proper git repo
  src = fetchgit {
    url = https://github.com/sjau/pdfForts.git;
    rev = "6f40ced39a7f75c900e1696f51c273f4e6caf265";
    sha256 = "sha256-F1YW5exoyID+7wcw3hFNV3jxnv6MMzTrFwmarHrnaGk=";
  };
#  src = /home/hyper/Desktop/git-repos/pdfForts;
  installPhase = ''
    mkdir -p $out/bin
    cp -n **/*.sh $out/bin && continue || continue
    rm $out/bin/vars.sh
# NixOS does currently not provide Kate, so Zenity is chosen over Kate
    for i in $out/bin/*; do
      substituteInPlace $i \
        --replace /usr/bin/pdfForts/common.sh $out/lib/pdfForts/common.sh \
        --replace /usr/share/kservices5/ServiceMenus/pdfForts/ $out/share/kservices5/ServiceMenus/pdfForts/ \
        --replace kate ${kate}/bin/kate \
        --replace zenity ${zenity}/bin/zenity \
        --replace pdftk ${pdftk}/bin/pdftk \
        --replace " convert " " ${imagemagick}/bin/convert " \
        --replace " zip " " ${zip}/bin/zip " \
        --replace unzip ${unzip}/bin/unzip \
        --replace libreoffice ${libreoffice}/bin/libreoffice \
        --replace unoconv ${unoconv}/bin/unoconv \
        --replace tesseract ${tesseract}/bin/tesseract \
        --replace recode ${recode}/bin/recode \
        --replace cuneiform ${cuneiform}/bin/cuneiform \
        --replace pdftotext ${poppler_utils}/bin/pdftotext \
        --replace "gs -sDEVICE" " ${ghostscript}/bin/gs -sDEVICE"
    done

    mkdir -p $out/lib/pdfForts
    cp common.sh $out/lib/pdfForts/
    for i in $out/lib/pdfForts/*.sh; do
      substituteInPlace $i \
        --replace /usr/share/kservices5/ServiceMenus/pdfForts/ $out/share/kservices5/ServiceMenus/pdfForts/ \
        --replace pdftk ${pdftk}/bin/pdftk \
        --replace kate ${kate}/bin/kate \
        --replace zenity ${zenity}/bin/zenity
    done

    mkdir -p $out/share/kservices5/ServiceMenus/pdfForts/
    cp **/*.desktop $out/share/kservices5/ServiceMenus/pdfForts/

# For testing point the .desktop entries to /run/current-system/sw/bin/ instead of:
#        --replace /usr/bin/pdfForts/ $out/bin/
    for i in $out/share/kservices5/ServiceMenus/pdfForts/*.desktop; do
      substituteInPlace $i \
        --replace /usr/bin/pdfForts/ /run/current-system/sw/bin/
    done
    
    # NixOS does not provide exactimage / hocr2pdf -> hence searchable pdf needs to be removed
    rm $out/bin/searchablePDF.sh
    rm $out/share/kservices5/ServiceMenus/pdfForts/searchablePDF.desktop

    mkdir -p $out/share/pdfForts
    cp **/*.conf $out/share/pdfForts/
    cp **/*.odt $out/share/pdfForts/
    for i in $out/share/pdfForts/*.conf; do
      substituteInPlace $i \
        --replace /usr/share/kservices5/ServiceMenus/pdfForts/ /run/current-system/sw/share/pdfForts/
    done
  '';
}
