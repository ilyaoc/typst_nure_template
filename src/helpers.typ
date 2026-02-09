/// month name from its number
#let month-gen(month) = (
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

/// type-safe emptiness check
#let is-empty(val) = {
  if val == none { return true }
  if type(val) == str { val.len() == 0 } else if type(val) == array { val == [] } else { false }
}

#let degree-get(m) = if "degree" in m and not is-empty(m.degree) { [#m.degree\ ] }

/// returns verb form based on gender ("m", "f", or "p" for plural)
#let gender-verb(verb, gender: "p") = {
  (
    "author": ("m": "Виконав", "f": "Виконала", "p": "Виконали"),
    "mentor": ("m": "Перевірив", "f": "Перевірила", "p": "Перевірили"),
  )
    .at(verb)
    .at(if gender == "m" or gender == "f" { gender } else { "p" })
}

/// returns verb form for dictionary containing gender field
#let gender-form(verb, dict: none) = {
  let g = if type(dict) == dictionary and "gender" in dict { dict.gender } else { "p" }
  gender-verb(verb, gender: g)
}

#let pz-lb-title(type, number: none) = {
  let type-title = (
    "ЛБ": [Звіт \ з лабораторної роботи],
    "ПЗ": [Звіт \ з практичної роботи],
    "КР": [Контрольна робота],
    "РФ": [Реферат],
    "ІДЗ": [Індивідуальне домашнє завдання],
  ).at(type, default: type)
  if not is-empty(number) { [#type-title №#number] } else { [#type-title] }
}
