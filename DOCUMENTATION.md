# myFabric: System & User Documentation

## Table of Contents
- [myFabric: System \& User Documentation](#myfabric-system--user-documentation)
  - [Table of Contents](#table-of-contents)
  - [Part 1: System \& Functional Description](#part-1-system--functional-description)
    - [System Overview](#system-overview)
    - [Architecture \& Components](#architecture--components)
    - [Data Flow \& Storage](#data-flow--storage)
  - [Part 2: User Manual](#part-2-user-manual)
    - [Getting Started](#getting-started)
      - [Prerequisites](#prerequisites)
      - [Initialization](#initialization)
    - [Using Fabric](#using-fabric)
    - [YouTube Video Analysis](#youtube-video-analysis)
    - [Managing Patterns](#managing-patterns)

---

## Part 1: System & Functional Description

### System Overview
**myFabric** is a containerized development and execution environment tailored specifically for [Fabric](https://github.com/danielmiessler/fabric), an open-source framework for augmenting humans using AI. The system is designed to provide a reproducible, isolated, and feature-rich environment for running AI patterns against various data sources, with specialized, built-in support for processing multimedia and YouTube content.

### Architecture & Components
The environment is orchestrated using VS Code DevContainers and Docker/Podman. 

1. **Base Environment (`Dockerfile`)**
   - **OS/Runtime:** Built on `golang:1.25.1-alpine` to meet Fabric's Go version requirements while maintaining a minimal footprint. Use of fully qualified paths (`docker.io/...`) ensures compatibility with alternative container engines like Podman.
   - **Multimedia Pipeline:** Includes `python3`, `ffmpeg`, and a directly injected `yt-dlp` binary. This combination allows the system to download videos, extract audio, and process subtitles/transcripts dynamically.
   - **Fabric Core:** The latest version of Fabric is compiled and installed globally during the image build process.

2. **Workspace Configuration (`devcontainer.json`)**
   - **Bootstrapping:** Executes `fabric --setup` automatically upon container creation, ensuring base patterns are downloaded and the environment structure is ready.
   - **Developer Tooling:** Pre-configures VS Code with the `golang.go` extension for extending or debugging Fabric itself.

### Data Flow & Storage
- **State Persistence (The Bind Mount):** To prevent the loss of API keys (OpenAI, Anthropic, etc.) and custom patterns, the container binds the host machine's `~/.config/fabric` directory to the container's `/root/.config/fabric`. 
- **Ephemeral Processing:** Raw outputs, temporary video files, and transcripts (`*.vtt`) generated during processing remain in the container workspace. The `.gitignore` prevents these temporary artifacts from polluting version control.

---

## Part 2: User Manual

### Getting Started

#### Prerequisites
1. Docker or Podman installed on your host machine.
2. Visual Studio Code with the "Dev Containers" extension installed.
3. Your AI provider API keys ready (e.g., OpenAI, Anthropic).

#### Initialization
1. Open the `myFabric` folder in VS Code.
2. When prompted, click **"Reopen in Container"** (or use the command palette: `Dev Containers: Reopen in Container`).
3. The image will build, and the container will start. During the first run, the system will automatically execute `fabric --setup`.
4. If you haven't configured Fabric on your host machine before, run `fabric --setup` again in the container terminal to input your API keys (these will save directly to your host machine).

### Using Fabric

Fabric operates primarily via standard input (stdin) piping or direct flags.

**List all available patterns:**
```bash
fabric -l
```

**Analyze text from a file:**
```bash
cat article.txt | fabric --pattern summarize
```

**Save output to a file:**
```bash
cat article.txt | fabric --pattern extract_wisdom -o my_analysis.md
```

**Use clipboard as input and also translate output**
    There is a catch! In many CLI tools, spaces around the = character cause the shell to split the argument into separate pieces, but this specific Fabric implementation clearly requires that exact spacing to parse the variable assignment correctly. Therefore space characters are put around the '=' sign
```bash
xclip -selection clipboard -o | fabric --pattern analyze_personality | fabric --pattern translate -v lang_code = Hungarian > proba1.md
```

### YouTube Video Analysis

Thanks to the integrated `yt-dlp` and `ffmpeg` dependencies, myFabric excels at analyzing YouTube content directly from URLs.

**Option 1: Direct URL Analysis (Easiest)**
Use the `-y` flag to let Fabric automatically download the transcript and feed it into a pattern:
```bash
fabric -y "https://www.youtube.com/watch?v=VIDEO_ID" --pattern extract_wisdom
```

**Option 2: Manual Transcript Processing**
If you have already downloaded a transcript or have a `.vtt` file in your workspace, you can pipe it directly to save API calls and download time:
```bash
cat transcript.vtt | fabric --pattern analyze_claims
```

### Managing Patterns

Patterns are markdown files containing system prompts and instructions.

1. **Finding Patterns:** Run `fabric -l` to see community patterns.
2. **Creating Custom Patterns:** 
   - Navigate to `~/.config/fabric/patterns/` (which is mapped to your host).
   - Create a new directory for your pattern: `mkdir ~/.config/fabric/patterns/my_custom_pattern`
   - Create a `system.md` file inside that folder containing your prompt instructions.
   - You can now run your data through it using `--pattern my_custom_pattern`.
