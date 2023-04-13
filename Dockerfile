FROM golang:1.20-buster AS build

WORKDIR /usr/build

COPY go.mod go.sum ./
RUN go mod download

ARG version
RUN echo $version

COPY . .
RUN GOOS=linux GOARCH=amd64 make "version=$version"

FROM debian:buster-slim

RUN apt update && \
  apt install -y ffmpeg ca-certificates && \
  apt clean && apt autoclean
RUN	ffmpeg -version \
  && update-ca-certificates

WORKDIR /usr/app

RUN mkdir ./out
COPY --from=build /usr/build/jsfiddle ./jsfiddle
COPY --from=build /usr/build/webrtmp ./

ENTRYPOINT [ "./webrtmp" ]
