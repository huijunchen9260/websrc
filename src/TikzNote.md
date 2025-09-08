# Note on Tikz and PGFplots

<!-- vim-markdown-toc GFM -->

* [Tikz related](#tikz-related)
    * [Opinionated "Good" Habit when using Tikz](#opinionated-good-habit-when-using-tikz)
    * [Create a "bezier curve"](#create-a-bezier-curve)
    * [Define points on arbitrary curve](#define-points-on-arbitrary-curve)
    * [Get x and y coordinate of arbitrary point](#get-x-and-y-coordinate-of-arbitrary-point)
    * [Draw "tangent line" on curve](#draw-tangent-line-on-curve)
    * [Decoration: brace](#decoration-brace)
    * [Intersection between two curves](#intersection-between-two-curves)
    * [Change the font size of all node/label](#change-the-font-size-of-all-nodelabel)
    * [Calculation points](#calculation-points)
* [PGFplots related](#pgfplots-related)
    * [Get the dimension of the `axis` environment](#get-the-dimension-of-the-axis-environment)

<!-- vim-markdown-toc -->

## Tikz related

### Opinionated "Good" Habit when using Tikz

- We can separate the definition of the desired point from the label of the point, e.g.:

    ```tex
        \node[draw,fill=red,circle,inner sep=1pt] (x00) at ( $ (0, 0)$ ) {};
        \node[below]  at (x00) {$x_{00}(a_1, a_2)$};
    ```

    - Reason: I can have full control on the decoration of the node on `(0, 0)` and where I should put the label on.
        One can also use `\coordinate` to define points, i.e.,

    ```tex
        \coordinate[draw,fill=red,circle,inner sep=1pt] (x00) at ( $ (0, 0)$ );
        \node[below]  at (x00) {$x_{00}(a_1, a_2)$};
    ```

    It seems that `\coordinate` cannot have labels, so there's no need to include empty `{}` at the end of the `\node`.
- Define points first and give every point a reasonable name.
    - Reason: You can directly use those named points to create paths.


### Create a "bezier curve"

```tex
\draw (0, 0) to[bend right=40] (5, 5);
```

Can `bend right` or `bend left`, depends on from `(0, 0)` to `(5, 5)` or the other direction.

`bend right=40` means the degree of bending.

### Define points on arbitrary curve

Here I use "bezier curve" as example.

```tex
\draw (0, 0) to[bend right=40]
    node[pos=0.2,draw,fill=red,circle,inner sep=1pt] (a) {}
    (5, 5);
```

The `pos` option in `node` defines what fraction of this curve should I put a point on it.
This `node` is defined as `a`.

### Get x and y coordinate of arbitrary point

Let the arbitrary be `a`.

```tex
\path (a); \pgfgetlastxy{\xcoord}{\ycoord};
\coordinate (a_x) at (\xcoord, 0);
\coordinate (a_y) at (0, \ycoord);
```

First, let the `path` be on the point `a` so that `pgf` can remember it.

Second, `\pgfgetlastxy` outputs the x-coordinate `\xcoord` and y-coordinate `\ycoord` of the last path, which we define as point `a`.

Finally, we can define the `a_x` and `a_y` points for the corresponding coordinate points.

### Draw "tangent line" on curve

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

### Decoration: brace

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

### Intersection between two curves

[Source](https://tex.stackexchange.com/a/531279)

Need to add `\usetikzlibrary{intersections}` in preamble.

```tex
\documentclass[tikz, margin = 1mm]{standalone}
\usetikzlibrary{intersections}
\begin{document}
\begin{tikzpicture}
    \draw[name path=a] (0, 0) to[bend right = 40] (2, 0);
    \draw[name path=b] (0, -.5) to[bend left = 40] (2, -.5);
    \path[name intersections={of=a and b, by=e}];
    \node[draw,fill=red,circle,inner sep=1pt] at (e) {};
\end{tikzpicture}
\end{document}
```

Explanation:

- Need to add `name path=name` as argument to call this path.
- Use `\path` to define the `name intersections`. `of` is to define the intersections between two paths, and `by` defines the name of the intersection.
- Use `\node` to draw the point as `circle`. Can be other type.

### Change the font size of all node/label

Simply use `\tikzstyle` is suffice:

```tex
\begin{tikzpicture}
    \tikzstyle{every node}=[font=\scriptsize]
    ...
\end{tikzpicture}
```

### Calculation points

Need to add `\usetikzlibrary{calc}`

The syntax of `calc` library is

```tex
\documentclass[tikz, margin = 1mm]{standalone}
\usetikzlibrary{calc, intersections}
\begin{document}
\begin{tikzpicture}

    % The following figure shows how the golden section search separate the 2-D space.
    \pgfmathsetmacro{\x}{5};
    \pgfmathsetmacro{\y}{5};
    \pgfmathsetmacro{\tau}{0.618};

    \draw[-] (0, 0) -- (\x, 0) -- (\x, \y) -- (0, \y) -- (0, 0);

    % define (a, b) points in both dimension
    \coordinate[draw,fill=red,circle,inner sep=1pt] (x00) at ( $ (0, 0)$ );
    \coordinate[draw,fill=red,circle,inner sep=1pt] (x01) at ( $ (\x, 0) $ );
    \coordinate[draw,fill=red,circle,inner sep=1pt] (x10) at ( $ (0, \y)$ );
    \coordinate[draw,fill=red,circle,inner sep=1pt] (x11) at ( $ (\x, \y) $ );

    % use calc library to calculate the coordinate of the (c, d) points in both dimension
    \coordinate[draw,fill=blue,circle,inner sep=1pt](c1) at ( $ (x00)!1-\tau!(x01) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](c1mirror) at ( $ (x10)!1-\tau!(x11) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](d1) at ( $ (x00)!\tau!(x01) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](d1mirror) at ( $ (x10)!\tau!(x11) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](c2) at ( $ (x00)!1-\tau!(x10) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](c2mirror) at ( $ (x01)!1-\tau!(x11) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](d2) at ( $ (x00)!\tau!(x10) $ );
    \coordinate[draw,fill=blue,circle,inner sep=1pt](d2mirror) at ( $ (x01)!\tau!(x11) $ );

    % draw dashed line to connect coordinates
    \draw[dashed, name path = dashc1] (c1) -- (c1mirror);
    \draw[dashed, name path = dashd1] (d1) -- (d1mirror);
    \draw[dashed, name path = dashc2] (c2) -- (c2mirror);
    \draw[dashed, name path = dashd2] (d2) -- (d2mirror);

    % define the interior (c, d) points using coordinates
    \path[name intersections={of=dashc1 and dashc2, by=y00}];
    \node[draw,fill=orange,circle,inner sep=1pt] at (y00) {};

    \path[name intersections={of=dashc1 and dashd2, by=y10}];
    \node[draw,fill=orange,circle,inner sep=1pt] at (y10) {};

    \path[name intersections={of=dashd1 and dashc2, by=y01}];
    \node[draw,fill=orange,circle,inner sep=1pt] at (y01) {};

    \path[name intersections={of=dashd1 and dashd2, by=y11}];
    \node[draw,fill=orange,circle,inner sep=1pt] at (y11) {};

\end{tikzpicture}
\end{document}
```
## PGFplots related

### Get the dimension of the `axis` environment

This is useful to draw a vertical line or horizontal line in the `axis` environment.

The code is `\pgfkeysvalueof{/pgfplots/variable}`. For example, `\pgfkeysvalueof{/pgfplots/xmin}` will give you the `xmin` variable value defined in `axis`.

Examples:

```tex
\draw[color=blue, dashed] (1.0, \pgfkeysvalueof{/pgfplots/ymin}) -- (1.0, \pgfkeysvalueof{/pgfplots/ymax});
```

Will draw a blue dashed vertical line at $x = 1.0$.

;tags: Miscellaneous
