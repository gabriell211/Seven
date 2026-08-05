# GitHub Linguist registration

Seven uses the official source extension `.sev` and the TextMate scope
`source.seven`.

## Registration metadata

```yaml
Seven:
  type: programming
  color: "#7B2CBF"
  extensions:
    - ".sev"
  tm_scope: source.seven
  ace_mode: text
  language_id: <assigned-by-linguist>
```

The syntax grammar is maintained at:

```text
syntax/seven.tmLanguage.json
```

## Upstream issue body

Use the following content when opening an **Add Language** issue in
`github-linguist/linguist`:

```markdown
### Language name

Seven

### URL of example repository

https://github.com/gabriell211/Seven

### URL of syntax highlighting grammar

https://github.com/gabriell211/Seven/blob/main/syntax/seven.tmLanguage.json

### Most popular extension

`.sev`

### Language type

Programming

### Additional context

Seven is a systems-to-full-stack programming language created by Gabriel
Barcelos (`gabriell211`). Its public repository contains the language
specification, formal grammar, compiler and runtime sources written in Seven,
standard-library sources, examples, conformance files, bootstrap documentation,
and a TextMate grammar.

The official compiler command is `seven`, and the canonical source extension is
`.sev`.
```

## Upstream pull request checklist

After the request is accepted for implementation:

1. Fork `github-linguist/linguist`.
2. Add the Seven entry to `lib/linguist/languages.yml` in alphabetical order.
3. Register `source.seven` in `grammars.yml` using the grammar repository or
   vendored grammar source requested by Linguist maintainers.
4. Add representative `.sev` files under `samples/Seven/`.
5. Generate or obtain an unused `language_id` according to Linguist's current
   contribution workflow.
6. Run the Linguist test suite and generated-file checks.
7. Open a pull request titled `Add Seven programming language`.

GitHub repository language statistics only recognize Seven globally after the
upstream Linguist contribution is merged and deployed by GitHub.
