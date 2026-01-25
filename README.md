% CodeChecker Control  
% Tamás Dezső  
% Jan 25, 2026
<!-- pandoc README.md -o CodeChecker_Control.pdf \
    -V papersize:A4 \
    -V documentclass=report \
    -V geometry:margin=1in \
    -V colorlinks \
    -V lot \
    --toc \
    --pdf-engine=xelatex \
    -V monofont='Ubuntu Mono'
-->


# CodeChecker Control

CCTL is a lightweight control tool and workflow driver for running
**CodeChecker** inside Docker. It standardizes build capture, analysis,
and report generation for local development and CI, while keeping the
execution environment reproducible.

CCTL focuses on:

- building and analyzing code in a consistent environment
- detecting newly introduced defects
- generating local, static HTML reports
- optionally running a CodeChecker server and storing results centrally

---

## Quick start

This is the shortest useful path. It assumes Docker is installed and
`cctl` is already on your `PATH`.

```bash
# build the CodeChecker image (once)
make -C /path/to/cctl image


# run analysis
cd /path/to/c-project
cctl build
cctl analyze
cctl parse

# open local HTML report
firefox codechecker/report-html/index.html
```

That’s it. No server required.

Read further for tuning checkers, excluding files, or storing results in
a CodeChecker server.

---

## Architecture overview

CCTL builds a single Docker image that can be used in two modes:
- **CLI mode** for analysis and report generation
- **Server mode** for browsing and storing results

```
┌──────────────────────────────┐
│  CodeChecker Control Image   │
│                              │
│  gcc / clang / cppcheck      │
│  CodeChecker CLI             │
│  CodeChecker server          │
└──────────────┬───────────────┘
               │ mounts
               V
┌──────────────────────────────┐
│  Host filesystem             │
│                              │
│  → source code               │
│  → CodeChecker workspace     │
└──────────────────────────────┘
```

The analyzed project always lives on the host filesystem. The container
only provides the tooling.

---

## Preparation

### Build the Docker image

Build the CodeChecker Docker image.  
If required, customize the environment beforehand by editing
`docker/Dockerfile`.

```bash
make image
```

This is typically done once per version update.

---

### Make `cctl` available in the shell

Add the `cctl` entry point to your `PATH` (for example via `~/.profile`):

```bash
export PATH="/path/to/cctl/bin:$PATH"
```

Reload the shell or source the profile for the change to take effect.

---

### Prepare CodeChecker configuration for the target project

In the project to be analyzed, copy the sample CodeChecker configuration
and adjust it as needed.

```bash
cd ${PROJECT_DIR}
cp -r /path/to/cctl/codechecker ./
vi codechecker/config.yml
vi codechecker/skipfile.txt
```

These files control:
- enabled and disabled checkers
- file and directory exclusions

They are expected to live **inside the analyzed project**.

---

## Workflow

All commands below are executed **from the project directory** being
analyzed.

```bash
cd ${PROJECT_DIR}

cctl build [build-cmd] # build the project and generate compile_commands.json
cctl analyze           # run CodeChecker analysis and produce reports
cctl parse             # generate a static HTML report
cctl server-up         # start the CodeChecker web server
cctl store             # upload reports to the CodeChecker server
```

---

### Build command selection

`cctl build` runs the project build **inside the Docker container** in
order to generate `compile_commands.json`.

By default, the following build command is used:

```bash
make clean && make
```

The build command can be overridden in two ways.

#### Environment variable

```bash
export PROJECT_BUILD_CMD="cmake --build build"
cctl build
```

This is useful for CI or when working with multiple projects.

#### Command-line override

```bash
cctl build ninja -C build
```

When provided, the command-line argument takes precedence over the
environment variable.


#### Precedence order

1. Command-line argument  
2. `PROJECT_BUILD_CMD` environment variable  
3. Built-in default

The build command is passed verbatim to CodeChecker and executed inside
the container. Ensure the Docker image contains all tools and
dependencies required to build the project.

---

Open the web UI in a browser:

```bash
firefox http://localhost:8001/
```

When finished, stop the server if needed:

```bash
cctl server-down
```

---

## Files and configuration

### Credentials

Password file for accessing the CodeChecker server when storing results:

```bash
chmod 600 ${HOME}/.codechecker/passwords.json
```

Example structure:

```json
{
  "client_autologin": true,
  "credentials": {
    "*": "user123:232341f5f368dcc56783344cda5881ab"
  }
}
```

---

### Server configuration

The CodeChecker server configuration is stored in:

```bash
~/.local/share/codechecker/workspace/server_config.json
```

Edit this file to adjust server ports, paths, or authentication behavior.

---

## Notes

- `cctl` assumes it is run from the project being analyzed.
- `compile_commands.json` must be present (generated by `cctl build` or an equivalent build step).
- The static HTML output (`cctl parse`) can be used independently of the server for local or offline review.
- The Docker image is an implementation detail; analysis results always live on the host.
