(* trivial cppo replacement with just enough features to do conditional compilation *)

let version_triple major minor patch = (major, minor, patch)
let current_version = Scanf.sscanf Sys.ocaml_version "%u.%u.%u" version_triple
let greater_or_equal (v : int * int * int) = current_version >= v

module PrintingState : sig
  type t

  val empty : t
  val is_empty : t -> bool
  val flip_top : t -> t
  val should_output : t -> bool
  val pop : t -> t
  val push : bool -> t -> t
end = struct
  type state = { state : bool; was_flipped : bool }
  type t = state list

  let empty = [ { state = true; was_flipped = true } ]
  let is_empty (x : t) = x = empty

  let flip_top = function
    | [] -> failwith "Output stack empty, invalid state"
    | { was_flipped = true; _ } :: _ -> failwith "#else already used"
    | x :: xs -> { state = not x.state; was_flipped = true } :: xs

  let should_output l = (List.hd l).state
  let pop = List.tl
  let push state l = { state; was_flipped = false } :: l
end

module Variables = struct
  module Map = Map.Make (String)

  (* type t = unit Map.t *)

  let is_defined name = Map.mem name
  let define name = Map.add name ()
  let undefine name = Map.remove name
  let empty = Map.empty
end

let starts_with ~prefix s =
  let len = String.length prefix in
  String.length s >= len && String.equal (String.sub s 0 len) prefix

let is_if_statement = starts_with ~prefix:"#if"
let is_include_statement = starts_with ~prefix:"#include"
let is_define_statement = starts_with ~prefix:"#define"
let is_undef_statement = starts_with ~prefix:"#undef"
let is_ifdef = starts_with ~prefix:"#ifdef"
let filename_of_include s = Scanf.sscanf s "#include %S" (fun x -> x)
let variable_of_define s = Scanf.sscanf s "#define %s" (fun x -> x)
let variable_of_undef s = Scanf.sscanf s "#undef %s" (fun x -> x)
let variable_of_ifdef s = Scanf.sscanf s "#ifdef %s" (fun x -> x)

let is_ocaml_version s =
  (* Sscanf.sscanf_opt exists but only since 5.0 *)
  match Scanf.sscanf s "#if OCAML_VERSION >= (%u, %u, %u)" version_triple with
  | v -> Some v
  | exception _ -> None

module State = struct
  (* type t = PrintingState.t * Variables.t *)

  let flip_condition (ps, vars) = (PrintingState.flip_top ps, vars)
  let pop (ps, vars) = (PrintingState.pop ps, vars)
  let push v (ps, vars) = (PrintingState.push v ps, vars)
  let should_output (ps, _vars) = PrintingState.should_output ps
  let is_empty (ps, _vars) = PrintingState.is_empty ps
  let empty = (PrintingState.empty, Variables.empty)
  let define v (ps, vars) = (ps, Variables.define v vars)
  let undefine v (ps, vars) = (ps, Variables.undefine v vars)
  let is_defined v (_ps, vars) = Variables.is_defined v vars
end

let rec loop ic ~lineno ~filename vars =
  match input_line ic with
  | line -> (
      let next = loop ic ~lineno:(Int.succ lineno) ~filename in
      match String.trim line with
      | "#else" -> next (State.flip_condition vars)
      | "#endif" -> next (State.pop vars)
      | trimmed_line when is_define_statement trimmed_line ->
          let var = variable_of_define trimmed_line in
          let vars = State.define var vars in
          next vars
      | trimmed_line when is_undef_statement trimmed_line ->
          let var = variable_of_undef trimmed_line in
          let vars = State.undefine var vars in
          next vars
      | trimmed_line when is_include_statement trimmed_line ->
          let filename = filename_of_include trimmed_line in
          let included_ic = open_in filename in
          loop included_ic ~lineno:1 ~filename vars;
          next vars
      | trimmed_line when is_ifdef trimmed_line ->
          let var = variable_of_ifdef trimmed_line in
          let is_defined = State.is_defined var vars in
          let vars = State.push is_defined vars in
          next vars
      | trimmed_line when is_if_statement trimmed_line -> (
          match is_ocaml_version line with
          | None ->
              failwith
                (Printf.sprintf "Parsing #if in file %s line %d failed, exiting"
                   filename lineno)
          | Some (major, minor, patch) ->
              next (State.push (greater_or_equal (major, minor, patch)) vars))
      | _trimmed_line ->
          if State.should_output vars then print_endline line;
          next vars)
  | exception End_of_file ->
      if not (State.is_empty vars) then
        failwith "Output stack messed up, missing #endif?"

let () = loop stdin ~lineno:1 ~filename:"<stdin>" State.empty
