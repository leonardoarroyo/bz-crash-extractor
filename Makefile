SHELL := /bin/sh

run:
	while true; do .stack-work/dist/x86_64-linux-nix/Cabal-3.2.1.0/build/crash-extractor-exe/crash-extractor-exe > ~/Documents/crash-data; done
