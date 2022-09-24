# Note on Fortran

## Table of Content

<!-- vim-markdown-toc GFM -->

* [Fortran Package Manager](#fortran-package-manager)
    * [Change module name after fpm initialized the project](#change-module-name-after-fpm-initialized-the-project)
* [Fortran Compiler](#fortran-compiler)

<!-- vim-markdown-toc -->

## Fortran Package Manager

### Change module name after fpm initialized the project

After changing all the corresponding code, like `module` name and `use` statement in the directory `src/`, you need to go to `build/` and update the `cache.toml` file to the new module name.

## Fortran Compiler
