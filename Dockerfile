# Stage 1: Runtime =============================================================
# The minimal package dependencies required to run the app in the release image:

# Use the official Ruby 2.7.2 Slim Buster image as base:
FROM ruby:2.7.2-slim-buster AS runtime

# We'll set MALLOC_ARENA_MAX for optimization purposes & prevent memory bloat
# https://www.speedshop.co/2017/12/04/malloc-doubles-ruby-memory.html
ENV MALLOC_ARENA_MAX="2"

# We'll install curl for later dependency package installation steps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libpq5 \
    openssl \
    tzdata \
 && rm -rf /var/lib/apt/lists/*

# Stage 2: testing =============================================================
# This stage will contain the minimal dependencies for the CI/CD environment to
# run the test suite:

# Use the "runtime" stage as base:
FROM runtime AS testing

# Install gnupg, used to install node, but will also allow us to GPG sign our
# git commits when using the development image:
RUN apt-get update \
 && apt-get install -y --no-install-recommends gnupg2

# Add nodejs debian LTS repo:
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Add the Yarn debian repository:
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install the app build system dependency packages:
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    nodejs \
    yarn

# Receive the app path as an argument:
ARG APP_PATH=/srv/arrow-challenge

# Receive the developer user's UID and USER:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_USERNAME=you

# Replicate the developer user in the development image:
RUN addgroup --gid ${DEVELOPER_UID} ${DEVELOPER_USERNAME} \
 ;  useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_UID} \
    --shell /bin/bash -c "Developer User,,," ${DEVELOPER_USERNAME}

# Ensure the developer user's home directory and APP_PATH are owned by him/her:
# (A workaround to a side effect of setting WORKDIR before creating the user)
RUN userhome=$(eval echo ~${DEVELOPER_USERNAME}) \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} $userhome \
 && mkdir -p ${APP_PATH} \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} ${APP_PATH}

# Add the app's "bin/" directory to PATH:
ENV PATH=${APP_PATH}/bin:$PATH

# Set the app path as the working directory:
WORKDIR ${APP_PATH}

# Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Copy the project's Gemfile and Gemfile.lock files:
COPY --chown=${DEVELOPER_USERNAME} Gemfile* ${APP_PATH}/

# Install the gems in the Gemfile, except for the ones in the "development"
# group, which shouldn't be required in order to  run the tests with the leanest
# Docker image possible:
RUN bundle install --jobs=4 --retry=3 --without="development"

# Copy the project's node package dependency lists:
COPY --chown=${DEVELOPER_USERNAME} package.json yarn.lock ${APP_PATH}/

# Install the project's node packages:
RUN yarn install

# Stage 3: Development =========================================================
# In this stage we'll add the packages, libraries and tools required in the
# day-to-day development process.

# Use the "testing" stage as base:
FROM testing AS development

# Receive the developer username again, as ARGS won't persist between stages on
# non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Change to root user to install the development packages:
USER root

# Install sudo, along with any other tool required at development phase:
RUN apt-get install -y --no-install-recommends \
  # Add the bash autocompletion stuff:
  bash-completion \
  openssh-client \
  # Vim will be used to edit files when inside the container (git, etc):
  vim \
  # Sudo will be used to install/configure system stuff if needed during dev:
  sudo

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Change back to the developer user:
USER ${DEVELOPER_USERNAME}
# Install the gems in the Gemfile, this time including the previously ignored
# "development" gems - We'll need to delete the bundler config, as it currently
# belongs to "root":
RUN bundle install --jobs=4 --retry=3 --with="development"

# Put the `node_modules/.keep` file, to prevent Git from thinking it was removed
RUN touch node_modules/.keep

# Stage 4: Builder =============================================================
# In this stage we'll add the rest of the code, compile assets, and perform a 
# cleanup for the releasable image.

# Use the "testing" stage as base:
FROM testing AS builder

# Receive the developer username and the app path arguments again, as ARGS
# won't persist between stages on non-buildkit builds:
ARG DEVELOPER_USERNAME=you
ARG APP_PATH=/srv/arrow-challenge

# Copy the full contents of the project:
COPY --chown=${DEVELOPER_USERNAME} . ${APP_PATH}/

# Precompile the application assets:
RUN export SECRET_KEY_BASE=10167c7f7654ed02b3557b05b88ece RAILS_ENV=production \
 && rails assets:precompile \
 # Test if everything is OK:
 && rails secret > /dev/null

# Remove installed gems that belong to the development & test groups -
# we'll copy the remaining system gems into the deployable image on the next
# stage:
RUN bundle config without development test && bundle clean --force

# Change to root, before performing the final cleanup:
USER root

# Remove unneeded gem cache files (cached *.gem, *.o, *.c):
RUN rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove project files not used on release image:
RUN rm -rf \
    .rspec \
    Guardfile \
    bin/rspec \
    bin/checkdb \
    bin/dumpdb \
    bin/restoredb \
    bin/setup \
    bin/dev-entrypoint \
    node_modules \
    tmp/cache/*

# Stage 5: Release =============================================================
# In this stage, we build the final, releasable, deployable Docker image, which
# should be smaller than the images generated on previous stages:

# Use the "runtime" stage as base:
FROM runtime AS release

# Copy the remaining installed gems from the "builder" stage:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Receive the app path argument again, as ARGS are not persisted between stages
# on non-buildkit builds:
ARG APP_PATH=/srv/arrow-challenge

# Copy the app code and compiled assets from the "builder" stage to the
# final destination at /srv/arrow-challenge:
COPY --from=builder --chown=nobody:nogroup ${APP_PATH} /srv/arrow-challenge

# Set the container user to 'nobody':
USER nobody

# Set the RAILS and PORT default values:
ENV HOME=/srv/arrow-challenge RAILS_ENV=production PORT=3000

# Set the installed app directory as the working directory:
WORKDIR /srv/arrow-challenge

# Set the default command:
CMD [ "puma" ]

# Add label-schema.org labels to identify the build info:
ARG SOURCE_BRANCH="master"
ARG SOURCE_COMMIT="000000"
ARG BUILD_DATE="2017-09-26T16:13:26Z"
ARG IMAGE_NAME="icalialabs/arrow-challenge:latest"
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="arrow-challenge" \
      org.label-schema.description="arrow-challenge" \
      org.label-schema.vcs-url="https://github.com/icalialabs/arrow-challenge.git" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.schema-version="1.0.0-rc1" \
      build-target="release" \
      build-branch=$SOURCE_BRANCH
