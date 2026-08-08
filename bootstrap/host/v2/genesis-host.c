#ifdef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#endif

#include "genesis-host.part00.inc"
#include "genesis-host.part01.inc"
#define syscall genesis_base_syscall
#include "genesis-host.part02.inc"
#include "genesis-host.part03.inc"
#undef syscall
#include "genesis-host.transition.inc"
#ifdef SEVEN_RELEASE_HOST
#define main genesis_bootstrap_main
#endif
#include "genesis-host.part04.inc"
#ifdef SEVEN_RELEASE_HOST
#undef main
int main(int argc,char**argv){return transition_release_main(argc,argv);}
#endif
