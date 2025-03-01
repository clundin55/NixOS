# Introduction

This repo contains my home folder and dotfiles, managed by Nix Home Manager.

# Getting Started

1. Install Nix.
1. Install Home Manager.
     - `nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager`
     - `nix-channel --update`
     - `nix-shell '<home-manager>' -A install`
1. Setup Home Manager.
     - `$ home-manager switch`

# Extra steps

## Set up git scm breeze

`$ install-scm-breeze`
