Test that defines work:

  $ cat > defines.ml <<EOF
  > #define FOO
  > #ifdef FOO
  > Should print
  > #endif
  > #undef FOO
  > #ifdef FOO
  > Should not print
  > #endif
  > EOF
  $ mucppo < defines.ml
  Should print
