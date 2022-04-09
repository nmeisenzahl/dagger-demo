package main

import (
    "dagger.io/dagger"
    "universe.dagger.io/alpine"
    "universe.dagger.io/docker"
    "universe.dagger.io/go"
)

dagger.#Plan & {
    client: filesystem: ".": read: contents: dagger.#FS

    actions: {
        // Test the app
        test_app: go.#Test & {
            source: client.filesystem.".".read.contents
        }

        // Build the app
        // Builds the golang app
        build_app: go.#Build & {
            source: client.filesystem.".".read.contents
        }

        // Build base
        // "environment" fpr the golang app build
        build_base: alpine.#Build & {
            packages: "ca-certificates": _
        }

        // Build image
        build_image: docker.#Build & {
            steps: [
                docker.#Copy & {
                    input: build_base.output
                    contents: build_app.output
                    dest:     "/app"
                },
                docker.#Set & {
                    config: cmd: ["/app"]
                },
            ]
        }

        // Push not implemented
    }
}
