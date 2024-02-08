# Note on Fortran

## Table of Content

<!-- vim-markdown-toc GFM -->

* [Video Resource](#video-resource)
* [Fortran Package Manager](#fortran-package-manager)
    * [Change module name after fpm initialized the project](#change-module-name-after-fpm-initialized-the-project)

<!-- vim-markdown-toc -->

## Video Resource

- [Fortran: Array Language](https://www.youtube.com/watch?v=vdaps6Z0kJY)

## Fortran Package Manager

### Change module name after fpm initialized the project

After changing all the corresponding code, like `module` name and `use` statement in the directory `src/`, you need to go to `build/` and update the `cache.toml` file to the new module name.

<!-- ## Fortran Compiler -->


;tags: Miscellaneous
