# minesweeper-cr

A crystal implementation og minesweeper.

## Usage

`crystal build src/main.cr && ./main`

See `src/input.cr` for all available commands.

## Example

```
>> crystal build src/main.cr && bombs=10 cols=8 rows=8 ./main
  0 1 2 3 4 5 6 7
0 · · · · · · · ·
1 · · · · · · · ·
2 · · · · · · · ·
3 · · · · · · · ·
4 · · · · · · · ·
5 · · · · · · · ·
6 · · · · · · · ·
7 · · · · · · · ·

0/64 0/10 » 0 2
Show(@x=0, @y=2)
  0 1 2 3 4 5 6 7
0 · · · · 1 · · ·
1 · 1 1 1 1 · · ·
2 · 1 · · · · · ·
3 · 1 · · · · · ·
4 1 1 · · · · · ·
5 · · · · · · · ·
6 · · · · · · · ·
7 · · · · · · · ·

16/64 0/10 » 3 3
Show(@x=3, @y=3)
  0 1 2 3 4 5 6 7
0 · · · · 1 💣 1 ·
1 · 1 1 1 1 1 1 ·
2 · 1 💣 2 1 · · ·
3 · 1 3 💥 3 1 1 ·
4 1 1 3 💣 4 💣 1 ·
5 💣 2 3 💣 4 2 2 ·
6 2 💣 2 1 3 💣 2 ·
7 1 1 1 · 2 💣 2 ·

Game over.
```
