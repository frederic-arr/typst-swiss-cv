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

  let show-range(from, to) = emph({
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
  })

  set text(
    font: "Liberation Sans",
    lang: lang.split("-").first(),
    size: 10pt,
    ligatures: false,
  )
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
      = #first_name #upper(last_name)
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

  show heading.where(level: 1): it => {
    v(1em, weak: true)
    (
      text(size: 14pt, smallcaps(it.body))
        + h(0.25cm)
        + box(
          width: 1fr,
          height: 6pt,
          baseline: 40%,
          line(length: 100%),
        )
    )
    v(0.25em, weak: true)
  }
  show heading.where(level: 2): set text(size: 11pt)

  heading(linguify("work-experience"))
  let has_tags = tags.len() > 0
  for work in work {
    let has_position_tag = work.position.any(it => it.tag in tags)
    let has_included_tags = work.position.any(it => {
      it.task.any(it => it.tag in tags)
    })

    if has_tags and not has_position_tag and not has_included_tags {
      continue
    }

    box(heading(l(work.name), level: 2))
    h(1fr)
    strong(l(work.location))
    linebreak()


    for position in work.position {
      let has_tagged_tasks = position.task.any(it => it.tag in tags)

      if has_tags and not has_tagged_tasks and position.tag not in tags {
        continue
      }

      emph({
        l(position.title)
        if ("extra" in position) [ (#l(position.extra))]
      })
      h(1fr)
      show-range(position.from, position.at("to", default: none))
      linebreak()

      let tasks = position
        .task
        .filter(it => if has_tags { it.tag in tags } else {
          true
        })
        .map(it => it.description)
        .flatten()
        .map(it => l(it))

      if tasks.len() > 0 {
        list(..tasks)
      }
    }
  }

  if projects != none {
    heading(linguify("projects"))
    projects
  }

  heading(linguify("education"))
  for edu in education {
    box(emph(heading(l(edu.title), level: 2)))
    h(1fr)
    strong({
      emph([#edu.to.year()])
      if datetime.today() < edu.to {
        [ ]
        linguify("estimated")
      }
    })
    linebreak()

    box(strong(l(edu.subtitle)))
    h(1fr)

    if lang.ends-with("CH") {
      let grade = str(calc.round((edu.grade / 100.0) * 6.0, digits: 1))
      if grade.len() == 1 {
        grade += ".0"
      }
      emph(linguify("grade-ch", args: (grade: str(grade))))
    } else {
      emph(linguify("grade", args: (grade: edu.grade)))
    }
    linebreak()

    box(emph(l(edu.name)))
    h(1fr)
    emph(l(edu.location))
    linebreak()

    if "details" in edu {
      if type(edu.details) == content {
        list(edu.details)
      } else {
        list(cmarker.render(l(edu.details)))
      }
    }

    v(0.25em)
  }

  if skills != none {
    heading(linguify("skills"))
    skills
  }
}

