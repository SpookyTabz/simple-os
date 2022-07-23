GCCPARAMS = -m32
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = obj/loader.o \
		  obj/kernel.o

obj/%.o: src/%.cpp
	mkdir -p $(@D)
	g++ $(GCCPARAMS) -c -o $@ $<

obj/%.o: src/%.s
	mkdir -p $(@D)
	as $(ASPARAMS) -o $@ $<

kernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o bin/$@ $(objects)
	rm $(objects)

kernel.iso: kernel.bin
	grub-mkrescue --output=bin/$@ bin

run: kernel.iso
	(pkill VirtualBoxVM) || true
	VirtualBoxVM --startvm "simple-os" &

wsl-run: kernel.iso
	(powershell.exe "taskkill /IM "VirtualBoxVM.exe" /F") || true
	/mnt/c/Program\ Files/Oracle/VirtualBox/VirtualBoxVM.exe --startvm "simple-os" &

.phony: build-docker-image docker qemu qemu-run
build-docker-image:
	docker build --platform linux/x86-64 -t simple-os .
docker:
	docker run --rm -v "$$(pwd)":/simple-os --platform linux/x86-64 simple-os
qemu: 
	qemu-system-i386 -cdrom kernel.iso -vga virtio -m 1G
qemu-run: docker qemu