# fund_plus_workspace

Fund Plus Workspace

## Getting Started

1. This project use "melos" to control dependencies between project please install "melos"

Install melos:

```sh
$ dart pub global activate melos
```

[melos](https://melos.invertase.dev/)

Boostrap packages recursively: (linking local dependencies)

```sh
$ melos bs
```

2. Before start in this project. Please run setup project first

2.1 Run prepare for setup all project.

```sh
$ melos run prepare
```

## Command Helper

Check utility command

```sh
$ melos run
```

## Stucture Package

packages

```
   |________app

   |________features
               |____________feature
               |____________feature
   |________libraries
               |____________common
               |____________template
```

## Run

You can run individual feature in run folder EX. suitability/run/main.dart

or you can run whole application in packages/app/run/main.dart

## Build for Native

1. update new requirement code

2. run for update and push code to gitlab

```
$ melos run build
```

for update ios source code to gitlab and build&deploy alpha tag in android

3. tag version and run cmd again to deploy final tag

```
$ melos run build
```

4. native use tag final


## Build for Android
## It will build and deploy to Nexus

1. 
```
$ melos run bs
```

2.
```
$ melos run build:android
```

## Build for IOS 
## It will build source code in git

1. 
```
$ melos run bs
```

2.
```
$ melos run build:ios
```

## Test

Run All Test every package

```
$ melos run test
```
