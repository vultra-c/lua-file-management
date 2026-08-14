/*
 * payload/src/module.c
 * 最小原生模块（用真实 ARM 交叉工具链构建，NuttX/Vela modlib ET_REL 格式）。
 *
 * module_main 由表盘 INJECT 链以 `exec <base+1>` 调用（base 为 lsmod 解析的 textalloc）：
 *   - 写验证标记1：*(0x20001000) = 0x5EED0001
 *   - 写验证标记2：*(0x20001004) = 1
 *   然后干净返回（LR 由 exec 以函数调用方式设置，pop {pc} 回到调用方）。
 *
 * 构建（见 scripts/build-ko.sh）：
 *   arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=soft -Os \
 *     -ffreestanding -fno-common -fno-builtin -fno-stack-protector \
 *     -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-pic -fno-pie \
 *     -nostdlib -c module.c
 *   arm-none-eabi-ld -r -T payload/gnu-elf.ld module.o -o module.ko
 */

/* 强制产生 .data / .bss 段：真实工具链链接产物通常都带这两个段，
 * 部分旧式 modlib 按段名查找 .text/.data/.bss，缺段会被拒（insmod exit 65280）。
 * 这里只确保段存在，代码并不引用它们（保持零重定位，降低加载器要求）。 */
static unsigned int s_dummy_data = 0x5EEDD00D; /* -> .data */
static unsigned int s_dummy_bss;               /* -> .bss  */

void module_main(void)
{
    volatile unsigned int *m1 = (volatile unsigned int *)0x20001000UL;
    volatile unsigned int *m2 = (volatile unsigned int *)0x20001004UL;

    *m1 = 0x5EED0001UL; /* 标记1：注入闭环验证魔数（同朋友探针） */
    *m2 = 1UL;          /* 标记2：版本号 */
}
