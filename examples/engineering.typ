#import "/src/lib.typ"

#lib.engineering(
  lang: "fr",
  first_name: "John",
  last_name: "Doe",
  gender: "Male",
  date_of_birth: datetime(year: 2000, month: 01, day: 01),
  tel: "+41 11 300 01 01",
  email: "contact@example.com",
  address: [
    Rue du Pont 4\
    1200 Genève
  ],
  nationality: "Swiss",
  links: (
    "https://github.com",
    "https://www.linkedin.com/",
  ),
  work: (
    (
      name: "ACME Suisse SA",
      location: "Genève",
      position: (
        (
          tag: "some-tag",
          from: datetime(year: 2025, month: 09, day: 01),
          title: "Lead Engineer",
          task: (
            (
              tag: "some-more-tags",
              keywords: array(()),
              description: (
                lorem(20),
                lorem(20),
              ),
            ),
          ),
        ),
      ),
    ),
    (
      name: "ACME Suisse SA",
      location: "Genève",
      position: (
        (
          tag: "some-tag",
          from: datetime(year: 2020, month: 01, day: 31),
          to: datetime(year: 2025, month: 09, day: 01),
          title: "Lead Engineer",
          task: (
            (
              tag: "some-more-tags",
              keywords: array(()),
              description: (
                lorem(20),
                lorem(20),
              ),
            ),
          ),
        ),
        (
          tag: "some-tag",
          from: datetime(year: 2015, month: 01, day: 01),
          to: datetime(year: 2020, month: 01, day: 31),
          title: "Lead Engineer",
          task: (
            (
              tag: "some-more-tags",
              keywords: array(()),
              description: (
                lorem(20),
                lorem(20),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  education: (
    (
      from: datetime(year: 2015, month: 01, day: 01),
      to: datetime(year: 2020, month: 01, day: 31),
      grade: 95,
      grade_ch: "5.7",
      name: "Some University",
      title: "Bachelor of Civil Engineering",
      subtitle: "Specialized in Military Bases",
      location: "Vaud",
      details: [Thesis on _round military bases and their structural density_ with the *jury's awards*],
    ),
  ),
  tags: (),
  projects: [
    == My Project
    #lorem(20)
  ],
  skills: [
    *Languages*: French, German, English
  ],
)
