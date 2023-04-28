µCPPO: minimal usable subset of CPPO
====================================

Code-generation via textual macros can be very useful, but it also has a number
of downsides. CPPO implements a fairly complete macro language, but its
downside is that it is an additional (build-time) dependency to projects.

µCPPO attempts to alleviate this by being a single file dependency that is
meant to be vendored into one's build. The idea is similar to the
[stb](https://github.com/nothings/stb) suite of single-file header libraries.

Goals
-----

* No external dependencies
* Single file for easy embedding
* µCPPO files should remain valid CPPO files
* 80% of the usecases of CPPO at 20% of the cost
* Compatibility with the oldest supported compiler version that dune supports
* Conservative language subset to avoid breaking in future OCaml versions

Non-goals
---------

* Implement the whole CPPO language
* Support CPPO files unchanged
* Have complete CLI parsing
* Fancy error handling

Usage
-----

The main intended usage is within Dune, to allow for features that can't
natively done with Dune itself:

Create a `mucppo` folder with this `dune` file:

```scheme
(executable
  (name mucppo))
```

Copy `mucppo.ml` into it.

Then preprocess the files that need CPPO like so:

```scheme
(rule
  (action (with-stdout-to compat.ml
            (run ./mucppo/mucppo.exe compat.pp.ml))))
```

Supported features
------------------

* OCaml version comparison: `#if OCAML_VERSION >= (major, minor, patch)`
* Inclusion of other files: `#include`

Unless otherwise stated, other features are not implemented. Notably, macros
and macros with arguments are unlikely to ever get implemented, as they are
rarely used and make codebases hard to read.

License
-------

 [![License: CC0-1.0](https://licensebuttons.net/l/zero/1.0/80x15.png)](http://creativecommons.org/publicdomain/zero/1.0/)

As µCPPO is meant to be vendored into projects, the code is public domain in as
far as possible under international law. Therefore it is under
[CC0](https://creativecommons.org/share-your-work/public-domain/cc0/) to
facilitate relicensing and reuse.
