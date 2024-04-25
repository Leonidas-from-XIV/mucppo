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

Test that `elif` works:

  $ cat > elif.ml <<EOF
  > #define OTHERWISE
  > #ifdef UNDEFINED
  > Should not print
  > #elif defined OTHERWISE
  > Should print
  > #endif
  > EOF
  $ mucppo < elif.ml
  Should print

  $ cat > elif.ml <<EOF
  > #define DEFINED
  > #ifdef DEFINED
  > Should print
  > #elif defined OTHERWISE
  > Should not print
  > #endif
  > EOF
  $ mucppo < elif.ml
  Should print

Both values are set but it is `elif` so it should only run the first matching
branch:

  $ cat > elif.ml <<EOF
  > #define IF
  > #define ELIF
  > #ifdef IF
  > Should print
  > #elif defined ELIF
  > Should not print
  > #endif
  > EOF
  $ mucppo < elif.ml
  Should print

  $ cat > elif.ml <<EOF
  > #define ELIF1
  > #define ELIF2
  > #ifdef IF
  > Should not print
  > #elif defined ELIF1
  > Should print
  > #elif defined ELIF2
  > Should not print
  > #elif defined ELIF3
  > Should not print
  > #endif
  > EOF
  $ mucppo < elif.ml
  Should print

Nested ifdefs should work:

  $ cat > nested.ml <<EOF
  > #define STRING
  > Nested with false condition:
  > #ifdef VARIANT
  > #ifdef STRING
  > Should not print
  > #endif
  > #else
  > VARIANT wasn't defined
  > #endif
  > Unnested:
  > #ifdef STRING
  > Should print
  > #endif
  > Nested with true condition:
  > #ifdef STRING
  > #ifdef STRING
  > Should print
  > #endif
  > #endif
  > EOF
  $ mucppo < nested.ml
  Nested with false condition:
  VARIANT wasn't defined
  Unnested:
  Should print
  Nested with true condition:
  Should print
