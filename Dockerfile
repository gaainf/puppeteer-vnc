ARG VERSION=20.04
FROM ubuntu:$VERSION

WORKDIR /usr/src/app

RUN apt update && apt upgrade -y
RUN apt install -y curl bash sudo zsh git
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt install -y ca-certificates fonts-liberation gconf-service libappindicator1 \
  libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libasound2 \
  libgbm-dev libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 \
  libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
  libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
  lsb-release wget x11-apps x11-xkb-utils x11vnc xdg-utils xfonts-100dpi xfonts-75dpi \
  xfonts-cyrillic xfonts-scalable xvfb

# Install nodejs/npm
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt install -y nodejs
RUN npm install -g npm@7

# Configure screen resolution
ENV DISPLAY=:1
ENV SCREEN=1280x1024x24

# Configure vnc server
RUN echo "Xvfb $DISPLAY -screen 0 $SCREEN &" >> /start.sh
RUN echo "x11vnc -display $DISPLAY" >> /start.sh
RUN chmod 755 /start.sh

# Install node modules
COPY package*.json ./
RUN chmod 777 package*.json
RUN npm install
RUN chmod -R 777 node_modules

# Configure kernel to avoid no-sanbox error
RUN echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

# Setup not root user to avoid no-sanbox error
ARG user=appuser
ARG group=appuser
ARG uid=1000
ARG gid=1000
RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/sh -m ${user}
RUN echo "appuser ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/username
# Switch to user
USER ${uid}:${gid}

# Setup zsh for active user
ENV ZSH=/home/appuser/.oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

CMD ["bash", "-c", "/start.sh"]
