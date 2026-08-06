#!/usr/bin/env bash
set -euo pipefail

work="${RUNNER_TEMP:-/tmp}/seven-web-seed"
rm -rf "$work"
mkdir -p "$work" .github/scripts

git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/rebuild-semantic-seeds.sh > .github/scripts/rebuild-semantic-seeds.sh
git show e4a709ae6a3f0af55c8b7db84beb8a5d09d49241:.github/scripts/enable-generic-fields.py > .github/scripts/enable-generic-fields.py
python .github/scripts/enable-generic-fields.py

REBUILD_SCRIPT=".github/scripts/rebuild-semantic-seeds.sh" python - <<'PY'
import json
import os
from pathlib import Path

path = Path(os.environ["REBUILD_SCRIPT"])
text = path.read_text()
build_marker = '\ngcc -std=c11 -O2 -s -Wall -Wextra -Wno-unused-parameter "$work/seven-bootstrap.c" -o "$work/seven-linux"\n'

html = '''<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="generator" content="Seven 0.2.0 WebAssembly">
  <title>Seven Web</title>
</head>
<body>
  <main id="seven-app"><pre id="seven-output"></pre></main>
  <script type="module" src="./seven-loader.mjs"></script>
</body>
</html>
'''

loader = r'''const decoder = new TextDecoder();
const output = document.getElementById('seven-output');
let memory;
const imports = { seven: {
  terminal_diga(ptr, len) {
    const texto = decoder.decode(new Uint8Array(memory.buffer, ptr, len));
    if (output) output.textContent += texto + '\n';
  }
} };
const resposta = await fetch('./app.wasm', { cache: 'no-store' });
if (!resposta.ok) throw new Error(`Falha ao carregar app.wasm (${resposta.status})`);
const bytes = await resposta.arrayBuffer();
const modulo = await WebAssembly.instantiate(bytes, imports);
memory = modulo.instance.exports.memory;
const codigo = modulo.instance.exports.seven_start();
globalThis.SevenWeb = Object.freeze({ instance: modulo.instance, codigo });
'''

manifest_format = '''{
  "format": "seven-web-1",
  "language": "Seven",
  "sourceExtension": ".sev",
  "target": "webassembly",
  "executable": "app.wasm",
  "entryExport": "seven_start",
  "hostAbi": "seven-web-1",
  "applicationLanguageDependency": false,
  "sha256": "%s"
}
'''

def c_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=True)

web_code = r'''
typedef struct { unsigned char*p; size_t n; size_t cap; } SevenWebBuf;
typedef struct { char*texto; size_t tamanho; uint32_t deslocamento; } SevenWebMensagem;

static int seven_web_reserva(SevenWebBuf*b,size_t extra){
 size_t need=b->n+extra;if(need<=b->cap)return 1;
 size_t cap=b->cap?b->cap:128;while(cap<need){if(cap>SIZE_MAX/2)return 0;cap*=2;}
 unsigned char*p=(unsigned char*)realloc(b->p,cap);if(!p)return 0;b->p=p;b->cap=cap;return 1;
}
static int seven_web_u8(SevenWebBuf*b,unsigned value){if(!seven_web_reserva(b,1))return 0;b->p[b->n++]=(unsigned char)value;return 1;}
static int seven_web_bytes(SevenWebBuf*b,const void*data,size_t n){if(!seven_web_reserva(b,n))return 0;memcpy(b->p+b->n,data,n);b->n+=n;return 1;}
static int seven_web_uleb(SevenWebBuf*b,uint32_t value){do{unsigned char byte=(unsigned char)(value&0x7f);value>>=7;if(value)byte|=0x80;if(!seven_web_u8(b,byte))return 0;}while(value);return 1;}
static int seven_web_sleb(SevenWebBuf*b,int32_t value){int more=1;while(more){unsigned char byte=(unsigned char)(value&0x7f);int sign=byte&0x40;value>>=7;if((value==0&&!sign)||(value==-1&&sign))more=0;else byte|=0x80;if(!seven_web_u8(b,byte))return 0;}return 1;}
static int seven_web_nome(SevenWebBuf*b,const char*s){size_t n=strlen(s);return n<=UINT32_MAX&&seven_web_uleb(b,(uint32_t)n)&&seven_web_bytes(b,s,n);}
static int seven_web_secao(SevenWebBuf*mod,unsigned id,SevenWebBuf*sec){return sec->n<=UINT32_MAX&&seven_web_u8(mod,id)&&seven_web_uleb(mod,(uint32_t)sec->n)&&seven_web_bytes(mod,sec->p,sec->n);}
static void seven_web_libera(SevenWebBuf*b){free(b->p);b->p=NULL;b->n=0;b->cap=0;}
static int seven_web_ident(int c){return isalnum((unsigned char)c)||c=='_';}
static const char*seven_web_espacos(const char*p){
 for(;;){while(*p&&isspace((unsigned char)*p))p++;
  if(p[0]=='/'&&p[1]=='/'){p+=2;while(*p&&*p!='\n')p++;continue;}
  if(p[0]=='/'&&p[1]=='*'){int d=1;p+=2;while(*p&&d){if(p[0]=='/'&&p[1]=='*'){d++;p+=2;}else if(p[0]=='*'&&p[1]=='/'){d--;p+=2;}else p++;}continue;}
  return p;
 }
}
static char*seven_web_string(const char**cursor,size_t*out_n){
 const char*p=seven_web_espacos(*cursor);if(*p=='(')p=seven_web_espacos(p+1);if(*p!='"')return NULL;p++;
 size_t cap=64,n=0;char*out=(char*)malloc(cap);if(!out)return NULL;
 while(*p&&*p!='"'){unsigned char c=(unsigned char)*p++;
  if(c=='\\'&&*p){unsigned char e=(unsigned char)*p++;if(e=='n')c='\n';else if(e=='r')c='\r';else if(e=='t')c='\t';else if(e=='"')c='"';else if(e=='\\')c='\\';else c=e;}
  if(n==cap){cap*=2;char*q=(char*)realloc(out,cap);if(!q){free(out);return NULL;}out=q;}out[n++]=(char)c;
 }
 if(*p!='"'){free(out);return NULL;}p++;*cursor=p;*out_n=n;return out;
}
static int seven_web_mensagens(const char*src,SevenWebMensagem*msgs,int cap){
 int count=0;const char*p=src;
 while(*p){if(*p=='"'){p++;while(*p&&*p!='"'){if(*p=='\\'&&p[1])p+=2;else p++;}if(*p)p++;continue;}
  if(p[0]=='/'&&p[1]=='/'){while(*p&&*p!='\n')p++;continue;}
  if(p[0]=='/'&&p[1]=='*'){p=seven_web_espacos(p);continue;}
  if((p==src||!seven_web_ident((unsigned char)p[-1]))&&strncmp(p,"diga",4)==0&&!seven_web_ident((unsigned char)p[4])){
   const char*q=p+4;size_t n=0;char*s=seven_web_string(&q,&n);if(!s)return -1;if(count>=cap){free(s);return -2;}
   msgs[count].texto=s;msgs[count].tamanho=n;msgs[count].deslocamento=0;count++;p=q;continue;
  }p++;
 }
 return count;
}
static int32_t seven_web_retorno(const char*src){
 const char*p=src;int32_t value=0;
 while((p=strstr(p,"devolve"))!=NULL){if((p==src||!seven_web_ident((unsigned char)p[-1]))&&!seven_web_ident((unsigned char)p[7])){
   const char*q=seven_web_espacos(p+7);char*end=NULL;long long v=strtoll(q,&end,0);if(end!=q)value=(int32_t)v;
  }p+=7;
 }return value;
}
static int seven_web_emite(const char*src,SevenWebBuf*mod){
 SevenWebMensagem msgs[256];memset(msgs,0,sizeof(msgs));int count=seven_web_mensagens(src,msgs,256);if(count<0){puts("SV-WASM-TEXTO: diga exige texto constante");return 0;}
 SevenWebBuf dados={0};uint32_t off=1024;
 for(int i=0;i<count;i++){if(msgs[i].tamanho>UINT32_MAX-off||off+msgs[i].tamanho>65536){puts("SV-WASM-MEMORIA: dados excedem uma pagina");goto fail;}msgs[i].deslocamento=off;if(!seven_web_bytes(&dados,msgs[i].texto,msgs[i].tamanho))goto fail;off+=(uint32_t)msgs[i].tamanho;}
 if(!seven_web_bytes(mod,"\0asm\1\0\0\0",8))goto fail;
 SevenWebBuf s={0};
 if(!seven_web_uleb(&s,2)||!seven_web_u8(&s,0x60)||!seven_web_uleb(&s,2)||!seven_web_u8(&s,0x7f)||!seven_web_u8(&s,0x7f)||!seven_web_uleb(&s,0)||
    !seven_web_u8(&s,0x60)||!seven_web_uleb(&s,0)||!seven_web_uleb(&s,1)||!seven_web_u8(&s,0x7f)||!seven_web_secao(mod,1,&s))goto fail;seven_web_libera(&s);
 if(!seven_web_uleb(&s,1)||!seven_web_nome(&s,"seven")||!seven_web_nome(&s,"terminal_diga")||!seven_web_u8(&s,0)||!seven_web_uleb(&s,0)||!seven_web_secao(mod,2,&s))goto fail;seven_web_libera(&s);
 if(!seven_web_uleb(&s,1)||!seven_web_uleb(&s,1)||!seven_web_secao(mod,3,&s))goto fail;seven_web_libera(&s);
 if(!seven_web_uleb(&s,1)||!seven_web_u8(&s,0)||!seven_web_uleb(&s,1)||!seven_web_secao(mod,5,&s))goto fail;seven_web_libera(&s);
 if(!seven_web_uleb(&s,2)||!seven_web_nome(&s,"memory")||!seven_web_u8(&s,2)||!seven_web_uleb(&s,0)||
    !seven_web_nome(&s,"seven_start")||!seven_web_u8(&s,0)||!seven_web_uleb(&s,1)||!seven_web_secao(mod,7,&s))goto fail;seven_web_libera(&s);
 SevenWebBuf body={0};if(!seven_web_uleb(&body,0))goto fail;
 for(int i=0;i<count;i++){if(!seven_web_u8(&body,0x41)||!seven_web_sleb(&body,(int32_t)msgs[i].deslocamento)||!seven_web_u8(&body,0x41)||!seven_web_sleb(&body,(int32_t)msgs[i].tamanho)||!seven_web_u8(&body,0x10)||!seven_web_uleb(&body,0))goto fail;}
 if(!seven_web_u8(&body,0x41)||!seven_web_sleb(&body,seven_web_retorno(src))||!seven_web_u8(&body,0x0b))goto fail;
 if(!seven_web_uleb(&s,1)||body.n>UINT32_MAX||!seven_web_uleb(&s,(uint32_t)body.n)||!seven_web_bytes(&s,body.p,body.n)||!seven_web_secao(mod,10,&s))goto fail;seven_web_libera(&body);seven_web_libera(&s);
 if(!seven_web_uleb(&s,1)||!seven_web_uleb(&s,0)||!seven_web_u8(&s,0x41)||!seven_web_sleb(&s,1024)||!seven_web_u8(&s,0x0b)||dados.n>UINT32_MAX||!seven_web_uleb(&s,(uint32_t)dados.n)||!seven_web_bytes(&s,dados.p,dados.n)||!seven_web_secao(mod,11,&s))goto fail;
 seven_web_libera(&s);seven_web_libera(&dados);for(int i=0;i<count;i++)free(msgs[i].texto);return 1;
fail:
 seven_web_libera(&s);seven_web_libera(&dados);for(int i=0;i<count;i++)free(msgs[i].texto);seven_web_libera(mod);puts("SV-WASM-MEMORIA: falha emitindo modulo");return 0;
}
static int seven_web_path(char*out,size_t cap,const char*dir,const char*name){int n=snprintf(out,cap,"%s/%s",dir,name);if(n<0||(size_t)n>=cap){puts("SV-WEB-CAMINHO: caminho de saida muito longo");return 0;}return 1;}
static int cmd_web_build(const char*in,const char*out_dir){
 if(!out_dir||!*out_dir)out_dir="build/web";if(cmd_check(in,0))return 1;
 size_t source_n=0;char*source=read_file(in,&source_n);if(!source)return 1;
 SevenWebBuf wasm={0};if(!seven_web_emite(source,&wasm)){free(source);return 1;}free(source);
 char app[MAX_PATH_LEN],index[MAX_PATH_LEN],loader_path[MAX_PATH_LEN],manifest_path[MAX_PATH_LEN],sum_path[MAX_PATH_LEN];
 if(!seven_web_path(app,sizeof(app),out_dir,"app.wasm")||!seven_web_path(index,sizeof(index),out_dir,"index.html")||
    !seven_web_path(loader_path,sizeof(loader_path),out_dir,"seven-loader.mjs")||!seven_web_path(manifest_path,sizeof(manifest_path),out_dir,"seven.web.json")||
    !seven_web_path(sum_path,sizeof(sum_path),out_dir,"app.wasm.sha256")){seven_web_libera(&wasm);return 1;}
 char digest[65];hash_hex((const char*)wasm.p,wasm.n,digest);
 const char*html=SEVEN_WEB_HTML;const char*loader=SEVEN_WEB_LOADER;const char*manifest_format=SEVEN_WEB_MANIFEST;
 char manifest[1024],sum[160];int mn=snprintf(manifest,sizeof(manifest),manifest_format,digest);int sn=snprintf(sum,sizeof(sum),"%s  app.wasm\n",digest);
 if(mn<0||(size_t)mn>=sizeof(manifest)||sn<0||(size_t)sn>=sizeof(sum)||
    !write_file(app,(const char*)wasm.p,wasm.n)||!write_file(index,html,strlen(html))||!write_file(loader_path,loader,strlen(loader))||
    !write_file(manifest_path,manifest,(size_t)mn)||!write_file(sum_path,sum,(size_t)sn)){seven_web_libera(&wasm);return 1;}
 seven_web_libera(&wasm);printf("web wasm: %s\n",app);printf("web sha256: %s\n",digest);return 0;
}
'''

defines = (
    f'\n#define SEVEN_WEB_HTML {c_string(html)}\n'
    f'#define SEVEN_WEB_LOADER {c_string(loader)}\n'
    f'#define SEVEN_WEB_MANIFEST {c_string(manifest_format)}\n'
)

patch = f'''
CHECKER_SOURCE="$work/seven-bootstrap.c" python - <<'PYWEB'
import os
from pathlib import Path

path = Path(os.environ["CHECKER_SOURCE"])
source = path.read_text()
source = source.replace('#define SEVEN_VERSION "0.1.0"', '#define SEVEN_VERSION "0.2.0"', 1)

marker = 'static int cmd_run(const char*path)'
if marker not in source:
    raise SystemExit('cmd_run insertion target not found')
defines = {defines!r}
web_code = {web_code!r}
source = source.replace(marker, defines + web_code + marker, 1)

old_usage = 'static void usage(void){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos\\nusage:\\n  seven --version\\n  seven check <file.sev>\\n  seven build <file.sev> [out.svbc]\\n  seven run <file.sev>\\n  seven verify <foundation|bootstrap|production>\\n  seven doctor");}}'
new_usage = 'static void usage(void){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos\\nusage:\\n  seven --version\\n  seven check <file.sev>\\n  seven build <file.sev> [out.svbc]\\n  seven web build <file.sev> [out-dir]\\n  seven run <file.sev>\\n  seven verify <foundation|bootstrap|production>\\n  seven doctor");}}'
if old_usage not in source:
    raise SystemExit('usage target not found')
source = source.replace(old_usage, new_usage, 1)

old_core = 'static int core_main(int argc,char**argv){{if(argc<2||streq(argv[1],"--help")||streq(argv[1],"-h")){{usage();return 0;}}if(streq(argv[1],"--version")){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos");return 0;}}if(streq(argv[1],"check")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],"build")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],"run")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],"verify")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],"doctor")){{puts("seven doctor: semantic native bootstrap operational\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC");return 0;}}printf("unknown or incomplete command\\n");usage();return 2;}}'
new_core = 'static int core_main(int argc,char**argv){{if(argc<2||streq(argv[1],"--help")||streq(argv[1],"-h")){{usage();return 0;}}if(streq(argv[1],"--version")){{puts("Seven " SEVEN_VERSION "\\nCreator: Gabriel Barcelos");return 0;}}if(streq(argv[1],"check")&&argc>=3)return cmd_check(argv[2],0);if(streq(argv[1],"build")&&argc>=3)return cmd_build(argv[2],argc>=4?argv[3]:NULL);if(streq(argv[1],"web")&&argc>=4&&streq(argv[2],"build"))return cmd_web_build(argv[3],argc>=5?argv[4]:"build/web");if(streq(argv[1],"run")&&argc>=3)return cmd_run(argv[2]);if(streq(argv[1],"verify")&&argc>=3)return cmd_verify(argv[2]);if(streq(argv[1],"doctor")){{puts("seven doctor: semantic transition seed operational\\nchecks: syntax, names, types, mutability, effects, bounds, deterministic SVBC, direct WebAssembly");return 0;}}printf("unknown or incomplete command\\n");usage();return 2;}}'
if old_core not in source:
    raise SystemExit('core_main target not found')
source = source.replace(old_core, new_core, 1)
path.write_text(source)
PYWEB
'''

if build_marker not in text:
    raise SystemExit('Linux compiler build marker not found')
text = text.replace(build_marker, '\n' + patch + build_marker, 1)

old_link = '"$link" /subsystem:console /entry:mainCRTStartup /nodefaultlib /out:"$work/seven-windows.exe" "$work/seven-windows.obj" "$work/kernel32.lib" "$work/msvcrt.lib"\n'
new_link = '"$link" /subsystem:console /entry:mainCRTStartup /stack:16777216 /nodefaultlib /out:"$work/seven-windows.exe" "$work/seven-windows.obj" "$work/kernel32.lib" "$work/msvcrt.lib"\n'
if old_link not in text:
    raise SystemExit('Windows linker target not found')
text = text.replace(old_link, new_link, 1)

web_test = r'''"$seven" web build examples/hello.sev "$work/web"
test -s "$work/web/app.wasm"
test -s "$work/web/app.wasm.sha256"
test -s "$work/web/index.html"
test -s "$work/web/seven-loader.mjs"
test -s "$work/web/seven.web.json"
grep -q '"target": "webassembly"' "$work/web/seven.web.json"
node - "$work/web/app.wasm" <<'JS'
const fs = require('fs');
const path = process.argv[2];
const bytes = fs.readFileSync(path);
if (!WebAssembly.validate(bytes)) throw new Error('app.wasm invalido');
let memory;
let output = '';
WebAssembly.instantiate(bytes, {seven:{terminal_diga(ptr,len){output += Buffer.from(memory.buffer, ptr, len).toString('utf8') + '\n';}}}).then(({instance}) => {
  memory = instance.exports.memory;
  const code = instance.exports.seven_start();
  if (code !== 0) throw new Error(`codigo inesperado: ${code}`);
  if (output !== 'Seven nasceu.\n') throw new Error(`saida inesperada: ${JSON.stringify(output)}`);
  console.log(output.trim());
});
JS
'''
marker = '"$seven" doctor\n'
if marker not in text:
    raise SystemExit('web test insertion target not found')
text = text.replace(marker, marker + web_test, 1)

old_git_add = 'git add seed/native/final/v1/part*.b64 seed/native/final/v1/SHA256SUMS'
hash_update = r'''HASH_WORK="$work" python - <<'PYHASH'
import os
import re
from pathlib import Path
import hashlib

work = Path(os.environ["HASH_WORK"])
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
values = {
    "archive": digest(work / "native-seeds.zip"),
    "linux": digest(work / "new/seven-linux"),
    "windows": digest(work / "new/seven-windows.exe"),
}
for name in [".github/workflows/foundation.yml", ".github/workflows/readiness.yml", ".github/workflows/web.yml"]:
    path = Path(name)
    text = path.read_text()
    text = re.sub(r"[0-9a-f]{64}(?=  build/native-seeds\.zip)", values["archive"], text)
    text = re.sub(r"[0-9a-f]{64}(?=  build/native-seeds/seven-linux)", values["linux"], text)
    text = re.sub(r"[0-9a-f]{64}(?=  build/native-seeds/seven-windows\.exe)", values["windows"], text)
    path.write_text(text)
PYHASH
git add seed/native/final/v1/part*.b64 seed/native/final/v1/SHA256SUMS .github/workflows/foundation.yml .github/workflows/readiness.yml .github/workflows/web.yml
'''
if old_git_add not in text:
    raise SystemExit('git add target not found')
text = text.replace(old_git_add, hash_update, 1)
text = text.replace(
    "git commit -m 'rebuild semantic seeds with delimiter-aware checker'",
    "git commit -m 'rebuild transition seeds with Seven WebAssembly'",
    1,
)
text = text.replace(
    "git push origin HEAD:gabriell211/production-readiness",
    "git push origin HEAD:agent/seven-web-build",
    1,
)
path.write_text(text)
PY

bash .github/scripts/rebuild-semantic-seeds.sh
