# Note on Tikz

## Create a "bezier curve"

```tex
\draw (0, 0) to[bend right=40] (5, 5);
```

Can `bend right` or `bend left`, depends on from `(0, 0)` to `(5, 5)` or the other direction.

`bend right=40` means the degree of bending.

## Define points on arbitrary curve

Here I use "bezier curve" as example.

```tex
\draw (0, 0) to[bend right=40]
    node[pos=0.2,draw,fill=red,circle,inner sep=1pt] (a) {}
    (5, 5);
```

The `pos` option in `node` defines what fraction of this curve should I put a point on it.
This `node` is defined as `a`.

## Get x and y coordinate of arbitrary point

Let the arbitrary be `a`.

```tex
\path (a); \pgfgetlastxy{\xcoord}{\ycoord};
\coordinate (a_x) at (\xcoord, 0);
\coordinate (a_y) at (0, \ycoord);
```

First, let the `path` be on the point `a` so that `pgf` can remember it.

Second, `\pgfgetlastxy` outputs the x-coordinate `\xcoord` and y-coordinate `\ycoord` of the last path, which we define as point `a`.

Finally, we can define the `a_x` and `a_y` points for the corresponding coordinate points.

## Draw "tangent line" on curve

Here I use "bezier curve" as example.

```tex
\draw (0, 0) to[bend right=40]
    node[pos=0.5,draw,fill=red,circle,inner sep=1pt] (a) {}
    node[pos=0.51] (b) {}
    (5, 5);
\draw[shorten >=-1cm, shorten <=-1cm, thick, red] (a) -- (b);
```

Instead of do the tangent line in a [delicated way](https://tex.stackexchange.com/a/25940), I found out that just define two close point (`a` and `b`) and connect them together.

Notice that I didn't draw the inner point at point `b`.

When connecting two points, use negative number in `shorten` to actually extend the line out.

## Decoration: brace

Need to add `\usetikzlibrary{decorations.pathreplacing}` in preamble.

```tex
%%% brace on up/right
\draw [decorate,decoration={brace,amplitude=4pt},xshift=0pt,yshift=3pt]
       (a) -- (b) node [black,midway,yshift=.3cm] {\footnotesize $foo$};
%%% brace on down/left (mirror)
\draw [decorate,decoration={brace,amplitude=4pt, mirror},xshift=0pt,yshift=3pt]
       (a) -- (b) node [black,midway,yshift=.3cm] {\footnotesize $foo$};
```

Need to modify `xshift` and `yshift` to micro-adjust the brace display.
