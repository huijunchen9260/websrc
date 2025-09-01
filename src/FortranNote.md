# Note on Fortran

## Table of Content

<!-- vim-markdown-toc GFM -->

* [Video Resource](#video-resource)
* [Fortran Package Manager](#fortran-package-manager)
    * [Change module name after fpm initialized the project](#change-module-name-after-fpm-initialized-the-project)
* [Variable initialization](#variable-initialization)

<!-- vim-markdown-toc -->

## Video Resource

- [Fortran: Array Language](https://www.youtube.com/watch?v=vdaps6Z0kJY)

## Fortran Package Manager

### Change module name after fpm initialized the project

After changing all the corresponding code, like `module` name and `use` statement in the directory `src/`, you need to go to `build/` and update the `cache.toml` file to the new module name.

## Variable initialization

I refer to this [discussion](https://fortran-lang.discourse.group/t/questions-on-variable-scope-in-parallel-computing/9824) in fortran-lang wiki.

One will face race condition with `OpenMP` if you initialize variable like

```fortran
real(wp) :: a = 0.0_wp
```

This way, the variable `a` will be `save` variable, and the `a` variable in each thread will not be independent.

For example, if you have a subroutine like this:

```fortran
SUBROUTINE test()
  INTEGER :: x = 5
  x = x + 1
  WRITE (*, *) x
END SUBROUTINE test
```

and then in you program you do

```fortran
CALL test()
CALL test()
CALL test()
CALL test()
CALL test()
```

it will print

```
6
7
8
9
10
```

Instead, we should initialize variables as

```fortran
real(wp) :: a
a = 0.0_wp
```

so that the variable will be automatic variables.


;tags: Miscellaneous
