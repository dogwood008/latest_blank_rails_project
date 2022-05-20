# syntax = docker/dockerfile:1.4

# 使用するDebianのバージョンを固定
ARG DEBIAN_CODENAME=bullseye
# 使用するRubyのバージョンを固定
ARG RUBY_VERSION=3.1.2
FROM ruby:${RUBY_VERSION?}-${DEBIAN_CODENAME?}

LABEL maintainer dogwood008

ARG DEBIAN_CODENAME
ARG RUBY_VERSION
# インストールする bundle を固定
ARG BUNDLER_VERSION=2.3.13
# gemのキャッシュを識別するID
ARG CACHE_ID=debian_${DEBIAN_CODENAME?}_ruby${RUBY_VERSION?}

ENV DEBIAN_CODENAME ${DEBIAN_CODENAME?}
# gemのインストール先兼キャッシュマウント位置
ARG CACHE_MOUNT_PATH=/opt/${DEBIAN_CODENAME?}/ruby${RUBY_VERSION?}/.cache/bundle
# キャッシュアンマウント後に使用するgemのインストール先
ARG NEW_BUNDLE_PATH=/root/bundle

# 一時ディレクトリでGemfileを使用してgemをインストールする
ARG WORKDIR=/tmp
WORKDIR ${WORKDIR?}
# Gemfileをコンテナにコピー
COPY ./app/Gemfile ${WORKDIR?}/Gemfile
COPY ./app/Gemfile.lock ${WORKDIR?}/Gemfile.lock

ENV BUNDLE_PATH ${CACHE_MOUNT_PATH?}
# bundler をインストール
RUN gem install bundler:${BUNDLER_VERSION?} --no-document
# nokogiriをソースからビルドではなくバイナリだけ取ってくるならfalse
ARG BUILD_NOKOGIRI_FROM_SOURCE=false
RUN bundle config set force_ruby_platform ${BUILD_NOKOGIRI_FROM_SOURCE?}
# キャッシュを保存するディレクトリを作成
RUN mkdir -p ${CACHE_MOUNT_PATH?}
# gemをインストール
RUN --mount=type=cache,uid=1000,target=${BUNDLE_PATH?},id=${CACHE_ID?} \
  bundle install && \
  cp -ar ${BUNDLE_PATH?} ${NEW_BUNDLE_PATH?}
# gemを読み込む先を変更
ENV BUNDLE_PATH ${NEW_BUNDLE_PATH?}

# 作業ディレクトリを固定
ARG WORKDIR=/app
WORKDIR ${WORKDIR?}
