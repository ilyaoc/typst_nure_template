/// bold text
#let bold(content) = text(weight: "bold")[#content]

/// numberless heading
#let nheading(title) = heading(depth: 1, numbering: none, title)

/// fill horizontal space with a filled box
#let hfill(width) = box(width: width, repeat(" "))  // HAIR SPACE (U+200A)

/// convert an array of lines into filled lines for underlined task fields
#let filled-lines(content) = if type(content) == array {
  content.map(line => [#line #hfill(1fr)]).join(linebreak())
} else {
  content
}

/// underlined cell with centered content by default
#let uline(align: center, content) = underline[
  #if align != left { hfill(1fr) }
  #content
  #if align != right { hfill(1fr) }
]

/// Extract filename stem without extension
#let stem(path) = path.split("/").last().split(".").first()

/// Extract parent directory name
#let parent-dir(path) = path.split("/").at(-2, default: "")

/// Generate label from image path:
/// - "image.png" → "image"
/// - "img/foo/bar.png" → "foo_bar"
#let img-label(path) = {
  let name = stem(path)
  let parent = parent-dir(path)

  // If parent exists and name doesn't start with parent name, combine them
  let base = if parent != "" and not name.starts-with(parent) {
    parent + "_" + name
  } else {
    name
  }

  label(base.replace(" ", "_"))
}

/// Format image caption based on optional source
#let img-caption(base-caption, source) = {
  if source == none {
    base-caption + " (рисунок виконано самостійно)"
  } else if source == () or source == "" {
    base-caption
  } else {
    base-caption + " (за даними " + source + ")"
  }
}

/// captioned image with auto-generated label from path
/// Usage: img("path/to/image.png", "Caption")(optional: "source")
#let img(path, caption, ..sink) = {
  let source = sink.pos().at(0, default: ())
  [ #figure(image(path, ..sink.named()), caption: utils.img-caption(caption, source)) #utils.img-label(path) ]
}
