CROSS_COMPILE ?= aarch64-none-elf-

NAME = rtos
ELF  = $(NAME).elf
BIN  = $(NAME).bin
LIST = $(NAME).list

FREERTOS_DIR = FreeRTOS/FreeRTOS
PORTABLE_DIR = portable
BUILD_DIR    = build

INCLUDE  = $(FREERTOS_DIR)/Source/include
INCLUDE += $(PORTABLE_DIR)/ARM_CA72_64_BIT
INCLUDE += inc

# From src
OBJS  = startup.o
OBJS += FreeRTOS_asm_vector.o
OBJS += FreeRTOS_tick_config.o
OBJS += interrupt.o
OBJS += memset.o
OBJS += pl011.o
OBJS += main.o

# From protable
OBJS += port.o
OBJS += portASM.o

# FreeRTOS
OBJS += list.o
OBJS += tasks.o
OBJS += queue.o
OBJS += timers.o

# MemMang
OBJS += heap_1.o

# Add Prefix
OBJS := $(addprefix $(BUILD_DIR)/,$(OBJS))

# Linker script
LINKER_SCRPIT = scripts/raspberrypi4.ld

CFLAGS    = -std=gnu11 -O2 -mcpu=cortex-a72 -fpic -ffreestanding
CFLAGS   += -Wall -Wextra -DGUEST
CFLAGS   += $(addprefix -I,$(INCLUDE))
ASMFLAGS  = -mcpu=cortex-a72
LDFLAGS   = -Wl,--build-id=none -T $(LINKER_SCRPIT) -nostdlib -ffreestanding 

all: $(BUILD_DIR) $(BIN) 

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN): $(ELF)
	$(Q)$(CROSS_COMPILE)objcopy -O binary $^ $@

$(LIST): $(ELF)
	$(Q)$(CROSS_COMPILE)objdump -d $^ > $@

$(ELF) : $(LINKER_SCRPIT) $(OBJS)
	$(Q)$(CROSS_COMPILE)gcc -o $@ $(LDFLAGS) $(OBJS)

$(BUILD_DIR)/%.o : src/%.S
	$(Q)$(CROSS_COMPILE)as $(ASMFLAGS) -c -o $@ $<
	
$(BUILD_DIR)/%.o : src/%.c
	$(Q)$(CROSS_COMPILE)gcc $(CFLAGS)  -c -o $@ $<

$(BUILD_DIR)/%.o : $(FREERTOS_DIR)/Source/%.c
	$(Q)$(CROSS_COMPILE)gcc $(CFLAGS)  -c -o $@ $<

$(BUILD_DIR)/%.o : $(PORTABLE_DIR)/ARM_CA72_64_BIT/%.c
	$(Q)$(CROSS_COMPILE)gcc $(CFLAGS)  -c -o $@ $<

$(BUILD_DIR)/%.o : $(PORTABLE_DIR)/ARM_CA72_64_BIT/%.S
	$(Q)$(CROSS_COMPILE)as $(ASMFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o : $(FREERTOS_DIR)/Source/portable/MemMang/%.c
	$(Q)$(CROSS_COMPILE)gcc $(CFLAGS)  -c -o $@ $<

clean :
	rm -rf $(BUILD_DIR)
	rm -f $(ELF)
	rm -f $(BIN)
	rm -f $(LIST)

