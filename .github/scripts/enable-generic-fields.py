from pathlib import Path

path = Path('.github/scripts/rebuild-semantic-seeds.sh')
text = path.read_text()
marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
patch = r"""
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
old_field = 'static int is_field_decl(Tokens*t,int i){return i>=0&&i+2<t->n&&streq(t->v[i].text,"campo")&&t->v[i+1].kind==TK_IDENT&&streq(t->v[i+2].text,"(");}'
new_field = '''static int is_field_decl(Tokens*t,int i){
 if(!(i>=0&&i+2<t->n&&streq(t->v[i].text,"campo")&&t->v[i+1].kind==TK_IDENT))return 0;
 int j=i+2;
 if(j<t->n&&streq(t->v[j].text,"<")){
  int depth=1;j++;
  while(j<t->n&&depth){
   if(streq(t->v[j].text,"<"))depth++;
   else if(streq(t->v[j].text,">"))depth--;
   j++;
  }
 }
 return j<t->n&&streq(t->v[j].text,"(");
}'''
if old_field not in source:
    raise SystemExit('generic field declaration target not found')
source = source.replace(old_field, new_field, 1)

old_open = 'static int is_open_at(Tokens*t,int i){return is_field_decl(t,i)||(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text));}'
new_open = '''static int has_block_marker(Tokens*t,int i){
 int line=t->v[i].line;
 for(int j=i+1;j<t->n&&t->v[j].line==line;j++)if(t->v[j].kind==TK_SYMBOL&&streq(t->v[j].text,"::"))return 1;
 return 0;
}
static int is_open_at(Tokens*t,int i){return is_field_decl(t,i)||(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text)&&has_block_marker(t,i));}'''
if old_open not in source:
    raise SystemExit('contextual block opener target not found')
source = source.replace(old_open, new_open, 1)
path.write_text(source)
PY
"""
if marker not in text:
    raise SystemExit('compiler build marker not found')
path.write_text(text.replace(marker, '\n' + patch + marker, 1))
