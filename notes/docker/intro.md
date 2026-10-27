# Intro

Table of Contents:
- [Intro](#intro)
  - [What is Docker?](#what-is-docker)
  - [What is a Docker Image?](#what-is-a-docker-image)
  - [What is a Container?](#what-is-a-container)
  - [Dockerfile](#dockerfile)
- [One-Sentence Definitions](#one-sentence-definitions)
- [The Big Picture](#the-big-picture)

## What is Docker?

Docker is a platform for building, packaging, distributing, and running applications in isolated environments called containers.
The main idea behind Docker is: Package an application together with everything it needs to run, and make that package portable.

An application may depend on many things:
* application source code
* libraries and dependencies
* a programming language runtime
* system libraries
* configuration files
* system utilities

Without Docker, we might have a situation like:

```
Developer's machine
    ├── Python 3.12
    ├── Flask 3.x
    ├── PostgreSQL ...
    └── works perfectly
Server
    ├── Python 3.10
    ├── Flask 2.x
    ├── PostgreSQL ...
    └── application breaks
```

Docker helps make the application’s environment much more consistent.

⸻

## What is a Docker Image?

A Docker image is an immutable package containing the files and environment needed to create a container.
An image can contain: Application code, Dependencies, Runtime, System libraries, System tools, Configuration/files.


For example, a Python application image might contain:

```
Python 3.12          ← runtime
Flask                ← dependency
Requests             ← dependency
Application files    ← your code
System libraries     ← required environment
```

## What is a Container?

A container is a running instance of a Docker image. A container provides an isolated environment in which an application can run.
The relationship is: Docker Image -> docker run -> Docker Container.
You can create many containers from the same image. The image remains the same, while each container is a separate running instance.

For example: `docker run nginx`. Docker takes the nginx image and creates a container from it.

⸻

## Dockerfile

A Dockerfile is a text file containing instructions for building a Docker image.

For example:
```
FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

⸻

# One-Sentence Definitions

If you need to memorize the essentials:

Concept	        Meaning
Docker	        Platform for building, distributing, and running containerized applications
Container	    Running instance of an image
Image	        Packaged filesystem/environment used to create containers
Dockerfile	    Instructions for building an image
Runtime	        Software/environment that allows an application to execute
Dependency	    Software/library required by an application
Docker Client	Interface used to communicate with Docker
Docker Engine	Component that manages and runs Docker objects
Docker Host	    Machine/environment where Docker Engine runs
Registry	    Storage/distribution service for images
Docker Hub	    A popular public Docker registry
Network	        Provides connectivity between containers and other networks
Port mapping    Makes a container port accessible through the host
Volume	        Persistent storage managed by Docker

⸻

# The Big Picture

The entire Docker workflow can be summarized as:

                    DEVELOPMENT
                 Dockerfile
                     │
                     │ docker build
                     ↓
                Docker Image
                     │
                     │ push
                     ↓
              Docker Registry
                     │
                     │ pull
                     ↓
                  Docker Host
                     │
                 Docker Engine
                     │
              ┌──────┴──────┐
              ↓             ↓
          Containers      Networks
              │
              ↓
           Volumes

The central idea is simple:

Docker packages an application and its environment into images, runs those images as isolated containers, connects containers through networks, and stores persistent data in volumes.


<br>
<br>
<br>

**The next topic: [Docker Fundamentals & Containerization](/notes/docker/docker_fundamentals.md)**