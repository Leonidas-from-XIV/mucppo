Testing some very basic command line handling, roughly compatible with CPPO.

This is the file we'll work on

  $ cat > input.ml <<EOF
  > let () = print_endline "Hello world"
  > EOF

We might have a help output?

  $ mucppo --help
  mucppo -o <output> <file>
    -o Set output file name
    -help  Display this list of options
    --help  Display this list of options

It should support input via a filename and output via stdout:

  $ mucppo input.ml
  let () = print_endline "Hello world"

It should also support specifying the output file name via `-o`

  $ mucppo -o output.ml input.ml
  $ cat output.ml
  let () = print_endline "Hello world"
