(
   set -e
   ifs="$(! printf '\n\t ')" || IFS="${ifs}"
   cd -L -- "$(dirname -- "${0}")"
   download() {
      wget --quiet --no-check-certificate --no-verbose --no-glob --no-hsts --show-progress --progress=bar:force --content-disposition ${wget_args} -- "${@}"
   }
   languages="
      ar-SA	العربية
      bg-BG	Български
      cs-CZ	Čeština
      da-DK	Dansk
      de-DE	Deutsch
      el-GR	Ελληνικά
      en-US	English
      es-ES	Español
      et-EE	Eesti
      fi-FI	Suomi
      fr-FR	Français
      he-IL	עברית
      hi-IN	हिंदी
      hr-HR	Hrvatski
      hu-HU	Magyar
      id-ID	Indonesia
      it-IT	Italiano
      ja-JP	日本語
      kk-KZ	Қазақ Тілі
      ko-KR	한국어
      lt-LT	Lietuvių
      lv-LV	Latviešu
      ms-MY	Bahasa Melayu
      nb-NO	Norsk Bokmål
      nl-NL	Nederlands
      pl-PL	Polski
      pt-BR	Português (Brasil)
      pt-PT	Português (Portugal)
      ro-RO	Română
      ru-RU	Русский
      sk-SK	Slovenčina
      sl-SI	Slovenščina
      sr-Latn-RS	Srpski
      sv-SE	Svenska
      th-TH	ไทย
      tr-TR	Türkçe
      uk-UA	Українська
      vi-VN	Tiếng Việt
      zh-CN	中文(简体)
      zh-TW	中文(繁體)
   " && languages="$(printf %s "${languages}" | sed -e "s/^[[:space:]][[:space:]]*//" | grep -e . | cut -f 1 | tr '\012' '\040' | sed -e 's/[[:space:]][[:space:]]*$//')"
   printf '%s\n' "${languages}"
   for i in \
      "MacOS (64-bit):https://go.microsoft.com/fwlink/?linkid=2159108&Region=SG#https://go.microsoft.com/fwlink/?linkid=799520#https://officecdnmac.microsoft.com/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_365_and_Office_16.99.25071321_HomeStudent_Installer.pkg;once	wget_args=--continue && curl_args='-C -'" \
      "Windows Online Installer (default):https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=HomeStudent2021Retail&platform=Def&language={language}&TaxRegion=sg&correlationId=00000000-0000-0000-0000-000000000000&token=00000000-0000-0000-0000-000000000000&version=O16GA&source=AMC&StoreId=CFQ7TTC0H8N8;loop	wget_args=--no-continue && curl_args='-C 0'" \
      "Windows Online Installer (32-bit):https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=HomeStudent2021Retail&platform=X86&language={language}&TaxRegion=sg&correlationId=00000000-0000-0000-0000-000000000000&token=00000000-0000-0000-0000-000000000000&version=O16GA&source=AMC&StoreId=CFQ7TTC0H8N8;loop	wget_args=--no-continue && curl_args='-C 0'" \
      "Windows Online Installer (64-bit):https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=HomeStudent2021Retail&platform=X64&language={language}&TaxRegion=sg&correlationId=00000000-0000-0000-0000-000000000000&token=00000000-0000-0000-0000-000000000000&version=O16GA&source=AMC&StoreId=CFQ7TTC0H8N8;loop	wget_args=--no-continue && curl_args='-C 0'" \
      "Windows Offline Installer (32-bit & 64-bit):https://officecdn.microsoft.com/sg/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/{language}/HomeStudent2021Retail.img;zh-CN	wget_args=--continue && curl_args='-C -'" \
   ; do
      env="$(printf %s "${i}" | cut -f 2- -s)"
      i="$(printf %s "${i}" | cut -f 1)"
      test "${env}" != "${i}" || env=
      dir="${i%%:*}" && i="${i#*:}" && test "${dir}" != "${i}" || i=
      url="${i%;*}" && ext="${i##*;}" && test "${url}" != "${ext}" || ext=
      printf '# %s\n\t> %s\t[%s]\t<%s>\n' "${dir}" "${url}" "${ext}" "${env}"
      (
         mkdir -p -- "${dir}"
         cd -L -- "${dir}"
         handler() { (
            printf '\t\t[%s]\n' "${lng}"
            mkdir -p -- "${lng}"
            cd -L -- "${lng}"
            test "${lng}" = default || url="$(printf %s "${url}" | sed -e "s/{language}/${lng}/g")"
            printf '\t\t\t> %s\n' "${url}"
            test -z "${env}" || eval "${env}"
            download "${url}"
         ); }
         pid= && case "${ext}" in
            once)
               lng=default && handler & pid="${pid:+"${pid} "}${!}"
            ;;
            loop)
               for lng in ${languages}; do
                  handler & pid="${pid:+"${pid} "}${!}"
               done
            ;;
            *-*)
               for lng in ${languages}; do
                  for i in $(printf %s "${ext}" | tr , '\040'); do
                     test "${lng}" = "${i}" || continue
                     handler & pid="${pid:+"${pid} "}${!}"
                  done
               done
            ;;
         esac
         eval wait "${pid}"
      )
   done
) 2>&1