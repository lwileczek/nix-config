# Python

{ pkgs }:

with pkgs; [
    python314 # runtime

    # Project & Package management
    python314Packages.setuptools
    python314Packages.pip
    python314Packages.virtualenv
    python314Packages.uv
    python314Packages.ty
    python314Packages.ruff
    python314Packages.ruff-format
    python314Packages.python-lsp-ruff
    python314Packages.pytest

    # Default packages
    ## python314Packages.requests
    ## python314Packages.numpy
    ## python314Packages.polars
    ## python314Packages.boto3
]
