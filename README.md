# DEL-AWARE

DEL-AWARE is a tool for automating the application of requirements sourced from a USCDI+ Data Element List (DEL) to a FHIR Implementation Guide (IG). It is intended to be used to help generate and maintain these IGs over time. DEL-AWARE was primarily written with [QI-Core](http://hl7.org/fhir/us/qicore) and [USCDI+ Quality](https://uscdiplus.healthit.gov/uscdiplus) in mind, but other USCDI+ domains and FHIR IGs may find utility as well.

DEL-AWARE ingests an IG, a USCDI+ Data Element List with IG profile and element mappings, and updates the IG source to reference all the elements listed in the data element list via Profile extension tagging. It also generates and adds CapabilityStatement(s), SearchParameter(s), narratives (key element summary and profile introductions), ModelInfo files, and more.

## Installation

### Ruby Installation

1. Ensure you have the correct version of Ruby installed (i.e. respects the version listed in the `.ruby-version` file). On Mac or Linux, one option is to use [rbenv](https://github.com/rbenv/rbenv) to manage Ruby versions. On Windows, one option is to use [RubyInstaller](https://rubyinstaller.org/). An installer for Ruby 3.3.6 is available [here](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.3.6-2/rubyinstaller-devkit-3.3.6-2-x64.exe).

2. Clone the repository locally.

   ```sh
   git clone <repository-url>
   cd del-aware
   ```

3. Run `bundle install` in the root directory.

### Docker Installation

You can use Docker to simplify the installation process and avoid manually installing Ruby, Node.js, and Java dependencies.

Note that it is possible to run things via the Docker image directly, but it is suggested to use the docker compose approach outlined below so that all of the proper directories are mounted against the running Docker image.

## Running DEL-AWARE

### Directly using Ruby

#### Generate modified IG

Apply the given data element list to the given IG source. This will update the IG source in-place. DEL-AWARE applies changes idempotently.

This assumes you have a copy of the `del-aware-qi-core` IG in the same parent directory as DEL-AWARE.

```sh
bin/delaware apply --del=example/del_2026_03_11.json --config=example/config.yaml --ig=../del-aware-qi-core
```

##### Include CQL ModelInfo (experimental)

Add the `--modelinfo` flag to the apply command to include a freshly generated modelinfo file for use with CQL. This will download and run the latest `cqf-tooling` jar against the IG source.

##### Output as FSH (experimental)

Add the `--fsh` flag to the apply command to generate a version of the modified IG in FSH. You will need a copy of GoFSH installed (with a compatible node runtime). You can run `npm install` in the root directory to install a project-local copy of GoFSH.

#### View CLI Help

```sh
bin/delaware help
```

Displays the list of available commands and their usage.

### Using Docker Compose

In order to persist changes outside of the Docker image environment, you should modify the IG source mount directory in the `.docker-compose.yml` to point at your local IG copy. By default, this is set to `../del-aware-qi-core`, which assumes you have a copy of that IG in the same parent directory as your copy of DEL-AWARE.

1. Build and start the container:

   ```sh
   docker compose up --build
   ```

2. Run specific commands:

   Checking the version:

   ```sh
   docker compose run del-aware bin/delaware version
   ```

   Applying the DEL to the IG:

   ```sh
   docker compose run del-aware bin/delaware apply --del=example/del_2026_03_11.json --config=example/config.yaml --ig=ig
   ```

3. Shut down the container:

   ```sh
   docker compose down

## Scripts

### del2json.rb

This script takes as input a DEL spreadsheet and converts it to the JSON format used by DEL-AWARE.

#### Usage

```sh
ruby del2json.rb <path to xlsx> <path to output>
```

For example (from repository root):

```sh
ruby scripts/del2json.rb ~/Desktop/del_2026_03_11.xlsx example/del_2026_03_11.json
```

## Testing & Linting

Run Tests:

```sh
bundle exec rspec
```

Run Rubocop:

```sh
bundle exec rubocop
```

## Console

```sh
bin/console
```

## GitHub Actions Workflows

This repository includes GitHub Actions workflows that replicate the functionality of the GitLab CI/CD pipelines. These workflows are located in the `.github/workflows` directory and are not triggered automatically. To manually run these workflows, use the "workflow_dispatch" trigger in the GitHub Actions interface.
