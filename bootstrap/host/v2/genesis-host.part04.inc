static int vm_dynamic_call(VM *vm, uint32_t argc, size_t base) {
  if (argc < 1) {
    vm_fail(vm, "dynamic call missing target");
    return 0;
  }

  String campo_nome = text(vm->stack[base]);
  int alvo_indice = field_index_string(vm->img, campo_nome);
  if (alvo_indice < 0) {
    vm_fail(vm, "dynamic call target missing");
    return 0;
  }

  Field *alvo = &vm->img->fields[alvo_indice];
  if (argc - 1 != alvo->params) {
    vm_fail(vm, "dynamic call arity mismatch");
    return 0;
  }

  Value *novos_locais = (Value*)xcalloc(alvo->locals, sizeof(Value));
  for (uint32_t i = 0; i < argc - 1; i++) {
    novos_locais[i] = vm->stack[base + 1 + i];
  }

  vm->sp = base;
  Frame quadro = { vm->field, vm->ip, vm->locals, vm->local_count };
  frame_push(vm, quadro);
  vm->field = (uint32_t)alvo_indice;
  vm->ip = alvo->entry;
  vm->locals = novos_locais;
  vm->local_count = alvo->locals;
  return 1;
}

static int vm_run(Image *im, int argc, char **argv) {
  VM vm = {0};
  vm.img = im;
  vm.arg_count = argc;
  vm.args = argv;

  int entry = field_index_entry(im);
  if (entry < 0) die("entry field inicio missing");

  vm.field = (uint32_t)entry;
  vm.ip = im->fields[entry].entry;
  vm.local_count = im->fields[entry].locals;
  vm.locals = (Value*)xcalloc(vm.local_count, sizeof(Value));

  if (im->fields[entry].params) {
    List *l = list_new();
    for (int i = 0; i < argc; i++) list_push(l, v_str_c(argv[i]));
    vm.locals[0] = v_list(l);
  }

  uint64_t steps = 0;
  while (!vm.failed) {
    if (++steps > 20000000000ULL) {
      vm_fail(&vm, "step limit");
      break;
    }

    if (vm.ip >= im->code_count) {
      vm_fail(&vm, "instruction pointer out of bounds");
      break;
    }

    Instr in = im->code[vm.ip++];
    switch (in.op) {
      case 0:
        return 0;
      case 1:
        if (in.a >= im->num_count) { vm_fail(&vm, "number constant out of bounds"); break; }
        push(&vm, v_int(im->nums[in.a]));
        break;
      case 2:
        if (in.a >= im->text_count) { vm_fail(&vm, "text constant out of bounds"); break; }
        push(&vm, v_str(im->texts[in.a]));
        break;
      case 3:
        if (in.a >= vm.local_count) { vm_fail(&vm, "local read out of bounds"); break; }
        push(&vm, vm.locals[in.a]);
        break;
      case 4:
        if (in.a >= vm.local_count) { vm_fail(&vm, "local write out of bounds"); break; }
        vm.locals[in.a] = pop(&vm);
        break;
      case 5: case 6: case 7: case 8: case 9:
      case 10: case 21: case 22: case 23: case 24: {
        Value r = pop(&vm), l = pop(&vm);
        const char *op = in.op == 5 ? "+" :
                         in.op == 6 ? "-" :
                         in.op == 7 ? "*" :
                         in.op == 8 ? "/" :
                         in.op == 9 ? "==" :
                         in.op == 10 ? "<" :
                         in.op == 21 ? "!=" :
                         in.op == 22 ? "<=" :
                         in.op == 23 ? ">" : ">=";
        String operador = { (char*)op, strlen(op) };
        push(&vm, binary(&vm, l, operador, r));
        break;
      }
      case 11:
        if (in.a >= im->code_count) vm_fail(&vm, "jump out of bounds");
        else vm.ip = in.a;
        break;
      case 12: {
        Value c = pop(&vm);
        if (!truth(c)) {
          if (in.a >= im->code_count) vm_fail(&vm, "conditional jump out of bounds");
          else vm.ip = in.a;
        }
        break;
      }
      case 13: {
        if (in.a >= im->field_count) { vm_fail(&vm, "call field out of bounds"); break; }
        Field *t = &im->fields[in.a];
        if (in.b != t->params || in.b > vm.sp) { vm_fail(&vm, "invalid call arity"); break; }
        Value *nl = (Value*)xcalloc(t->locals, sizeof(Value));
        size_t base = vm.sp - in.b;
        for (uint32_t i = 0; i < in.b; i++) nl[i] = vm.stack[base + i];
        vm.sp = base;
        Frame fr = { vm.field, vm.ip, vm.locals, vm.local_count };
        frame_push(&vm, fr);
        vm.field = in.a;
        vm.ip = t->entry;
        vm.locals = nl;
        vm.local_count = t->locals;
        break;
      }
      case 14: {
        Value ret = vm.sp ? pop(&vm) : v_null();
        Value *locais_concluidos = vm.locals;
        if (!vm.fp) {
          int codigo = (int)number(ret);
          free(locais_concluidos);
          return codigo;
        }
        Frame fr = vm.frames[--vm.fp];
        vm.field = fr.field;
        vm.ip = fr.ret_ip;
        vm.locals = fr.locals;
        vm.local_count = fr.local_count;
        free(locais_concluidos);
        push(&vm, ret);
        break;
      }
      case 15: {
        int64_t n = number(pop(&vm));
        if (n < 0) { vm_fail(&vm, "negative byte block size"); break; }
        Bytes *b = bytes_new();
        bytes_reserve(b, (size_t)n);
        memset(b->data, 0, (size_t)n);
        b->len = (size_t)n;
        push(&vm, v_bytes(b));
        break;
      }
      case 16: {
        Value value = pop(&vm), index = pop(&vm), block = pop(&vm);
        if (block.tag != V_BYTES) { vm_fail(&vm, "byte block expected"); break; }
        size_t i = (size_t)number(index);
        if (i >= block.as.bytes->len) { vm_fail(&vm, "byte write out of bounds"); break; }
        block.as.bytes->data[i] = (uint8_t)number(value);
        break;
      }
      case 17: {
        Value index = pop(&vm), block = pop(&vm);
        if (block.tag != V_BYTES) { vm_fail(&vm, "byte block expected"); break; }
        size_t i = (size_t)number(index);
        if (i >= block.as.bytes->len) { vm_fail(&vm, "byte read out of bounds"); break; }
        push(&vm, v_int(block.as.bytes->data[i]));
        break;
      }
      case 18:
        break;
      case 19: {
        if (in.a >= im->name_count || in.b > vm.sp) {
          vm_fail(&vm, "invalid syscall operands");
          break;
        }
        size_t base = vm.sp - in.b;
        String syscall_nome = im->names[in.a];
        if (str_eq_c(syscall_nome, "sys_chamada_dinamica")) {
          vm_dynamic_call(&vm, in.b, base);
          break;
        }
        Value out = syscall(&vm, syscall_nome, vm.stack + base, in.b);
        vm.sp = base;
        if (!vm.failed) push(&vm, out);
        break;
      }
      case 20:
        if (in.a >= im->const_count) { vm_fail(&vm, "constant out of bounds"); break; }
        push(&vm, im->consts[in.a]);
        break;
      default:
        vm_fail(&vm, "unsupported opcode");
        break;
    }
  }

  fprintf(
    stderr,
    "genesis-host: %s (field=%.*s ip=%u steps=%llu)\n",
    vm.error,
    (int)im->fields[vm.field].name.len,
    im->fields[vm.field].name.data,
    vm.ip,
    (unsigned long long)steps
  );
  return 1;
}

static int has_suffix(const char *text, const char *suffix) {
  size_t text_len = strlen(text);
  size_t suffix_len = strlen(suffix);
  return text_len >= suffix_len && memcmp(text + text_len - suffix_len, suffix, suffix_len) == 0;
}

static char *dirname_dup_c(const char *path) {
  const char *last_slash = strrchr(path, '/');
  const char *last_backslash = strrchr(path, '\\');
  const char *last = last_slash;
  if (last_backslash && (!last || last_backslash > last)) last = last_backslash;
  if (!last) return str_c(".").data;
  return str_n(path, (size_t)(last - path)).data;
}

static const char *default_launcher_image(const char *executable_path) {
  static const char *repo_launcher = "build/seven.launcher.svbc";
  static const char *local_launcher = "seven.launcher.svbc";
  static const char *bin_launcher = "bin/seven.launcher.svbc";
  static char *sibling_launcher = NULL;

  if (path_exists_c(repo_launcher)) return repo_launcher;
  if (path_exists_c(local_launcher)) return local_launcher;
  if (path_exists_c(bin_launcher)) return bin_launcher;

  char *dir = dirname_dup_c(executable_path);
  sibling_launcher = path_join_c(dir, "seven.launcher.svbc");
  free(dir);
  if (path_exists_c(sibling_launcher)) return sibling_launcher;

  return repo_launcher;
}

static const char *default_compiler_image(const char *executable_path) {
  static const char *repo_compiler = "build/seven.stage2.svbc";
  static const char *local_compiler = "seven.stage2.svbc";
  static const char *bin_compiler = "bin/seven.stage2.svbc";
  static char *sibling_compiler = NULL;

  if (path_exists_c(repo_compiler)) return repo_compiler;
  if (path_exists_c(local_compiler)) return local_compiler;
  if (path_exists_c(bin_compiler)) return bin_compiler;

  char *dir = dirname_dup_c(executable_path);
  sibling_compiler = path_join_c(dir, "seven.stage2.svbc");
  free(dir);
  if (path_exists_c(sibling_compiler)) return sibling_compiler;

  return repo_compiler;
}

static const char *default_webbuild_image(const char *executable_path) {
  static const char *repo_webbuild = "build/seven.webbuild.svbc";
  static const char *local_webbuild = "seven.webbuild.svbc";
  static const char *bin_webbuild = "bin/seven.webbuild.svbc";
  static char *sibling_webbuild = NULL;

  if (path_exists_c(repo_webbuild)) return repo_webbuild;
  if (path_exists_c(local_webbuild)) return local_webbuild;
  if (path_exists_c(bin_webbuild)) return bin_webbuild;

  char *dir = dirname_dup_c(executable_path);
  sibling_webbuild = path_join_c(dir, "seven.webbuild.svbc");
  free(dir);
  if (path_exists_c(sibling_webbuild)) return sibling_webbuild;

  return repo_webbuild;
}

int main(int argc, char **argv) {
  const char *image_path = NULL;
  int program_argc = 0;
  char **program_argv = NULL;

  if (argc >= 2 && has_suffix(argv[1], ".svbc")) {
    image_path = argv[1];
    program_argc = argc - 2;
    program_argv = argv + 2;
  } else if (argc >= 2 && strcmp(argv[1], "build") == 0) {
    image_path = default_compiler_image(argv[0]);
    program_argc = argc - 2;
    program_argv = argv + 2;
  } else if (argc >= 3 && strcmp(argv[1], "web") == 0 && strcmp(argv[2], "build") == 0) {
    image_path = default_webbuild_image(argv[0]);
    program_argc = argc - 3;
    program_argv = argv + 3;
  } else {
    image_path = default_launcher_image(argv[0]);
    program_argc = argc - 1;
    program_argv = argv + 1;
  }

  Image im = load_image(image_path);
  return vm_run(&im, program_argc, program_argv);
}
