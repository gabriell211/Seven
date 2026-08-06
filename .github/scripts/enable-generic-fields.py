from pathlib import Path

path = Path('.github/scripts/rebuild-semantic-seeds.sh')
text = path.read_text()
marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'
patch = r'''
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
old = 'static int is_field_decl(Tokens*t,int i){return i>=0&&i+2<t->n&&streq(t->v[i].text,"campo")&&t->v[i+1].kind==TK_IDENT&&streq(t->v[i+2].text,"(");}'
new = '''static int is_field_decl(Tokens*t,int i){
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
if old not in source:
    raise SystemExit('generic field declaration target not found')
path.write_text(source.replace(old, new, 1))
PY
'''
if marker not in text:
    raise SystemExit('compiler build marker not found')
path.write_text(text.replace(marker, '\n' + patch + marker, 1))
