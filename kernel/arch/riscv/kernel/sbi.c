#include "types.h"
#include "sbi.h"

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0,
                        uint64 arg1, uint64 arg2,
                        uint64 arg3, uint64 arg4,
                        uint64 arg5)
{
  struct sbiret ret;
  uint64 error, value;
  asm volatile (
      "mv a0, %[arg0]\n"
      "mv a1, %[arg1]\n"
      "mv a2, %[arg2]\n"
      "mv a3, %[arg3]\n"
      "mv a4, %[arg4]\n"
      "mv a5, %[arg5]\n"
      "mv a6, %[fid]\n"
      "mv a7, %[ext]\n"
      "ecall\n"
      "mv %[error], a0\n"
      "mv %[value], a1"
      : [error] "=r" (error), [value] "=r" (value)
      : [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5), [fid] "r" (fid), [ext] "r" (ext)
      : "a0", "a1", "memory"
  );
  ret.error = error;
  ret.value = value;
  return ret;
}
void sbi_set_timer(uint64 stime_value) {
    sbi_ecall(0x00, 0, stime_value, 0, 0, 0, 0, 0);
    return;
}

int sbi_console_getchar() {
    struct sbiret ret;
    ret = sbi_ecall(0x02, 0, 0, 0, 0, 0, 0, 0);
    return ret.error;
}
