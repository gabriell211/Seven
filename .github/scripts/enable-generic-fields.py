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
}
static int is_anonymous_field(Tokens*t,int i){return i>=0&&i+1<t->n&&t->v[i].kind==TK_IDENT&&streq(t->v[i].text,"campo")&&t->v[i+1].kind==TK_SYMBOL&&streq(t->v[i+1].text,"(");}'''
if old_field not in source:
    raise SystemExit('generic field declaration target not found')
source = source.replace(old_field, new_field, 1)

old_open = 'static int is_open_at(Tokens*t,int i){return is_field_decl(t,i)||(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text));}'
new_open = '''static int has_block_marker(Tokens*t,int i){
 int line=t->v[i].line;
 for(int j=i+1;j<t->n&&t->v[j].line==line;j++)if(t->v[j].kind==TK_SYMBOL&&streq(t->v[j].text,"::"))return 1;
 return 0;
}
static int is_keyword_block(Tokens*t,int i){
 if(!(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text)&&has_block_marker(t,i)))return 0;
 if(streq(t->v[i].text,"para"))return i+1<t->n&&t->v[i+1].kind==TK_IDENT&&streq(t->v[i+1].text,"cada");
 return 1;
}
static int is_open_at(Tokens*t,int i){return is_field_decl(t,i)||is_anonymous_field(t,i)||is_keyword_block(t,i);}'''
if old_open not in source:
    raise SystemExit('contextual block opener target not found')
source = source.replace(old_open, new_open, 1)

old_extract = 'for(int i=0;i<t.n-1;i++)if(is_field_decl(&t,i)){'
new_extract = 'for(int i=0;i<t.n-1;i++)if(is_field_decl(&t,i)||is_anonymous_field(&t,i)){'
if old_extract not in source:
    raise SystemExit('field extraction target not found')
source = source.replace(old_extract, new_extract, 1)

old_skip = 'if(nf<MAX_SYMBOLS)funcs[nf++]=f;i=end;}'
new_skip = 'if(nf<MAX_SYMBOLS)funcs[nf++]=f;}'
if old_skip not in source:
    raise SystemExit('nested field extraction skip target not found')
source = source.replace(old_skip, new_skip, 1)

old_body = 'for(int i=f->body;i<f->end;i++){Token*x=&t.v[i];if('
new_body = 'for(int i=f->body;i<f->end;i++){Token*x=&t.v[i];if(is_anonymous_field(&t,i)){int nested_end=find_close(&t,i);if(nested_end>i){i=nested_end;continue;}}if('
if old_body not in source:
    raise SystemExit('nested field body target not found')
source = source.replace(old_body, new_body, 1)

path.write_text(source)
PY
"""
if marker not in text:
    raise SystemExit('compiler build marker not found')
path.write_text(text.replace(marker, '\n' + patch + marker, 1))
