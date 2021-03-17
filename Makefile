BUILD_PATH = ./build
SRC_PATH   = ./src
HEADERS_PATH = ./headers
LIB_PATH = ./lib

TEST_PATH = ./test
BUILD_TEST_PATH = $(TEST_PATH)/build
HEADERS_TEST_PATH = $(TEST_PATH)/headers
SRC_TEST_PATH = $(TEST_PATH)/src

ASSEMBLY_OBJS  = $(BUILD_PATH)/masked_and_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/masked_xor_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/masked_shiftrows_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/masked_ror_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/bitslicing_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/masked_mixcolumns_s.o
ASSEMBLY_OBJS += $(BUILD_PATH)/masked_rotword_xorcol_s.o

C_OBJS  = $(BUILD_PATH)/xoshiro_c.o
C_OBJS += $(BUILD_PATH)/masked_aes_sbox_c.o
C_OBJS += $(BUILD_PATH)/masked_aes_keyschedule_c.o
C_OBJS += $(BUILD_PATH)/masking_c.o
C_OBJS += $(BUILD_PATH)/masked_utils_c.o
C_OBJS += $(BUILD_PATH)/masked_aes_c.o

C_OBJS_TEST  = $(BUILD_TEST_PATH)/startup.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_and.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_aes_sbox.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_mask_unmask.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_ror.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_shiftrows.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_bitslicing.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_mixcolumns.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_keyschedule.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_utils.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/test_masked_aes.o
C_OBJS_TEST += $(BUILD_TEST_PATH)/main.o

ARCH_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS = -Wall -Werror -s -funroll-loops $(ARCH_FLAGS) -O3 -I$(HEADERS_PATH)
CFLAGS_TEST = -g $(ARCH_FLAGS) -I$(HEADERS_TEST_PATH) -I$(HEADERS_PATH) -lnosys

LSCRIPT = $(TEST_PATH)/lscript.ld
LFLAGS_TEST = -static -nostartfiles -T$(LSCRIPT) -L$(LIB_PATH) -lmasked_aes


# LIBRARY

$(BUILD_PATH)/%_s.o: $(SRC_PATH)/%.s $(HEADERS_PATH)/%.h
	arm-none-eabi-as $(ARCH_FLAGS) $< -o $@ 

$(BUILD_PATH)/%_c.o: $(SRC_PATH)/%.c $(HEADERS_PATH)/%.h
	arm-none-eabi-gcc $(CFLAGS) -c $< -o $@

$(LIB_PATH)/libmasked_aes.a: $(ASSEMBLY_OBJS) $(C_OBJS)
	arm-none-eabi-ar rcs $@ $(ASSEMBLY_OBJS) $(C_OBJS)


lib: ./lib/libmasked_aes.a

lib-unroll: ./lib/libmasked_aes.a

# TEST

$(BUILD_TEST_PATH)/%.o: $(SRC_TEST_PATH)/%.c
	arm-none-eabi-gcc $(CFLAGS_TEST) -c $< -o $@

$(BUILD_TEST_PATH)/main.elf: $(C_OBJS_TEST) $(LSCRIPT) $(LIB_PATH)/libmasked_aes.a
	arm-none-eabi-gcc $(ARCH_FLAGS) $(C_OBJS_TEST) -o $@ $(LFLAGS_TEST)

$(BUILD_TEST_PATH)/main.bin: $(BUILD_TEST_PATH)/main.elf
	arm-none-eabi-objcopy -O binary $< $@

test: $(BUILD_TEST_PATH)/main.bin

# QEMU

QEMU_FLAGS = -machine lm3s6965evb -cpu cortex-m3 -nographic -kernel
QEMU_GDB_FLAGS = -gdb tcp::1234 -S

qemu: test
	qemu-system-arm $(QEMU_FLAGS) $(BUILD_TEST_PATH)/main.bin

qemu-gdb: test
	qemu-system-arm $(QEMU_GDB_FLAGS) $(QEMU_FLAGS) $(BUILD_TEST_PATH)/main.bin

# CHIPWHISPERER

SSH_ADDR = 192.168.1.51
SSH_USER = vagrant
SSH_PASSWORD = vagrant
CW_PATH = /home/vagrant/work/projects/chipwhisperer/hardware/victims/firmware
CW_HEADER_PATH = $(CW_PATH)/crypto
CW_LIB_PATH = $(CW_PATH)/mylib

cw: lib $(HEADERS_PATH)/masked_aes.h
	sshpass -p $(SSH_PASSWORD) scp $(LIB_PATH)/libmasked_aes.a $(SSH_USER)@$(SSH_ADDR):$(CW_LIB_PATH)
	sshpass -p $(SSH_PASSWORD) scp $(HEADERS_PATH)/masked_aes.h $(SSH_USER)@$(SSH_ADDR):$(CW_HEADER_PATH)


.PHONY: all clean lib test qemu qemu-gdb cw


clean:
	rm -f $(BUILD_PATH)/*.o $(LIB_PATH)/*.a $(BUILD_TEST_PATH)/*.o $(BUILD_TEST_PATH)/main.elf $(BUILD_TEST_PATH)/main.bin
#	cp ./xoshiro_c.o $(BUILD_PATH)/ # DIRTY H4XX

all: lib test qemu

.DEFAULT_GOAL := all
