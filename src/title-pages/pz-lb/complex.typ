#import "../../helpers.typ": *
#let complex(uni, edu-program, subject, type, number, title, authors, mentors) = {
  align(center)[
    Міністерство освіти і науки України \
    #uni.name

    \
    #set par(first-line-indent: 0pt)
    #align(left)[
      #let edu = uni.edu-programs.at(edu-program)
      Кафедра #underline(edu.department-gen) \
      Спеціальність #underline([#edu.code #edu.description]) \
      Освітня програма #underline(edu.name-long)
    ]

    \ \

    #pz-lb-title(type, number: number)

    з навчальної дисципліни "#uni.subjects.at(subject, default: subject)"\
    #if title != none [з теми "#eval(title, mode: "markup")"\ ]
    #if authors.first().variant != none [\ Варіант №#authors.first().variant\ ]

    \ \ \

    #align(right)[
      #if authors.len() == 1 {
        let a = authors.first()
        [#gender-form("author", dict: a):\
          студент групи #a.edu-program\-#a.group\ #a.name\ ]
        text(size: 8pt, [(прізвище та ініціали)\ ])
      } else if authors.len() > 1 [
        #gender-verb("author"):\
        #for a in authors [студент групи #a.edu-program\-#a.group\ #a.name\ ]
        #text(size: 8pt, [(прізвище та ініціали)\ ])
      ]

      \

      #if mentors.len() == 1 {
        let m = mentors.first()
        [#gender-form("mentor", dict: m):\ ]
        degree-get(m)
        [#m.name\ ]
        text(size: 8pt, [(прізвище та ініціали)\ ])
      } else if mentors.len() > 1 [
        #gender-verb("mentor"):\
        #for m in mentors {
          degree-get(m)
          [#m.name\ ]
        }
      ]
    ]

    #v(1fr)

    Харків\
    #datetime.today().display("[year]")
  ]
}
