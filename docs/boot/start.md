
> 参考书籍是: 一个64位操作系统的设计与实现

## 创建软盘

```
    bximage  # 输入命令一直手动选择  fd  1.44M  boot.img
```

## 填入数据

```


%.bin: %.asm
	nasm -f bin $< -o $@



%.img: boot.bin
	dd if=boot.bin of=$@ bs=512 count=1 conv=notrunc
	rm -rf boot.bin

# boot.img: boot.bin
# 	dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
# 	rm -rf boot.bin

run:  boot.img
	bochs -q




.PHONY: clean run writeLoaderbin

clean:
	rm -rf *.bin

writeLoaderbin:
	mkdir /tmp/boot_img_mount
	sudo mount -o loop boot.img -t vfat /tmp/boot_img_mount
	sudo cp loader.bin /tmp/boot_img_mount/
	sudo umount /tmp/boot_img_mount
	rmdir /tmp/boot_img_mount


```

