 if(IS("sys_obj_pega")){String k=value_key(args[1]);if(str_eq_c(k,"tamanho")){if(args[0].tag==V_LIST)return v_int((int64_t)args[0].as.list->len);if(args[0].tag==V_STRING)return v_int((int64_t)args[0].as.s.len);if(args[0].tag==V_BYTES)return v_int((int64_t)args[0].as.bytes->len);if(args[0].tag==V_OBJECT)return v_int((int64_t)args[0].as.obj->len);}if(args[0].tag!=V_OBJECT)return v_null();return obj_get(args[0].as.obj,k);}
 if(IS("sys_obj_define")){if(args[0].tag!=V_OBJECT){vm_fail(vm,"obj_define expects object");return v_null();}obj_set(args[0].as.obj,value_key(args[1]),args[2]);return args[0];}
 if(IS("sys_indice_pega")){size_t i=(size_t)number(args[1]);if(args[0].tag==V_LIST){if(i>=args[0].as.list->len){vm_fail(vm,"index out of bounds");return v_null();}return args[0].as.list->items[i];}if(args[0].tag==V_STRING){if(i>=args[0].as.s.len)return v_null();return v_str(str_n(args[0].as.s.data+i,1));}if(args[0].tag==V_BYTES){if(i>=args[0].as.bytes->len)return v_null();return v_int(args[0].as.bytes->data[i]);}return v_null();}
 if(IS("sys_indice_define")){size_t i=(size_t)number(args[1]);if(args[0].tag==V_LIST){if(i>=args[0].as.list->len){vm_fail(vm,"index define out of bounds");return v_null();}args[0].as.list->items[i]=args[2];return args[0];}if(args[0].tag==V_BYTES){if(i>=args[0].as.bytes->len){vm_fail(vm,"byte define out of bounds");return v_null();}args[0].as.bytes->data[i]=(uint8_t)number(args[2]);return args[0];}return args[0];}
 if(IS("sys_iterador_novo")){if(args[0].tag!=V_LIST){vm_fail(vm,"iterator expects list");return v_null();}Iter*it=(Iter*)xcalloc(1,sizeof(Iter));it->list=args[0].as.list;return v_iter(it);}
 if(IS("sys_iterador_tem"))return v_bool(args[0].tag==V_ITER&&args[0].as.iter->index<args[0].as.iter->list->len);
 if(IS("sys_iterador_atual")){if(args[0].tag!=V_ITER||args[0].as.iter->index>=args[0].as.iter->list->len)return v_null();return args[0].as.iter->list->items[args[0].as.iter->index];}
 if(IS("sys_iterador_avanca")){if(args[0].tag==V_ITER)args[0].as.iter->index++;return args[0];}
 if(IS("sys_texto_tamanho"))return v_int((int64_t)text(args[0]).len);
 if(IS("sys_texto_caractere")){String s=text(args[0]);size_t i=(size_t)number(args[1]);if(i>=s.len)return v_str(str_n("\0",1));return v_str(str_n(s.data+i,1));}
 if(IS("sys_texto_fatia")){String s=text(args[0]);size_t a=(size_t)number(args[1]),b=(size_t)number(args[2]);if(a>b||b>s.len){vm_fail(vm,"invalid text slice");return v_null();}return v_str(str_n(s.data+a,b-a));}
 if(IS("sys_texto_contem")){String a=text(args[0]),b=text(args[1]);if(!b.len)return v_bool(1);if(b.len>a.len)return v_bool(0);for(size_t i=0;i+b.len<=a.len;i++)if(!memcmp(a.data+i,b.data,b.len))return v_bool(1);return v_bool(0);}
 if(IS("sys_bytes_novo"))return v_bytes(bytes_new());
 if(IS("sys_bytes_coloca_byte")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}bytes_push(args[0].as.bytes,(uint8_t)number(args[1]));return args[0];}
 if(IS("sys_bytes_coloca_u32_be")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}uint32_t x=(uint32_t)number(args[1]);for(int k=3;k>=0;k--)bytes_push(args[0].as.bytes,(uint8_t)(x>>(k*8)));return args[0];}
 if(IS("sys_bytes_coloca_u64_be")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}uint64_t x=(uint64_t)number(args[1]);for(int k=7;k>=0;k--)bytes_push(args[0].as.bytes,(uint8_t)(x>>(k*8)));return args[0];}
 if(IS("sys_bytes_coloca_texto")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}String s=text(args[1]);bytes_reserve(args[0].as.bytes,args[0].as.bytes->len+s.len);memcpy(args[0].as.bytes->data+args[0].as.bytes->len,s.data,s.len);args[0].as.bytes->len+=s.len;return args[0];}
 if(IS("sys_bytes_pega")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}size_t i=(size_t)number(args[1]);if(i>=args[0].as.bytes->len){vm_fail(vm,"byte index out of bounds");return v_null();}return v_int(args[0].as.bytes->data[i]);}
 if(IS("sys_bytes_define")){if(args[0].tag!=V_BYTES){vm_fail(vm,"bytes expected");return v_null();}size_t i=(size_t)number(args[1]);if(i>=args[0].as.bytes->len){vm_fail(vm,"byte define out of bounds");return v_null();}args[0].as.bytes->data[i]=(uint8_t)number(args[2]);return args[0];}
 if(IS("sys_arquivo_existe")){String p=text(args[0]);FILE*f=fopen(p.data,"rb");if(!f)return v_bool(0);fclose(f);return v_bool(1);}
 if(IS("arquivo_ler")){String p=text(args[0]);size_t n=0;uint8_t*d=read_file(p.data,&n);if(!d){vm_fail(vm,"cannot read source file");return v_null();}return v_str(str_n((char*)d,n));}
 if(IS("sys_arquivo_grava_bytes")){String p=text(args[0]);if(args[1].tag!=V_BYTES||!write_file(p.data,args[1].as.bytes->data,args[1].as.bytes->len)){vm_fail(vm,"cannot write output file");return v_null();}return v_null();}
 if(IS("sys_vm_binaria"))return binary(vm,args[0],text(args[1]),args[2]);
 if(IS("sys_bit_nao"))return v_bool(!truth(args[0]));
 if(IS("sys_falha")){String a=text(args[0]),b=text(args[1]);snprintf(vm->error,sizeof(vm->error),"%.*s: %.*s",(int)a.len,a.data,(int)b.len,b.data);vm->failed=1;return v_null();}
 vm_fail(vm,"unknown syscall");fprintf(stderr,"unknown syscall: %.*s\n",(int)name.len,name.data);return v_null();
#undef IS
}

