#import "../../shared.typ": universities
#import "../../helpers.typ": *
#import "../../style.typ": spacing
#import "../../utils.typ": bold, uline, filled-lines

#let note(content) = block(width: 100%, above: 5pt, below: 0pt)[
  #set text(size: 10pt)
  #set par(first-line-indent: 0pt, spacing: 0pt)
  #align(center)[#content]
]

#let form-field(alignment: center, content) = box(
  width: 100%,
  stroke: (bottom: 0.5pt),
  inset: (bottom: 1.5pt),
)[
  #align(alignment)[#content]
]

#let label-line(label, value, caption: none, label-width: auto) = {
  set par(first-line-indent: 0pt)
  if label-width == auto {
    [#label #form-field(alignment: center, value)]
  } else {
    grid(
      columns: (label-width, 1fr),
      gutter: 0pt,
      align: horizon,
      label, form-field(alignment: center, value),
    )
  }
  if caption != none {
    note(caption)
  }
}

#let inline-field(value) = form-field(alignment: center, value)

#let inline-label-line(label, value) = {
  set par(first-line-indent: 0pt)
  block(width: 100%, below: 0pt)[
    #label #uline(align: center, value)
  ]
}

#let task-head-fields(fields) = {
  set par(first-line-indent: 0pt)
  let cells = ()
  for (label, value) in fields {
    if type(value) == array {
      for (i, line) in value.enumerate() {
        cells.push(if i == 0 { label } else { [] })
        cells.push(inline-field(line))
      }
    } else {
      cells.push(label)
      cells.push(inline-field(value))
    }
  }
  grid(
    columns: (auto, 1fr),
    gutter: 0pt,
    row-gutter: 0.65em,
    align: top,
    ..cells,
  )
}

#let task-num(n) = box(str(n) + ".")

#let title-field(value) = {
  uline(align: center, filled-lines(value))
  uline(align: center, [])
  note[(тема)]
}

#let nure(
  university,
  title,
  authors,
  mentors,
  task-list,
  calendar-plan,
  abstract,
  bib-count,
  faculty: "комп’ютерних наук",
  education-level: "перший (бакалаврський)",
  program-type: "освітньо-професійна",
  program-name: none,
) = {
  let author = authors.first()
  let head-mentor = mentors.first()

  let uni = universities.at(university)
  let edu-prog = uni.edu-programs.at(author.edu-program)
  let program-name = if program-name == none {
    edu-prog.at("program-name", default: edu-prog.name-long)
  } else {
    program-name
  }
  let group-name = if str(author.group).starts-with(author.edu-program) {
    str(author.group)
  } else {
    author.edu-program + "-" + str(author.group)
  }
  let executor-label = if author.gender == "f" or author.gender == "female" or author.gender == "ж" {
    "Виконала:"
  } else {
    "Виконав:"
  }
  let author-display-name = author.at("display-name", default: author.name)
  let author-full-name-dat = author.at("full-name-dat", default: author.full-name-gen)
  let mentor-display-name = head-mentor.at("display-name", default: head-mentor.name)
  let mentor-degree = head-mentor.at("degree", default: "")

  [
    #set par(first-line-indent: 0pt, justify: false, leading: 0.45em)

    #set text(size: 14pt)
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    #uni.name

    #v(0.7em)

    #set align(left)
    #inline-label-line(
      [Факультет],
      faculty,
    )
    #note([(повна назва)])

    #v(0.8em)
    #inline-label-line([Кафедра], edu-prog.department-gen)
    #note([(повна назва)])

    #v(1.8em)

    #set align(center)
    #text(size: 20pt, weight: "bold")[КОМПЛЕКСНИЙ КУРСОВИЙ ПРОЄКТ]\
    #text(size: 20pt, weight: "bold")[Пояснювальна записка]

    #v(0.9em)

    #set align(left)
    #label-line([рівень вищої освіти], education-level, label-width: 120pt)

    #v(1.0em)
    #title-field(title)

    #v(3em)

    #grid(
      columns: (0.36fr, 0.64fr),
      [],
      [
        #executor-label\
        здобувач #underline([#author.course]) курсу, групи #underline(group-name)\
        #uline(align: center, author-display-name)
        #note[(Власне ім’я, ПРІЗВИЩЕ)]

        #v(0.2em)
        #inline-label-line([Спеціальність], [#edu-prog.code -- #edu-prog.name-long])
        #note[(код і повна назва спеціальності)]
        #inline-label-line([Тип програми], program-type)
        #inline-label-line([Освітня програма], program-name)
        #note[(повна назва освітньої програми)]

        #v(0.3em)
        #inline-label-line([Керівник], [#mentor-degree #mentor-display-name])
        #note[(посада, Власне ім’я, ПРІЗВИЩЕ)]

        #v(0.3em)
        #pad(left: 75pt)[
          #set par(first-line-indent: 0pt)
          Члени комісії (#text(size: 10pt)[Власне ім’я, ПРІЗВИЩЕ, підпис])
          #v(0.55em)
          #line(length: 100%, stroke: 0.5pt)
          #v(0.55em)
          #line(length: 100%, stroke: 0.5pt)
          #v(0.55em)
          #line(length: 100%, stroke: 0.5pt)
        ]
      ],
    )

    #v(1fr)

    #set align(center)
    #task-list.done-date.display("[year]") р.

    #pagebreak()
  ]

  [
    #set par(first-line-indent: 0pt, justify: false)
    #align(center)[#uni.name]

    #v(1.1em)
    #task-head-fields((
      (
        [Факультет],
        (
          faculty,
        ),
      ),
      ([Кафедра], edu-prog.department-gen),
      ([Рівень вищої освіти], education-level),
      ([Спеціальність], [#edu-prog.code -- #edu-prog.name-long]),
      ([Тип програми], program-type),
      ([Освітня програма], program-name),
    ))
    #note[(шифр і назва)]

    #v(1.7em)
    #grid(
      columns: (1.1fr, 1.1fr, 1.1fr, 1.7fr, 1.3fr, 1.1fr),
      gutter: 0pt,
      align: center + horizon,
      [Курс], uline(author.course), [Група], uline(group-name), [Семестр], uline(author.semester),
    )

    #v(2.6em)

    #align(center)[
      #bold[ЗАВДАННЯ]\
      #text(style: "italic", weight: "bold")[на курсовий проєкт (роботу) студента]
    ]

    #v(1.0em)

    #label-line([здобувачеві], author-full-name-dat, caption: [(прізвище, ім’я, по батькові)], label-width: 95pt)

    #v(1.0em)

    #task-num(1) Тема роботи #uline(align: left, filled-lines(title))

    #v(0.4em)
    #task-num(2) Термін здачі студентом закінченої роботи
    “#underline(task-list.done-date.display("[day]"))” #underline(month-gen(task-list.done-date.month())) #task-list.done-date.display("[year]")р.

    #v(0.4em)
    #task-num(3) Вихідні дані до проєкту #uline(align: left, filled-lines(task-list.at("source", default: [])))
    #v(0.4em)
    #uline(align: left, [])

    #v(0.4em)
    #task-num(4) Перелік питань, що потрібно опрацювати в роботі\
    #uline(align: left, filled-lines(task-list.at("content", default: [])))
    #v(0.4em)
    #uline(align: left, [])

    #pagebreak()
  ]

  [
    #align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
    #set par(first-line-indent: 0pt)

    #v(1.4em)

    #calendar-plan.plan-table

    #v(5.0em)

    Дата видачі завдання “#underline(task-list.initial-date.display("[day]"))” #underline(month-gen(task-list.initial-date.month())) #task-list.initial-date.display("[year]")р.

    #v(1.4em)

    Здобувач #uline(align: center, [])
    #note[(підпис)]

    #v(1.4em)

    Керівник роботи #uline(align: center, []) #h(1cm) #underline[#mentor-degree #mentor-display-name]
    #note[(підпис) #h(4.5cm) (посада, Власне ім’я, ПРІЗВИЩЕ)]

    #pagebreak()
  ]

  [
    #let header = if abstract.at("en", default: none) != none {
      bold[РЕФЕРАТ / ABSTRACT]
    } else {
      bold[РЕФЕРАТ]
    }
    #align(center, header) \

    #context [
      #let pages = counter(page).final().at(0)
      #let images = query(figure.where(kind: image)).len()
      #let tables = query(figure.where(kind: table)).len()
      #let bibs = bib-count.final().dedup().len()

      #let counters = ()
      #if pages != 0 { counters.push[#pages с.] }
      #if tables != 0 { counters.push[#tables табл.] }
      #if images != 0 { counters.push[#images рис.] }
      #if bibs != 0 { counters.push[#bibs джерел] }

      Пояснювальна записка містить: #counters.join(", ").
    ]

    \

    #(
      abstract
        .keywords
        .map(upper)
        .sorted(by: (a, b) => {
          if is-cyr(a) != is-cyr(b) { is-cyr(a) } else { a < b }
        })
        .join(", ")
    )

    \

    #abstract.text

    #if abstract.at("en", default: none) != none [
      \
      #(abstract.en.keywords.map(upper).join(", "))

      \

      #abstract.en.text
    ]
  ]

  {
    show outline.entry: it => {
      let el = it.element

      if el.func() == heading and el.supplement == [Додаток] {
        if el.level > 1 {
          none
        } else {
          block(width: 100%)[
            #link(el.location())[
              ДОДАТОК #it.prefix()#h(0.5em)#it.inner()
            ]
          ]
        }
      } else {
        it
      }
    }

    outline(
      title: [
        ЗМІСТ
        #v(spacing * 2, weak: true)
      ],
      depth: 2,
      indent: auto,
    )
  }
}
