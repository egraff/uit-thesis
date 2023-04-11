FROM ubuntu:focal

RUN \
  apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get install --no-install-recommends -y wget apt-utils software-properties-common

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get install --no-install-recommends -qq -y git python3 curl && \
  apt-get install --no-install-recommends -qq -y poppler-utils ghostscript imagemagick --fix-missing && \
  apt-get install --no-install-recommends -qq -y libfile-fcntllock-perl gcc equivs libwww-perl fontconfig && \
  apt-get install --no-install-recommends -qq -y unzip openssh-client rsync

# Install .NET 3.1 runtime, required by secure-file utility
RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  rm packages-microsoft-prod.deb && \
  apt-get update && \
  apt-get install --no-install-recommends -y dotnet-runtime-3.1

COPY ci/texlive2019.profile ./texlive.profile

RUN \
  export INSTALL_TL_REPO=https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2019/tlnet-final && \
  wget ${INSTALL_TL_REPO}/install-tl-unx.tar.gz && \
  tar -xf "install-tl-unx.tar.gz" && \
  export tl_dir=$( ls | grep -P "install-tl-\d{8}$" | head -n 1 ) && \
  (echo "i" | ${tl_dir}/install-tl -logfile install-tl.log -repository ${INSTALL_TL_REPO} -profile ./texlive.profile) || \
  ( \
    while [ $? -ne 0 ]; do \
      echo "y" | ${tl_dir}/install-tl -logfile install-tl.log -repository ${INSTALL_TL_REPO} -profile ./texlive.profile ; \
    done \
  ) && \
  export MAINTEXDIR=$(grep "TEXDIR:" "install-tl.log" | awk -F'"' '{ print $2 }') && \
  ln -s "${MAINTEXDIR}/bin"/* "/opt/texbin" && \
  sed -i 's/^PATH="/PATH="\/opt\/texbin:/' /etc/environment && \
  rm -rf ${tl_dir} "install-tl-unx.tar.gz"

RUN \
  export TLNET_REPO=http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2019/tlnet-final ; \
  tlmgr repository set ${TLNET_REPO} ; \
  tlmgr install \
    collection-basic \
    collection-bibtexextra \
    collection-binextra \
    collection-fontsextra \
    collection-fontsrecommended \
    collection-fontutils \
    collection-formatsextra \
    collection-langenglish \
    collection-langeuropean \
    collection-langother \
    collection-latex \
    collection-latexextra \
    collection-latexrecommended \
    collection-mathscience \
    collection-metapost \
    collection-pictures \
    collection-plaingeneric \
    collection-pstricks \
  ; while [ $? -ne 0 ]; do !!; done ; \
  export TLNET_REPO=https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2019/tlnet-final ; \
  tlmgr repository set ${TLNET_REPO} ; \
  tlmgr update --reinstall-forcibly-removed --all --self ; \
  tlmgr path add
