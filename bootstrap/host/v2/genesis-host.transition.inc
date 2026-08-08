#ifdef _WIN32
#include <direct.h>
#define seven_mkdir(path) _mkdir(path)
#else
#include <sys/stat.h>
#include <sys/types.h>
#define seven_mkdir(path) mkdir(path, 0777)
#endif

#ifdef SEVEN_RELEASE_HOST
#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif
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

#ifdef SEVEN_RELEASE_HOST
static char* transition_last_path_sep(char*path){
 char*last=NULL;
 for(char*p=path;*p;p++)if(*p=='/'||*p=='\\')last=p;
 return last;
}

static int transition_release_main(int argc,char**argv){
 char executable[4096];
#ifdef _WIN32
 DWORD length=GetModuleFileNameA(NULL,executable,(DWORD)sizeof(executable));
 if(length==0||length>=sizeof(executable))die("cannot resolve release executable path");
 executable[length]=0;
#else
 ssize_t length=readlink("/proc/self/exe",executable,sizeof(executable)-1);
 if(length<0){
  if(!argc||!argv||!argv[0])die("cannot resolve release executable path");
  size_t fallback=strlen(argv[0]);
  if(fallback>=sizeof(executable))die("release executable path too long");
  memcpy(executable,argv[0],fallback+1);
 }else executable[length]=0;
#endif

 char*file_sep=transition_last_path_sep(executable);
 if(!file_sep)die("release executable must live inside bin directory");
 *file_sep=0;
 char*bin_sep=transition_last_path_sep(executable);
 if(!bin_sep)die("cannot resolve release root directory");
 *bin_sep=0;

 char image_path[4096];
 int written=snprintf(image_path,sizeof(image_path),"%s%cseven.svbc",executable,PATH_SEP);
 if(written<0||(size_t)written>=sizeof(image_path))die("release image path too long");
 Image image=load_image(image_path);
 return vm_run(&image,argc>0?argc-1:0,argc>0?argv+1:NULL);
}
#endif

#undef seven_mkdir
