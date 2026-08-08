#ifdef _WIN32
#include <direct.h>
#define seven_mkdir(path) _mkdir(path)
#else
#include <sys/stat.h>
#include <sys/types.h>
#define seven_mkdir(path) mkdir(path, 0777)
#endif

static int vm_run(Image*im,int argc,char**argv);

static Value syscall(VM*vm,String name,Value*args,uint32_t argc){
#define IS(x) str_eq_c(name,x)
 if(IS("sys_num_mod")){
  if(argc!=2){vm_fail(vm,"sys_num_mod expects two arguments");return v_null();}
  int64_t divisor=number(args[1]);
  if(!divisor){vm_fail(vm,"modulo by zero");return v_null();}
  return v_int(number(args[0])%divisor);
 }
 if(IS("sys_diretorio_cria")){
  if(argc!=1){vm_fail(vm,"sys_diretorio_cria expects one argument");return v_null();}
  String path=text(args[0]);
  if(seven_mkdir(path.data)==0||errno==EEXIST)return v_null();
  vm_fail(vm,"cannot create directory");
  return v_null();
 }
 if(IS("sys_arquivo_grava_texto")){
  if(argc!=2){vm_fail(vm,"sys_arquivo_grava_texto expects two arguments");return v_null();}
  String path=text(args[0]);
  String value=text(args[1]);
  if(!write_file(path.data,(const uint8_t*)value.data,value.len)){
    vm_fail(vm,"cannot write text file");
    return v_null();
  }
  return v_null();
 }
 if(IS("sys_svbc_run")){
  if(argc!=1){vm_fail(vm,"sys_svbc_run expects one argument");return v_null();}
  String path=text(args[0]);
  Image child=load_image(path.data);
  return v_int(vm_run(&child,0,NULL));
 }
 return genesis_base_syscall(vm,name,args,argc);
#undef IS
}

#undef seven_mkdir
