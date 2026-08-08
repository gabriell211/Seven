#include "genesis-host.part00.inc"
#include "genesis-host.part01.inc"
#define syscall genesis_base_syscall
#include "genesis-host.part02.inc"
#include "genesis-host.part03.inc"
#undef syscall
#include "genesis-host.transition.inc"
#include "genesis-host.part04.inc"
