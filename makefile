
BUILD := ./build
SRC := ./src
WORKDIR := .

ENTRYPOINT := 0x10000

INCLUDE :=  -I$(SRC)/include

CFLAGS:= -m32 					# 32 位的程序
CFLAGS+= -march=pentium			# pentium 处理器
CFLAGS+= -fno-builtin			# 不需要 gcc 内置函数
CFLAGS+= -nostdinc				# 不需要标准头文件
CFLAGS+= -fno-pic				# 不需要位置无关的代码  position independent code
CFLAGS+= -fno-pie				# 不需要位置无关的可执行程序 position independent executable
CFLAGS+= -nostdlib				# 不需要标准库
CFLAGS+= -fno-stack-protector	# 不需要栈保护
CFLAGS+= -Werror
CFLAGS+= -std=c99


CFLAGS:=$(strip ${CFLAGS})


# 将汇编变成2进制文件
$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@ 

# 将汇编变成可重入的elf文件
$(BUILD)/kernel/%.o: $(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $< -o $@ 

# 生成elf的静态的可执行程序
$(BUILD)/kernel.bin:  \
	$(BUILD)/kernel/main.o \
	$(BUILD)/kernel/start.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

# 这需要代码部分(这里是去除了elf的头部,因为我们不需要这些头部, 但是我们利用的工具ld是会生成的)
$(BUILD)/system.bin: $(BUILD)/kernel.bin
	
	objcopy -O binary $< $@

$(BUILD)/kernel/%.o: $(SRC)/kernel/%.c
	$(shell mkdir -p $(dir $@))
	gcc $(CFLAGS) $(INCLUDE) -c $<  -o $@


$(BUILD)/system.map: $(BUILD)/kernel.bin
	
	nm $< | sort > $@



$(BUILD)/master.img: $(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin \
	$(BUILD)/system.bin \
	$(BUILD)/system.map

	yes | bximage -mode=create -hd=16 -imgmode=flat -q $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4 seek=1 conv=notrunc
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc

	

# dd if=/dev/sdb of=boot.bin bs=512 count=1 conv=notrunc
usb: boot.bin /dev/sdb
	dd if=boot.bin of=/dev/sdb bs=446 count=1 conv=notrunc



run: $(BUILD)/master.img
	LTDL_LIBRARY_PATH=/usr/local/bochs/lib/bochs/plugins \
	BXSHARE=/usr/local/bochs/share/bochs \
	bochs -q -f $(WORKDIR)/bochs/bochsrc

debug: $(BUILD)/master.img

	LTDL_LIBRARY_PATH=/usr/local/bochs-gdb/lib/bochs/plugins \
	BXSHARE=/usr/local/bochs-gdb/share/bochs \
	bochs-gdb -q -f $(WORKDIR)/bochs/bochsrc-gdb

.PHONT: clean run
clean:
	rm -rf $(BUILD)