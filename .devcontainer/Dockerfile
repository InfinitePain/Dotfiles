FROM archlinux/archlinux:latest

# Install packages
Run pacman-key --init && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed \
    sudo \
    base-devel \
    git \
    cmake \
    ninja \
    ncurses \
    gdb \
    neofetch

#set non-root user
RUN useradd -m -G wheel vs-code && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'vs-code:admin' | chpasswd && \
    passwd --delete root && \
    chown -R vs-code:vs-code /home/vs-code

# Mount Docker socket for Docker-in-Docker support
VOLUME /var/run/docker.sock

# Switch to non-root user
USER vs-code
Workdir /home/vs-code
CMD ["bash"]
