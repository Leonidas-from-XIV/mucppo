(lang dune 3.7)
(name mucppo)
(cram enable)

(generate_opam_files true)

(source (github Leonidas-from-XIV/mucppo))
(maintainers "marek@xivilization.net")
(license "CC0-1.0")

(package
  (name mucppo)
  (synopsis "Minimal, embeddable subset of CPPO")
  (description "\
This package provides a single-file no-dependency reimplementation of a
subset of CPPO that is meant to be used in packages that use dune.")
  (depends
    (ocaml (>= 4.02.3))))
