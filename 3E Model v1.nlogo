globals[
  aura-size
  half-side
  %-familyback
  P-base-cc
  P-base-ce
  P-base-ec
  P-base-ee
  duration-cc
  duration-ce
  duration-ec
  duration-ee
  selected-uni-course
  selected-uni-event
  selected-location-excourse
  selected-location-exevent
  random-sample-students-cc
  random-sample-teachers/researchers-cc
  random-sample-students-ce
  random-sample-teachers/researchers-ce
  random-sample-entrepreneurs-ce
  random-sample-investors-ce
  random-sample-students-ec
  random-sample-teachers-ec
  random-sample-entrepreneurs-ec
  random-sample-investors-ec
  random-sample-students-ee
  random-sample-teachers-ee
  random-sample-entrepreneurs-ee
  random-sample-investors-ee
  corruption-incidence
  burocracy-incidence
  perception-incidence
  melting-incidence
  access-incidence
  culture-incidence
  %num-familyback
  %num-motivation
  mean-ecosystem-entrepreneurial-knowledge
  motivation-history-students
  motivation-history-teachers
  motivation-history-entrepreneurs
  motivation-history-investors
  entrepreneurs-history
]

patches-own [
  aura-marked?
]

turtles-own [
  course-ticks
  event-ticks
  excourse-ticks
  exevent-ticks
]
breed [institutions institution]
institutions-own [
  species
  entrepreneurial-culture
  university-type
  pause-ticks
  curricular-course-active?
  curricular-event-active?
  extracurricular-course-active?
  extracurricular-event-active?
  course-students
  course-teachers/researchers
  event-students
  event-teachers/researchers
  event-entrepreneurs
  event-investors
  excourse-students
  excourse-entrepreneurs
  excourse-teachers/researchers
  excourse-investors
  exevent-students
  exevent-entrepreneurs
  exevent-teachers/researchers
  exevent-investors
]
breed [individuals individual]
individuals-own [
  species
  age
  nationality
  education-background
  family-background?
  university-assigned
  teachers/researchers-type
  entrepreneurs-type
  investors-type
  entrepreneurial-knowledge
  initial-entrepreneurial-knowledge
  mean-entrepreneurial-knowledge
  motivation
  motivation-initialized?
  moving?
  entre-know-updated-cc?
  entre-know-updated-ce?
  entre-know-updated-ec?
  entre-know-updated-ee?
  attending-curricular-course?
  attending-curricular-event?
  attending-extracurricular-course?
  attending-extracurricular-event?
  old-xcor
  old-ycor
  last-motivation-update-tick
]

;-------------------------------------------------------------------------------------------------------;
;SETUP PROCEDURE;
to setup
  clear-all
  set aura-size min (list world-width world-height) / 12 ;; Dimensione proporzionale al mondo
  set half-side floor (aura-size / 2)
  set corruption-incidence -0.49
  set burocracy-incidence 0.52
  set perception-incidence 0.40
  set melting-incidence 0.35
  set access-incidence 0.45
  set culture-incidence 0.50
  set %num-familyback 0.35
  set %num-motivation 0.6

  ask patches [
    set pcolor green
    set aura-marked? false
  ]

  create-agents
  ensure-turtles-aura-fit
  draw-aura
  inizialization/update-entrepreneurial-knowledge
  inizialization/update-entrepreneurial-culture

  ask individuals[
    set moving? true
    set nationality "italian"
  ]
  ask n-of (min (list (%melting-pot * count individuals) count individuals)) individuals [
    set nationality "foreign"
  ]
  ;  show count individuals with [nationality = "italian"]
  ;  show count individuals with [nationality = "foreign"]
;; Calcola la media della conoscenza imprenditoriale degli imprenditori sotto la media
  set mean-ecosystem-entrepreneurial-knowledge mean [mean-entrepreneurial-knowledge] of individuals with [
    species = "entrepreneur" and
    mean-entrepreneurial-knowledge < mean [mean-entrepreneurial-knowledge] of individuals with [species = "entrepreneur"]
  ]
  set motivation-history-students []
  set motivation-history-teachers []
  set motivation-history-entrepreneurs []
  set motivation-history-investors []
  set entrepreneurs-history []

  reset-ticks
end
;-------------------------------------------------------------------------------------------------------;
;GO PROCEDURE;
to go
  move-randomly
  curricular-course
  curricular-event
  extracurricular-course
  extracurricular-event
  inizialization/update-entrepreneurial-culture
  replace-entrepreneurial-individuals
 ; log-motivation
  tick
end
to curricular-course
  set P-base-cc 0.25
  let P (P-base-cc
         + perception-incidence * %perception-of-entrepreneurship
         + melting-incidence * %melting-pot
         + corruption-incidence * corruption
         - burocracy-incidence * %burocracy
         + access-incidence * access-to-credit
         + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))

  let P-min 0.02  ;; Probabilità minima (2%)
  set P max (list P-min (min (list 1 P)))

  if random-float 1 < P [
    prepare-curricular-course
  ]
  update-curricular-course
end

to extracurricular-course
  set P-base-ec 0.20
  let P (P-base-ec
         + perception-incidence * %perception-of-entrepreneurship
         + melting-incidence * %melting-pot
         + corruption-incidence * corruption
         - burocracy-incidence * %burocracy
         + access-incidence * access-to-credit
         + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))

  let P-min 0.02
  set P max (list P-min (min (list 1 P)))

  if random-float 1 < P [
    prepare-extracurricular-course
  ]
  update-extracurricular-course
end

to curricular-event
  set P-base-ce 0.22
  let P (P-base-ce
         + perception-incidence * %perception-of-entrepreneurship
         + melting-incidence * %melting-pot
         + corruption-incidence * corruption
         - burocracy-incidence * %burocracy
         + access-incidence * access-to-credit
         + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))

  let P-min 0.02
  set P max (list P-min (min (list 1 P)))

  if random-float 1 < P [
    prepare-curricular-event
  ]
  update-curricular-event
end

to extracurricular-event
  set P-base-ee 0.18
  let P (P-base-ee
         + perception-incidence * %perception-of-entrepreneurship
         + melting-incidence * %melting-pot
         + corruption-incidence * corruption
         - burocracy-incidence * %burocracy
         + access-incidence * access-to-credit
         + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))

  let P-min 0.02
  set P max (list P-min (min (list 1 P)))

  if random-float 1 < P [
    prepare-extracurricular-event
  ]
  update-extracurricular-event
end

;-------------------------------------------------------------------------------------------------------;
;GENERATE ALL TURTLES ;
to create-agents
  create-universities-no-overlap
  create-inc/acc-min-distance
  create-students
  create-teach/resea
  create-entrepreneurs
  create-investors
  create-policy-makers
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE UNIVERSITIES
to create-universities-no-overlap
  let created 0
  let max-distance floor (world-width / 4)

  while [created < universities] [
    let new-x random (max-distance * 2) - max-distance
    let new-y random (max-distance * 2) - max-distance
    if all? patches with [
      pxcor >= new-x - half-side and
      pxcor <= new-x + half-side and
      pycor >= new-y - half-side and
      pycor <= new-y + half-side
    ] [not aura-marked?] [
      create-institutions 1 [
        setxy new-x new-y
        set shape "house"
        set size 3
        set color violet - 1
        set species "university"
      ]
      ask patches with [
        pxcor >= new-x - half-side and
        pxcor <= new-x + half-side and
        pycor >= new-y - half-side and
        pycor <= new-y + half-side
      ] [
        set aura-marked? true
      ]
      set created created + 1
    ]
  ]
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE INCUBATORS
to create-inc/acc-min-distance
  let created 0
  let min-distance (min list world-width world-height) / 5 + aura-size
  while [created < incubators/accelerators] [
    let new-x random-xcor
    let new-y random-ycor

    if all? turtles [distancexy new-x new-y >= min-distance] [
      create-institutions 1 [
        setxy new-x new-y
        set shape "house two story"
        set size 3
        set color orange - 1
        set species "incubator/accelerator"
      ]

      set created created + 1
    ]
  ]
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE STUDENTS;
to create-students
  let created 0
  ;let %-italians 0.99
  let limit-age-probability 0.95
  let %-bachelor-degree 0.2
  set %-familyback 0.36
  while [created < students] [

    let within-aura? random-float 1 < 0.7

    ifelse within-aura? [
      let university one-of turtles with [color = violet - 1]

      let aura-patches patches with [
        pxcor >= [xcor] of university - half-side and
        pxcor <= [xcor] of university + half-side and
        pycor >= [ycor] of university - half-side and
        pycor <= [ycor] of university + half-side
      ]

      let spawn-patch one-of aura-patches

      create-individuals 1 [
        setxy [pxcor] of spawn-patch [pycor] of spawn-patch
        set shape "person student"
        set size 1.5
        set color red
        set species "student"
        set university-assigned university
        set last-motivation-update-tick 0
      ]
    ] [
      create-individuals 1 [
        setxy random-xcor random-ycor
        set shape "person student"
        set size 1.5
        set color red
        set species "student"
        set university-assigned one-of institutions with [species = "university"]
        set last-motivation-update-tick 0
      ]
    ]
    set created created + 1
  ]

  ask n-of (limit-age-probability * students) individuals with [species = "student"] [
    set age 18 + random 18
  ]
  ask individuals with [species = "student" and age = 0] [
    set age 36 + random 30
  ]

  ask n-of (%-familyback * students) individuals with [species = "student"] [
    set family-background? 1
  ]
  ask n-of (%-bachelor-degree * students) individuals with [species = "student"] [
    set education-background "Bachelor Degree"
  ]
  ask individuals with [species = "student" and education-background != "Bachelor Degree"] [
    set education-background "High School Diploma"
  ]


  ;  show count individuals with [species = "student" and age > 35]
  ;  show count individuals with [species = "student" and nationality = "italian"]
  ;  show count individuals with [species = "student" and nationality = "foreign"]
  ;  show count individuals with [species = "student" and education-background = "Bachelor Degree"]
  ;  show count individuals with [species = "student" and education-background = "High School Diploma"]
  ;  show count individuals with [species = "student" and family-background? = 1]

  ;  show count individuals with [species = "student" and nationality = "italian"]
  ;  show count individuals with [species = "student" and nationality = "foreign"]
  ;  show count individuals with [species = "student" and background = "Bachelor Degree"]
  ;  show count individuals with [species = "student" and background = "High School Diploma"]

end
;-------------------------------------------------------------------------------------------------------;
;GENERATE TEACHERS & RESEARCHERS
to create-teach/resea
  let created 0
  let %-entrepreneurial 0.5
  while [created < teachers/researchers] [

    let within-aura? random-float 1 < 0.7

    ifelse within-aura? [
      let university one-of turtles with [color = violet - 1]

      let aura-patches patches with [
        pxcor >= [xcor] of university - half-side and
        pxcor <= [xcor] of university + half-side and
        pycor >= [ycor] of university - half-side and
        pycor <= [ycor] of university + half-side
      ]

      let spawn-patch one-of aura-patches
      create-individuals 1 [
        setxy [pxcor] of spawn-patch [pycor] of spawn-patch
        set shape "person graduate"
        set size 1.5
        set color black
        set species "teacher/researcher"
        set university-assigned university
        set last-motivation-update-tick 0
      ]
    ][
      create-individuals 1 [
        setxy random-xcor random-ycor
        set shape "person graduate"
        set size 1.5
        set color black
        set species "teacher/researcher"
        set university-assigned one-of institutions with [species = "university"]
        set last-motivation-update-tick 0
      ]
    ]
    set created created + 1
  ]

  ask n-of (%-entrepreneurial * teachers/researchers) individuals with [species = "teacher/researcher"] [
    set teachers/researchers-type "entrepreneurial teacher/researcher"
  ]
  ask individuals with [species = "teacher/researcher" and teachers/researchers-type = 0] [
    set teachers/researchers-type "non-entrepreneurial teacher/researcher"
  ]

  ;  show count individuals with [species = "teacher/researcher" and teachers/researchers-type = "entrepreneurial teacher/researcher"]
  ;  show count individuals with [species = "teacher/researcher" and teachers/researchers-type = "non-entrepreneurial teacher/researcher"]
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE ENTREPRENEUS
to create-entrepreneurs
  let created 0
  let %-TEA 0.08
  while [created < entrepreneurs] [
    let within-aura? random-float 1 < 0.7

    ifelse within-aura? [
      let incubator one-of turtles with [color = orange - 1]


      let aura-patches patches with [
        pxcor >= [xcor] of incubator - half-side and
        pxcor <= [xcor] of incubator + half-side and
        pycor >= [ycor] of incubator - half-side and
        pycor <= [ycor] of incubator + half-side
      ]


      let spawn-patch one-of aura-patches

      create-individuals 1 [
        setxy [pxcor] of spawn-patch [pycor] of spawn-patch
        set shape "person business"
        set size 1.5
        set color blue
        set species "entrepreneur"
        set last-motivation-update-tick 0
      ]
    ] [
      create-individuals 1 [
        setxy random-xcor random-ycor
        set shape "person business"
        set size 1.5
        set color blue
        set species "entrepreneur"
        set last-motivation-update-tick 0
      ]
    ]
    set created created + 1
  ]

  ask n-of round (%-TEA * entrepreneurs) individuals with [species = "entrepreneur"] [
    set entrepreneurs-type "Early-stage entrepreneur"
  ]
  ask individuals with [species = "entrepreneur" and entrepreneurs-type = 0] [
    set entrepreneurs-type "Expert entrepreneur"
  ]
  ;    show count individuals with [species = "entrepreneur" and entrepreneurs-type = "Early-stage entrepreneur" ]

end
;-------------------------------------------------------------------------------------------------------;
;GENERATE INVESTORS;
to create-investors
  let created 0
  let buildings 3
  let %-top 0.7
  let total-investors investors

  while [created < total-investors] [
    let new-x random-xcor
    let new-y random-ycor
    let is-building? created < buildings

    if is-building? [

      let min-distance (min list world-width world-height) / 5 + aura-size
      let valid-location? false


      while [not valid-location?] [
        set new-x random-xcor
        set new-y random-ycor
        let aura-size-check floor (aura-size / 2)


        if all? turtles with [color = violet - 1 or color = orange - 1 ] [
          distancexy new-x new-y >= aura-size + aura-size-check]
        and all? turtles with [shape = "building store"] [
          distancexy new-x new-y >= min-distance
        ] [
          set valid-location? true
        ]
      ]

      create-institutions 1 [
        setxy new-x new-y
        set shape "building store"
        set size 3
        set color brown - 1
        set species "venture capital/bank"
      ]
    ]
    if not is-building? [

      create-individuals 1 [
        setxy new-x new-y
        set shape "person"
        set size 1.5
        set color brown - 1
        set species "business angel"
        set last-motivation-update-tick 0
      ]
    ]
    set created created + 1
  ]

  ask n-of round (%-top * count individuals with [species = "business angel"] ) individuals with [species = "business angel"] [
    set investors-type "Expert investor"
  ]
  ask individuals with [species = "business angel" and entrepreneurs-type = 0] [
    set investors-type "Early-stage investor"
  ]
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE POLICY-MAKERS ;
to create-policy-makers
  let created 0
  let min-distance (min list world-width world-height) / 5 + aura-size
  let max-attempts 100
  let attempts 0

  while [created < policy-makers] [
    let new-x random-xcor
    let new-y random-ycor
    let valid-location? false

    while [not valid-location? and attempts < max-attempts] [
      set new-x random-xcor
      set new-y random-ycor
      let aura-size-check floor (aura-size / 2)

      if all? turtles with [color = violet - 1 or color = orange - 1  or color = brown - 1] [
        distancexy new-x new-y >= aura-size + aura-size-check
      ]
      and all? turtles with [shape = "building institution"] [
        distancexy new-x new-y >= min-distance
      ] [
        set valid-location? true
      ]

      set attempts attempts + 1
    ]

    if valid-location? [
      create-institutions 1 [
        setxy new-x new-y
        set shape "building institution"
        set size 3
        set color lime - 1
        set species "policy maker"
      ]
      set created created + 1
    ]
  ]
end
;-------------------------------------------------------------------------------------------------------;
;DRAW AURA OF INFLUENCE;
to draw-aura
  ask institutions [
    ifelse species = "university" [
      ask patches with [
        pxcor >= [pxcor] of myself - half-side and
        pxcor <= [pxcor] of myself + half-side and
        pycor >= [pycor] of myself - half-side and
        pycor <= [pycor] of myself + half-side
      ] [
        set pcolor violet + 2
      ]
    ] [
      ifelse species = "incubator/accelerator" [
        ask patches with [
          pxcor >= [pxcor] of myself - half-side and
          pxcor <= [pxcor] of myself + half-side and
          pycor >= [pycor] of myself - half-side and
          pycor <= [pycor] of myself + half-side
        ] [
          set pcolor orange + 2
        ]
      ][
        ifelse species = "venture capital/bank" [
          ask patches with [
            pxcor >= [pxcor] of myself - half-side and
            pxcor <= [pxcor] of myself + half-side and
            pycor >= [pycor] of myself - half-side and
            pycor <= [pycor] of myself + half-side
          ] [
            set pcolor brown + 2
          ]
        ][
          ask patches with [
            pxcor >= [pxcor] of myself - half-side and
            pxcor <= [pxcor] of myself + half-side and
            pycor >= [pycor] of myself - half-side and
            pycor <= [pycor] of myself + half-side
          ] [
            set pcolor lime + 2
          ]
        ]
      ]
    ]
  ]

end
;-------------------------------------------------------------------------------------------------------;
;CHECK AURA POSITION;
to ensure-turtles-aura-fit
  ask turtles [
    let new-x pxcor
    let new-y pycor

    if pxcor - half-side < min-pxcor [
      set new-x min-pxcor + half-side
    ]
    if pxcor + half-side > max-pxcor [
      set new-x max-pxcor - half-side
    ]
    if pycor - half-side < min-pycor [
      set new-y min-pycor + half-side
    ]
    if pycor + half-side > max-pycor [
      set new-y max-pycor - half-side
    ]

    setxy new-x new-y
  ]
end
;-------------------------------------------------------------------------------------------------------;
;INIZIALIZATION ENTREPRENEURIAL KNOWLEDGE & CULTURE;
to inizialization/update-entrepreneurial-knowledge
  let target-means-students (list 4.76 6.46 5.32 6.34 6.06 4.69 5.95)
  let target-means-teachers/researchers (list 6.01 7.71 6.57 7.59 7.31 6.69 7.20)
  let target-means-entrepreneurs (list 7.26 8.96 7.82 8.84 8.56 8.69 8.45)
  let target-means-investors (list 6.98 8.77 8.32 8.65 8.35 8.10 8.24)

  let target-std-dev 0.5

  ask individuals with [species = "student"] [
    set entrepreneurial-knowledge []

    foreach range length target-means-students [ ?i ->
      let target-mean-students item ?i target-means-students

      let value 0
      while [value = 0 or abs (value - target-mean-students) > (target-std-dev)] [
        set value (random-normal target-mean-students target-std-dev)
      ]

      set entrepreneurial-knowledge lput (precision value 2) entrepreneurial-knowledge
    ]

    set entrepreneurial-knowledge entrepreneurial-knowledge

    set initial-entrepreneurial-knowledge []
    set initial-entrepreneurial-knowledge entrepreneurial-knowledge

    set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
    if motivation-initialized? = 0 [
        set motivation (mean entrepreneurial-knowledge
                        + perception-incidence * %perception-of-entrepreneurship
                        + melting-incidence * %melting-pot
                        + corruption-incidence * corruption
                        - burocracy-incidence * %burocracy
                        - access-incidence * access-to-credit
                        + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))
        set motivation-initialized? 1
    ]
  ]
  ask individuals with [species = "teacher/researcher"] [
    set entrepreneurial-knowledge[]

    foreach range length target-means-teachers/researchers [ ?i ->
      let target-mean-teachers/researchers item ?i target-means-teachers/researchers

      let value 0
      while [value = 0 or abs (value - target-mean-teachers/researchers) > (target-std-dev)] [
        set value (random-normal target-mean-teachers/researchers target-std-dev)
      ]

      set entrepreneurial-knowledge lput (precision value 2) entrepreneurial-knowledge
    ]

    set entrepreneurial-knowledge entrepreneurial-knowledge

    set initial-entrepreneurial-knowledge []
    set initial-entrepreneurial-knowledge entrepreneurial-knowledge

    set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
        if motivation-initialized? = 0 [
        set motivation (mean entrepreneurial-knowledge
                        + perception-incidence * %perception-of-entrepreneurship
                        + melting-incidence * %melting-pot
                        + corruption-incidence * corruption
                        - burocracy-incidence * %burocracy
                        - access-incidence * access-to-credit
                        + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))
        set motivation-initialized? 1
    ]
  ]
  ask individuals with [species = "entrepreneur"][
    set entrepreneurial-knowledge []

    foreach range length target-means-entrepreneurs [ ?i ->
      let target-mean-entrepreneurs item ?i target-means-entrepreneurs


      let value 0
      while [value = 0 or abs (value - target-mean-entrepreneurs) > (target-std-dev)] [
        set value (random-normal target-mean-entrepreneurs target-std-dev)
      ]

      set entrepreneurial-knowledge lput (precision value 2) entrepreneurial-knowledge
    ]

    set entrepreneurial-knowledge entrepreneurial-knowledge

    set initial-entrepreneurial-knowledge []
    set initial-entrepreneurial-knowledge entrepreneurial-knowledge

    set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
        if motivation-initialized? = 0 [
        set motivation (mean entrepreneurial-knowledge
                        + perception-incidence * %perception-of-entrepreneurship
                        + melting-incidence * %melting-pot
                        + corruption-incidence * corruption
                        - burocracy-incidence * %burocracy
                        - access-incidence * access-to-credit
                        + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))
        set motivation-initialized? 1
    ]
  ]
  ask individuals with [species = "business angel"] [
    set entrepreneurial-knowledge []

    foreach range length target-means-investors [ ?i ->
      let target-mean-investors item ?i target-means-investors

      let value 0
      while [value = 0 or abs (value - target-mean-investors) > (target-std-dev)] [
        set value (random-normal target-mean-investors target-std-dev)
      ]

      set entrepreneurial-knowledge lput (precision value 2) entrepreneurial-knowledge
    ]

    set entrepreneurial-knowledge entrepreneurial-knowledge

    set initial-entrepreneurial-knowledge []
    set initial-entrepreneurial-knowledge entrepreneurial-knowledge

    set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
    if motivation-initialized? = 0 [
        set motivation (mean entrepreneurial-knowledge
                        + perception-incidence * %perception-of-entrepreneurship
                        + melting-incidence * %melting-pot
                        + corruption-incidence * corruption
                        - burocracy-incidence * %burocracy
                        - access-incidence * access-to-credit
                        + culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions))
        set motivation-initialized? 1
    ]
  ]
end
to inizialization/update-entrepreneurial-culture
  foreach sort institutions with [species = "university" and entrepreneurial-culture != 10] [the-university ->
    let student-knowledge-list []
    let teachers/researchers-knowledge-list []
    let knowledge-list []

    let assigned-students individuals with [species = "student" and university-assigned = the-university]
    ask assigned-students [
      set student-knowledge-list lput mean entrepreneurial-knowledge student-knowledge-list
    ]

    let assigned-teachers/researchers individuals with [species = "teacher/researcher" and university-assigned = the-university]
    ask assigned-teachers/researchers [
      set teachers/researchers-knowledge-list lput mean entrepreneurial-knowledge teachers/researchers-knowledge-list
    ]

    set knowledge-list (sentence student-knowledge-list teachers/researchers-knowledge-list)

    ask the-university [
      set entrepreneurial-culture precision (min list mean knowledge-list 10) 2
    ]
  ]

  ask institutions with [species = "university" ][
    let target-mean-uni mean [entrepreneurial-culture] of institutions with [species = "university"]
    ifelse entrepreneurial-culture > target-mean-uni [
      set university-type "entrepreneurial university"
    ][
      set university-type "non-entreprenurial university"
    ]
  ]

  ask institutions with [species = "incubator/accelerator" and entrepreneurial-culture != 10] [
    let entrepreneurs-knowledge-list []

    ask individuals with [species = "entrepreneur"] [
      set entrepreneurs-knowledge-list lput mean entrepreneurial-knowledge entrepreneurs-knowledge-list
    ]

    let target-mean precision mean entrepreneurs-knowledge-list 2
    let target-std-dev 0.5 ;; Deviazione standard comune per ogni elemento

    ;; Genera un valore casuale seguendo una distribuzione normale con deviazione standard
    let value 0
    while [value = 0 or abs (value - target-mean) > target-std-dev] [
      set value (random-normal target-mean target-std-dev)
    ]

    ;; Assegna il valore generato a entrepreneurial-culture
    set entrepreneurial-culture precision (min list value 10) 2
  ]

  ask institutions with [species = "venture capital/bank" and entrepreneurial-culture != 10] [
    let investors-knowledge-list []

    ask individuals with [species = "business angel"] [
      set investors-knowledge-list lput mean entrepreneurial-knowledge investors-knowledge-list
    ]

    let target-mean precision mean investors-knowledge-list 2

    let target-std-dev 0.5 ;; Deviazione standard comune per ogni elemento

    ;; Genera un valore casuale seguendo una distribuzione normale con deviazione standard
    let value 0
    while [value = 0 or abs (value - target-mean) > target-std-dev] [
      set value (random-normal target-mean target-std-dev)
    ]

    ;; Assegna il valore generato a entrepreneurial-culture
    set entrepreneurial-culture precision (min list value 10) 2
  ]

  ask institutions with [species = "policy maker" and entrepreneurial-culture != 10] [
    let universities-culture-list []
    let incubators/accelerators-culture-list []
    let investors-culture-list []
    let policy-culture-list []


    ask institutions with [species = "university"] [
      set universities-culture-list lput entrepreneurial-culture universities-culture-list
      ;show universities-culture-list
    ]
    ask institutions with [species = "incubator/accelerator"] [
      set incubators/accelerators-culture-list lput entrepreneurial-culture incubators/accelerators-culture-list
      ;show incubators/accelerators-culture-list
    ]
    ask institutions with [species = "venture capital/bank"] [
      set investors-culture-list lput entrepreneurial-culture investors-culture-list
      ;show investors-culture-list
    ]

    set policy-culture-list (sentence universities-culture-list incubators/accelerators-culture-list investors-culture-list)
    ;show policy-culture-list

    let target-mean precision mean policy-culture-list 2

    let target-std-dev 0.5 ;; Deviazione standard comune per ogni elemento

    ;; Genera un valore casuale seguendo una distribuzione normale con deviazione standard
    let value 0
    while [value = 0 or abs (value - target-mean) > target-std-dev] [
      set value (random-normal target-mean target-std-dev)
    ]

    ;; Assegna il valore generato a entrepreneurial-culture
    set entrepreneurial-culture precision (min list value 10) 2
  ]

end
;-------------------------------------------------------------------------------------------------------;
;MOVEMENT PROCEDURE;
to move-randomly
  ask individuals [
    ifelse moving? = true[
      set heading random 360
      fd 2][
      if (xcor > max-pxcor) or (xcor < min-pxcor) or (ycor > max-pycor) or (ycor < min-pycor) [
        set heading random 360
        fd 2
      ]
    ]
  ]
end
;-------------------------------------------------------------------------------------------------------;
to random-sample-curricular-course-generation
  let sample-teachers/researchers-size 1 + random 1
  let sample-students-size (0.1 * students)
  let num-familyback-students round (%num-familyback * sample-students-size)               ;Lo 0.35 è stato preso dal GUESS 2023 in Italia
  let num-motivation-students round (%num-motivation * sample-students-size)
  set random-sample-students-cc []

  ;; Selezione studenti con background familiare
  let available-familyback individuals with [species = "student" and family-background? = 1 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0
    and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course]
  let familyback-sample n-of (min (list num-familyback-students count available-familyback)) available-familyback

  ;; Selezione studenti con motivazione sopra la media
  let additional-motivation-needed (num-motivation-students - count familyback-sample with [motivation > mean [motivation] of individuals with [species = "student"]])
  let available-motivated individuals with [
    species = "student" and
    motivation > mean [motivation] of individuals with [species = "student"] and
    not member? self familyback-sample and
    family-background? = 0 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0
    and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course
  ]
  let motivation-sample nobody
  if additional-motivation-needed > 0 [
    set motivation-sample n-of (min (list additional-motivation-needed count available-motivated)) available-motivated
  ]

  ;; Creazione del campione combinato
  let combined-sample (turtle-set familyback-sample motivation-sample)
  let remaining (sample-students-size - count combined-sample)

  ;; Selezione studenti aggiuntivi se necessario
  if remaining > 0 [
    let available-additional individuals with [
      species = "student" and
      not member? self combined-sample and
      motivation < mean [motivation] of individuals with [species = "student"] and
      family-background? = 0 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0
      and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course
    ]
    let additional-sample n-of (min (list remaining count available-additional)) available-additional
    set combined-sample (turtle-set combined-sample additional-sample)
  ]

  set random-sample-students-cc combined-sample

  ;; Selezione degli insegnanti
  let available-teachers individuals with [
    species = "teacher/researcher" and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course
    ;    and teachers/researchers-type = "entrepreneurial teacher/researcher" and university-assigned = selected-uni-course
  ]
  let entrepreneurial-teachers n-of (min (list sample-teachers/researchers-size count available-teachers)) available-teachers
  set random-sample-teachers/researchers-cc entrepreneurial-teachers


  ;  show mean [motivation] of individuals with [species = "student"]
  ;  show [who] of random-sample-students-cc
  ;  show [family-background?] of random-sample-students-cc
  ;  show [motivation] of random-sample-students-cc
  ;  show random-sample-teachers/researchers-cc

end
to random-sample-curricular-event-generation

  let sample-students-size (0.1 * students)
  let num-familyback-students round (%num-familyback * sample-students-size)          ;Lo 0.35 è stato preso dal GUESS 2023 in Italia
  let num-motivation-students round (%num-motivation * sample-students-size)

  let sample-teachers/researchers-size 1 + random 1
  let sample-entrepreneurs-size 1 + random 3
  let sample-investors-size 1 + random 1

  set random-sample-students-ce []

  ;; Selezione studenti con background familiare
  let available-familyback individuals with [species = "student" and family-background? = 1 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course]
  let familyback-sample n-of (min (list num-familyback-students count available-familyback)) available-familyback

  ;; Selezione studenti con motivazione sopra la media
  let additional-motivation-needed (num-motivation-students - count familyback-sample with [motivation > mean [motivation] of individuals with [species = "student"]])
  let available-motivated individuals with [
    species = "student" and
    motivation > mean [motivation] of individuals with [species = "student"] and
    not member? self familyback-sample and
    family-background? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course
  ]
  let motivation-sample nobody
  if additional-motivation-needed > 0 [
    set motivation-sample n-of (min (list additional-motivation-needed count available-motivated)) available-motivated
  ]

  ;; Creazione del campione combinato
  let combined-sample (turtle-set familyback-sample motivation-sample)
  let remaining (sample-students-size - count combined-sample)

  ;; Selezione studenti aggiuntivi se necessario
  if remaining > 0 [
    let available-additional individuals with [
      species = "student" and
      not member? self combined-sample and
      motivation < mean [motivation] of individuals with [species = "student"] and
      family-background? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and university-assigned = selected-uni-course
    ]
    let additional-sample n-of (min (list remaining count available-additional)) available-additional
    set combined-sample (turtle-set combined-sample additional-sample)
  ]

  set random-sample-students-ce combined-sample

  ;; Selezione degli insegnanti
  let available-teachers individuals with [
    species = "teacher/researcher" and attending-curricular-event? = 0 and attending-extracurricular-event? = 0 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and university-assigned = selected-uni-course
  ]
  let num-possible-teachers min (list sample-teachers/researchers-size count available-teachers)
  let entrepreneurial-teachers n-of num-possible-teachers available-teachers
  set random-sample-teachers/researchers-ce entrepreneurial-teachers

  ;; Selezione degli imprenditori
  let available-entrepreneurs individuals with [species = "entrepreneur" and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-entrepreneurs min (list sample-entrepreneurs-size count available-entrepreneurs)
  let entrepreneurial-entrepreneurs n-of num-possible-entrepreneurs available-entrepreneurs
  set random-sample-entrepreneurs-ce entrepreneurial-entrepreneurs

  ;; Selezione degli investitori
  let available-investors individuals with [species = "business angel" and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-investors min (list sample-investors-size count available-investors)
  set random-sample-investors-ce n-of num-possible-investors available-investors
  ;show count random-sample-entrepreneurs-ce
end
to random-sample-extracurricular-course-generation

  let sample-students-size (0.1 * students)
  let num-familyback-students round (%num-familyback * sample-students-size)     ;Lo 0.35 è stato preso dal GUESS 2023 in Italia
  let num-motivation-students round (%num-motivation * sample-students-size)

  let sample-entrepreneurs-size 1 + random 5
  let num-motivation-entrepreneurs round (%num-motivation * sample-entrepreneurs-size)

  set random-sample-students-ec []
  set random-sample-entrepreneurs-ec []

  let sample-teachers-size 1 + random 5
  let num-motivation-teachers round (%num-motivation * sample-teachers-size)
  let sample-investors-size 1 + random 3
  let num-motivation-investors round (%num-motivation * sample-investors-size)

  ;; Selezione degli studenti
  let available-familyback individuals with [species = "student" and family-background? = 1 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let familyback-sample n-of (min (list num-familyback-students count available-familyback)) available-familyback

  let additional-motivation-needed (num-motivation-students - count familyback-sample with [motivation > mean [motivation] of individuals with [species = "student"]])
  let available-motivated individuals with [
    species = "student" and
    motivation > mean [motivation] of individuals with [species = "student"] and
    not member? self familyback-sample and
    family-background? = 0 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
  ]
  let motivation-sample nobody
  if additional-motivation-needed > 0 [
    set motivation-sample n-of (min (list additional-motivation-needed count available-motivated)) available-motivated
  ]

  let combined-sample (turtle-set familyback-sample motivation-sample)
  let remaining (sample-students-size - count combined-sample)
  if remaining > 0 [
    let available-additional individuals with [
      species = "student" and
      not member? self combined-sample and
      motivation < mean [motivation] of individuals with [species = "student"] and
      family-background? = 0 and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
    ]
    let additional-sample n-of (min (list remaining count available-additional)) available-additional
    set combined-sample (turtle-set combined-sample additional-sample)
  ]

  set random-sample-students-ec combined-sample
  ;show random-sample-students-ec

  ;; Selezione degli imprenditori
  let available-entrepreneurs individuals with [
    species = "entrepreneur" and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
  ]
  let num-possible-entrepreneurs min (list sample-entrepreneurs-size count available-entrepreneurs)

  ; Trova gli imprenditori con motivazione sotto la media
  let available-low-motivation-entrepreneurs available-entrepreneurs with [
    motivation > mean [motivation] of individuals with [species = "entrepreneur"]
  ]

  let num-motivation-entre (min (list num-motivation-entrepreneurs count available-low-motivation-entrepreneurs))

  let motivation-sample-entrepreneurs n-of num-motivation-entre available-low-motivation-entrepreneurs

  let remaining-entrepreneurs (num-possible-entrepreneurs - count motivation-sample-entrepreneurs)
  let combined-sample-entrepreneurs motivation-sample-entrepreneurs

  if remaining-entrepreneurs > 0 [
    let available-additional-entrepreneurs available-entrepreneurs with [
      not member? self motivation-sample-entrepreneurs and
      motivation < mean [motivation] of individuals with [species = "entrepreneur"]
    ]
    let additional-sample-entrepreneurs n-of (min (list remaining-entrepreneurs count available-additional-entrepreneurs)) available-additional-entrepreneurs
    set combined-sample-entrepreneurs (turtle-set combined-sample-entrepreneurs additional-sample-entrepreneurs)
  ]

  set random-sample-entrepreneurs-ec combined-sample-entrepreneurs

  ;; Selezione degli insegnanti
  let available-teachers individuals with [species = "teacher/researcher" and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-teachers min (list sample-teachers-size count available-teachers)

  let available-motivated-teachers available-teachers with [
    motivation > mean [motivation] of individuals with [species = "teacher/researcher"]
  ]

  let num-motivation-teach (min (list num-motivation-teachers count available-motivated-teachers))
  let motivation-sample-teachers n-of num-motivation-teach available-motivated-teachers

  let remaining-teachers (num-possible-teachers - count motivation-sample-teachers)
  let combined-sample-teachers motivation-sample-teachers

  if remaining-teachers > 0 [
    let available-additional-teachers available-teachers with [
      not member? self motivation-sample-teachers and
      motivation < mean [motivation] of individuals with [species = "teacher/researcher"]
    ]
    let additional-sample-teachers n-of (min (list remaining-teachers count available-additional-teachers)) available-additional-teachers
    set combined-sample-teachers (turtle-set combined-sample-teachers additional-sample-teachers)
  ]

  set random-sample-teachers-ec combined-sample-teachers
  ;show random-sample-teachers-ec

  ;; Selezione degli investitori
  let available-investors individuals with [species = "business angel" and attending-curricular-course? = 0 and attending-extracurricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-investors min (list sample-investors-size count available-investors)

  let available-motivated-investors available-investors with [
    motivation > mean [motivation] of individuals with [species = "business angel"]
  ]

  let num-motivation-inv (min (list num-motivation-investors count available-motivated-investors))
  let motivation-sample-investors n-of num-motivation-inv available-motivated-investors

  let remaining-investors (num-possible-investors - count motivation-sample-investors)
  let combined-sample-investors motivation-sample-investors

  if remaining-investors > 0 [
    let available-additional-investors available-investors with [
      not member? self motivation-sample-investors and
      motivation < mean [motivation] of individuals with [species = "business angel"]
    ]
    let additional-sample-investors n-of (min (list remaining-investors count available-additional-investors)) available-additional-investors
    set combined-sample-investors (turtle-set combined-sample-investors additional-sample-investors)
  ]

  set random-sample-investors-ec combined-sample-investors
  ;show random-sample-investors-ec

end
to random-sample-extracurricular-event-generation

  let sample-students-size (0.1 * students)
  let num-familyback-students round (%num-familyback * sample-students-size)    ;Lo 0.35 è stato preso dal GUESS 2023 in Italia
  let num-motivation-students round (%num-motivation * sample-students-size)

  let sample-entrepreneurs-size 1 + random 5
  let num-motivation-entrepreneurs round (%num-motivation * sample-entrepreneurs-size)

  set random-sample-students-ee []
  set random-sample-entrepreneurs-ee []

  let sample-teachers-size 1 + random 5
  let num-motivation-teachers round (%num-motivation * sample-teachers-size)
  let sample-investors-size 1 + random 3
  let num-motivation-investors round (%num-motivation * sample-investors-size)

  ;; Selezione degli studenti
  let available-familyback individuals with [species = "student" and family-background? = 1 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let familyback-sample n-of (min (list num-familyback-students count available-familyback)) available-familyback

  let additional-motivation-needed (num-motivation-students - count familyback-sample with [motivation > mean [motivation] of individuals with [species = "student"]])
  let available-motivated individuals with [
    species = "student" and
    motivation > mean [motivation] of individuals with [species = "student"] and
    not member? self familyback-sample and
    family-background? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
  ]
  let motivation-sample nobody
  if additional-motivation-needed > 0 [
    set motivation-sample n-of (min (list additional-motivation-needed count available-motivated)) available-motivated
  ]

  let combined-sample (turtle-set familyback-sample motivation-sample)
  let remaining (sample-students-size - count combined-sample)
  if remaining > 0 [
    let available-additional individuals with [
      species = "student" and
      not member? self combined-sample and
      motivation < mean [motivation] of individuals with [species = "student"] and
      family-background? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
    ]
    let additional-sample n-of (min (list remaining count available-additional)) available-additional
    set combined-sample (turtle-set combined-sample additional-sample)
  ]

  set random-sample-students-ee combined-sample

  ;; Selezione degli imprenditori
  let available-entrepreneurs individuals with [
    species = "entrepreneur" and attending-curricular-event? = 0 and attending-extracurricular-event? = 0
  ]
  let num-possible-entrepreneurs min (list sample-entrepreneurs-size count available-entrepreneurs)

  ; Trova gli imprenditori con motivazione sotto la media
  let available-low-motivation-entrepreneurs available-entrepreneurs with [
    motivation > mean [motivation] of individuals with [species = "entrepreneur"]
  ]

  ; Calcola quanti ne possiamo effettivamente selezionare
  let num-motivation-entre (min (list num-motivation-entrepreneurs count available-low-motivation-entrepreneurs))

  ; Seleziona gli imprenditori con motivazione bassa (senza errori)
  let motivation-sample-entrepreneurs n-of num-motivation-entre available-low-motivation-entrepreneurs

  let remaining-entrepreneurs (num-possible-entrepreneurs - count motivation-sample-entrepreneurs)
  let combined-sample-entrepreneurs motivation-sample-entrepreneurs

  if remaining-entrepreneurs > 0 [
    let available-additional-entrepreneurs available-entrepreneurs with [
      not member? self motivation-sample-entrepreneurs and
      motivation < mean [motivation] of individuals with [species = "entrepreneur"]
    ]
    let additional-sample-entrepreneurs n-of (min (list remaining-entrepreneurs count available-additional-entrepreneurs)) available-additional-entrepreneurs
    set combined-sample-entrepreneurs (turtle-set combined-sample-entrepreneurs additional-sample-entrepreneurs)
  ]

  set random-sample-entrepreneurs-ee combined-sample-entrepreneurs

  ;; Selezione degli insegnanti
  let available-teachers individuals with [species = "teacher/researcher" and attending-curricular-course? = 0 and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-teachers min (list sample-teachers-size count available-teachers)

  let available-motivated-teachers available-teachers with [
    motivation > mean [motivation] of individuals with [species = "teacher/researcher"]
  ]

  let num-motivation-teach (min (list num-motivation-teachers count available-motivated-teachers))
  let motivation-sample-teachers n-of num-motivation-teach available-motivated-teachers

  let remaining-teachers (num-possible-teachers - count motivation-sample-teachers)
  let combined-sample-teachers motivation-sample-teachers

  if remaining-teachers > 0 [
    let available-additional-teachers available-teachers with [
      not member? self motivation-sample-teachers and
      motivation < mean [motivation] of individuals with [species = "teacher/researcher"]
    ]
    let additional-sample-teachers n-of (min (list remaining-teachers count available-additional-teachers)) available-additional-teachers
    set combined-sample-teachers (turtle-set combined-sample-teachers additional-sample-teachers)
  ]

  set random-sample-teachers-ee combined-sample-teachers
  ;show random-sample-teachers-ee

  ;; Selezione degli investitori
  let available-investors individuals with [species = "business angel"  and attending-curricular-event? = 0 and attending-extracurricular-event? = 0]
  let num-possible-investors min (list sample-investors-size count available-investors)

  let available-motivated-investors available-investors with [
    motivation > mean [motivation] of individuals with [species = "business angel"]
  ]

  let num-motivation-inv (min (list num-motivation-investors count available-motivated-investors))
  let motivation-sample-investors n-of num-motivation-inv available-motivated-investors

  let remaining-investors (num-possible-investors - count motivation-sample-investors)
  let combined-sample-investors motivation-sample-investors

  if remaining-investors > 0 [
    let available-additional-investors available-investors with [
      not member? self motivation-sample-investors and
      motivation < mean [motivation] of individuals with [species = "business angel"]
    ]
    let additional-sample-investors n-of (min (list remaining-investors count available-additional-investors)) available-additional-investors
    set combined-sample-investors (turtle-set combined-sample-investors additional-sample-investors)
  ]

  set random-sample-investors-ee combined-sample-investors
  ;show random-sample-investors-ee
end
to-report remove-turtle-set [excluded-set base-set]
  report base-set with [not member? self excluded-set]
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE CURRICULAR COURSE;
to prepare-curricular-course
  set selected-uni-course one-of institutions with [(species = "university" and university-type = "entrepreneurial university") and curricular-course-active? = 0 and pause-ticks = 0]
  random-sample-curricular-course-generation
  if selected-uni-course != nobody and any? random-sample-teachers/researchers-cc[
    ask selected-uni-course[
      set curricular-course-active? 1
      contemporaneity self
      set course-ticks 0
      set course-students random-sample-students-cc
      set course-teachers/researchers random-sample-teachers/researchers-cc

      ask course-students [
        set course-ticks 0
        set entre-know-updated-cc? 0
      ]
      ask course-teachers/researchers[
        set course-ticks 0
        set entre-know-updated-cc? 0
      ]
    ]

    set duration-cc 60 + random 61
    redirect-curricular-course-turtles
  ]
end
to redirect-curricular-course-turtles
  ask random-sample-students-cc [
    face selected-uni-course

    let target-x ([pxcor] of selected-uni-course) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-course) + random-float (2 * half-side) - half-side

    move-turtle-to-course target-x target-y
    set old-xcor target-x
    set old-ycor target-y

    set attending-curricular-course? 1
  ]
  ask random-sample-teachers/researchers-cc[
    face selected-uni-course

    let target-x ([pxcor] of selected-uni-course) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-course) + random-float (2 * half-side) - half-side

    move-turtle-to-course target-x target-y
    set old-xcor target-x
    set old-ycor target-y

    set attending-curricular-course? 1
  ]

  check-position
end
to move-turtle-to-course [target-x target-y]
  let x target-x - xcor
  let y target-y - ycor
  let distance-to-target sqrt (x * x + y * y)

  if distance-to-target > 0 [
    set heading towards selected-uni-course
    fd distance-to-target
  ]
end
to update-curricular-course
  ask institutions with [species = "university" and curricular-course-active? = 1][
    if curricular-course-active? = 1 [
      set course-ticks course-ticks + 1
      if course-ticks >= duration-cc [
        end-curricular-course self
      ]
    ]

    if (curricular-course-active? = 0) and (pause-ticks > 0) [
      set pause-ticks pause-ticks - 1
      ;     show pause-ticks
    ]

    if is-agentset? course-students [
      ask course-students [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0) [
          set course-ticks course-ticks + 1
        ]
      ]
    ]
    if is-agentset? course-teachers/researchers [
      ask course-teachers/researchers [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0)[
          set course-ticks course-ticks + 1
        ]
      ]
    ]
    check-and-update-entre-know-curricular-course self
  ]

end
to end-curricular-course [current-1]
  ask current-1[
    set curricular-course-active? 0
    set course-ticks 0
    set pause-ticks 60 + random 61
    contemporaneity self

    ask course-students[
      set attending-curricular-course? 0
      set course-ticks 0
      set entre-know-updated-cc? 0
    ]
    ask course-teachers/researchers [
      set attending-curricular-course? 0
      set course-ticks 0
      set entre-know-updated-cc? 0
    ]
  ]
  check-position
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE CURRICULAR EVENT;
to prepare-curricular-event
  set selected-uni-event one-of institutions with [(species = "university" and university-type = "entrepreneurial university") and curricular-event-active? = 0]
  random-sample-curricular-event-generation
  if selected-uni-event != nobody [
    ask selected-uni-event[
      set curricular-event-active? 1
      contemporaneity self
      set event-ticks 0
      set event-students random-sample-students-ce
      set event-teachers/researchers random-sample-teachers/researchers-ce
      set event-entrepreneurs random-sample-entrepreneurs-ce
      set event-investors random-sample-investors-ce

      ask event-students[
        set event-ticks 0
        set entre-know-updated-ce? 0
      ]
      ask event-teachers/researchers[
        set event-ticks 0
        set entre-know-updated-ce? 0
      ]
      ask event-entrepreneurs[
        set event-ticks 0
        set entre-know-updated-ce? 0
      ]
      ask event-investors[
        set event-ticks 0
        set entre-know-updated-ce? 0
      ]

    ]

    set duration-ce 2 + random 10
    redirect-curricular-event-turtles
  ]
end
to redirect-curricular-event-turtles
  ask random-sample-students-ce [
    face selected-uni-event

    let target-x ([pxcor] of selected-uni-event) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-event) + random-float (2 * half-side) - half-side

    move-turtle-to-event target-x target-y

    set attending-curricular-event? 1
  ]
  ask random-sample-teachers/researchers-ce [
    face selected-uni-event

    let target-x ([pxcor] of selected-uni-event) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-event) + random-float (2 * half-side) - half-side

    move-turtle-to-event target-x target-y

    set attending-curricular-event? 1
  ]
  ask random-sample-entrepreneurs-ce [
    face selected-uni-event

    let target-x ([pxcor] of selected-uni-event) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-event) + random-float (2 * half-side) - half-side

    move-turtle-to-event target-x target-y

    set attending-curricular-event? 1
    if entrepreneurs-type = "Expert entrepreneur"[
      set color yellow
    ]
  ]
  ask random-sample-investors-ce [
    face selected-uni-event

    let target-x ([pxcor] of selected-uni-event) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-uni-event) + random-float (2 * half-side) - half-side

    move-turtle-to-event target-x target-y

    set attending-curricular-event? 1
    if investors-type = "Expert investor"[
      set color yellow
    ]
  ]

  check-position
end
to move-turtle-to-event [target-x target-y]
  let x target-x - xcor
  let y target-y - ycor
  let distance-to-target sqrt (x * x + y * y)

  if distance-to-target > 0 [
    set heading towards selected-uni-event
    fd distance-to-target
  ]
end
to update-curricular-event
  ask institutions with [species = "university" and curricular-event-active? = 1][
    set event-ticks event-ticks + 1
    if event-ticks >= duration-ce [
      end-curricular-event self
    ]
    if is-agentset? event-students [
      ask event-students [
        if is-in-aura? myself [
          set event-ticks event-ticks + 1
        ]
      ]
    ]
    if is-agentset? event-teachers/researchers [
      ask event-teachers/researchers [
        if is-in-aura? myself [
          set event-ticks event-ticks + 1
        ]
      ]
    ]

    if is-agentset? event-entrepreneurs [
      ask event-entrepreneurs [
        if is-in-aura? myself [
          set event-ticks event-ticks + 1
        ]
      ]
    ]
    if is-agentset? event-investors [
      ask event-investors [
        if is-in-aura? myself [
          set event-ticks event-ticks + 1
        ]
      ]
    ]
    check-and-update-entre-know-curricular-event self
  ]
end
to end-curricular-event [current-2]
  ask current-2[
    set curricular-event-active? 0
    set event-ticks 0
    contemporaneity self

    ask event-students[
      set attending-curricular-event? 0
      set event-ticks 0
      set entre-know-updated-ce? 0
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask event-teachers/researchers [
      set attending-curricular-event? 0
      set event-ticks 0
      set entre-know-updated-ce? 0
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask event-entrepreneurs [
      set attending-curricular-event? 0
      set event-ticks 0
      set entre-know-updated-ce? 0
      set color blue
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask event-investors [
      set attending-curricular-event? 0
      set event-ticks 0
      set entre-know-updated-ce? 0
      set color brown - 1
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
  ]

  check-position
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE EXTRACURRICULAR COURSE;
to prepare-extracurricular-course
  set selected-location-excourse one-of institutions with [(species = "university" and university-type = "entrepreneurial university") or species = "incubator/accelerator" and extracurricular-course-active? = 0 and pause-ticks = 0]
  random-sample-extracurricular-course-generation
  if selected-location-excourse != nobody and any? random-sample-teachers-ec[
    ask selected-location-excourse[
      set extracurricular-course-active? 1
      contemporaneity self
      set excourse-ticks 0
      set excourse-students random-sample-students-ec
      set excourse-entrepreneurs random-sample-entrepreneurs-ec
      set excourse-teachers/researchers random-sample-teachers-ec
      set excourse-investors random-sample-investors-ec

      ask excourse-students[
        set excourse-ticks 0
        set entre-know-updated-ec? 0
      ]
      ask excourse-teachers/researchers[
        set excourse-ticks 0
        set entre-know-updated-ec? 0
      ]
      ask excourse-entrepreneurs[
        set excourse-ticks 0
        set entre-know-updated-ec? 0
      ]
      ask excourse-investors[
        set excourse-ticks 0
        set entre-know-updated-ec? 0
      ]
    ]
    set duration-ec 60 + random 61
    redirect-extracurricular-course-turtles
  ]
end
to redirect-extracurricular-course-turtles

  ask random-sample-students-ec [
    face selected-location-excourse

    let target-x ([pxcor] of selected-location-excourse) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-excourse) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-course target-x target-y
    set old-xcor target-x
    set old-ycor target-y

    set attending-extracurricular-course? 1

  ]
  ask random-sample-teachers-ec [
    face selected-location-excourse

    let target-x ([pxcor] of selected-location-excourse) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-excourse) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-course target-x target-y
    set old-xcor target-x
    set old-ycor target-y

    set attending-extracurricular-course? 1
  ]
  ask random-sample-entrepreneurs-ec [
    face selected-location-excourse

    let target-x ([pxcor] of selected-location-excourse) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-excourse) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-course target-x target-y
    set old-xcor target-x
    set old-ycor target-y

    set attending-extracurricular-course? 1
  ]

  ask random-sample-investors-ec [
    face selected-location-excourse

    let target-x ([pxcor] of selected-location-excourse) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-excourse) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-course target-x target-y

    set attending-extracurricular-course? 1
  ]

  check-position
end
to move-turtle-to-extra-course [target-x target-y]
  let x target-x - xcor
  let y target-y - ycor
  let distance-to-target sqrt (x * x + y * y)

  if distance-to-target > 0 [
    set heading towards selected-location-excourse
    fd distance-to-target
  ]

end
to update-extracurricular-course
  ask institutions with [(species = "university" or species = "incubator/accelerator") and extracurricular-course-active? = 1][
    if extracurricular-course-active? = 1 [
      set excourse-ticks excourse-ticks + 1
      if excourse-ticks >= duration-ec [
        end-extracurricular-course self
      ]
    ]
    if (extracurricular-course-active? = 0) and (pause-ticks > 0) [
      set pause-ticks pause-ticks - 1
      ;     show pause-ticks
    ]

    if is-agentset? excourse-students [
      ask excourse-students [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0) [
          set excourse-ticks excourse-ticks + 1
        ]
      ]
    ]
    if is-agentset? excourse-teachers/researchers [
      ask excourse-teachers/researchers [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0) [
          set excourse-ticks excourse-ticks + 1
        ]
      ]
    ]

    if is-agentset? excourse-entrepreneurs [
      ask excourse-entrepreneurs [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0) [
          set excourse-ticks excourse-ticks + 1
        ]
      ]
    ]
    if is-agentset? excourse-investors [
      ask excourse-investors [
        if is-in-aura? myself and (attending-curricular-event? = 0 and attending-extracurricular-event? = 0)[
          set excourse-ticks excourse-ticks + 1
        ]
      ]
    ]
    check-and-update-entre-know-extracurricular-course self
  ]
end
to end-extracurricular-course [current-3]
  ask current-3 [
    set extracurricular-course-active? 0
    set excourse-ticks 0
    set pause-ticks 60 + random 61
    contemporaneity self

    ask excourse-students[
      set attending-extracurricular-course? 0
      set excourse-ticks 0
      set entre-know-updated-ec? 0
    ]
    ask excourse-entrepreneurs [
      set attending-extracurricular-course? 0
      set excourse-ticks 0
      set entre-know-updated-ec? 0
    ]
    ask excourse-teachers/researchers[
      set attending-extracurricular-course? 0
      set excourse-ticks 0
      set entre-know-updated-ec? 0
    ]
    ask excourse-investors [
      set attending-extracurricular-course? 0
      set excourse-ticks 0
      set entre-know-updated-ec? 0
    ]
  ]
  check-position
end
;-------------------------------------------------------------------------------------------------------;
;GENERATE EXTRACURRICULAR EVENT;
to prepare-extracurricular-event
  random-sample-extracurricular-event-generation
  set selected-location-exevent one-of institutions with [(species = "university" and university-type = "entrepreneurial university") or species = "incubator/accelerator" or species = "policy maker" and extracurricular-event-active? = 0]
  if selected-location-exevent != nobody[
    ask selected-location-exevent[
      set extracurricular-event-active? 1
      contemporaneity self
      set exevent-ticks 0
      set exevent-students random-sample-students-ee
      set exevent-entrepreneurs random-sample-entrepreneurs-ee
      set exevent-investors random-sample-investors-ee
      set exevent-teachers/researchers random-sample-teachers-ee


      ask exevent-students[
        set exevent-ticks 0
        set entre-know-updated-ee? 0
      ]
      ask exevent-teachers/researchers[
        set exevent-ticks 0
        set entre-know-updated-ee? 0
      ]
      ask exevent-entrepreneurs[
        set exevent-ticks 0
        set entre-know-updated-ee? 0
      ]
      ask exevent-investors[
        set exevent-ticks 0
        set entre-know-updated-ee? 0
      ]
    ]

    set duration-ee 2 + random 10
    redirect-extracurricular-event-turtles
  ]

end
to redirect-extracurricular-event-turtles
  ask random-sample-students-ee [
    face selected-location-exevent

    let target-x ([pxcor] of selected-location-exevent) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-exevent) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-event target-x target-y

    set attending-extracurricular-event? 1

  ]
  ask random-sample-teachers-ee [
    face selected-location-exevent

    let target-x ([pxcor] of selected-location-exevent) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-exevent) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-event target-x target-y

    set attending-extracurricular-event? 1

  ]
  ask random-sample-entrepreneurs-ee [
    face selected-location-exevent

    let target-x ([pxcor] of selected-location-exevent) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-exevent) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-event target-x target-y

    set attending-extracurricular-event? 1
    if entrepreneurs-type = "Expert entrepreneur"[
      set color yellow
    ]
  ]
  ask random-sample-investors-ee [
    face selected-location-exevent

    let target-x ([pxcor] of selected-location-exevent) + random-float (2 * half-side) - half-side
    let target-y ([pycor] of selected-location-exevent) + random-float (2 * half-side) - half-side

    move-turtle-to-extra-event target-x target-y

    set attending-extracurricular-event? 1
    if investors-type = "Expert investor"[
      set color yellow
    ]
  ]
  check-position
end
to move-turtle-to-extra-event [target-x target-y]
  let x target-x - xcor
  let y target-y - ycor
  let distance-to-target sqrt (x * x + y * y)

  if distance-to-target > 0 [
    set heading towards selected-location-exevent
    fd distance-to-target
  ]
end
to update-extracurricular-event
  ask institutions with [(species = "university" or species = "incubator/accelerator" or species = "policy maker") and extracurricular-event-active? = 1][
    set exevent-ticks exevent-ticks + 1
    if exevent-ticks >= duration-ee [
      end-extracurricular-event self
    ]
    if is-agentset? exevent-students [
      ask exevent-students [
        if is-in-aura? myself [
          set exevent-ticks exevent-ticks + 1
        ]
      ]
    ]
    if is-agentset? exevent-teachers/researchers [
      ask exevent-teachers/researchers [
        if is-in-aura? myself [
          set exevent-ticks exevent-ticks + 1
        ]
      ]
    ]

    if is-agentset? exevent-entrepreneurs [
      ask exevent-entrepreneurs [
        if is-in-aura? myself [
          set exevent-ticks exevent-ticks + 1
        ]
      ]
    ]
    if is-agentset? exevent-investors [
      ask exevent-investors [
        if is-in-aura? myself [
          set exevent-ticks exevent-ticks + 1
        ]
      ]
    ]
    check-and-update-entre-know-extracurricular-event self
  ]
end
to end-extracurricular-event [current-4]
  ask current-4 [
    set extracurricular-event-active? 0
    set exevent-ticks 0
    contemporaneity self

    ask exevent-students[
      set attending-extracurricular-event? 0
      set exevent-ticks 0
      set entre-know-updated-ee? 0
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask exevent-entrepreneurs [
      set attending-extracurricular-event? 0
      set exevent-ticks 0
      set entre-know-updated-ee? 0
      set color blue
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask exevent-teachers/researchers[
      set attending-extracurricular-event? 0
      set exevent-ticks 0
      set entre-know-updated-ee? 0
      set color brown - 1
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
    ask exevent-investors [
      set attending-extracurricular-event? 0
      set exevent-ticks 0
      set entre-know-updated-ee? 0
      if attending-curricular-course? = 1 or attending-extracurricular-course? = 1[
        go-back
      ]
    ]
  ]
  check-position
end
;------------------------------------------------------------------------------------------------------;
;RETURNS AGENTS TO PREVIOUS POSITIONS;
to go-back
  ask self [
    setxy old-xcor old-ycor
  ]
end
;------------------------------------------------------------------------------------------------------;
;COLOR PATCHES PROCEDURE;
to contemporaneity [selected]
  ;; Helper per selezionare le patches di un'area
  let area-patches patches with [
    pxcor >= [xcor] of selected - half-side and
    pxcor <= [xcor] of selected + half-side and
    pycor >= [ycor] of selected - half-side and
    pycor <= [ycor] of selected + half-side
  ]

  ask selected[
    ;Condizione 1: Solo Curricular-Course-Active
    if (curricular-course-active? = 1 and curricular-event-active? = 0 and extracurricular-course-active? = 0 and extracurricular-event-active? = 0)[
      ask area-patches[
        set pcolor yellow
      ]
    ]

    ;Condizione 2: Solo Curricular-Event-Active
    if (curricular-course-active? = 0 and curricular-event-active? = 1 and extracurricular-course-active? = 0 and extracurricular-event-active? = 0)[
      ask area-patches [
        set pcolor cyan
      ]
    ]

    ;Condizione 3: Solo Extracurricular-Course-Active
    if (curricular-course-active? = 0 and curricular-event-active? = 0 and extracurricular-course-active? = 1 and extracurricular-event-active? = 0)[
      ask area-patches [
        set pcolor white
      ]
    ]

    ;Condizione 4: Solo Extracurricular-Event-Active
    if (curricular-course-active? = 0 and curricular-event-active? = 0 and extracurricular-course-active? = 0 and extracurricular-event-active? = 1)[
      ask area-patches [
        set pcolor magenta
      ]
    ]

    ;Condizione 5: Curricular-Course e Curricular-Event Active - Extracurricular-Course Spento - Extracurricular-Event Spento
    if (curricular-course-active? = 1 and curricular-event-active? = 1 and extracurricular-course-active? = 0 and extracurricular-event-active? = 0) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor yellow  ; Metà sinistra gialla
        ] [
          set pcolor cyan    ; Metà destra cyan
        ]
      ]
    ]

    ;Condizione 6: Curricular-Course Active - Curricular-Event Spento - Extracurricular-Course Active - Extracurricular-Event Spento
    if (curricular-course-active? = 1 and curricular-event-active? = 0 and extracurricular-course-active? = 1 and extracurricular-event-active? = 0) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor yellow  ; Metà sinistra gialla
        ] [
          set pcolor white    ; Metà destra bianca
        ]
      ]
    ]

    ;Condizione 7: Curricular Course Spento - Curricular-Event Active - Extracurricualr Course Active - Extracurricular-Event Spento
    if (curricular-course-active? = 0 and curricular-event-active? = 1 and extracurricular-course-active? = 1 and extracurricular-event-active? = 0) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor cyan  ; Metà sinistra cyan
        ] [
          set pcolor white    ; Metà destra bianca
        ]
      ]
    ]

    ; Condizione 8: Curricular Course Spento - Curricular Event Spento - Extra Curricular Course e Extra Curricular Event Active
    if (curricular-course-active? = 0 and curricular-event-active? = 0 and extracurricular-course-active? = 1 and extracurricular-event-active? = 1) [
      ; Caso Università o Incubatore
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor white  ; Metà sinistra bianca
        ] [
          set pcolor magenta  ; Metà destra magenta
        ]
      ]
    ]

    ; Condizione 9: Curricular Course Spento - Curricular Event Active - Extracurricular Course Spento - Extracurricular Event Active
    if (curricular-course-active? = 0 and curricular-event-active? = 1 and extracurricular-course-active? = 0 and extracurricular-event-active? = 1) [
      ; Caso Università: Metà cyan e metà magenta
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor cyan  ; Metà sinistra cyan
        ] [
          set pcolor magenta  ; Metà destra magenta
        ]
      ]
    ]

    ; Condizione 10: Curricular Course Spento - Curricular Event Active - Extracurricular Course Active - Extracurricular Event Active
    if (curricular-course-active? = 0 and curricular-event-active? = 1 and extracurricular-course-active? = 1 and extracurricular-event-active? = 1) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor cyan  ; Metà sinistra cyan
        ] [
          ; Metà destra divisa in quarto superiore bianco e quarto inferiore magenta
          ifelse pycor > [ycor] of selected [
            set pcolor white  ; Quarto superiore destro
          ] [
            set pcolor magenta ; Quarto inferiore destro
          ]
        ]
      ]
    ]


    ; Condizione 11: Curricular Course Active - Curricular Event Off - Extracurricular Course Off - Extracurricular Event Active
    if (curricular-course-active? = 1 and curricular-event-active? = 0 and extracurricular-course-active? = 0 and extracurricular-event-active? = 1) [
      ; Caso Università: Metà giallo e metà magenta
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor yellow  ; Metà sinistra giallo
        ] [
          set pcolor magenta  ; Metà destra magenta
        ]
      ]
    ]

    ; Condizione 12: Curricular Course Active - Curricular Event Off - Extracurricular Course Active - Extracurricular Event Active
    if (curricular-course-active? = 1 and curricular-event-active? = 0 and extracurricular-course-active? = 1 and extracurricular-event-active? = 1) [
      ; Caso Università: Metà destra giallo, metà sinistra divisa
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          ; Metà sinistra divisa: quarto superiore bianco e quarto inferiore magenta
          ifelse pycor > [ycor] of selected [
            set pcolor white  ; Quarto superiore sinistro bianco
          ] [
            set pcolor magenta  ; Quarto inferiore sinistro magenta
          ]
        ] [
          set pcolor yellow  ; Metà destra giallo
        ]
      ]
    ]

    ; Condizione 13: Curricular Course Active - Curricular Event Active - Extracurricular Course Off - Extracurricular Event Active
    if (curricular-course-active? = 1 and curricular-event-active? = 1 and extracurricular-course-active? = 0 and extracurricular-event-active? = 1) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor yellow  ; Metà sinistra gialla
        ] [
          ; Metà destra divisa in quarto superiore cyan e quarto inferiore magenta
          ifelse pycor > [ycor] of selected [
            set pcolor cyan  ; Quarto superiore destro cyan
          ] [
            set pcolor magenta  ; Quarto inferiore destro magenta
          ]
        ]
      ]
    ]

    ; Condizione 14: Curricular Course Active - Curricular Event Active - Extracurricular Course Active - Extracurricular Event Off
    if (curricular-course-active? = 1 and curricular-event-active? = 1 and extracurricular-course-active? = 1 and extracurricular-event-active? = 0) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          set pcolor yellow  ; Metà sinistra gialla
        ] [
          ; Metà destra divisa in quarto superiore cyan e quarto inferiore white
          ifelse pycor > [ycor] of selected [
            set pcolor cyan  ; Quarto superiore destro cyan
          ] [
            set pcolor white  ; Quarto inferiore destro white
          ]
        ]
      ]
    ]

    ; Condizione 15: All Active
    if (curricular-course-active? = 1 and curricular-event-active? = 1 and extracurricular-course-active? = 1 and extracurricular-event-active? = 1) [
      ask area-patches [
        ifelse pxcor <= [xcor] of selected [
          ; Metà sinistra: Divisa in quarto superiore giallo e quarto inferiore magenta
          ifelse pycor > [ycor] of selected [
            set pcolor yellow  ; Quarto superiore sinistro
          ] [
            set pcolor magenta ; Quarto inferiore sinistro
          ]
        ] [
          ; Metà destra: Divisa in quarto superiore bianco e quarto inferiore cyan
          ifelse pycor > [ycor] of selected [
            set pcolor white  ; Quarto superiore destro
          ] [
            set pcolor cyan   ; Quarto inferiore destro
          ]
        ]
      ]
    ]

    ; Condizione 16: All Off
    if (curricular-course-active? = 0 and curricular-event-active? = 0 and extracurricular-course-active? = 0 and extracurricular-event-active? = 0) [
      ifelse species = "university" [
        ; Se è un'università, colorare violet + 2
        ask area-patches [
          set pcolor violet + 2
        ]
        ] [ ifelse species = "incubator/accelerator"[
          ask area-patches [
            set pcolor orange + 2
          ]
        ] [
          ask area-patches [
            set pcolor green + 2
          ]
        ]
      ]
    ]
  ]
end
;------------------------------------------------------------------------------------------------------;
;CHECK AND UPDATE PROCEDURES;
to check-position
  ask individuals [
    ifelse (attending-curricular-course? = 1 or attending-curricular-event? = 1 or attending-extracurricular-course? = 1 or attending-extracurricular-event? = 1) and (pcolor = yellow or pcolor = cyan or pcolor = white or pcolor = magenta) [
      set moving? false
    ]
    [ set moving? true]
  ]
end
to check-and-update-entre-know-curricular-course [current-1]
  ask current-1 [
    if is-agentset? course-students [
      ask course-students [
        if (course-ticks >= (duration-cc / 2)) and (entre-know-updated-cc? = 0) [
          set entrepreneurial-knowledge map [[x] -> precision min (list (x + 0.25) 10) 2] entrepreneurial-knowledge
          set entre-know-updated-cc? 1
          set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
          if (ticks - last-motivation-update-tick) > 10 [
          set motivation min (list (motivation
                        + (perception-incidence * %perception-of-entrepreneurship)
                        + (melting-incidence * %melting-pot)
                        + (corruption-incidence * corruption)
                        - (burocracy-incidence * %burocracy * (1 + 0.75 * corruption))
                        + (access-incidence * access-to-credit * (1 - 0.40 * corruption))
                        + (culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption)))) 10)
            set last-motivation-update-tick ticks
          ]
          ]
        ]
      ]

    if is-agentset? course-teachers/researchers [
      ask course-teachers/researchers [
        if (course-ticks >= (duration-cc / 2)) and (entre-know-updated-cc? = 0) [
          set entrepreneurial-knowledge map [[x] -> precision min (list (x + 0.02) 10) 2] entrepreneurial-knowledge
          set entre-know-updated-cc? 1
          set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge
             if (ticks - last-motivation-update-tick) > 10 [
             set motivation min (list (motivation
                        + (perception-incidence * %perception-of-entrepreneurship)
                        + (melting-incidence * %melting-pot)
                        + (corruption-incidence * corruption)
                        - (burocracy-incidence * %burocracy * (1 + 0.75 * corruption))
                        + (access-incidence * access-to-credit * (1 - 0.40 * corruption))
                        + (culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption)))) 10)
            set last-motivation-update-tick ticks
          ]
      ]
      ]
    ]
  ]
end




to check-and-update-entre-know-curricular-event [current-2]
  ask current-2 [

    let growth-rate 0.05
    let motivation-increase ((perception-incidence * %perception-of-entrepreneurship)
                              + (melting-incidence * %melting-pot)
                              + (corruption-incidence * corruption)
                              - (burocracy-incidence * %burocracy * (1 + 0.75 * corruption))
                              + (access-incidence * access-to-credit * (1 - 0.40 * corruption))
                              + (culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption))))

    let agent-groups (list event-students event-teachers/researchers event-entrepreneurs event-investors)

    foreach agent-groups [ group ->
      if is-agentset? group [
        ask group [
          if (event-ticks >= (duration-ce / 2)) and (entre-know-updated-ce? = 0) [

            set entrepreneurial-knowledge map [[x] -> precision min (list (x + 0.05) 10) 2] entrepreneurial-knowledge

            set entre-know-updated-ce? 1
            set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge

              if (ticks - last-motivation-update-tick) > 10 [
              set motivation min (list (motivation + (growth-rate * motivation-increase)) 10)
              set last-motivation-update-tick ticks
            ]
          ]
        ]
      ]
    ]
  ]
end

to check-and-update-entre-know-extracurricular-course [current-3]
  ask current-3 [

    let growth-rate 0.05
    let motivation-increase ((perception-incidence * %perception-of-entrepreneurship)
                              + (melting-incidence * %melting-pot)
                              + (corruption-incidence * corruption)
                              - (burocracy-incidence * %burocracy * (1 + 0.75 * corruption))
                              + (access-incidence * access-to-credit * (1 - 0.40 * corruption))
                              + (culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption))))

    let agent-groups (list excourse-students excourse-teachers/researchers excourse-entrepreneurs excourse-investors)

    foreach agent-groups [ group ->
      if is-agentset? group [
        ask group [
          if (excourse-ticks >= (duration-ec / 2)) and (entre-know-updated-ec? = 0) [

            let knowledge-increment 0.05
            set entrepreneurial-knowledge map [[x] -> precision min (list (x + knowledge-increment) 10) 2] entrepreneurial-knowledge

            set entre-know-updated-ec? 1
            set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge

              if (ticks - last-motivation-update-tick) > 10 [
              set motivation min (list (motivation + (growth-rate * motivation-increase)) 10)
              set last-motivation-update-tick ticks
            ]
          ]
        ]
      ]
    ]
  ]
end

to check-and-update-entre-know-extracurricular-event [current-4]
  ask current-4 [

    let growth-rate 0.05
    let motivation-increase ((perception-incidence * %perception-of-entrepreneurship)
                              + (melting-incidence * %melting-pot)
                              + (corruption-incidence * corruption)
                              - (burocracy-incidence * %burocracy * (1 + 0.75 * corruption))
                              + (access-incidence * access-to-credit * (1 - 0.40 * corruption))
                              + (culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption))))

    let agent-groups (list exevent-students exevent-teachers/researchers exevent-entrepreneurs exevent-investors)

    foreach agent-groups [ group ->
      if is-agentset? group [
        ask group [
          if (exevent-ticks >= (duration-ee / 2)) and (entre-know-updated-ee? = 0) [

            let knowledge-increment 0.05
            set entrepreneurial-knowledge map [[x] -> precision min (list (x + knowledge-increment) 10) 2] entrepreneurial-knowledge

            set entre-know-updated-ee? 1
            set mean-entrepreneurial-knowledge mean entrepreneurial-knowledge

            if (ticks - last-motivation-update-tick) > 10 [
              set motivation min (list (motivation + (growth-rate * motivation-increase)) 10)
              set last-motivation-update-tick ticks
            ]
          ]
        ]
      ]
    ]
  ]
end

to-report is-in-aura? [current-1]
  ifelse current-1 != nobody [
    report (xcor >= [xcor] of current-1 - half-side and
      xcor <= [xcor] of current-1  + half-side and
      ycor >= [ycor] of current-1  - half-side and
      ycor <= [ycor] of current-1  + half-side)
  ][
    report false
  ]
end
to replace-entrepreneurial-individuals
  ;; Calcola la motivation media
  let mean-motiv-students mean [motivation] of individuals with [species = "student"]
  let mean-motiv-teachers/researchers mean [motivation] of individuals with [species = "teacher/researcher"]

  ;; Seleziona gli studenti e i docenti con sufficiente conoscenza imprenditoriale
  let students-entrepreneurs individuals with [
    species = "student" and
    mean-entrepreneurial-knowledge >= (mean-ecosystem-entrepreneurial-knowledge * 0.9)
  ]
  let teachers-entrepreneurs individuals with [
    species = "teacher/researcher" and
    mean-entrepreneurial-knowledge >= (mean-ecosystem-entrepreneurial-knowledge )
  ]

  ;; Definizione delle probabilità di transizione per studenti e docenti (VALORI ORIGINALI)
  let transition-probability-students (0.008
      + 0.015 * perception-incidence * %perception-of-entrepreneurship * (1 - 0.20 * corruption)
      + 0.015 * melting-incidence * %melting-pot
      + 0.015 * corruption-incidence * corruption
      - 0.015 * burocracy-incidence * %burocracy * (1 + 0.75 * corruption)
      + 0.015 * access-incidence * access-to-credit * (1 - 0.40 * corruption)
      + 0.015 * culture-incidence * (0.3 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption))
      + 0.002 * mean-motiv-students)

  let transition-probability-teachers (0.001
      + 0.015 * perception-incidence * %perception-of-entrepreneurship * (1 - 0.20 * corruption)
      + 0.015 * melting-incidence * %melting-pot
      + 0.015 * corruption-incidence * corruption
      - 0.015 * burocracy-incidence * %burocracy * (1 + 0.75 * corruption)
      + 0.015 * access-incidence * access-to-credit * (1 - 0.40 * corruption)
      + 0.015 * culture-incidence * (0.1 * mean [entrepreneurial-culture] of institutions * (1 - 0.30 * corruption))
      + 0.002 * mean-motiv-teachers/researchers)

  ;; Assicuriamoci che le probabilità rimangano tra 0 e 1
  set transition-probability-students min list transition-probability-students 1
  set transition-probability-teachers min list transition-probability-teachers 1

  ;; Esegui la transizione per gli studenti
  ask students-entrepreneurs [
    let rand random-float 1
    show (word "Tick: " ticks " - Student: " self " - Random: " rand " - Prob: " transition-probability-students)
    if rand < transition-probability-students [
      set species "entrepreneur"
      set color blue
      set shape "person business"
      show (word "Student " self " è diventato imprenditore!")
    ]
  ]

  ;; Esegui la transizione per i docenti/ricercatori
  ask teachers-entrepreneurs [
    let rand random-float 1
    show (word "Tick: " ticks " - Teacher: " self " - Random: " rand " - Prob: " transition-probability-teachers)
    if rand < transition-probability-teachers [
      set species "entrepreneur"
      set color blue
      set shape "person business"
      show (word "Teacher " self " è diventato imprenditore!")
    ]
  ]
end


;
;to log-motivation
;  set motivation-history-students (list mean [motivation] of individuals with [species = "student"])
;  set motivation-history-teachers (list mean [motivation] of individuals with [species = "teacher/researcher"])
;  set motivation-history-entrepreneurs (list mean [motivation] of individuals with [species = "entrepreneur"])
;  set motivation-history-investors (list mean [motivation] of individuals with [species = "business angel"])
;  set entrepreneurs-history (list count individuals with [species = "entrepreneur"])
;end
;
to-report mean-motivation
  report mean [motivation] of individuals
end

to-report mean-motivation-students
  report precision mean [motivation] of individuals with [species = "student"] 2
end

to-report mean-motivation-teachers
  report precision mean [motivation] of individuals with [species = "teacher/researcher"] 2
end

to-report mean-motivation-entrepreneurs
  report precision mean [motivation] of individuals with [species = "entrepreneur"] 2
end

to-report mean-motivation-investors
  report precision mean [motivation] of individuals with [species = "business angel"] 2
end

to-report count-entrepreneurs
  report count individuals with [species = "entrepreneur"]
end

to-report count-students
  report count individuals with [species = "student"]
end

to-report count-teachers
  report count individuals with [species = "teacher/researcher"]
end

;to-report motivation-history-students-report
;  report motivation-history-students
;end
;
;to-report motivation-history-teachers-report
;  report motivation-history-teachers
;end
;
;to-report motivation-history-entrepreneurs-report
;  report motivation-history-entrepreneurs
;end
;
;to-report motivation-history-investors-report
;  report motivation-history-investors
;end
;
;to-report entrepreneurs-history-report
;  report entrepreneurs-history
;end

to-report current-ticks
  report ticks
end
@#$#@#$#@
GRAPHICS-WINDOW
197
14
1005
823
-1
-1
12.31
1
10
1
1
1
0
0
0
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
29
13
92
46
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
92
189
125
universities
universities
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
17
174
189
207
teachers/researchers
teachers/researchers
5
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
17
129
189
162
students
students
10
1000
300.0
1
1
NIL
HORIZONTAL

SLIDER
17
214
189
247
incubators/accelerators
incubators/accelerators
1
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
19
292
192
325
investors
investors
1
50
23.0
1
1
NIL
HORIZONTAL

SLIDER
18
254
191
287
entrepreneurs
entrepreneurs
10
800
150.0
1
1
NIL
HORIZONTAL

SLIDER
19
330
192
363
policy-makers
policy-makers
1
5
4.0
1
1
NIL
HORIZONTAL

BUTTON
97
13
174
46
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1020
19
1355
249
ENTREPRENEURIAL KNOWLEDGE
time
entrepreneurial-knowledge
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Students" 1.0 0 -2674135 true "" "plot mean [mean entrepreneurial-knowledge] of individuals with [species = \"student\"]"
"Teachers/Researchers" 1.0 0 -16777216 true "" "plot mean [mean entrepreneurial-knowledge] of individuals with [species = \"teacher/researcher\"]"
"Entrepreneurs" 1.0 0 -13345367 true "" "plot mean [mean entrepreneurial-knowledge] of individuals with [species = \"entrepreneur\"]"
"Business Angels" 1.0 0 -6459832 true "" "plot mean [mean entrepreneurial-knowledge] of individuals with [species = \"business angel\"]"

MONITOR
1021
482
1118
527
course-ticks - 0
[course-ticks] of institution 0
17
1
11

MONITOR
1124
482
1221
527
course-ticks-1
[course-ticks] of institution 1
17
1
11

MONITOR
1434
578
1531
623
excourse-ticks-4
[excourse-ticks] of institution 4
17
1
11

MONITOR
1227
482
1324
527
course-ticks-2
[course-ticks] of institution 2
17
1
11

MONITOR
1020
577
1118
622
excourse-ticks-0
[excourse-ticks] of institution 0
17
1
11

MONITOR
1123
578
1221
623
excourse-ticks-1
[excourse-ticks] of institution 1
17
1
11

MONITOR
1227
578
1325
623
excourse-ticks-2
[excourse-ticks] of institution 2
17
1
11

MONITOR
1332
578
1428
623
excourse-ticks-3
[excourse-ticks] of institution 3
17
1
11

MONITOR
1537
578
1633
623
excourse-ticks-5
[excourse-ticks] of institution 5
17
1
11

MONITOR
1021
530
1118
575
event-ticks-0
[event-ticks] of institution 0
17
1
11

MONITOR
1124
530
1221
575
event-ticks-1
[event-ticks] of institution 1
17
1
11

MONITOR
1227
530
1324
575
event-ticks-2
[event-ticks] of institution 2
17
1
11

PLOT
1020
252
1502
468
ENTREPRENEURIAL CULTURE
time
entrepreneurial-culture
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Universities" 1.0 0 -10141563 true "" "plot mean [entrepreneurial-culture] of institutions with [species = \"university\"]"
"Incubators/Accelerators" 1.0 0 -3844592 true "" "plot mean [entrepreneurial-culture] of institutions with [species = \"incubator/accelerator\"]"
"Policy Makers" 1.0 0 -14439633 true "" "plot mean [entrepreneurial-culture] of institutions with [species = \"policy maker\"]"
"Venture Capital/Banks" 1.0 0 -8431303 true "" "plot mean [entrepreneurial-culture] of institutions with [species = \"venture capital/bank\"]"

BUTTON
61
53
134
86
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
392
192
425
corruption
corruption
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
20
430
192
463
%burocracy
%burocracy
0
1
0.535
0.001
1
NIL
HORIZONTAL

SLIDER
20
468
192
501
%perception-of-entrepreneurship
%perception-of-entrepreneurship
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
20
506
192
539
%melting-pot
%melting-pot
0
1
0.73
0.01
1
NIL
HORIZONTAL

SLIDER
20
543
192
576
access-to-credit
access-to-credit
0
1
0.382
0.001
1
NIL
HORIZONTAL

PLOT
1015
477
1636
707
MOTIVATION
time
motivation
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Students" 1.0 0 -2674135 true "" "plot mean [motivation] of individuals with [species = \"student\"]"
"Teachers/Researchers" 1.0 0 -16777216 true "" "plot mean [motivation] of individuals with [species = \"teacher/researcher\"]"
"Entrepreneurs" 1.0 0 -13345367 true "" "plot mean [motivation] of individuals with [species = \"entrepreneur\"]"
"Business Angels" 1.0 0 -6459832 true "" "plot mean [motivation] of individuals with [species = \"business angel\"]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -16777216 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -7500403 true true 195 225 195 300 270 270 270 195
Rectangle -7500403 true true 180 225 195 300
Polygon -7500403 true true 180 226 195 226 270 196 255 196
Polygon -7500403 true true 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -7500403 true true 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -7500403 true true 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -16777216 true false 90 19 150 37 210 19 195 4 105 4
Polygon -16777216 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -7500403 true true 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -7500403 true true 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -16777216 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -16777216 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -7500403 true true 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -7500403 true true 145 91 172 77 172 101

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="(Fernando) 3E experiment 10" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
      <value value="0.238"/>
      <value value="0.038"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
      <value value="0.75"/>
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
      <value value="0.055"/>
      <value value="0.035"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.55"/>
      <value value="0.65"/>
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-familyback">
      <value value="0.36"/>
      <value value="0.41"/>
      <value value="0.31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption-incidence">
      <value value="0.3"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="burocracy-incidence">
      <value value="0.3"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception-incidence">
      <value value="0.3"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="melting-incidence">
      <value value="0.2"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-incidence">
      <value value="0.2"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="culture-incidence">
      <value value="0.2"/>
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-cc">
      <value value="0.2"/>
      <value value="0.25"/>
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ce">
      <value value="0.15"/>
      <value value="0.2"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ec">
      <value value="0.1"/>
      <value value="0.15"/>
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ee">
      <value value="0.12"/>
      <value value="0.17"/>
      <value value="0.07"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-familyback">
      <value value="0.35"/>
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-motivation">
      <value value="0.6"/>
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) 3E Experiment 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
      <value value="0.238"/>
      <value value="0.038"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
      <value value="0.75"/>
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
      <value value="0.055"/>
      <value value="0.035"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.55"/>
      <value value="0.65"/>
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="burocracy-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="melting-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="culture-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-cc">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ce">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ec">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ee">
      <value value="0.12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-familyback">
      <value value="0.36"/>
      <value value="0.41"/>
      <value value="0.31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-familyback">
      <value value="0.35"/>
      <value value="0.45"/>
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-motivation">
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) 3E Experiment 2" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
      <value value="0.238"/>
      <value value="0.038"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
      <value value="0.75"/>
      <value value="0.55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
      <value value="0.055"/>
      <value value="0.035"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.55"/>
      <value value="0.65"/>
      <value value="0.45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%-familyback">
      <value value="0.36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="burocracy-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="perception-incidence">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="melting-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="culture-incidence">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-cc">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ce">
      <value value="0.15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ec">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P-base-ee">
      <value value="0.12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-familyback">
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%num-motivation">
      <value value="0.6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) Experiment-corruption" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <metric>count individuals with [species = "entrepreneur"]</metric>
    <metric>count individuals with [species = "teacher/researcher"]</metric>
    <metric>count individuals with [species = "student"]</metric>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.39"/>
      <value value="0.54"/>
      <value value="0.69"/>
      <value value="0.84"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) Experiment-burocracy" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <metric>count individuals with [species = "entrepreneur"]</metric>
    <metric>count individuals with [species = "teacher/researcher"]</metric>
    <metric>count individuals with [species = "student"]</metric>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.078"/>
      <value value="0.138"/>
      <value value="0.198"/>
      <value value="0.258"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) Experiment-perception" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <metric>count individuals with [species = "entrepreneur"]</metric>
    <metric>count individuals with [species = "teacher/researcher"]</metric>
    <metric>count individuals with [species = "student"]</metric>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.35"/>
      <value value="0.5"/>
      <value value="0.65"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) Experiment-meltingpot" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <metric>count individuals with [species = "entrepreneur"]</metric>
    <metric>count individuals with [species = "teacher/researcher"]</metric>
    <metric>count individuals with [species = "student"]</metric>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.05"/>
      <value value="0.15"/>
      <value value="0.25"/>
      <value value="0.35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.045"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="(Fernando) Experiment-accesstocredit" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "student"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "teacher/researcher"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "entrepreneur"] 2</metric>
    <metric>precision mean [mean entrepreneurial-knowledge] of individuals with [species = "business angel"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "university"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "incubator/accelerator"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "policy maker"] 2</metric>
    <metric>precision mean [entrepreneurial-culture] of institutions with [species = "venture capital/bank"] 2</metric>
    <metric>count individuals with [species = "entrepreneur"]</metric>
    <metric>count individuals with [species = "teacher/researcher"]</metric>
    <metric>count individuals with [species = "student"]</metric>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.54"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.138"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.035"/>
      <value value="0.045"/>
      <value value="0.055"/>
      <value value="0.065"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2 - Corruption" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Best Scenario - Experiment 1" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Worst Scenario - Experimenti 1" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Realistic Scenario - Experiment 1" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.47"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.53"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2 - Burocracy" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2 - Perception Of Entrepreneurship" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2 - Melting Pot" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2 - Access To Credit" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="250"/>
    <metric>mean-motivation</metric>
    <metric>mean-motivation-students</metric>
    <metric>mean-motivation-teachers</metric>
    <metric>mean-motivation-entrepreneurs</metric>
    <metric>mean-motivation-investors</metric>
    <metric>count-entrepreneurs</metric>
    <metric>current-ticks</metric>
    <enumeratedValueSet variable="%melting-pot">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="policy-makers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="students">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%burocracy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="universities">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="access-to-credit">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%perception-of-entrepreneurship">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="teachers/researchers">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="entrepreneurs">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corruption">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="incubators/accelerators">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="investors">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
