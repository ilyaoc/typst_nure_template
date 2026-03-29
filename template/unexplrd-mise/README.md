# unexplrd's example setup with mise

This example has the following structure:
```
.
├── mise.lock
├── mise.toml
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
    ├── appendices.typ
    ├── main.typ
    └── utils.typ
```

## Advantages
- Declarative approach
- Fixed dependencies: locked Typst version, `nure` package fetched from a specific commit
- Customizable: it's just a `.toml` file, modify it according to your needs

## Mise tasks
- `compile`: Execute `typst compile` on `src/main.typ`
- `watch`: Execute `typst watch` on `src/main.typ`
- `fetch-nure-package`: clone package git repository to a directory specified in `[vars]`
- `update-package-rev`: updates `vars.nure_package_rev` with the last commit id from the specified branch (`vars.nure_package_ref`)

## Examples
- A patch to add new subjects to the package:
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
  +    ТІК: Теорія інформаціі та кодування
  ```
  To apply it, add the following command to the `fetch_nure_package` task:
  ```sh
  git -C {{vars.nure_package_path}} apply --check --apply --quiet $MISE_PROJECT_ROOT/custom-subjects.patch || exit 0
  ```
