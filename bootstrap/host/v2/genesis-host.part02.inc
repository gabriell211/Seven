  uint32_t effects=cu32(c);for(uint32_t e=0;e<effects;e++){uint32_t ei=cu32(c);if(ei>=im.name_count)die("effect name out of bounds");}
 }
 im.code_count=cu32(c);im.code=(Instr*)xcalloc(im.code_count,sizeof(Instr));
 for(uint32_t i=0;i<im.code_count;i++){
  uint8_t raw=cbyte(c);im.code[i].op=stable_opcode(raw);im.code[i].a=cu32(c);im.code[i].b=cu32(c);(void)cu32(c);(void)cu64(c);
 }
 return im;
}
static Image load_image(const char*path){
 size_t n=0;uint8_t*b=read_file(path,&n);if(!b)die("cannot read bytecode image");Cursor c={b,n,0};need(&c,4);
 Image im={0};
 if(!memcmp(b,"SVB0",4)){c.pos=4;im=load_svbc0(&c);}
 else if(!memcmp(b,"SVBC",4)){c.pos=4;im=load_svbc1(&c);}
 else die("invalid bytecode magic");
 if(c.pos!=c.n)die("trailing bytes in bytecode image");
 for(uint32_t i=0;i<im.field_count;i++)if(im.fields[i].entry>=im.code_count)die("field entry out of bounds");
 return im;
}

static void vm_fail(VM*vm,const char*msg){vm->failed=1;snprintf(vm->error,sizeof(vm->error),"%s",msg);}
static void push(VM*vm,Value v){if(vm->sp==vm->stack_cap){vm->stack_cap=vm->stack_cap?vm->stack_cap*2:1024;vm->stack=(Value*)xrealloc(vm->stack,vm->stack_cap*sizeof(Value));}vm->stack[vm->sp++]=v;}
static Value pop(VM*vm){if(!vm->sp){vm_fail(vm,"stack underflow");return v_null();}return vm->stack[--vm->sp];}
static void frame_push(VM*vm,Frame fr){if(vm->fp==vm->frame_cap){vm->frame_cap=vm->frame_cap?vm->frame_cap*2:256;vm->frames=(Frame*)xrealloc(vm->frames,vm->frame_cap*sizeof(Frame));}vm->frames[vm->fp++]=fr;}
static String value_key(Value v){return text(v);}

static Value binary(VM*vm,Value l,String op,Value r){if(str_eq_c(op,"=="))return v_bool(value_eq(l,r));if(str_eq_c(op,"!="))return v_bool(!value_eq(l,r));if(str_eq_c(op,"+")){if(l.tag==V_STRING||r.tag==V_STRING)return v_str(str_cat(text(l),text(r)));return v_int(number(l)+number(r));}if(str_eq_c(op,"-"))return v_int(number(l)-number(r));if(str_eq_c(op,"*"))return v_int(number(l)*number(r));if(str_eq_c(op,"/")){int64_t d=number(r);if(!d){vm_fail(vm,"division by zero");return v_null();}return v_int(number(l)/d);}if(str_eq_c(op,"%")){int64_t d=number(r);if(!d){vm_fail(vm,"modulo by zero");return v_null();}return v_int(number(l)%d);}if(str_eq_c(op,"<")||str_eq_c(op,"<=")||str_eq_c(op,">")||str_eq_c(op,">=")){int cmp;if(l.tag==V_STRING&&r.tag==V_STRING){size_t n=l.as.s.len<r.as.s.len?l.as.s.len:r.as.s.len;cmp=memcmp(l.as.s.data,r.as.s.data,n);if(!cmp)cmp=l.as.s.len<r.as.s.len?-1:l.as.s.len>r.as.s.len?1:0;}else{int64_t a=number(l),b=number(r);cmp=a<b?-1:a>b?1:0;}if(str_eq_c(op,"<"))return v_bool(cmp<0);if(str_eq_c(op,"<="))return v_bool(cmp<=0);if(str_eq_c(op,">"))return v_bool(cmp>0);return v_bool(cmp>=0);}if(str_eq_c(op,"e"))return v_bool(truth(l)&&truth(r));if(str_eq_c(op,"ou"))return v_bool(truth(l)||truth(r));vm_fail(vm,"unknown binary operator");return v_null();}

static Value syscall(VM*vm,String name,Value*args,uint32_t argc){
#define IS(x) str_eq_c(name,x)
 if(IS("terminal_diga")||IS("diga")){String s=text(argc?args[0]:v_null());fwrite(s.data,1,s.len,stdout);fputc('\n',stdout);return v_null();}
 if(IS("texto")||IS("texto_u64"))return v_str(text(argc?args[0]:v_null()));
 if(IS("numero")||IS("sys_num_cast")||IS("U32")||IS("U64")||IS("Num")||IS("Byte")||IS("Real64"))return v_int(number(argc?args[0]:v_int(0)));
 if(IS("tamanho")){Value x=args[0];if(x.tag==V_STRING)return v_int((int64_t)x.as.s.len);if(x.tag==V_LIST)return v_int((int64_t)x.as.list->len);if(x.tag==V_BYTES)return v_int((int64_t)x.as.bytes->len);if(x.tag==V_OBJECT)return v_int((int64_t)x.as.obj->len);return v_int(0);}
 if(IS("sys_lista_nova"))return v_list(list_new());
 if(IS("lista_tamanho")){if(args[0].tag!=V_LIST){vm_fail(vm,"lista_tamanho expects list");return v_null();}return v_int((int64_t)args[0].as.list->len);}
 if(IS("sys_lista_coloca")||IS("lista_coloca")){if(args[0].tag!=V_LIST){vm_fail(vm,"lista_coloca expects list");return v_null();}list_push(args[0].as.list,args[1]);return args[0];}
 if(IS("sys_lista_pega")||IS("lista_pega")){if(args[0].tag!=V_LIST){vm_fail(vm,"lista_pega expects list");return v_null();}size_t i=(size_t)number(args[1]);if(i>=args[0].as.list->len){vm_fail(vm,"list index out of bounds");return v_null();}return args[0].as.list->items[i];}
 if(IS("sys_lista_define")||IS("lista_define")){if(args[0].tag!=V_LIST){vm_fail(vm,"lista_define expects list");return v_null();}size_t i=(size_t)number(args[1]);if(i>=args[0].as.list->len){vm_fail(vm,"list define out of bounds");return v_null();}args[0].as.list->items[i]=args[2];return args[0];}
 if(IS("sys_lista_insere")){if(args[0].tag!=V_LIST){vm_fail(vm,"lista_insere expects list");return v_null();}list_insert(args[0].as.list,(size_t)number(args[1]),args[2]);return args[0];}
 if(IS("sys_obj_novo")){Object*o=obj_new();for(uint32_t i=0;i+1<argc;i+=2)obj_set(o,value_key(args[i]),args[i+1]);Value t=obj_get(o,str_c("__tipo"));if(t.tag==V_STRING&&str_eq_c(t.as.s,"lista"))return v_list(list_new());return v_obj(o);}
