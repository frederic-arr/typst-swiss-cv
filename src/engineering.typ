#let engineering(
  lang: "",
  default_language: "",
  first_name: "",
  last_name: "",
  gender: "",
  date_of_birth: datetime.today(),
  tel: "",
  email: "",
  address: [],
  nationality: "",
  links: array(()),
  work: array(()),
  education: array(()),
  tags: (),
  sort-by-tags: false,
  projects: none,
  skills: none,
) = {
  import "@preview/linguify:0.5.0": linguify, load-ftl-data, set-database
  import "@preview/datify:1.0.1": custom-date-format
  import "@preview/cmarker:0.1.8"

  set-database(eval(load-ftl-data("/src/langs", ("fr", "en"))))

  let prefix = lang.split("-").first()
  let langkey = lang.replace("-", "_")
  let l(data) = {
    if type(data) == str or type(data) == content {
      return data
    }

    let exact = data.at(langkey, default: none)
    if exact != none {
      return exact
    }

    let parent = data.at(prefix, default: none)
    if parent != none {
      return parent
    }

    let neighkey = data.keys().find(it => it.starts-with(prefix))
    if neighkey != none {
      return data.at(neighkey)
    }

    let defkey = default_language.replace("-", "_")
    let defkeyprefix = default_language.split("-").first()

    let def = data.at(defkey, default: none)
    if def != none {
      return def
    }

    let defparent = data.at(defkeyprefix, default: none)
    if defparent != none {
      return defparent
    }

    panic("No translation found")
  }

  let show-range(from, to) = {
    custom-date-format(
      from,
      pattern: "MMMM yyyy",
      lang: lang,
    )
    [ ]
    sym.dash
    [ ]
    if to != none {
      custom-date-format(
        to,
        pattern: "MMMM yyyy",
        lang: lang,
      )
    } else {
      linguify("present")
    }
  }

  let show-position(position, i) = {
    if i > 0 {
      emph(show-range(position.from, position.at("to", default: none)))
    }

    if position.task.len() > 0 {
      list(..position.task.map(it => it.description).flatten().map(it => l(it)))
    }
  }

  set text(
    font: "Liberation Sans",
    lang: lang.split("-").first(),
    size: 10pt,
    ligatures: false,
    hyphenate: false,
  )
  set list(indent: 1em)
  show smallcaps: set text(font: "Alegreya Sans SC")
  set page(
    paper: "a4",
    header: none,
    footer: none,
    margin: 1.25cm,
  )
  show link: it => underline(text(fill: rgb("#2980b9"))[#it])
  set document(
    author: first_name + " " + last_name,
    title: [#first_name #last_name #sym.dash Curriculum
      Vitae],
    date: datetime.today(),
  )
  set par(justify: true)

  grid(
    columns: (1fr, auto),
    rows: auto,
    align: (left, right),
    [
      = #first_name #upper(last_name) \
      #link("mailto:" + email)[#email] \
      #link("tel:" + tel.replace(" ", "%20"))[#tel] \
      #l(address)
    ],
    [
      #linguify("birth", args: (
        gender: gender,
        date: custom-date-format(
          if type(date_of_birth) == datetime { date_of_birth } else {
            datetime(
              day: date_of_birth.day,
              month: date_of_birth.month,
              year: date_of_birth.year,
            )
          },
          pattern: "long",
          lang: lang,
        ),
      )) \
      #linguify("nationality", args: (nationality: l(nationality)))
      \
      #links.map(l => link(l)[#l]).join([\ ])
    ],
  )

  show heading.where(level: 1): it => block({
    it.body
    h(0.25cm)
    box(
      width: 1fr,
      height: 6pt,
      baseline: 40%,
      line(length: 100%),
    )
  })

  let work = work
    .map(work => {
      work.position = work
        .position
        .map(position => {
          position.task = position.task.filter(task => task.tag in tags or tags.len() == 0)
          position
        })
        .filter(position => position.tag in tags or position.task.len() > 0 or tags.len() == 0)
        .map(position => {
          let local-tags = position.task.map(t => t.tag)
          local-tags.push(position.tag)
          let idx = local-tags
            .map(t => {
              let pos = tags.position(it => it == t)
              pos = if pos == none { 99 } else { pos }
              (pos, t)
            })
            .sorted(key: x => x.first())
            .first()
            .first()

          position.insert("sort-index", idx)
          position
        })
        .sorted(key: it => {
          if sort-by-tags {
            -it.sort-index
          } else {
            (it.at("to", default: datetime.today()), it.from)
          }
        })
        .rev()

      work
    })
    .filter(work => work.position.len() > 0)
    .sorted(key: work => {
      if sort-by-tags {
        -work.position.sorted(key: it => it.sort-index).first().sort-index
      } else {
        let position = work.position.first()
        (position.at("to", default: datetime.today()), position.from)
      }
    })
    .rev()

  [= #linguify("work-experience") ]
  for (i, work) in work.enumerate() {
    let grouped = work
      .position
      .fold((:), (acc, x) => {
        let title = l(x.title)
        if title not in acc {
          acc.insert(
            title,
            (
              title: title,
              position: array(()),
            ),
          )
        }
        acc.at(title).position.push(x)

        acc
      })
      .values()

    if grouped.len() == 1 {
      let group = grouped.first()

      block(
        spacing: if i > 0 { 2em } else { 0em },
        below: 0.75em,
        {
          box([== #group.title])
          h(1fr)
          strong(l(work.name))
        },
      )

      box({
        let position = group.position.first()
        emph(show-range(position.from, position.at("to", default: none)))
        h(1fr)
        l(work.location)
      })

      box(inset: (right: 2em), {
        for (i, position) in group.position.enumerate() {
          show-position(position, i)
        }
      })
    } else {
      block(
        spacing: if i > 0 { 2em } else { 0em },
        below: 0.75em,
        {
          box([== #l(work.name)])
          [ (#l(work.location))]
        },
      )

      box({
        for (i, group) in grouped.enumerate() {
          for (i, position) in group.position.enumerate() {
            box([=== #group.title])
            h(0.25cm)
            emph(show-range(position.from, position.at("to", default: none)))
            show-position(position, i)
          }
        }
      })
    }
  }

  if projects != none {
    [= #linguify("projects")]
    context {
      let headings = state("headings", 0)
      show heading: it => {
        headings.update(it => it + 1)

        if headings.get() == 0 {
          block(spacing: 0em, below: 0.75em, it)
        } else {
          block(spacing: 1.5em, below: 0.75em, it)
        }
      }

      for c in projects.children {
        c
      }
    }
  }

  [= #linguify("education") ]
  for (i, edu) in education.enumerate() {
    block(
      spacing: if i > 0 { 2em } else { 0em },
      below: 0.75em,
      {
        box([== #l(edu.title)])
        h(1fr)
        strong({
          emph([#edu.to.year()])
          if datetime.today() < edu.to {
            [ ]
            linguify("estimated")
          }
        })
      },
    )

    l(edu.name)
    h(1fr)
    l(edu.location)
    if "subtitle" in edu {
      linebreak()
      emph(l(edu.subtitle))
    }

    if "details" in edu {
      if type(edu.details) == content {
        list(edu.details)
      } else {
        list(cmarker.render(l(edu.details)))
      }
    }
  }

  if skills != none {
    [= #linguify("skills")]
    skills
  }
}

