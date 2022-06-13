FROM amazonlinux:latest

RUN yum update -y
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -
RUN yum -y install \ 
    tar \
    nodejs \
    binutils \
    bison \
    bzip2 \
    cmake \
    curl \
    dbus-x11 \
    flex \
    git-core \
    gperf \
    patch \
    perl \
    python-setuptools \
    python3 \
    rpm \
    ruby \
    subversion \
    zip

# Install Brotli - https://www.howtoforge.com/how-to-compile-brotli-from-source-on-centos-7/
RUN yum install -y wget gcc make bc sed autoconf automake libtool git tree man
RUN git clone https://github.com/google/brotli.git
WORKDIR /brotli
RUN cp ./docs/brotli.1 /usr/share/man/man1 && gzip /usr/share/man/man1/brotli.1
RUN ./bootstrap
RUN ./configure --prefix=/usr \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --libexecdir=/usr/lib64/brotli \
    --libdir=/usr/lib64/brotli \
    --datarootdir=/usr/share \
    --mandir=/usr/share/man/man1 \
    --docdir=/usr/share/doc

RUN make
RUN make install
RUN brotli --version

# Install webkit
RUN npm install -g yarn
WORKDIR /var/layer
RUN yarn init -y
RUN PLAYWRIGHT_BROWSERS_PATH=$(pwd)/source yarn add playwright-webkit brotli

# use brotli to compress
WORKDIR /var/layer/source
RUN tar -cvf webkit.tar webkit-1641 .
RUN brotli --best --force webkit.tar

# Compile layer zip
WORKDIR /var/layer
RUN mkdir -p package/webkit
RUN cp ./source/webkit.tar.br ./package/webkit/webkit.tar.br
RUN zip -r package.zip package
