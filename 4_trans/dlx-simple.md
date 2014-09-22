Making data dance
=================

Donald Knuth's "Dancing Links" algorithm deserves wider recognition. It can solve the N-queens problem. It can help us tile pentominoes. It makes solving a Sudoku problem trivial.

There's only one little issue: these problems are all solved in another domain which we can call the "big huge matrix of ones and zeroes domain". Constructing such a matrix manually is about as fun as boning fish.

Solution: I wrote a set of parsers that can understand a given problem type, so that we can always deal with cute ASCII representations of the problems, and never the matrix itself. We become unfettered from the technical specifics of the algorithm, while still reaping all the benefits from it.

The same idea has been implemented in Perl 5/Moose (for prototyping), C (for speed), and Perl 6 (for beauty), and I will say a thing or two about what's nice about implementing a small project like this in each of those languages.