# Building simulation images

Pinned Linux/amd64 containers for command-line building simulation:

- EnergyPlus 26.2.0 with its Python API;
- OpenModelica 1.26.3 with OMPython, Modelica Standard Library 4.1.0, and Modelica Buildings 14.0.0.

Release archives and base images are version-pinned. Archive checksums are verified during each build. Images are published to GHCR with immutable `sha-*` tags and OCI provenance/SBOM.
