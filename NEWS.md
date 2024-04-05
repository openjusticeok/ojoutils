# ojoutils 0.1.3 (2024-04-05) 

- Adds  `comma` and `percent` functions to format numbers as strings with commas and percentages, respectively.

# ojoutils 0.1.2 (2024-03-12)

- Adds `ojo_use_template` function to make it easier to add a new blank Quarto report to a project repository.
- Adds `dir_empty`, styled in `{fs}` fashion, to easily check whether a directory is, well, empty.

# ojoutils 0.1.1 (2023-07-08)

- Adds `ojo_parse_county` function for standardizing Oklahoma county names, optionally specifying the case of the result.
- Adds `ojo_counties` object which is a vector of Oklahoma county names in lowercase. This is also used internally by `ojo_parse_county`.

# ojoutils 0.1.0 (2023-07-07)

- Adds function `limit` which works like `head` but is helpful for when your brain is in SQL mode.
