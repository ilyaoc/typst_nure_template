#import "../../helpers.typ": *
#let nure(uni, edu-program, subject, type, number, title, authors, mentors) = {
  align(center)[
    #upper([Міністерство освіти і науки України\ #uni.name])

    \ \
    Кафедра #uni.edu-programs.at(edu-program).department-gen

    \ \ \
    #pz-lb-title(type, number: number)

    з дисципліни: "#uni.subjects.at(subject, default: subject)"
    #if title != none [\ з теми: "#eval(title, mode: "markup")"]

    \ \ \ \
    #columns(2)[
      #set align(left)
      #set par(first-line-indent: 0pt)

      #if authors.len() == 1 {
        let a = authors.first()
        [#gender-form("author", dict: a):\ ]
        [ст. гр. #a.edu-program\-#a.group\ ]
        [#a.name\ ]
        if not is-empty(a.variant) [Варіант: №#a.variant]
      } else if authors.len() > 1 [
        #gender-form("author"):\
        #for a in authors [ст. гр. #a.edu-program\-#a.group\ #a.name\ ]
      ]

      #colbreak()
      #set align(right)

      #if mentors.len() == 1 {
        let m = mentors.first()
        [#gender-form("mentor", dict: m):\ ]
        degree-get(m)
        [#m.name\ ]
      } else if mentors.len() > 1 [
        #gender-form("mentor"):\
        #for m in mentors {
          degree-get(m)
          [#m.name\ ]
        }
      ]
    ]

    #v(1fr)

    Харків -- #datetime.today().display("[year]")
  ]
}
