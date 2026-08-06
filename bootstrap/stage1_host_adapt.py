from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = 'static int value_eq(Value a,Value b){ if(a.tag==b.tag){switch(a.tag){case V_NULL:return 1;case V_INT:return a.as.i==b.as.i;case V_BOOL:return a.as.b==b.as.b;case V_STRING:return str_eq(a.as.s,b.as.s);default:return a.as.obj==b.as.obj;}} if((a.tag==V_INT||a.tag==V_BOOL)&&(b.tag==V_INT||b.tag==V_BOOL))return number(a)==number(b);return 0; }'
new = '''static int value_eq(Value a,Value b){
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
}'''
if old in text:
    text = text.replace(old, new, 1)
elif 'case V_BYTES:' not in text:
    raise RuntimeError("Genesis value_eq implementation not found")
path.write_text(text, encoding="utf-8")
