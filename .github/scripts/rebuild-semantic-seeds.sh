#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-semantic-rebuild"
rm -rf "$work"
mkdir -p "$work"

git show 3e84aa820625d13370b833b59a869d4e99d81dae:.github/workflows/regenerate-semantic-seeds.yml > "$work/generator.yml"
awk '/seven-bootstrap.c.gz.b64.*B64/{capture=1;next} /^          B64$/{capture=0} capture{sub(/^          /,"");print}' "$work/generator.yml" > "$work/seven-bootstrap.c.gz.b64"
base64 --decode "$work/seven-bootstrap.c.gz.b64" | gzip --decompress > "$work/seven-bootstrap.c"

CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PY'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()

replacements = [
    (
        'typedef struct { char name[128]; char type[64]; int mutable_; int line; } Var;',
        'typedef struct { char name[128]; char type[64]; int mutable_; int line; int depth; } Var;',
    ),
    (
        'static int is_open_kw(const char*s){return streq(s,"campo")||streq(s,"molde")||streq(s,"selo")||streq(s,"veja")||streq(s,"gira")||streq(s,"para")||streq(s,"zona");}',
        'static int is_open_kw(const char*s){return streq(s,"molde")||streq(s,"selo")||streq(s,"veja")||streq(s,"gira")||streq(s,"para")||streq(s,"zona");}\n'
        'static int is_field_decl(Tokens*t,int i){return i>=0&&i+2<t->n&&streq(t->v[i].text,"campo")&&t->v[i+1].kind==TK_IDENT&&streq(t->v[i+2].text,"(");}\n'
        'static int is_open_at(Tokens*t,int i){return is_field_decl(t,i)||(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text));}',
    ),
    (
        'static int find_close(Tokens*t,int start){int d=0;for(int i=start;i<t->n;i++){if(t->v[i].kind==TK_IDENT&&is_open_kw(t->v[i].text))d++;else if(t->v[i].kind==TK_IDENT&&streq(t->v[i].text,"fecha")){d--;if(d==0)return i;}}return -1;}',
        'static int find_close(Tokens*t,int start){int d=0;for(int i=start;i<t->n;i++){if(is_open_at(t,i))d++;else if(t->v[i].kind==TK_IDENT&&streq(t->v[i].text,"fecha")){d--;if(d==0)return i;}}return -1;}\n'
        'static int scope_id(Tokens*t,int start,int end){int stack[256];int top=0;for(int i=start;i<end;i++){if(is_open_at(t,i)){if(top<256)stack[top++]=i;}else if(t->v[i].kind==TK_IDENT&&streq(t->v[i].text,"fecha")&&top>0)top--;}return top?stack[top-1]:start;}',
    ),
    (
        'static Var *var_by(Var*v,int n,const char*name){for(int i=n-1;i>=0;i--)if(streq(v[i].name,name))return &v[i];return NULL;}',
        'static Var *var_by(Var*v,int n,const char*name){for(int i=n-1;i>=0;i--)if(streq(v[i].name,name))return &v[i];return NULL;}\n'
        'static Var *var_by_depth(Var*v,int n,const char*name,int depth){for(int i=n-1;i>=0;i--)if(v[i].depth==depth&&streq(v[i].name,name))return &v[i];return NULL;}',
    ),
    (
        'else if(x->kind==TK_IDENT&&is_open_kw(x->text))blocks++;',
        'else if(x->kind==TK_IDENT&&is_open_at(&t,i))blocks++;',
    ),
    (
        'for(int i=0;i<t.n-1;i++)if(streq(t.v[i].text,"campo")){',
        'for(int i=0;i<t.n-1;i++)if(is_field_decl(&t,i)){',
    ),
    (
        'const char*name=t.v[i+1].text;if(var_by(vars,nv,name)){',
        'const char*name=t.v[i+1].text;int scope=scope_id(&t,f->body,i);if(var_by_depth(vars,nv,name,scope)){',
    ),
    (
        'v->mutable_=streq(x->text,"solta");v->line=x->line;',
        'v->mutable_=streq(x->text,"solta");v->line=x->line;v->depth=scope;',
    ),
    (
        'if(!var_by(vars,nv,n)&&!func_by(funcs,nf,n)&&!known_word(n))',
        'if(!strstr(n,".")&&!((n[0]>="A"[0])&&(n[0]<="Z"[0]))&&!var_by(vars,nv,n)&&!func_by(funcs,nf,n)&&!known_word(n))',
    ),
    (
        'for(int fi=0;fi<nf;fi++){Func*f=&funcs[fi];Var vars[MAX_SYMBOLS];int nv=0;ArrayInfo arr[MAX_SYMBOLS];int na=0;int returns=0;for(int i=f->body;i<f->end;i++){',
        'for(int fi=0;fi<nf;fi++){Func*f=&funcs[fi];Var vars[MAX_SYMBOLS];int nv=0;ArrayInfo arr[MAX_SYMBOLS];int na=0;int returns=0;for(int p=f->start+2;p+1<f->body;p++){if(t.v[p].kind==TK_IDENT&&streq(t.v[p+1].text,":")&&nv<MAX_SYMBOLS){Var*v=&vars[nv++];memset(v,0,sizeof(*v));strncpy(v->name,t.v[p].text,127);v->mutable_=0;v->line=t.v[p].line;v->depth=f->body;}}for(int i=f->body;i<f->end;i++){',
    ),
]

for old, new in replacements:
    if old not in source:
        raise SystemExit(f"checker patch target not found: {old[:120]}")
    source = source.replace(old, new, 1)

mark_rule = 'if(streq(x->text,"marca")&&i+3<f->end){ArrayInfo*a=arr_by(arr,na,t.v[i+1].text);if(a&&streq(t.v[i+2].text,"@")&&t.v[i+3].kind==TK_NUMBER&&strtoll(t.v[i+3].text,NULL,0)>=a->size)report(&r,"SV-MEM-LIMITE",&t.v[i+3],"constant index outside array bounds");}\n'
pega_rule = ' if(streq(x->text,"pega")){int j=i+1;while(j<f->end&&t.v[j].line==x->line&&!streq(t.v[j].text,"->"))j++;if(j+1<f->end&&streq(t.v[j].text,"->")&&t.v[j+1].kind==TK_IDENT&&!var_by(vars,nv,t.v[j+1].text)&&nv<MAX_SYMBOLS){Var*v=&vars[nv++];memset(v,0,sizeof(*v));strncpy(v->name,t.v[j+1].text,127);v->mutable_=0;v->line=x->line;v->depth=scope_id(&t,f->body,i);}}\n'
if mark_rule not in source:
    raise SystemExit("pega insertion target not found")
source = source.replace(mark_rule, mark_rule + pega_rule, 1)
path.write_text(source)
PY

gcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"

cat > "$work/kernel32.def" <<'DEF'
LIBRARY KERNEL32.dll
EXPORTS
 GetCommandLineA
 ExitProcess
 GetFileAttributesA
 CreateDirectoryA
DEF
cat > "$work/msvcrt.def" <<'DEF'
LIBRARY msvcrt.dll
EXPORTS
 malloc
 realloc
 free
 fopen
 fread
 fwrite
 fclose
 fseek
 ftell
 rewind
 strlen
 strcmp
 strncmp
 strstr
 memcpy
 memcmp
 memset
 strcpy
 strncpy
 sprintf
 _snprintf
 puts
 printf
 _strtoi64
DEF
link=$(command -v lld-link || command -v lld-link-18 || command -v lld-link-17)
"$link" /dll /noentry /def:"$work/kernel32.def" /out:"$work/kernel32-stub.dll" /implib:"$work/kernel32.lib"
"$link" /dll /noentry /def:"$work/msvcrt.def" /out:"$work/msvcrt-stub.dll" /implib:"$work/msvcrt.lib"
clang --target=x86_64-pc-windows-msvc -D_WIN32 -std=c11 -O2 -ffreestanding -fno-stack-protector -fno-builtin -mno-stack-arg-probe -c "$work/seven-bootstrap.c" -o "$work/seven-windows.obj"
"$link" /subsystem:console /entry:mainCRTStartup /nodefaultlib /out:"$work/seven-windows.exe" "$work/seven-windows.obj" "$work/kernel32.lib" "$work/msvcrt.lib"

seven="$work/seven-linux"
"$seven" --version
"$seven" check examples/hello.sev
"$seven" build examples/hello.sev "$work/hello.svbc"
"$seven" run examples/hello.sev
"$seven" doctor

while IFS= read -r file; do
  "$seven" check "$file"
done < <(find conformance -type f -path '*/valid/*.sev' | LC_ALL=C sort)

while IFS= read -r file; do
  if "$seven" check "$file"; then
    echo "invalid source accepted: $file"
    exit 1
  fi
done < <(find conformance -type f -path '*/invalid/*.sev' | LC_ALL=C sort)

while IFS= read -r file; do
  echo "source: $file"
  "$seven" check "$file"
done < seven.sources

mkdir -p "$work/old" "$work/new"
cat seed/native/final/v1/part*.b64 | tr -d '\r\n\t ' | base64 --decode > "$work/old.zip"
unzip -q "$work/old.zip" -d "$work/old"
cp "$work/seven-linux" "$work/new/seven-linux"
cp "$work/seven-windows.exe" "$work/new/seven-windows.exe"
cp "$work/old/seven-installer-linux" "$work/new/seven-installer-linux"
cp "$work/old/seven-installer-windows.exe" "$work/new/seven-installer-windows.exe"
chmod +x "$work/new/seven-linux" "$work/new/seven-installer-linux"
touch -t 202608060430.00 "$work/new"/*
(cd "$work/new" && zip -X -q "$work/native-seeds.zip" seven-windows.exe seven-installer-windows.exe seven-linux seven-installer-linux)

base64 -w0 "$work/native-seeds.zip" > "$work/native-seeds.b64"
SEED_WORK="$work" python - <<'PY'
import os
from pathlib import Path

work = Path(os.environ["SEED_WORK"])
encoded = (work / "native-seeds.b64").read_text()
count = 5
size = ((len(encoded) + count - 1) // count + 3) // 4 * 4
root = Path("seed/native/final/v1")
for old in root.glob("part*.b64"):
    old.unlink()
for index in range(count):
    (root / f"part{index + 1:02}.b64").write_text(encoded[index * size:(index + 1) * size])
PY

archive_sha=$(sha256sum "$work/native-seeds.zip" | cut -d' ' -f1)
linux_sha=$(sha256sum "$work/new/seven-linux" | cut -d' ' -f1)
windows_sha=$(sha256sum "$work/new/seven-windows.exe" | cut -d' ' -f1)
installer_linux_sha=$(sha256sum "$work/new/seven-installer-linux" | cut -d' ' -f1)
installer_windows_sha=$(sha256sum "$work/new/seven-installer-windows.exe" | cut -d' ' -f1)
printf '%s  native-seeds.zip\n%s  seven-linux\n%s  seven-windows.exe\n%s  seven-installer-linux\n%s  seven-installer-windows.exe\n' \
  "$archive_sha" "$linux_sha" "$windows_sha" "$installer_linux_sha" "$installer_windows_sha" \
  > seed/native/final/v1/SHA256SUMS
cat seed/native/final/v1/SHA256SUMS

git config user.name gabriell211
git config user.email 102088315+gabriell211@users.noreply.github.com
git add seed/native/final/v1/part*.b64 seed/native/final/v1/SHA256SUMS
if git diff --cached --quiet; then
  echo "validated semantic seeds are already current"
  exit 0
fi
git commit -m 'rebuild semantic seeds with parameter-aware checker'
git push origin HEAD:gabriell211/production-readiness
