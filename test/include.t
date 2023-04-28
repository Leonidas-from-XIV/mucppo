File inclusion should work.

  $ cat > included.ml <<EOF
  > let included = ()
  > EOF
  $ cat > including.ml <<EOF
  > #include "included.ml"
  > EOF
  $ mucppo < including.ml
  let included = ()

More complex inclusions should also work:

  $ cat > included.ml <<EOF
  > #if OCAML_VERSION >= (1, 0, 0)
  > OCaml
  > #endif
  > EOF
  $ mucppo < including.ml
  OCaml
