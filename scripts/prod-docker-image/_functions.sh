#!/usr/bin/env bash

function initialize() {
  # shellcheck source=scripts/_base_variables.sh
  source "$( dirname "${BASH_SOURCE[0]}" )/../_base_variables.sh"

  cd "$( dirname "${BASH_SOURCE[0]}" )/../../" || exit 1
}

function build_image() {
  echo "Building image"
  echo "IMAGE_TAG=${IMAGE_TAG}"

  RELEASE_SHA=$(git rev-parse HEAD)
  readonly RELEASE_SHA
  echo "RELEASE_SHA=${RELEASE_SHA}}"
  docker pull "python:${PYTHON_VERSION}-slim-buster"

  build_args=(\
    "."
    "--file=scripts/prod-docker-image/Dockerfile"
    "--cache-from=python:${PYTHON_VERSION}-slim-buster"
  )

  echo "Building image: ${BUILD_IMAGE_NAME}:${IMAGE_TAG}"

  if [[ "$(docker images -q "${BUILD_IMAGE_NAME}:latest" 2> /dev/null)" == "" ]]; then
    docker pull "${BUILD_IMAGE_NAME}:latest" || true
  fi

  if [[ ! "$(docker images -q "${BUILD_IMAGE_NAME}:latest" 2> /dev/null)" == "" ]]; then
      build_args+=("--cache-from=${BUILD_IMAGE_NAME}:latest")
  fi
  docker build \
    "${build_args[@]}" \
    --target "build" \
    --tag "${BUILD_IMAGE_NAME}:${IMAGE_TAG}"

  if [[ "$(docker images -q "${PROD_IMAGE_NAME}:latest" 2> /dev/null)" == "" ]]; then
    docker pull "${PROD_IMAGE_NAME}:latest" || true
  fi

  if [[ ! "$(docker images -q "${PROD_IMAGE_NAME}" 2> /dev/null)" == "" ]]; then
      build_args+=("--cache-from=${PROD_IMAGE_NAME}:latest")
  fi

  echo "Building image: ${PROD_IMAGE_NAME}:${IMAGE_TAG}"
  docker build \
    "${build_args[@]}" \
    --target "main" \
    --build-arg "RELEASE_SHA=${RELEASE_SHA}" \
    --tag "${PROD_IMAGE_NAME}:${IMAGE_TAG}"
}

function verify_image() {
    echo "Verifying image: ${PROD_IMAGE_NAME}:${IMAGE_TAG}"
    docker run --rm "${PROD_IMAGE_NAME}" pip freeze
    # TODO: Add more checks
}

function push_image() {
    echo "Pushing image: ${BUILD_IMAGE_NAME}:${IMAGE_TAG}"
    docker push "${BUILD_IMAGE_NAME}:${IMAGE_TAG}"
    echo "Pushing image: ${PROD_IMAGE_NAME}:${IMAGE_TAG}"
    docker push "${PROD_IMAGE_NAME}:${IMAGE_TAG}"
}

function pull_image() {
    echo "Pulling image: ${PROD_IMAGE_NAME}:${IMAGE_TAG}"
    docker pull "${PROD_IMAGE_NAME}:${IMAGE_TAG}"
}
