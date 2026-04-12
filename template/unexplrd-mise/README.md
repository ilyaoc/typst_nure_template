# unexplrd's example setup with mise

This example has the following structure:
```
.
├── .mise/
│   ├── config.toml
│   └── mise.lock
├── vendor/
│   └── typst-packages/
│       └── ...
└── src/
    ├── assets/
    │   ├── foo.csv
    │   ├── bar.c
    │   └── ...
    ├── figures/
    │   ├── clojure-logo.png
    │   ├── error-log.jpg
    │   └── ...
    ├── doc.toml
    ├── main.typ
    └── utils.typ
```

## Advantages
- Minimal
  - All you need is [`mise`](https://mise.jdx.dev/) and `git`
- Declarative
  - Sets up the environment and dependencies automatically
  - Every work config is separate to avoid breaking changes in Typst and `nure` package
- Customizable
  - Add your own mise tasks, change existing tasks, it's just a `.toml` file

## Project structure
All work contents are stored in `src/` to avoid clutter.

### Files
- `src/doc.toml`: work-specific settings, could be auto-filled, useful for scripts, see (TODO: add a demo nushell script)
- `src/utils.typ`: utilities and functions used across the project
- `src/main.typ`: main entry file

### Directories
- `src/chapters/`: for breaking up the project into multiple files, if necessary
- `src/figures/`: for images and pictures
- `src/assets/`: other non-image, non-typst files

## Mise

### Tasks
- `compile`: Execute `typst compile` on `src/main.typ`
- `watch`: Execute `typst watch` on `src/main.typ`
- `rename`: Copy output `.pdf` file with an auto-generated name from metadata in `doc.toml`
- `fetch-nure-package`: clone package git repository to a directory specified in `[vars]`
- `update-package-rev`: updates `vars.nure_package_rev` with the last commit id from the specified branch (`vars.nure_package_ref`)

## Examples

### Templating

I have a following per-semester directory structure:
```
/home/user/Documents/nure/
└── .config/
    ├── defaults.yaml
    ├── subjects.yaml
    ├── mise/
    │   ├── config.toml
    │   └── mise.lock
    └── template/
        ├── .mise
        │   ├── config.toml
        │   └── mise.lock
        └── src
            ├── appendices.typ
            ├── assets/
            ├── figures/
            ├── main.typ
            └── utils.typ
```

<details><summary>Contents of <code>.config/default.yaml</code></summary><p>

```yaml
university: ХНУРЕ
default_author:
  name: Косач Л. П.
  edu-program: ПЗПІ
  group: 23-2
  gender: f
  variant: 8
  full-name-gen: Косач Лариси Петрівни
  course: 2
  semester: 4
work_types:
  lb: ЛБ
  pz: ПЗ
  kr: КР
```

</p></details>

<details><summary>Contents of <code>.config/subjects.yaml</code></summary><p> 

```yaml
smp:
  name: СМП
  full_name: Скриптові мови програмування
  mentors:
    - name: Шевченко Т. Г.
      degree: Доцент кафедри ПІ
      gender: m
    - name: Франко І. Я.
      degree: Асистент кафедри ПІ
      gender: m
iks:
  name: ІКС
  full_name: Інформаційно-комунікаційні системи
  mentors:
    - name: Мартинчук О. О.
      degree: Доцент кафедри ІКІ
      gender: m
# etc...
```

</p></details>

<details><summary>Contents of <code>.config/mise/config.toml</code></summary><p>

```toml
[settings]
quiet = true
env_shell_expand = true
lockfile = true

[tools]
"aqua:nushell/nushell" = "latest"

[tasks.work]
usage = '''
arg "<subject>" help="Target environment"
arg "<type>" help="Target environment"
arg "<number>" help="Target environment"
'''

run = '''
#!/usr/bin/env nu

let template_dir = ".config/template"
let config_dir = ".config"
# let out_dir = $"(pwd)"
let out_dir = $"(pwd)/works"

def not_main [subject: string, shortcode: string, number?: int] {
    let subject_lower = ($subject | str downcase)
    let shortcode_lower = ($shortcode | str downcase)

    validate-input $subject $shortcode $number

    let temp_dir = $"/tmp/nure-work-(random chars -l 8)"
    let final_dir = $"($out_dir)/($subject_lower)/($shortcode_lower)($number)"
    let subject_dir = $"($out_dir)/($subject_lower)"

    # TODO?: replace with git clone
    cp -r ($config_dir)/template $temp_dir
    generate-doc-toml $shortcode_lower $subject_lower $temp_dir $number
    check-mkdir $out_dir
    if ($final_dir | path exists) {
        error make -u {msg: $"Directory ($final_dir) already exists"}
    }

    check-mkdir $subject_dir; cp -r $temp_dir $final_dir; rm -rf $temp_dir
    print $"=> Created new work: ($final_dir)"
}

def check-mkdir [path: string] { if not ($path | path exists) { mkdir $path } }

def validate-input [subject: string, shortcode: string, number?: int] {
    if not ($config_dir | path exists) {
        error make -u {msg: $"($config_dir) not found"}
    }

    let defaults_yaml = $"($config_dir)/defaults.yaml"
    let subjects_yaml = $"($config_dir)/subjects.yaml"

    if not ($defaults_yaml | path exists) {
        error make -u {msg: $"defaults.yaml not found in ($config_dir)"}
    }
    if not ($subjects_yaml | path exists) {
        error make -u {msg: $"subjects.yaml not found in ($config_dir)"}
    }

    if ($number != nothing and $number < 1 ) {
        error make -u {msg: "Work number should be greater than 0"}
    }

    let subject_lower = ($subject | str downcase)
    let subjects = (open $subjects_yaml | columns)
    if $subject_lower not-in $subjects {
        error make -u {
            msg: $"Subject '($subject)' not found in configuration"
            help: $"Available subjects: ($subjects | str join ', ')"
        }
    }
}

def generate-doc-toml [shortcode: string, subject: string, target_dir: string, number?: int] {
    let defaults = (open $"($config_dir)/defaults.yaml")
    let subjects = (open $"($config_dir)/subjects.yaml")

    let subject_data = ($subjects | get $subject)
    let work_type = ($defaults | get work_types | try { get $shortcode } catch { $shortcode })

    {
        university: ($defaults | get university)
        subject: ($subject_data | get name), type: $work_type, number: $number
        mentors: ($subject_data | get mentors), authors: [($defaults | get default_author)]
    } | compact --empty | to toml | save $"($target_dir)/src/doc.toml" --force
}

not_main {{usage.subject}} {{usage.type}} {{usage.number}}
'''
```

</p></details>

`template/` is this empty template without `doc.toml`

Nushell script does two things:
  - Creates a new work from a template: `works/smp/lb1`
  - Auto-fills `doc.toml` with data from `defaults.yaml` and mentor data from `subjects.yaml`

### Patching the package
A patch to add new subjects:

```diff
diff --git a/src/config/universities.yaml b/src/config/universities.yaml
index 8855a07..1aefc96 100644
--- a/src/config/universities.yaml
+++ b/src/config/universities.yaml
@@ -60,7 +60,6 @@
  ПЕСЕ: Психологія екстремальних стосунків та ефективної адаптації
  ПНП: Програмування на платформі .NЕТ
  ПП: Проектний практикум
-    ПРОГ: Програмування
  ПарП: Параллельне програмування
  СА: Системний аналіз
  СМП: Скриптові мови програмування
@@ -76,3 +75,10 @@
  ФІЛ: Філософія
  ФВС: Фізичне виховання та спорт
  ХТ: Хмарні технології
+    АКС: Архітектура комп'ютерних систем
+    ІКС: Інформаційно-комунікаційні системи
+    МБ: Мережна безпека
+    МКр: Мережна криміналістика
+    ОКЗІ: Основи криптографічного захисту інформації
+    Прог: Програмування
+    ТІК: Теорія інформації та кодування
```

To apply it, add the following command to the end of `fetch_nure_package` task:
```sh
git -C {{vars.nure_package_path}} apply --check --apply --quiet $MISE_PROJECT_ROOT/custom-subjects.patch || exit 0
```
