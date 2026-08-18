/* Canopus 模块 C 构造器 glue（与 bluetooth-audio-device/c_shim/canopus_ctor.c 同构，
 * 去掉蓝牙 codec 的 rodata anchor/fixup 部分——文件管理器无解码表）。 */
#include <stdint.h>

extern int canopus_mod_prepare(const void *);
extern int canopus_register_module_descriptor(void);
extern int canopus_mod_stop(const void *);

__attribute__((constructor)) static void canopus_mod_ctor(void)
{
    (void)canopus_mod_prepare(0);
    (void)canopus_register_module_descriptor();
}

__attribute__((destructor)) static void canopus_mod_dtor(void)
{
    (void)canopus_mod_stop(0);
}
