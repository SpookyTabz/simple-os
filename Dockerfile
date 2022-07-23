FROM ubuntu
RUN apt update
RUN apt install make g++ build-essential gdb binutils libc6-dev-i386 grub-common xorriso grub-pc-bin zsh curl git -y
WORKDIR /simple-os
CMD ["make", "-j8", "kernel.iso"]
