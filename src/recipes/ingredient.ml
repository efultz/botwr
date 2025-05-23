open! Core_kernel

module Duration = struct
  type t =
    | Always      of int
    | Diminishing of {
        first: int;
        next: int;
      }
  [@@deriving sexp, compare, equal, hash]

  let base = function
  | Always x
   |Diminishing { first = x; _ } ->
    x

  let merge ~count = function
  | Always x -> Always (x * count)
  | Diminishing { first; next } -> Always (first + (next * (count - 1)))

  let combine left right =
    match left, right with
    | Always x, Always y
     |Always x, Diminishing { first = y; _ }
     |Diminishing { first = x; _ }, Always y
     |Diminishing { first = x; _ }, Diminishing { first = y; _ } ->
      Always (x + y)
end

module Hearts = struct
  type quarters = Quarters of int [@@deriving sexp, compare, equal, hash] [@@unboxed]

  type t =
    | Always      of quarters
    | Diminishing of {
        first: quarters;
        next: quarters;
      }
  [@@deriving sexp, compare, equal, hash]

  let base = function
  | Always (Quarters q)
   |Diminishing { first = Quarters q; _ } ->
    q

  let merge ~count = function
  | Always (Quarters x) -> Always (Quarters (x * count))
  | Diminishing { first = Quarters first; next = Quarters next } ->
    Always (Quarters (first + (next * (count - 1))))

  let combine left right =
    match left, right with
    | Always (Quarters x), Always (Quarters y)
     |Always (Quarters x), Diminishing { first = Quarters y; _ }
     |Diminishing { first = Quarters x; _ }, Always (Quarters y)
     |Diminishing { first = Quarters x; _ }, Diminishing { first = Quarters y; _ } ->
      Always (Quarters (x + y))
end

module Effect = struct
  module Activity = struct
    type t = {
      duration: Duration.t;
      points: int;
    }
    [@@deriving sexp, compare, equal, hash]

    let merge ~count { duration; points } =
      { duration = Duration.merge ~count duration; points = points * count }

    let combine left right =
      { duration = Duration.combine left.duration right.duration; points = left.points + right.points }
  end

  module Quarters = struct
    type t = Quarters of int [@@deriving sexp, compare, equal, hash] [@@unboxed]

    let merge ~count (Quarters x) = Quarters (x * count)

    let combine (Quarters x) (Quarters y) = Quarters (x + y)
  end

  module Fifths = struct
    type t = Fifths of int [@@deriving sexp, compare, equal, hash] [@@unboxed]

    let merge ~count (Fifths x) = Fifths (x * count)

    let combine (Fifths x) (Fifths y) = Fifths (x + y)
  end

  type t =
    | Nothing
    | Neutral    of Duration.t
    | Hearty     of int
    | Sunny      of int
    | Energizing of Fifths.t
    | Enduring   of Quarters.t
    | Spicy      of Activity.t
    | Chilly     of Activity.t
    | Electro    of Activity.t
    | Fireproof  of Activity.t
    | Hasty      of Activity.t
    | Rapid      of Activity.t
    | Sticky     of Activity.t
    | Sneaky     of Activity.t
    | Mighty     of Activity.t
    | Tough      of Activity.t
    | Bright     of Activity.t
    | Scorching     of Activity.t
    | Biting     of Activity.t
    | Stormy     of Activity.t
  [@@deriving sexp, compare, equal, hash, variants]

  let merge ~count = function
  | Nothing -> Nothing
  | Neutral x -> Neutral (Duration.merge ~count x)
  | Hearty x -> Hearty (x * count)
  | Sunny x -> Sunny (x * count)
  | Energizing x -> Energizing (Fifths.merge ~count x)
  | Enduring x -> Enduring (Quarters.merge ~count x)
  | Spicy x -> Spicy (Activity.merge ~count x)
  | Chilly x -> Chilly (Activity.merge ~count x)
  | Electro x -> Electro (Activity.merge ~count x)
  | Fireproof x -> Fireproof (Activity.merge ~count x)
  | Hasty x -> Hasty (Activity.merge ~count x)
  | Rapid x -> Rapid (Activity.merge ~count x)
  | Sticky x -> Sticky (Activity.merge ~count x)
  | Sneaky x -> Sneaky (Activity.merge ~count x)
  | Mighty x -> Mighty (Activity.merge ~count x)
  | Tough x -> Tough (Activity.merge ~count x)
  | Bright x -> Bright (Activity.merge ~count x)
  | Scorching x -> Scorching (Activity.merge ~count x)
  | Biting x -> Biting (Activity.merge ~count x)
  | Stormy x -> Stormy (Activity.merge ~count x)

  let combine left right =
    match left, right with
    | Nothing, _
     |_, Nothing ->
      Nothing
    | Neutral x, Neutral y -> Neutral (Duration.combine x y)
    | Hearty x, Hearty y -> Hearty (x + y)
    | Sunny x, Sunny y -> Sunny (x + y)
    | Energizing x, Energizing y -> Energizing (Fifths.combine x y)
    | Enduring x, Enduring y -> Enduring (Quarters.combine x y)
    | Spicy x, Spicy y -> Spicy (Activity.combine x y)
    | Chilly x, Chilly y -> Chilly (Activity.combine x y)
    | Electro x, Electro y -> Electro (Activity.combine x y)
    | Fireproof x, Fireproof y -> Fireproof (Activity.combine x y)
    | Hasty x, Hasty y -> Hasty (Activity.combine x y)
    | Rapid x, Rapid y -> Rapid (Activity.combine x y)
    | Sticky x, Sticky y -> Sticky (Activity.combine x y)
    | Sneaky x, Sneaky y -> Sneaky (Activity.combine x y)
    | Mighty x, Mighty y -> Mighty (Activity.combine x y)
    | Tough x, Tough y -> Tough (Activity.combine x y)
    | Bright x, Bright y -> Bright (Activity.combine x y)
    | Scorching x, Scorching y -> Scorching (Activity.combine x y)
    | Biting x, Biting y -> Biting (Activity.combine x y)
    | Stormy x, Stormy y -> Stormy (Activity.combine x y)
    | Neutral dur, x
     |x, Neutral dur -> (
      match x with
      | Nothing -> Nothing
      | Neutral x -> Neutral (Duration.combine dur x)
      | (Hearty _ as x)
       |(Sunny _ as x)
       |(Energizing _ as x)
       |(Enduring _ as x) ->
        x
      | Spicy x -> Spicy { x with duration = Duration.combine dur x.duration }
      | Chilly x -> Chilly { x with duration = Duration.combine dur x.duration }
      | Electro x -> Electro { x with duration = Duration.combine dur x.duration }
      | Fireproof x -> Fireproof { x with duration = Duration.combine dur x.duration }
      | Hasty x -> Hasty { x with duration = Duration.combine dur x.duration }
      | Rapid x -> Rapid { x with duration = Duration.combine dur x.duration }
      | Sticky x -> Sticky { x with duration = Duration.combine dur x.duration }
      | Sneaky x -> Sneaky { x with duration = Duration.combine dur x.duration }
      | Mighty x -> Mighty { x with duration = Duration.combine dur x.duration }
      | Tough x -> Tough { x with duration = Duration.combine dur x.duration }
      | Bright x -> Bright { x with duration = Duration.combine dur x.duration }
      | Scorching x -> Scorching { x with duration = Duration.combine dur x.duration }
      | Biting x -> Biting { x with duration = Duration.combine dur x.duration }
      | Stormy x -> Stormy { x with duration = Duration.combine dur x.duration })
    | _ -> Nothing

  module Kind = struct
    module Self = struct
      type t =
        | Nothing
        | Neutral
        | Chilly
        | Electro
        | Enduring
        | Energizing
        | Fireproof
        | Bright
        | Hasty
        | Rapid
        | Sticky
        | Hearty
        | Mighty
        | Sneaky
        | Spicy
        | Sunny
        | Tough
        | Scorching
        | Biting
        | Stormy
      [@@deriving sexp, compare, equal, hash]
    end

    module Map = Map.Make (Self)
    include Self

    let has_duration = function
    | Nothing
     |Neutral
     |Hearty
     |Sunny
     |Energizing
     |Enduring ->
      false
    | Spicy
     |Chilly
     |Electro
     |Fireproof
     |Hasty
     |Rapid
     |Sticky
     |Sneaky
     |Mighty
     |Tough
     |Bright
     |Scorching
     |Biting
     |Stormy ->
      true

    let availability : t -> Game.availability = function
    | Nothing
     |Neutral
     |Chilly
     |Electro
     |Enduring
     |Energizing
     |Fireproof
     |Hasty
     |Hearty
     |Mighty
     |Sneaky
     |Spicy
     |Tough ->
      Both
    | Sunny
     |Rapid
     |Sticky
     |Bright
     |Scorching
     |Biting
     |Stormy ->
      TOTK
  end
end

module Category = struct
  type t =
    | Food
    | Spice
    | Critter
    | Monster
    | Elixir
    | With_fairy of t
    | Dragon
    | Dubious
  [@@deriving sexp, compare, equal, hash]

  let rec combine left right =
    match left, right with
    | x, Dragon
     |Dragon, x ->
      x
    | With_fairy x, With_fairy y
     |With_fairy x, y
     |y, With_fairy x ->
      With_fairy (combine x y)
    | Food, Food -> Food
    | Spice, Spice -> Spice
    | Food, Spice
     |Spice, Food ->
      Food
    | Food, _
     |_, Food
     |Spice, _
     |_, Spice
     |Dubious, _
     |_, Dubious ->
      Dubious
    | Monster, Monster -> Monster
    | Critter, Critter -> Critter
    | Elixir, Elixir
     |Critter, Monster
     |Monster, Critter
     |Elixir, Critter
     |Critter, Elixir
     |Elixir, Monster
     |Monster, Elixir ->
      Elixir
end

type t = {
  item: Items.t;
  hearts: Hearts.t;
  effect: Effect.t;
  category: Category.t;
  critical: bool;
  fused: int;
}
[@@deriving sexp, compare, equal, hash]

let compare_item x y = [%compare: Items.t] x.item y.item

module Map = Map.Make (struct
  type nonrec t = t [@@deriving sexp]

  let compare = compare_item
end)

let to_kind : t -> Effect.Kind.t = function
| { effect = Nothing; _ } -> Nothing
| { effect = Neutral _; _ } -> Neutral
| { effect = Hearty _; _ } -> Hearty
| { effect = Sunny _; _ } -> Sunny
| { effect = Energizing _; _ } -> Energizing
| { effect = Enduring _; _ } -> Enduring
| { effect = Spicy _; _ } -> Spicy
| { effect = Chilly _; _ } -> Chilly
| { effect = Electro _; _ } -> Electro
| { effect = Fireproof _; _ } -> Fireproof
| { effect = Hasty _; _ } -> Hasty
| { effect = Rapid _; _ } -> Rapid
| { effect = Sticky _; _ } -> Sticky
| { effect = Sneaky _; _ } -> Sneaky
| { effect = Mighty _; _ } -> Mighty
| { effect = Tough _; _ } -> Tough
| { effect = Bright _; _ } -> Bright
| { effect = Scorching _; _ } -> Scorching
| { effect = Biting _; _ } -> Biting
| { effect = Stormy _; _ } -> Stormy

let has_effect_or_special : t -> bool = function
| { category = Dragon; _ } -> true
| { effect = Nothing; _ }
 |{ effect = Neutral _; _ } ->
  false
| { effect = Hearty _; _ }
 |{ effect = Sunny _; _ }
 |{ effect = Energizing _; _ }
 |{ effect = Enduring _; _ }
 |{ effect = Spicy _; _ }
 |{ effect = Chilly _; _ }
 |{ effect = Electro _; _ }
 |{ effect = Fireproof _; _ }
 |{ effect = Hasty _; _ }
 |{ effect = Rapid _; _ }
 |{ effect = Sticky _; _ }
 |{ effect = Sneaky _; _ }
 |{ effect = Mighty _; _ }
 |{ effect = Tough _; _ }
 |{ effect = Bright _; _ }
 |{ effect = Scorching _; _ }
 |{ effect = Biting _; _ }
 |{ effect = Stormy _; _ } ->
  true

let merge ({ item; hearts; effect; category; critical; fused } as ingredient) ~count =
  match count with
  | 1 -> ingredient
  | _ ->
    {
      item;
      hearts = Hearts.merge ~count hearts;
      effect = Effect.merge ~count effect;
      category;
      critical;
      fused = fused * count;
    }

let combine left right =
  {
    item = left.item;
    hearts = Hearts.combine left.hearts right.hearts;
    effect = Effect.combine left.effect right.effect;
    category = Category.combine left.category right.category;
    critical = left.critical || right.critical;
    fused = left.fused + right.fused;
  }
