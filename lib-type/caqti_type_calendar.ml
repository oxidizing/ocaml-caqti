(* Copyright (C) 2017  Petter A. Urkedal <paurkedal@gmail.com>
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or (at your
 * option) any later version, with the OCaml static compilation exception.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *)

type _ Caqti_type.field +=
  | Date : CalendarLib.Date.t Caqti_type.field
  | Time : CalendarLib.Calendar.t Caqti_type.field

let conv f x = try Ok (f x) with _ -> Error "Conversion failed."

let () =
  let open Caqti_type.Field in
  let open CalendarLib in
  let get_coding : type a. a t -> a coding = function
   | Date ->
      let encode date = conv int_of_float (Date.to_unixfloat date /. 86400.0) in
      let decode pday = conv Date.from_unixfloat (float_of_int pday *. 86400.0) in
      Coding {rep = Caqti_type.Pday; encode; decode}
   | Time ->
      let encode time =
        (match Ptime.of_float_s (Calendar.to_unixfloat time) with
         | Some t -> Ok t
         | None -> Error "Failed to convert Calendar.t to Ptime.t") in
      let decode ptime =
        conv Calendar.from_unixfloat (Ptime.to_float_s ptime) in
      Coding {rep = Caqti_type.Ptime; encode; decode}
   | _ -> assert false in
  define_coding Date {get_coding};
  define_coding Time {get_coding}

let date = Caqti_type.field Date
let time = Caqti_type.field Time
