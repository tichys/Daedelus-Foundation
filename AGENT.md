# AGENT.md - Daedalus Dock Codebase Guide

## Build/Test Commands
- `BUILD.cmd` or `tools/build/build.bat` - Build the entire project (DM + TGUI)
- `bin/server.cmd` - Quick build and run server on port 1337
- `tools/build/build --ci lint tgui-test` - Run linters and TGUI tests
- For unit tests: Uncomment `#define UNIT_TESTS` in `code/_compile_options.dm` and run daedalus.dmb
- `tools/bootstrap/python -m mapmerge2.dmm_test` - Map validation tests
- `~/dreamchecker` - DM static analysis linting (requires SpacemanDMM)

## Architecture
- **DreamMaker (DM)**: Main game engine using BYOND language, entry point is `daedalus.dme`
- **TGUI**: TypeScript/React frontend in `tgui/` directory with Jest tests
- **Code structure**: Modular design in `code/modules/` with feature-specific directories
- **Database**: SQL schemas in `SQL/` directory, configs in `config/`
- **Assets**: Icons in `icons/`, sounds in `sound/`, maps in `_maps/`
- **Tools**: Build tools in `tools/`, Python utilities, deployment scripts

## Code Style
- **Indentation**: Tabs (4 spaces), UTF-8 encoding, LF line endings (see .editorconfig)
- **Naming**: snake_case for variables/procs, PascalCase for types/datums
- **Comments**: Minimal comments, prefer self-documenting code unless complex
- **Tests**: Custom DM unit test framework in `code/modules/unit_tests/`, use allocate() for test objects
- **Conventions**: Follow SpacemanDMM standards, use absolute type paths, no relative definitions
