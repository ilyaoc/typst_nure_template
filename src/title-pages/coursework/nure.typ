#import "../../shared.typ": universities
#import "../../helpers.typ": *
#import "../../style.typ": *
#import "../../utils.typ": bold, hfill, uline

#let nure(
  university,
  subject,
  title,
  authors,
  mentors,
  task-list,
  calendar-plan,
  abstract,
) = {
  let bib-count = state("citation-counter", ())
  show cite: it => {
    it
    bib-count.update(((..c)) => (..c, it.key))
  }

  let author = authors.first()
  let head-mentor = mentors.first()

  let uni = universities.at(university)
  let edu-prog = uni.edu-programs.at(author.edu-program)

  // page 1 {{{2
  [
    #set align(center)
    МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ\
    #upper(uni.name)

    \

    Кафедра #edu-prog.department-gen

    \

    ПОЯСНЮВАЛЬНА ЗАПИСКА\
    ДО КУРСОВОЇ РОБОТИ\
    з дисципліни: "#uni.subjects.at(subject, default: subject)"\
    Тема роботи: "#title"

    \ \ \

    #columns(2, gutter: 4cm)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #gender-form("author", dict: author) ст. гр. #author.edu-program\-#author.group

      \
      Керівник:\ #head-mentor.degree

      \
      Робота захищена на оцінку

      \
      Комісія:\ #for m in mentors { degree-get(m) }

      #colbreak()
      #set align(left)


      #author.name

      \ \
      #head-mentor.name

      \
      #underline(" " * 35)

      \ \
      #for m in mentors [#m.name\ ]
    ]

    #v(1fr)

    Харків -- #task-list.done-date.display("[year]")

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
        uline(align: left, edu-prog.department-gen)
        linebreak()
        uline(align: left, uni.subjects.at(subject, default: subject))
        linebreak()
        uline(align: left, [#edu-prog.code #edu-prog.name-long])
      },
    )
    grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.3fr,
      [#bold[Курс] #uline(author.course)],
      [#bold[Група] #uline([#author.edu-program\-#author.group])],
      [#bold[Семестр] #uline(author.semester)],
    )

    linebreak()
    linebreak()
    linebreak()

    align(center, bold[ЗАВДАННЯ \ на курсову роботу студента])

    linebreak()

    uline(align: left)[_#author.full-name-gen _]

    linebreak()
    linebreak()

    bold[\1. Тема роботи:]
    uline[#title.]

    linebreak()

    {
      bold[\2. Строк здачі закінченої роботи:]
      uline(task-list.done-date.display("[day].[month].[year]"))
      hfill(10fr)
    }

    linebreak()

    bold[\3. Вихідні дані для роботи:]
    uline(task-list.source)

    linebreak()

    bold[\4. Зміст розрахунково-пояснювальної записки:]
    uline(task-list.content)

    linebreak()

    bold[\5. Перелік графічного матеріалу:]
    uline(task-list.graphics)

    linebreak()

    {
      bold[\6. Дата видачі завдання:]
      uline(task-list.initial-date.display("[day].[month].[year]"))
      hfill(10fr)
    }

    pagebreak()
  }

  // page 3 {{{2
  {
    align(center, bold[КАЛЕНДАРНИЙ ПЛАН])
    set par(first-line-indent: 0pt)

    linebreak()

    calendar-plan.plan-table

    linebreak()

    grid(
      columns: (5fr, 5fr),
      grid(
        columns: (1fr, 2fr, 1fr),
        gutter: 0.2fr,
        [
          Студент \
          Керівник \
          #align(center)["#underline[#calendar-plan.approval-date.day()]"]
        ],
        [
          #uline(align: center, []) \
          #uline(align: center, []) \
          #uline(align: center, month-gen(calendar-plan.approval-date.month()))
        ],
        [
          \ \
          #underline[#calendar-plan.approval-date.year()] р.
        ],
      ),
      [
        #author.name, \
        #head-mentor.degree
        #head-mentor.name.
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
}
