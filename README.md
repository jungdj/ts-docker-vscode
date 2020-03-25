# Typescript Docker VSCode

## Available Scripts

```json
{
  "name": "typescript-docker-vscode",
  "version": "0.0.0",
  "scripts": {
    "postinstall": "test -n \"$NOYARNPOSTINSTALL\" || yarn run build",
    "build": "tsc -p ./src",
    "watch": "tsc -w -p ./src",
    "debug": "nodemon --legacy-watch --watch ./dist --inspect=0.0.0.0:5858 --nolazy ./dist/index.js",
    "docker-debug": "docker-compose up",
    "start": "node ./dist/index.js"
  },
}

```

- The `postinstall` script uses the TypeScript compiler to translate the source into JavaScript in the 'dist' folder.
- The `watch` script runs the TypeScript compiler in 'watch' mode: whenever the TypeScript source is modified, it is transpiled into the 'dist' folder.
- The `debug` script uses 'nodemon' to watch for changes in the 'dist' folder and restart the node runtime in debug mode.
- The `docker-debug` script creates a docker image for debugging.
- The `start` script runs the server in production mode.

## Run Program Locally

You can run the server locally with these steps:
```sh
yarn
yarn start
```
Then open a browser on localhost:3000

## Running in Docker

```sh
docker build -t ts-docker-vscode .
docker run -p 3000:3000 ts-docker-vscode
```

## Running with Docker Compose

```sh
docker-compose up
```

### Additional Information on Docker Compose

For a faster edit/compile/debug cycle 'dist' folder of the VS Code workspace is mounted directly into the container running in Docker.

`docker-compose.yml`:

```yml
version: "2"

services:
  web:
    build: .
    command: yarn debug
    volumes:
      - ./dist:/server/dist
    ports:
      - "3000:3000"
      - "5858:5858"
```

## Debugging in VS Code

VS Code `tasks.json` inside the `.vscode` folder:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "tsc-watch",
      "command": "yarn",
      "args": [ "watch" ],
      "type":"shell",
      "isBackground": true,
      "group":"build",
      "problemMatcher": "$tsc-watch",
      "presentation":{
        "reveal": "always",
      }
    }
  ]
}
```
The build command will be automatically triggered whenever a debug session is started.

For launching the VS Code node debugger inside Docker container we use this launch configuration:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch in Docker",
      "preLaunchTask": "tsc-watch",
      "protocol": "auto",
      "runtimeExecutable": "yarn",
      "runtimeArgs": [ "docker-debug" ],
      "port": 5858,
      "restart": true,
      "timeout": 60000,
      "localRoot": "${workspaceFolder}/dist",
      "remoteRoot": "/usr/src/app/dist",
      "outFiles": [
        "${workspaceFolder}/dist/**/*.js"
      ],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen"
    },
  ]
}
```
- As a `preLaunchTask` we run the watch task that transpiles TypeScript into the `dist`folder. Since this task runs in background, the debugger does not wait for its termination.
- The `localRoot`/`remoteRoot` attributes are used to map file paths between the docker container and the local system: `remoteRoot` is set to `/server` because that's the absolute path of the folder where the program lives in the docker container.
- The `restart` flag is set to `true` because VS Code should try to re-attach to node.js whenever it loses the connection to it. This typically happens when nodemon detects a file change and restarts node.js.

After running "Attach to Docker" you can debug the server in TypeScript source:
- Set a breakpoint in `index.ts:9` and it will be hit as soon as the browser requests a new page,
- Modify the message string in `index.ts:7` and after you have saved the file, the server running in Docker restarts and the browser shows the modified page.

## Acknowledgements

This project is based on the vscode-recipes.