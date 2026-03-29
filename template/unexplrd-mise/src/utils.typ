#import "@local/nure:0.1.1": utils

/// captioned image with auto-generated label from path
/// Usage: img("path/to/image.png", "Caption")(optional: "source")
#let img(path, caption, ..sink) = {
  let source = sink.pos().at(0, default: ())
  [ #figure(image(path, ..sink.named()), caption: utils.img-caption(caption, source)) #utils.img-label(path) ]
}

/// takes in a string of code, e.g. #code(read("foo.c"))
#let code(content) = raw(block: true, theme: none, content)

/// read path as bytes
#let b(path) = bytes(read(path, encoding: none))

/// include chapters by file names from /chapters
#let chapters(ch) = (
  array(ch).map(chapter => include str(chapter) + ".typ").join()
)

/// https://forum.typst.app/t/how-to-make-bullet-list-item-bodies-flow-like-paragraphs/3756/3?u=andrew
/// Spacing doesn't work the same way as native solution if par leading and
/// spacing are different.
#let correctly-indent-list-and-enum-items(doc) = {
  let first-line-indent() = if type(par.first-line-indent) == dictionary {
    par.first-line-indent.amount
  } else {
    par.first-line-indent
  }

  show list: li => {
    for (i, it) in li.children.enumerate() {
      let nesting = state("list-nesting", 0)
      let indent = context h((nesting.get() + 1) * li.indent)
      let get-nesting() = calc.div-euclid(nesting.get(), 10)
      let marker = context {
        let n = get-nesting()
        if type(li.marker) == array {
          li.marker.at(calc.rem-euclid(n, li.marker.len()))
        } else if type(li.marker) == content {
          li.marker
        } else {
          li.marker(n)
        }
      }
      let parents = state("enum-parents", ()) // Support enum nesting.
      let body = {
        parents.update(arr => arr + (-1,))
        nesting.update(x => x + 10)
        it.body + parbreak()
        nesting.update(x => x - 10)
        parents.update(arr => arr.slice(0, -1))
      }
      let content = {
        marker
        h(li.body-indent)
        body
      }
      context pad(left: int(nesting.get() != 0) * li.indent, content)
    }
  }

  show enum: en => {
    let start = if en.start == auto {
      if en.children.first().has("number") {
        if en.reversed { en.children.first().number } else { 1 }
      } else {
        if en.reversed { en.children.len() } else { 1 }
      }
    } else {
      en.start
    }
    let number = start
    for (i, it) in en.children.enumerate() {
      number = if it.number != auto { it.number } else { number }
      if en.reversed { number = start - i }
      let parents = state("enum-parents", ())
      let get-parents() = parents.get().filter(x => x >= 0)
      let indent = context h((get-parents().len() + 1) * en.indent)
      let num = if en.full {
        context numbering(en.numbering, ..get-parents(), number)
      } else {
        numbering(en.numbering, number)
      }
      let max-num = if en.full {
        context numbering(en.numbering, ..get-parents(), en.children.len())
      } else {
        numbering(en.numbering, en.children.len())
      }
      num = context box(
        width: measure(max-num).width,
        align(right, text(overhang: false, num)),
      )
      let list-nesting = state("list-nesting", 0) // Support list nesting.
      let body = {
        parents.update(arr => arr + (number,))
        list-nesting.update(x => x + 1)
        it.body + parbreak()
        list-nesting.update(x => x - 1)
        parents.update(arr => arr.slice(0, -1))
      }
      if not en.reversed { number += 1 }
      let content = {
        num
        h(en.body-indent)
        body
      }
      context pad(left: int(parents.get().len() != 0) * en.indent, content)
    }
  }
  doc
}
