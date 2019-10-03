BUILD_DIR?=build

default: qemu.img

qemu.img: debootstrap.tgz | $(BUILD_DIR)
	BUILD_DIR=$(BUILD_DIR) ./qemu.img.sh $@.tmp $<
	mv $@.tmp $@

debootstrap.tgz: debootstrap.txt postdebootstrap.sh | $(BUILD_DIR)
	BUILD_DIR=$(BUILD_DIR) ./debootstrap.tgz.sh $@.tmp
	mv $@.tmp $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

cleanall: clean
	rm -f qemu.img debootstrap.tgz
