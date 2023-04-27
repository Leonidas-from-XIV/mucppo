Simple test for futuristic OCaml version

  $ cat > high-version.ml <<EOF
  > #if OCAML_VERSION >= (3000, 0, 0)
  > OCaml3k
  > #else
  > OCaml
  > #endif
  > EOF
  $ mucppo < high-version.ml

Also for a very old version

  $ cat > low-version.ml <<EOF
  > #if OCAML_VERSION >= (1, 0, 0)
  > OCaml 1.0.0 or newer
  > #else
  > OCaml the ancient
  > #endif
  > EOF
  $ mucppo < low-version.ml
