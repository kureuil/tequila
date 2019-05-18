defmodule Ptolemy.QueryParser do
  import NimbleParsec

  @moduledoc """
  A parser for the query language used to search the index.

  Words in the search query will be matched against the entry title, description, and cached content
  if there is any (this is referred to as "the document"). Each word is matched independently, and
  all words must be contained in the document for an entry to be included in the search results. You
  can use quotes either to search for phrases or to escape keywords and use them as a search term.

  ## Tagging

  If you want to filter by tags, add them in the query and prefix them with a pound (`#`). Imagine
  you want to search for document containing the word "debugging" and tagged "linux", the query will
  look like this: `debugging #linux`.

  ## Facets

  Facets are another way of filtering documents, acting like meta-tags. A facet consists of two
  parts: the metadata you want to filter on, and the value you're filtering on. You write a facet in
  a query by joining these two parts with a colon (`:`).

  ### Tag facet

  Behaves the same way as the pound prefix.

  **Examples**

  * `tag:linux`
  * `tag:programming tag:elixir`

  ### Site facet

  Allow you to filter documents based on the host part of their link. It does **not** match against
  the protocol, user, password, port, path or query part of the document URI. The argument must be a
  valid host string.

  **Examples**

  * `site:localhost`
  * `site:medium.com`
  * `site:kureuil.github.io`

  ## Conditional operators

  ### `and` operator

  You can use the and operator to combine two clauses that the document has to match if it is to be
  included in the search results. This behaviour is used whether you explicitely write `and` to join
  two clauses, or whether you just join them using spaces. For example, the two following queries
  are equivalent:

  * `site:kureuil.github.io knowledge base #elixir`
  * `site:kureuil.github.io and knowledge and base and #elixir`

  ### `or` operator

  You can use the or operator to combine two clauses of which the document must match at least one
  to be included in the search results (e.g: `#linux or #windows`).

  ### `not` operator

  You can use the not operator to negate a filter you used in your query. It is written as a right
  associative unary operator. For example, if you want to search all results tagged debugging not
  hosted on GitHub, you could write: `#debugging not site:github.com`.

  ## Subqueries

  Subqueries are a mean of grouping multiple clauses into a single one, using parenthesis as a
  delimiter. A subquery can contain other subqueries, et caetera. You can use subqueries to negate a
  bunch of tags without having to negate them one-by-one, e.g: `not (#linux #windows #macos)` is
  equivalent to `not #linux not #windows not #macos`.
  """

  defcombinatorp(
    :ws0,
    ignore(
      repeat(
        choice([
          utf8_char([?\t]),
          utf8_char([?\n]),
          utf8_char([?\r]),
          utf8_char([?\ ])
        ])
      )
    )
  )

  defcombinatorp(
    :ws1,
    ignore(
      times(
        choice([
          utf8_char([?\t]),
          utf8_char([?\n]),
          utf8_char([?\r]),
          utf8_char([?\ ])
        ]),
        min: 1
      )
    )
  )

  defcombinatorp(
    :and_keyword,
    ignore(string("and")) |> parsec(:ws1)
  )

  defcombinatorp(
    :or_keyword,
    ignore(string("or")) |> parsec(:ws1)
  )

  defcombinatorp(
    :word,
    choice([
      utf8_string([?A..?Z, ?a..?z, ?0..?9], min: 1),
      ignore(ascii_char([?"]))
      |> utf8_string([?A..?Z, ?a..?z, ?0..?9, ?\t, ?\n, ?\r, ?\ ], min: 1)
      |> ignore(ascii_char([?"]))
    ])
    |> unwrap_and_tag(:word)
  )

  defcombinatorp(
    :tag,
    ignore(string("#"))
    |> utf8_string([?A..?Z, ?a..?z, ?0..?9], min: 1)
    |> unwrap_and_tag(:tag)
  )

  defcombinatorp(
    :facet,
    choice([
      ignore(string("tag:"))
      |> utf8_string([?A..?Z, ?a..?z, ?0..?9], min: 1)
      |> unwrap_and_tag(:tag),
      ignore(string("site:"))
      |> utf8_string([?A..?Z, ?a..?z, ?0..?9], min: 1)
      |> unwrap_and_tag(:site)
    ])
  )

  defcombinatorp(
    :term,
    choice([
      parsec(:facet),
      parsec(:tag),
      parsec(:word)
    ])
  )

  defcombinatorp(
    :recursion,
    choice([
      ignore(ascii_char([?(]))
      |> parsec(:ws0)
      |> concat(parsec(:union))
      |> ignore(ascii_char([?)])),
      optional(parsec(:term))
    ])
  )

  defcombinatorp(
    :negation,
    choice([
      ignore(string("not"))
      |> parsec(:ws1)
      |> concat(parsec(:recursion))
      |> unwrap_and_tag(:not),
      parsec(:recursion)
    ])
  )

  defcombinatorp(
    :intersection,
    choice([
      parsec(:negation)
      |> parsec(:ws1)
      |> lookahead_not(parsec(:or_keyword))
      |> optional(parsec(:and_keyword))
      |> concat(parsec(:intersection))
      |> tag(:and),
      parsec(:negation)
    ])
  )

  defcombinatorp(
    :union,
    choice([
      parsec(:intersection)
      |> parsec(:ws1)
      |> parsec(:or_keyword)
      |> concat(parsec(:union))
      |> tag(:or),
      parsec(:intersection) |> parsec(:ws0)
    ])
  )

  defparsec(:parse, parsec(:ws0) |> parsec(:union)) |> parsec(:ws0) |> eos()
end
