#import "@local/nure:0.1.1": *
#import style: spacing

#let authors = (
  (
    name: "Сокорчук І. П.",
    display-name: "Ігор СОКОРЧУК",
    full-name-gen: "Сокорчука Ігоря Петровича",
    full-name-dat: "Сокорчуку Ігорю Петровичу",
    edu-program: "ПЗПІ",
    group: "23-3",
    gender: "m",
    course: 3,
    semester: 6,
    variant: 13,
  ),
)

#let mentors = (
  (name: "Сокорчук І. П.", display-name: "Ігор СОКОРЧУК", degree: "ст.викл. кафедри ПІ"),
)

#let task-list = (
  done-date: datetime(year: 2026, month: 12, day: 27),
  initial-date: datetime(year: 2026, month: 9, day: 15),
  source: (
    [Узагальнити модель предметної області,],
    [визначити основні сутності та зв'язки між ними.],
    [Підготувати демонстраційний набір технологій для шаблону.],
  ),
  content: (
    [Опис предметної галузі, формування вимог,],
    [архітектурне проєктування, тестування та],
    [перевірка верстки пояснювальної записки.],
  ),
)

#let calendar-plan = (
  plan-table: table(
    columns: (0.7fr, 5.8fr, 2.5fr, 1.6fr),
    align: (center, left, center, center),
    [№], [Назва етапів роботи], [Термін виконання етапів роботи], [Примітка],
    [1], [Аналіз предметної галузі], [], [виконано],
    [2], [Розробка постановки задачі], [], [виконано],
    [3], [Проєктування ПЗ], [], [виконано],
    [4], [Програмна реалізація], [], [виконано],
    [5], [Аналіз результатів], [], [виконано],
    [6], [Підготовка пояснювальної записки.], [], [виконано],
    [7], [Перевірка на наявність ознак академічного плагіату], [], [виконано],
    [8], [Захист роботи], [], [виконано],
  ),
)

#let abstract = (
  keywords: (
    "веб-застосунок",
    "інформаційна система",
    "курсова робота",
    "програмна інженерія",
    "тестовий приклад",
  ),
  text: [
    Мета даної роботи -- продемонструвати оформлення пояснювальної записки
    для комплексного курсового проєкту з використанням нового варіанта шаблону.
    Приклад містить узагальнену тему, типові сторінки завдання, календарного плану,
    реферату, змісту, переліку джерел посилання та додатків.

    У роботі наведено умовну структуру програмної системи, що може бути
    адаптована під конкретну предметну область. Основний акцент зроблено на
    перевірці полів титульної сторінки, сторінки завдання, службових підписів,
    нумерації розділів і коректної роботи додатків.

    Результатом є демонстраційний документ, який показує очікуване використання
    шаблону без прив'язки до реального студента, викладача або завершеної роботи.
  ],
)

#let abstract_en = (
  keywords: (
    "WEB APPLICATION",
    "INFORMATION SYSTEM",
    "COURSEWORK",
    "SOFTWARE ENGINEERING",
    "DEMO SAMPLE",
  ),
  text: [
    The purpose of this work is to demonstrate the formatting of a coursework
    explanatory note using the new template variant.

    The sample contains a generalized topic, typical pages for the assignment,
    calendar plan, abstract, contents, bibliography, and appendices.

    The work presents an illustrative structure of a software system that can be
    adapted to a specific subject area. The main focus is on checking title-page
    fields, assignment-page fields, signature blocks, section numbering, and
    appendix handling.

    The result is a demonstration document that shows the expected template usage
    without being tied to a real student, supervisor, or completed project.
  ],
)

#let appendices = [
  = Приклад звіту 1
  #v(-spacing)
  == Частина 1
  #lorem(100)
  == Частина 2
  #lorem(200)

  = Приклад звіту 2
  #lorem(200)

  = Приклад звіту 3
  #lorem(200)
]

#show: coursework-v2.with(
  title: (
    "Демонстраційна інформаційна система для комплексного ",
    "курсового проєкту",
  ),
  authors: authors,
  mentors: mentors,
  task-list: task-list,
  calendar-plan: calendar-plan,
  abstract: abstract,
  abstract-en: abstract_en,
  bib-path: bytes(read("bibl.yml")),
  appendices: appendices,
)

= Моделювання
#lorem(250)

= Імплементація
#v(-spacing)
== Підготовка
#lorem(200)
== Процес
#lorem(500)

= Тестування
#lorem(300)
