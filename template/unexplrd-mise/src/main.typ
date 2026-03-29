#import "@vendor/nure:0.1.1": *
#import "utils.typ": *

#import style: spacing

// Apply custom rule from utils.typ
// #show: correctly-indent-list-and-enum-items

// #show: style.dstu
#show: pz-lb.with(..toml("doc.toml"), title: "") // set title to none if empty

/// Useful snippets

/// Import a .csv table
// #figure(
//   caption: [],
//   table(
//     columns: 4,
//     table.header([], [], [], []),
//     ..csv("assets/table.csv").flatten(),
//   ),
// )

/// Appendices
// #style.appendices(include "chapters/appendices.typ")
// or
// #show: style.appendices
// = ...
