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

# gemはDockerのビルドキャッシュ用のパスへインストールさせる
ENV BUNDLE_PATH ${CACHE_MOUNT_PATH?}
# bundler をインストール
RUN gem install bundler:${BUNDLER_VERSION?} --no-document
# nokogiriをソースからビルドではなくバイナリだけ取ってくるならfalse
ARG BUILD_NOKOGIRI_FROM_SOURCE=false
RUN bundle config set force_ruby_platform ${BUILD_NOKOGIRI_FROM_SOURCE?}

# キャッシュを保存するディレクトリを作成
RUN mkdir -p ${CACHE_MOUNT_PATH?}
# gemをDockerのビルドキャッシュを作成するパスへインストール後、
# コンテナとして実行する際のパスへコピーする
RUN --mount=type=cache,uid=1000,target=${CACHE_MOUNT_PATH?},id=${CACHE_ID?} \
  bundle install && \
  cp -ar ${CACHE_MOUNT_PATH?} ${BUNDLE_PATH_FOR_RUN?}
# gemを読み込む先を実行時に読み込めるパスへ変更
# （この時点でCACHE_MOUNT_PATH内のファイルは空になってしまっている）
ENV BUNDLE_PATH ${BUNDLE_PATH_FOR_RUN?}

# 作業ディレクトリを移動
ARG WORKDIR=/app
WORKDIR ${WORKDIR?}
