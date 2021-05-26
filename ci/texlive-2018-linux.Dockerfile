FROM ubuntu:bionic

RUN \
  apt-get update && \
  apt-get install -y wget apt-utils software-properties-common

RUN \
  apt-get install --no-install-recommends -y git python2.7 && \
  apt-get install --no-install-recommends -y poppler-utils ghostscript imagemagick --fix-missing && \
  apt-get install --no-install-recommends -y libfile-fcntllock-perl gcc equivs libwww-perl fontconfig unzip

COPY ci/texlive2018.profile ./texlive.profile

RUN \
  export TLNET_REPO=http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2018/tlnet-final && \
  wget ${TLNET_REPO}/install-tl-unx.tar.gz && \
  tar -xf "install-tl-unx.tar.gz" && \
  export tl_dir=$( ls | grep -P "install-tl-\d{8}$" | head -n 1 ) && \
  echo "i" | ${tl_dir}/install-tl -logfile install-tl.log -repository ${TLNET_REPO} -profile ./texlive.profile && \
  export MAINTEXDIR=$(grep "TEXDIR:" "install-tl.log" | awk -F'"' '{ print $2 }') && \
  ln -s "${MAINTEXDIR}/bin"/* "/opt/texbin" && \
  sed -i 's/^PATH="/PATH="\/opt\/texbin:/' /etc/environment && \
  rm -rf ${tl_dir} "install-tl-unx.tar.gz"
