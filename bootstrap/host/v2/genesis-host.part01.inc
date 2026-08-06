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
