static String text(Value v){ char buf[64]; switch(v.tag){case V_NULL:return str_c("nulo");case V_BOOL:return str_c(v.as.b?"sim":"nao");case V_INT:snprintf(buf,sizeof(buf),"%lld",(long long)v.as.i);return str_c(buf);case V_STRING:return v.as.s;case V_BYTES:snprintf(buf,sizeof(buf),"<bytes:%zu>",v.as.bytes->len);return str_c(buf);case V_LIST:return str_c("<lista>");case V_OBJECT:{Value t=obj_get_c(v.as.obj,"__tipo");if(t.tag==V_STRING){String a=str_c("<"),b=str_c(">");return str_cat(str_cat(a,t.as.s),b);}return str_c("<objeto>");}case V_ITER:return str_c("<iterador>");}return str_c("<valor>"); }
static int value_eq(Value a,Value b){
 if(a.tag==b.tag){
  switch(a.tag){
   case V_NULL:return 1;
   case V_INT:return a.as.i==b.as.i;
   case V_BOOL:return a.as.b==b.as.b;
   case V_STRING:return str_eq(a.as.s,b.as.s);
   case V_BYTES:return a.as.bytes->len==b.as.bytes->len && memcmp(a.as.bytes->data,b.as.bytes->data,a.as.bytes->len)==0;
   case V_LIST:
    if(a.as.list==b.as.list)return 1;
    if(a.as.list->len!=b.as.list->len)return 0;
    for(size_t i=0;i<a.as.list->len;i++)if(!value_eq(a.as.list->items[i],b.as.list->items[i]))return 0;
    return 1;
   case V_OBJECT:
    if(a.as.obj==b.as.obj)return 1;
    if(a.as.obj->len!=b.as.obj->len)return 0;
    for(size_t i=0;i<a.as.obj->len;i++){
     int j=obj_index(b.as.obj,a.as.obj->pairs[i].key);
     if(j<0||!value_eq(a.as.obj->pairs[i].value,b.as.obj->pairs[j].value))return 0;
    }
    return 1;
   case V_ITER:return a.as.iter==b.as.iter;
  }
 }
 if((a.tag==V_INT||a.tag==V_BOOL)&&(b.tag==V_INT||b.tag==V_BOOL))return number(a)==number(b);
 return 0;
}

static uint32_t be32(const uint8_t*p){return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];}
static uint64_t be64(const uint8_t*p){uint64_t x=0;for(int i=0;i<8;i++)x=(x<<8)|p[i];return x;}
static uint8_t *read_file(const char*path,size_t*len){FILE*f=fopen(path,"rb");if(!f)return NULL;if(fseek(f,0,SEEK_END)){fclose(f);return NULL;}long n=ftell(f);if(n<0){fclose(f);return NULL;}rewind(f);uint8_t*b=(uint8_t*)xmalloc((size_t)n+1);size_t got=fread(b,1,(size_t)n,f);fclose(f);if(got!=(size_t)n){free(b);return NULL;}b[n]=0;*len=(size_t)n;return b;}
static int write_file(const char*path,const uint8_t*data,size_t len){FILE*f=fopen(path,"wb");if(!f)return 0;size_t n=fwrite(data,1,len,f);int ok=n==len&&!fclose(f);return ok;}
static int path_exists_c(const char*path){
#ifdef _WIN32
 DWORD a=GetFileAttributesA(path);return a!=INVALID_FILE_ATTRIBUTES;
#else
 struct stat st;return stat(path,&st)==0;
#endif
}
static int path_is_dir_c(const char*path){
#ifdef _WIN32
 DWORD a=GetFileAttributesA(path);return a!=INVALID_FILE_ATTRIBUTES&&(a&FILE_ATTRIBUTE_DIRECTORY);
#else
 struct stat st;return stat(path,&st)==0&&S_ISDIR(st.st_mode);
#endif
}
static int mkdir_one(const char*path){if(!path||!*path||!strcmp(path,".")||!strcmp(path,".."))return 1;
#ifdef _WIN32
 if(_mkdir(path)==0)return 1;
#else
 if(mkdir(path,0775)==0)return 1;
#endif
 return errno==EEXIST||path_is_dir_c(path);
}
static int make_dirs(const char*path){if(!path||!*path)return 1;char*s=cstr(str_c(path));for(char*p=s;*p;p++)if(*p=='\\')*p='/';char*start=s;if(strlen(s)>2&&s[1]==':')start=s+2;while(*start=='/')start++;for(char*p=start;*p;p++){if(*p=='/'){*p=0;if(!mkdir_one(s)){free(s);return 0;}*p='/';}}int ok=mkdir_one(s);free(s);return ok;}
static int make_parent_dirs(const char*path){char*s=cstr(str_c(path));for(char*p=s;*p;p++)if(*p=='\\')*p='/';char*last=strrchr(s,'/');if(!last){free(s);return 1;}*last=0;int ok=make_dirs(s);free(s);return ok;}
static char* path_join_c(const char*a,const char*b){size_t an=strlen(a),bn=strlen(b);int sep=an&&a[an-1]!='/'&&a[an-1]!='\\';char*s=(char*)xmalloc(an+bn+(sep?2:1));memcpy(s,a,an);size_t p=an;if(sep)s[p++]=PATH_SEP;memcpy(s+p,b,bn);s[p+bn]=0;return s;}
static int copy_file_path(const char*src,const char*dst){size_t n=0;uint8_t*d=read_file(src,&n);if(!d)return 0;if(!make_parent_dirs(dst)){free(d);return 0;}int ok=write_file(dst,d,n);free(d);return ok;}
static int remove_path_tree(const char*path);
static int copy_dir_tree(const char*src,const char*dst){if(!path_is_dir_c(src))return copy_file_path(src,dst);if(!make_dirs(dst))return 0;
#ifdef _WIN32
 char*pat=path_join_c(src,"*");WIN32_FIND_DATAA fd;HANDLE h=FindFirstFileA(pat,&fd);free(pat);if(h==INVALID_HANDLE_VALUE)return 1;do{if(!strcmp(fd.cFileName,".")||!strcmp(fd.cFileName,".."))continue;char*s=path_join_c(src,fd.cFileName);char*d=path_join_c(dst,fd.cFileName);int ok=(fd.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)?copy_dir_tree(s,d):copy_file_path(s,d);free(s);free(d);if(!ok){FindClose(h);return 0;}}while(FindNextFileA(h,&fd));FindClose(h);return 1;
#else
 DIR*dir=opendir(src);if(!dir)return 0;struct dirent*e;while((e=readdir(dir))){if(!strcmp(e->d_name,".")||!strcmp(e->d_name,".."))continue;char*s=path_join_c(src,e->d_name);char*d=path_join_c(dst,e->d_name);int ok=path_is_dir_c(s)?copy_dir_tree(s,d):copy_file_path(s,d);free(s);free(d);if(!ok){closedir(dir);return 0;}}closedir(dir);return 1;
#endif
}
static int remove_path_tree(const char*path){if(!path_exists_c(path))return 1;if(!path_is_dir_c(path))return remove(path)==0||errno==ENOENT;
#ifdef _WIN32
 char*pat=path_join_c(path,"*");WIN32_FIND_DATAA fd;HANDLE h=FindFirstFileA(pat,&fd);free(pat);if(h!=INVALID_HANDLE_VALUE){do{if(!strcmp(fd.cFileName,".")||!strcmp(fd.cFileName,".."))continue;char*p=path_join_c(path,fd.cFileName);int ok=remove_path_tree(p);free(p);if(!ok){FindClose(h);return 0;}}while(FindNextFileA(h,&fd));FindClose(h);}return RemoveDirectoryA(path)!=0;
#else
 DIR*dir=opendir(path);if(dir){struct dirent*e;while((e=readdir(dir))){if(!strcmp(e->d_name,".")||!strcmp(e->d_name,".."))continue;char*p=path_join_c(path,e->d_name);int ok=remove_path_tree(p);free(p);if(!ok){closedir(dir);return 0;}}closedir(dir);}return rmdir(path)==0||errno==ENOENT;
#endif
}
static int chmod_exec_c(const char*path,int64_t mode){
#ifdef _WIN32
 (void)path;(void)mode;return 1;
#else
 return chmod(path,(mode_t)mode)==0;
#endif
}
static int link_file_c(const char*src,const char*dst){if(!make_parent_dirs(dst))return 0;
#ifdef _WIN32
 return copy_file_path(src,dst);
#else
 return symlink(src,dst)==0;
#endif
}
typedef struct Sha256Ctx{uint8_t data[64];uint32_t datalen;uint64_t bitlen;uint32_t state[8];}Sha256Ctx;
static uint32_t sha_rotr(uint32_t x,uint32_t n){return (x>>n)|(x<<(32-n));}
static void sha256_transform(Sha256Ctx*ctx,const uint8_t data[]){
 static const uint32_t k[64]={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2};
 uint32_t a,b,c,d,e,f,g,h,i,j,t1,t2,m[64];
 for(i=0,j=0;i<16;i++,j+=4)m[i]=((uint32_t)data[j]<<24)|((uint32_t)data[j+1]<<16)|((uint32_t)data[j+2]<<8)|data[j+3];
 for(;i<64;i++){uint32_t s0=sha_rotr(m[i-15],7)^sha_rotr(m[i-15],18)^(m[i-15]>>3);uint32_t s1=sha_rotr(m[i-2],17)^sha_rotr(m[i-2],19)^(m[i-2]>>10);m[i]=m[i-16]+s0+m[i-7]+s1;}
 a=ctx->state[0];b=ctx->state[1];c=ctx->state[2];d=ctx->state[3];e=ctx->state[4];f=ctx->state[5];g=ctx->state[6];h=ctx->state[7];
 for(i=0;i<64;i++){uint32_t S1=sha_rotr(e,6)^sha_rotr(e,11)^sha_rotr(e,25);uint32_t ch=(e&f)^((~e)&g);t1=h+S1+ch+k[i]+m[i];uint32_t S0=sha_rotr(a,2)^sha_rotr(a,13)^sha_rotr(a,22);uint32_t maj=(a&b)^(a&c)^(b&c);t2=S0+maj;h=g;g=f;f=e;e=d+t1;d=c;c=b;b=a;a=t1+t2;}
 ctx->state[0]+=a;ctx->state[1]+=b;ctx->state[2]+=c;ctx->state[3]+=d;ctx->state[4]+=e;ctx->state[5]+=f;ctx->state[6]+=g;ctx->state[7]+=h;
}
static void sha256_init(Sha256Ctx*ctx){ctx->datalen=0;ctx->bitlen=0;ctx->state[0]=0x6a09e667;ctx->state[1]=0xbb67ae85;ctx->state[2]=0x3c6ef372;ctx->state[3]=0xa54ff53a;ctx->state[4]=0x510e527f;ctx->state[5]=0x9b05688c;ctx->state[6]=0x1f83d9ab;ctx->state[7]=0x5be0cd19;}
static void sha256_update(Sha256Ctx*ctx,const uint8_t*data,size_t len){for(size_t i=0;i<len;i++){ctx->data[ctx->datalen++]=data[i];if(ctx->datalen==64){sha256_transform(ctx,ctx->data);ctx->bitlen+=512;ctx->datalen=0;}}}
static void sha256_final(Sha256Ctx*ctx,uint8_t hash[32]){uint32_t i=ctx->datalen;i<56? (ctx->data[i++]=0x80) : (ctx->data[i++]=0x80);if(i>56){while(i<64)ctx->data[i++]=0;sha256_transform(ctx,ctx->data);i=0;}while(i<56)ctx->data[i++]=0;ctx->bitlen+=ctx->datalen*8;for(int s=0;s<8;s++)ctx->data[63-s]=(uint8_t)(ctx->bitlen>>(s*8));sha256_transform(ctx,ctx->data);for(i=0;i<4;i++)for(int j=0;j<8;j++)hash[i+j*4]=(uint8_t)(ctx->state[j]>>(24-i*8));}
static Bytes* sha256_bytes_value(Bytes*input){uint8_t out[32];Sha256Ctx ctx;sha256_init(&ctx);sha256_update(&ctx,input->data,input->len);sha256_final(&ctx,out);Bytes*b=bytes_new();bytes_reserve(b,32);memcpy(b->data,out,32);b->len=32;return b;}
typedef struct Cursor{uint8_t*p;size_t n,pos;}Cursor;
static void need(Cursor*c,size_t n){if(c->pos+n>c->n)die("truncated SVBC0 image");}
static uint32_t cu32(Cursor*c){need(c,4);uint32_t x=be32(c->p+c->pos);c->pos+=4;return x;}
static uint64_t cu64(Cursor*c){need(c,8);uint64_t x=be64(c->p+c->pos);c->pos+=8;return x;}
static uint8_t cbyte(Cursor*c){need(c,1);return c->p[c->pos++];}
static String ctext(Cursor*c){uint32_t n=cu32(c);need(c,n);String s=str_n((char*)c->p+c->pos,n);c->pos+=n;return s;}
static uint8_t stable_opcode(uint8_t op){
 switch(op){
  case 0:return 0;case 1:return 20;case 2:return 3;case 3:return 4;
  case 4:return 5;case 5:return 6;case 6:return 7;case 7:return 8;
  case 8:return 9;case 9:return 21;case 10:return 10;case 11:return 22;
  case 12:return 23;case 13:return 24;case 14:return 11;case 15:return 12;
  case 16:return 13;case 17:return 14;case 18:return 15;case 19:return 16;
  case 20:return 17;case 21:return 18;case 22:return 19;
  default:die("unsupported stable SVBC opcode");
 }
 return 0;
}
static Image load_svbc0(Cursor*c){
 Image im={0};
 if(cu32(c)!=1)die("unsupported SVBC0 version");
 im.name_count=cu32(c);im.names=(String*)xcalloc(im.name_count,sizeof(String));for(uint32_t i=0;i<im.name_count;i++)im.names[i]=ctext(c);
 im.text_count=cu32(c);im.texts=(String*)xcalloc(im.text_count,sizeof(String));for(uint32_t i=0;i<im.text_count;i++)im.texts[i]=ctext(c);
 im.num_count=cu32(c);im.nums=(uint32_t*)xcalloc(im.num_count,sizeof(uint32_t));for(uint32_t i=0;i<im.num_count;i++)im.nums[i]=cu32(c);
 im.field_count=cu32(c);im.fields=(Field*)xcalloc(im.field_count,sizeof(Field));
 for(uint32_t i=0;i<im.field_count;i++){uint32_t ni=cu32(c);if(ni>=im.name_count)die("field name out of bounds");im.fields[i].name=im.names[ni];im.fields[i].entry=cu32(c);im.fields[i].locals=cu32(c);im.fields[i].params=cu32(c);}
 im.code_count=cu32(c);im.code=(Instr*)xcalloc(im.code_count,sizeof(Instr));for(uint32_t i=0;i<im.code_count;i++){im.code[i].op=cbyte(c);im.code[i].a=cu32(c);im.code[i].b=cu32(c);}
 return im;
}
static Image load_svbc1(Cursor*c){
 Image im={0};im.stable=1;
 if(cu32(c)!=1)die("unsupported SVBC version");
 im.name_count=cu32(c);im.names=(String*)xcalloc(im.name_count,sizeof(String));for(uint32_t i=0;i<im.name_count;i++)im.names[i]=ctext(c);
 im.const_count=cu32(c);im.consts=(Value*)xcalloc(im.const_count,sizeof(Value));
 for(uint32_t i=0;i<im.const_count;i++){
  uint8_t tag=cbyte(c);
  if(tag==0)im.consts[i]=v_null();
  else if(tag==2)im.consts[i]=v_bool(cbyte(c));
  else if(tag==3)im.consts[i]=v_int((int64_t)cu64(c));
  else if(tag==4)im.consts[i]=v_str(ctext(c));
  else die("unsupported SVBC constant tag");
 }
 im.field_count=cu32(c);im.fields=(Field*)xcalloc(im.field_count,sizeof(Field));
 for(uint32_t i=0;i<im.field_count;i++){
  uint32_t ni=cu32(c);if(ni>=im.name_count)die("field name out of bounds");im.fields[i].name=im.names[ni];
  uint64_t entry=cu64(c);if(entry>UINT32_MAX)die("field entry too large");im.fields[i].entry=(uint32_t)entry;
  im.fields[i].locals=cu32(c);im.fields[i].params=cu32(c);
