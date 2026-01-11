
// Academic aliases {{{1

#let universities = yaml("config/universities.yaml")

// Template formatting functions {{{1

/// bold text
#let bold(content) = text(weight: "bold")[#content]

/// numberless heading
#let nheading(title) = heading(depth: 1, numbering: none, title)

/// fill horizontal space with a box and not an empty space
#let hfill(width) = box(
  width: width,
  repeat(" "),
) // NOTE: This is a HAIR SPACE (U+200A), not a regular space

/// make underlined cell with filled value
#let uline(align: center, content) = underline[
  #if align != left { hfill(1fr) }
  #content
  #if align != right { hfill(1fr) }
]

/// month name from its number
#let month_gen(month) = (
  "січня",
  "лютого",
  "березня",
  "квітня",
  "травня",
  "червня",
  "липня",
  "серпня",
  "вересня",
  "жовтня",
  "листопада",
  "грудня",
).at(month - 1)

#let is-cyr(c) = regex("[\p{Cyrillic}]") in c

#let gender-form(verb, gender: "p") = {
  (
    "author": ("m": "Виконав", "f": "Виконала", "p": "Виконали"),
    "mentor": ("m": "Перевірив", "f": "Перевірила", "p": "Перевірили"),
  )
    .at(verb)
    .at(if gender == "m" or gender == "f" { gender } else { "p" }, default: "p")
}

#let pz-lb-title(type, number: none) = {
  let type-title = (
    "ЛБ": [Звіт \ з лабораторної роботи],
    "ПЗ": [Звіт \ з практичної роботи],
    "КР": [Контрольна робота],
    "РФ": [Реферат], // зрада
  ).at(type, default: type)
  if number != none { [#type-title №#number] } else { [#type-title] }
}

// Helper functions {{{1

/// captioned image with label derived from path:
/// - "image.png" = @image
/// - "img/image.png" = @image
/// - "img/foo/image.png" = @foo_image
/// - "img/foo/foo_image.png" = @foo_image
/// the caption will be modified based on a conditional positional value:
/// - `none`: no change
/// - some value: "`caption` (за даними `value`)"
/// - no value: "`caption` (рисунок виконано самостійно)"
/// additional named arguments will be passed to original `image` function
#let img(path, caption, ..sink) = {
  let parts = path.split(".").first().split("/")

  let label_string = if (
    parts.len() <= 2 or parts.at(-1).starts-with(parts.at(-2))
  ) {
    // ("image",), (_, "image") and (.., "img", "img_image")
    parts.last()
  } else {
    // (.., "img", "image") = "img_image"
    parts.at(-2) + "_" + parts.at(-1)
  }.replace(" ", "_")

  let caption = if sink.pos().len() == 0 {
    caption
  } else if sink.pos().first() == none {
    caption + " (рисунок виконано самостійно)"
  } else {
    [#caption (за даними #sink.pos().first())]
  }

  [#figure(
      image(path, ..sink.named()),
      caption: caption,
    ) #label(label_string)]
}

#let spacing = 0.95em // spacing between lines
#let num-to-alpha = "абвгдежиклмнпрстуфхцшщюя".split("") // 0 = "", 1 = "а"

/// DSTU 3008:2015 Style
/// -> content
/// - it (content): Content to apply the style to.
/// - skip (int): Do not show page number for this number of pages.
/// - offset (int): Adjust all page numbers by this amount.
#let dstu-style(
  it,
  skip: 0,
  offset: 0,
) = {
  // General Styling {{{1
  set page(
    paper: "a4",
    number-align: top + right,
    margin: (top: 20mm, right: 10mm, bottom: 20mm, left: 25mm),
    numbering: (i, ..) => if i > skip { numbering("1", i + offset) },
  )

  set text(
    lang: "uk",
    size: 14pt,
    hyphenate: false,
    font: ("Times New Roman", "Liberation Serif"),
  )

  set par(
    justify: true,
    spacing: spacing,
    leading: spacing,
    first-line-indent: (amount: 1.25cm, all: true),
  )

  set block(spacing: spacing)
  set underline(evade: false)

  // Enums & Lists {{{1
  // First level
  set enum(
    indent: 1.25cm,
    body-indent: 0.5cm,
    numbering: i => { num-to-alpha.at(i) + ")" },
  )

  // Second level and further nesting
  show enum: it => {
    set enum(indent: 0em, numbering: "1)")
    it
  }

  // Lists are not intended for multiple levels, use `enum`
  set list(indent: 1.35cm, body-indent: 0.5cm, marker: [--])

  // Figures {{{1
  show figure: it => {
    v(spacing * 2, weak: true)
    it
    v(spacing * 2, weak: true)
  }

  set figure.caption(separator: [ -- ])
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption.where(kind: table): set align(left)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set align(left)

  // Numbering {{{1
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }
  set figure(numbering: i => numbering("1.1", counter(heading).get().at(0), i))
  set math.equation(
    numbering: i => numbering(
      "(1.1)",
      counter(heading).get().at(0),
      i,
    ),
  )

  // Headings {{{1
  set heading(numbering: "1.1")

  show heading: it => if it.level == 1 {
    set align(center)
    set text(size: 14pt, weight: "semibold")

    pagebreak(weak: true)
    upper(it)
    v(spacing * 2, weak: true)
  } else {
    set text(size: 14pt, weight: "regular")

    v(spacing * 2, weak: true)
    block(width: 100%, spacing: 0em)[
      #h(1.25cm)
      #counter(heading).display(auto)
      #it.body
    ]
    v(spacing * 2, weak: true)
  }

  show heading.where(level: 3): it => {
    set text(size: 14pt, weight: "regular")

    v(spacing * 2, weak: true)
    block(width: 100%, spacing: 0em)[
      #h(1.25cm)
      #counter(heading).display(it.numbering)
      #it.body
    ]
    v(spacing * 2, weak: true)
  }

  // listings {{{3
  show raw.where(block: true): it => {
    let new_spacing = 0.5em
    set block(spacing: new_spacing)
    set par(spacing: new_spacing, leading: new_spacing)
    set text(
      size: 11pt,
      weight: "semibold",
      font: ("Courier New", "Liberation Mono"),
    )

    v(spacing * 2.5, weak: true)
    pad(it, left: 1.25cm)
    v(spacing * 2.5, weak: true)
  }

  it
  // }}}
}

/// DSTU 3008:2015 Appendices Style
/// -> content
/// - it (content): Content to apply the style to.
#let appendices-style(it) = /* {{{ */ {
  // Numbering
  counter(heading).update(0)
  set heading(
    numbering: (i, ..n) => (
      upper(num-to-alpha.at(i)) + numbering(".1.1", ..n)
    ),
  )
  set figure(
    numbering: i => [#upper(num-to-alpha.at(counter(heading).get().at(0))).#i],
  )
  set math.equation(
    numbering: i => [(#upper(num-to-alpha.at(counter(heading).get().at(0))).#i)],
  )

  // Heading supplement (Heading name shown when citing with @ref)
  set heading(supplement: [Додаток])

  // Headings
  show heading: it => if it.level == 1 {
    set align(center)
    set text(size: 14pt, weight: "regular")

    pagebreak(weak: true)
    text(weight: "bold")[ДОДАТОК #counter(heading).display(auto)]
    linebreak()
    it.body
    v(spacing * 2, weak: true)
  } else {
    set text(size: 14pt, weight: "regular")

    v(spacing * 2, weak: true)
    block(width: 100%, spacing: 0em)[
      #h(1.25cm)
      #counter(heading).display(auto)
      #it.body
    ]
    v(spacing * 2, weak: true)
  }

  it
} // }}}

// Coursework template {{{1

/// DSTU 3008:2015 Template for NURE
/// -> content
/// - doc (content): Content to apply the template to.
/// - title (str): Title of the document.
/// - subject (str): Subject short name.
/// - authors ((name: str, full_name_gen: str, variant: int, course: int, semester: int, group: str, gender: str),): List of authors.
/// - mentors ((name: str, degree: str),): List of mentors.
/// - task_list (done_date: datetime, initial_date: datetime, source: (content | str), content: (content | str), graphics: (content | str)): Task list object.
/// - calendar_plan ( plan_table: (content | str), approval_date: datetime): Calendar plan object.
/// - abstract (keywords: (str, ), text: (content | str)): Abstract object.
/// - bib_path path: Path to the bibliography yaml file.
/// - appendices (content): Content with appendices.
#let coursework(
  doc,
  university: "ХНУРЕ",
  subject: none,
  title: none,
  authors: (),
  mentors: (),
  task_list: (),
  calendar_plan: (),
  abstract: (),
  bib_path: none,
  appendices: (),
) = {
  set document(title: title, author: authors.at(0).name)

  show: dstu-style.with(skip: 1)

  let bib-count = state("citation-counter", ())
  show cite: it => {
    it
    bib-count.update(((..c)) => (..c, it.key))
  }
  show bibliography: it => {
    set text(size: 0pt)
    it
  }

  let author = authors.at(0)
  let head_mentor = mentors.at(0)
  let uni = universities.at(university)
  let edu_prog = uni.edu_programs.at(author.edu_program)

  // page 1 {{{2
  [
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    #upper(uni.name)

    \

    Кафедра #edu_prog.department_gen

    \

    ПОЯСНЮВАЛЬНА ЗАПИСКА\
    ДО КУРСОВОЇ РОБОТИ\
    з дисципліни: "#uni.subjects.at(subject, default: subject)"\
    Тема роботи: "#title"

    \ \ \

    #columns(2, gutter: 4cm)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #gender-form("author", gender: author.gender) ст. гр. #author.edu_program\-#author.group

      \
      Керівник:\
      #head_mentor.degree

      \
      Робота захищена на оцінку

      \
      Комісія:\
      #for m in mentors { [#m.degree\ ] }

      #colbreak()
      #set align(left)


      #author.name

      \ \
      #head_mentor.name

      \
      #underline(" " * 35)

      \ \
      #for m in mentors { [#m.name\ ] }
    ]

    #v(1fr)

    Харків -- #task_list.done_date.display("[year]")

    #pagebreak()
  ]

  // page 2 {{{2
  {
    uline[#uni.name]

    linebreak()
    linebreak()

    grid(
      columns: (100pt, 1fr),
      bold[
        Кафедра
        Дисципліна
        Спеціальність
      ],
      {
        uline(align: left, edu_prog.department_gen)
        linebreak()
        uline(align: left, uni.subjects.at(subject, default: subject))
        linebreak()
        uline(align: left, [#edu_prog.code #edu_prog.name_long])
      },
    )
    grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.3fr,
      [#bold[Курс] #uline(author.course)],
      [#bold[Група] #uline([#author.edu_program\-#author.group])],
      [#bold[Семестр] #uline(author.semester)],
    )

    linebreak()
    linebreak()
    linebreak()

    align(center, bold[ЗАВДАННЯ \ на курсову роботу студента])

    linebreak()

    uline(align: left)[_#author.full_name_gen _]

    linebreak()
    linebreak()

    bold[\1. Тема роботи:]
    uline[#title.]

    linebreak()

    {
      bold[\2. Строк здачі закінченої роботи:]
      uline(task_list.done_date.display("[day].[month].[year]"))
      hfill(10fr)
    }

    linebreak()

    bold[\3. Вихідні дані для роботи:]
    uline(task_list.source)

    linebreak()

    bold[\4. Зміст розрахунково-пояснювальної записки:]
    uline(task_list.content)

    linebreak()

    bold[\5. Перелік графічного матеріалу:]
    uline(task_list.graphics)

    linebreak()

    {
      bold[\6. Дата видачі завдання:]
      uline(task_list.initial_date.display("[day].[month].[year]"))
      hfill(10fr)
    }

    pagebreak()
  }

  // page 3 {{{2
  {
    align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
    set par(first-line-indent: 0pt)

    linebreak()

    calendar_plan.plan_table

    linebreak()

    grid(
      columns: (5fr, 5fr),
      grid(
        columns: (1fr, 2fr, 1fr),
        gutter: 0.2fr,
        [
          Студент \
          Керівник \
          #align(center)["#underline[#calendar_plan.approval_date.day()]"]
        ],
        [
          #uline(align: center, []) \
          #uline(align: center, []) \
          #uline(align: center, month_gen(calendar_plan.approval_date.month()))
        ],
        [
          \ \
          #underline[#calendar_plan.approval_date.year()] р.
        ],
      ),
      [
        #author.name, \
        #head_mentor.degree
        #head_mentor.name.
      ],
    )

    pagebreak()
  }

  // page 4 {{{2
  [
    #align(center, bold[РЕФЕРАТ]) \

    #context [
      #let pages = counter(page).final().at(0)
      #let images = query(figure.where(kind: image)).len()
      #let tables = query(figure.where(kind: table)).len()
      #let bibs = bib-count.final().dedup().len()
      /* TODO: why this stopped working?
      #let tables = counter(figure.where(kind: table)).final().at(0)
      #let images = counter(figure.where(kind: image)).final().at(0)*/

      #let counters = ()

      #if pages != 0 { counters.push[#pages с.] }
      #if tables != 0 { counters.push[#tables табл.] }
      #if images != 0 { counters.push[#images рис.] }
      #if bibs != 0 { counters.push[#bibs джерел] }

      Пояснювальна записка до курсової роботи: #counters.join(", ").
    ]

    \

    #(
      abstract
        .keywords
        .map(upper)
        .sorted(by: (a, b) => {
          if is-cyr(a) != is-cyr(b) { true } else { a < b }
        })
        .join(", ")
    )


    \

    #abstract.text
  ]

  // page 5 {{{2
  outline(
    title: [
      ЗМІСТ
      #v(spacing * 2, weak: true)
    ],
    depth: 2,
    indent: auto,
  )

  doc

  // bibliography {{{2
  {
    heading(depth: 1, numbering: none)[Перелік джерел посилання]

    bibliography(
      bib_path,
      style: "ieee",
      full: true,
      title: none,
    )

    let bib_data = yaml(bib_path)

    let format-entry(c) = {
      if (c.type == "Web") {
        let date_array = c.url.date.split("-")
        let date = datetime(
          year: int(date_array.at(0)),
          month: int(date_array.at(1)),
          day: int(date_array.at(2)),
        )
        [#c.title. #c.author. URL: #c.url.value (дата звернення: #date.display("[day].[month].[year]")).]
      } else if (
        c.type == "Book"
      ) [#c.author #c.title. #c.publisher, #c.date. #c.page-total c. ] else [
        UNSUPPORTED BIBLIOGRAPHY ENTRY TYPE, PLEASE OPEN AN ISSUE
      ]
    }

    show enum.item: it => {
      set par(first-line-indent: 0pt)
      box(width: 1.25cm)
      box(width: 1em + 0.5cm)[#it.number.]
      it.body
      linebreak()
    }

    context {
      for (i, citation) in query(ref.where(element: none))
        .map(r => str(r.target))
        .dedup()
        .enumerate() {
        enum.item(
          i + 1,
          format-entry(bib_data.at(citation)),
        )
      }
    }
  }

  appendices-style(appendices)
}

// Practice and Laboratory works template {{{1

/// DSTU 3008:2015 Template for NURE
/// -> content
/// - doc (content): Content to apply the template to.
/// - university: "ХНУРЕ": University metadata. Optional.
/// - subject: str: Subject shortcode.
/// - type: ("ЛБ" | "ПЗ" | "КР" | "РФ" | str): Work type.
/// - number: int or none: Work number. Optional.
/// - title: str or none: Work title. Optional.
/// - authors ((name: str, full_name_gen: str or none, edu_program: str, group: str, gender: str, variant: int or none),): List of authors.
/// - mentors ((name: str, degree: str, gender: ("m" | "f" | "p" | none)),): List of mentors. Optional.
#let pz-lb(
  doc,
  university: "ХНУРЕ",
  subject: none,
  type: none,
  number: none,
  title: none,
  authors: (),
  mentors: (),
) = {
  // TODO: add actually relevant asserts

  let edu_program = authors.at(0).edu_program
  let uni = universities.at(university)

  set document(title: title, author: authors.map(c => c.name))

  show: dstu-style.with(skip: 1)

  // page 1 {{{2

  align(center)[
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ \
    #upper(uni.name)

    \ \
    Кафедра #uni.edu_programs.at(edu_program).department_gen

    \ \ \
    #pz-lb-title(type, number: number)

    з дисципліни: "#uni.subjects.at(subject, default: subject)"
    #if title != none [\ з теми: "#eval(title, mode: "markup")"]


    \ \ \ \
    #columns(2)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #if authors.len() == 1 {
        let a = authors.at(0)
        [#gender-form("author", gender: if "gender" in a.keys() { a.gender } else { none }):\ ]
        [ст. гр. #a.edu_program\-#a.group\ #a.name\ ]
        if a.variant != none [Варіант: №#a.variant]
      } else if authors.len() > 1 [
        #gender-form("author"):\
        #for a in authors [ст. гр. #a.edu_program\-#a.group\ #a.name\ ]
      ]

      #colbreak()
      #set align(right)

      #if mentors.len() == 1 {
        let m = mentors.at(0)
        [#gender-form("mentor", gender: if "gender" in m.keys() { m.gender } else { none }):\ ]
        if "degree" in m.keys() and m.degree != none [#m.degree\ ]
        [#m.name\ ]
      } else if mentors.len() > 1 [
        #gender-form("mentor"):\
        #for mentor in mentors { [#mentor.degree\ #mentor.name\ ] }]
    ]

    #v(1fr)

    Харків -- #datetime.today().display("[year]")
  ]

  pagebreak(weak: true)

  // TODO(unexplrd): wrap my head around the old way
  if title == none {
    if number == none { context counter(heading).update(1) } else {
      context counter(heading).update(number)
    }
  } else {
    if number != none { context counter(heading).update(number - 1) }
    heading(eval(title, mode: "markup"))
  }

  doc
}

// vim:sts=2:sw=2:fdm=marker:cms=/*%s*/
