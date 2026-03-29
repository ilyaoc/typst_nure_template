#import "@vendor/nure:0.1.1": *
#import "utils.typ": *

#import style: spacing

// Apply custom rule from utils.typ
// #show: correctly-indent-list-and-enum-items

// #show: style.dstu
#show: pz-lb.with(..toml("doc.toml"), title: "") // set title to none if empty

// Useful snippets

// #figure(
//   caption: [],
//   table(
//     columns: 4,
//     table.header([], [], [], []),
//     ..csv("assets/table.csv").flatten(),
//   ),
// )

// #style.appendices(include "appendices.typ")
