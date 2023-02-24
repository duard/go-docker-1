# base image
FROM golang:1.19.3-alpine AS builder
# create appuser
RUN adduser -D -g '' elf
# create workspace
WORKDIR /opt/app/
COPY go.mod  ./
# fetch dependancies
RUN go mod download && \
    go mod verify
# copy the source code as the last step
COPY . .
# build binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/simples-users ./cmd/app
EXPOSE 8080/tcp
EXPOSE 8081/udp


# build a small image
FROM alpine:3.17.0
LABEL language="golang"
LABEL org.opencontainers.image.source https://github.com/mmorejon/microservices-docker-go-mongodb
# import the user and group files from the builder
COPY --from=builder /etc/passwd /etc/passwd
# copy the static executable
COPY --from=builder --chown=elf:1000 /go/bin/simples-users /simples-users
# use a non-root user
USER elf
# run app
ENTRYPOINT ["./simples-users"]
