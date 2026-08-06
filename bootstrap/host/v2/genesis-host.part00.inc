#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

#ifdef _WIN32
#define PATH_SEP '\\'
#else
#define PATH_SEP '/'
#endif

typedef struct String { char *data; size_t len; } String;
typedef struct Value Value;
typedef struct List List;
typedef struct Object Object;
typedef struct Bytes Bytes;
typedef struct Iter Iter;

typedef enum { V_NULL, V_INT, V_BOOL, V_STRING, V_BYTES, V_LIST, V_OBJECT, V_ITER } VTag;
struct Value { VTag tag; union { int64_t i; int b; String s; Bytes *bytes; List *list; Object *obj; Iter *iter; } as; };
struct List { Value *items; size_t len, cap; };
typedef struct Pair { String key; Value value; } Pair;
struct Object { Pair *pairs; size_t len, cap; };
struct Bytes { uint8_t *data; size_t len, cap; };
struct Iter { List *list; size_t index; };

typedef struct Field { String name; uint32_t entry, locals, params; } Field;
typedef struct Instr { uint8_t op; uint32_t a,b; } Instr;
typedef struct Image { String *names,*texts; uint32_t *nums; Value *consts; Field *fields; Instr *code; uint32_t name_count,text_count,num_count,const_count,field_count,code_count; int stable; } Image;
typedef struct Frame { uint32_t field, ret_ip; Value *locals; uint32_t local_count; } Frame;
typedef struct VM { Image *img; Value *stack; size_t sp, stack_cap; Frame *frames; size_t fp, frame_cap; uint32_t field, ip; Value *locals; uint32_t local_count; int failed; char error[512]; } VM;

static void die(const char *msg) { fprintf(stderr,"genesis-host: %s\n",msg); exit(1); }
static void *xmalloc(size_t n){ void *p=malloc(n?n:1); if(!p) die("out of memory"); return p; }
static void *xcalloc(size_t n,size_t s){ void *p=calloc(n?n:1,s?s:1); if(!p) die("out of memory"); return p; }
static void *xrealloc(void *p,size_t n){ void *q=realloc(p,n?n:1); if(!q) die("out of memory"); return q; }
static String str_n(const char *p,size_t n){ String s; s.data=(char*)xmalloc(n+1); memcpy(s.data,p,n); s.data[n]=0; s.len=n; return s; }
static String str_c(const char *p){ return str_n(p,strlen(p)); }
static int str_eq(String a,String b){ return a.len==b.len && memcmp(a.data,b.data,a.len)==0; }
static int str_eq_c(String a,const char *b){ size_t n=strlen(b); return a.len==n && memcmp(a.data,b,n)==0; }
static String str_cat(String a,String b){ String s; s.len=a.len+b.len; s.data=(char*)xmalloc(s.len+1); memcpy(s.data,a.data,a.len); memcpy(s.data+a.len,b.data,b.len); s.data[s.len]=0; return s; }
static Value v_null(void){ Value v={0}; v.tag=V_NULL; return v; }
static Value v_int(int64_t x){ Value v={0}; v.tag=V_INT; v.as.i=x; return v; }
static Value v_bool(int x){ Value v={0}; v.tag=V_BOOL; v.as.b=!!x; return v; }
static Value v_str(String s){ Value v={0}; v.tag=V_STRING; v.as.s=s; return v; }
static Value v_str_c(const char *s){ return v_str(str_c(s)); }
static List *list_new(void){ return (List*)xcalloc(1,sizeof(List)); }
static void list_reserve(List *l,size_t n){ if(n<=l->cap)return; size_t c=l->cap?l->cap*2:8; while(c<n)c*=2; l->items=(Value*)xrealloc(l->items,c*sizeof(Value)); l->cap=c; }
static void list_push(List*l,Value v){ list_reserve(l,l->len+1); l->items[l->len++]=v; }
static void list_insert(List*l,size_t i,Value v){ if(i>l->len)i=l->len; list_reserve(l,l->len+1); memmove(l->items+i+1,l->items+i,(l->len-i)*sizeof(Value)); l->items[i]=v; l->len++; }
static Value v_list(List*l){ Value v={0};v.tag=V_LIST;v.as.list=l;return v; }
static Object *obj_new(void){ return (Object*)xcalloc(1,sizeof(Object)); }
static void obj_reserve(Object*o,size_t n){ if(n<=o->cap)return;size_t c=o->cap?o->cap*2:8;while(c<n)c*=2;o->pairs=(Pair*)xrealloc(o->pairs,c*sizeof(Pair));o->cap=c; }
static int obj_index(Object*o,String k){ for(size_t i=0;i<o->len;i++)if(str_eq(o->pairs[i].key,k))return (int)i;return -1; }
static void obj_set(Object*o,String k,Value v){ int i=obj_index(o,k);if(i>=0){o->pairs[i].value=v;return;}obj_reserve(o,o->len+1);o->pairs[o->len].key=k;o->pairs[o->len].value=v;o->len++; }
static Value obj_get(Object*o,String k){ int i=obj_index(o,k);return i>=0?o->pairs[i].value:v_null(); }
static Value obj_get_c(Object*o,const char*k){ size_t n=strlen(k);for(size_t i=0;i<o->len;i++)if(o->pairs[i].key.len==n&&!memcmp(o->pairs[i].key.data,k,n))return o->pairs[i].value;return v_null(); }
static Value v_obj(Object*o){ Value v={0};v.tag=V_OBJECT;v.as.obj=o;return v; }
static Bytes *bytes_new(void){ return (Bytes*)xcalloc(1,sizeof(Bytes)); }
static void bytes_reserve(Bytes*b,size_t n){ if(n<=b->cap)return;size_t c=b->cap?b->cap*2:64;while(c<n)c*=2;b->data=(uint8_t*)xrealloc(b->data,c);b->cap=c; }
static void bytes_push(Bytes*b,uint8_t x){bytes_reserve(b,b->len+1);b->data[b->len++]=x;}
static Value v_bytes(Bytes*b){Value v={0};v.tag=V_BYTES;v.as.bytes=b;return v;}
static Value v_iter(Iter*i){Value v={0};v.tag=V_ITER;v.as.iter=i;return v;}

static int truth(Value v){ switch(v.tag){case V_NULL:return 0;case V_INT:return v.as.i!=0;case V_BOOL:return v.as.b;case V_STRING:return v.as.s.len>0;case V_BYTES:return v.as.bytes->len>0;case V_LIST:return v.as.list->len>0;case V_OBJECT:return v.as.obj->len>0;case V_ITER:return v.as.iter->index<v.as.iter->list->len;}return 0; }
static int64_t number(Value v){ if(v.tag==V_INT)return v.as.i;if(v.tag==V_BOOL)return v.as.b;if(v.tag==V_STRING){char *e=0; long long x=strtoll(v.as.s.data,&e,0);return e==v.as.s.data?0:x;}return 0; }
