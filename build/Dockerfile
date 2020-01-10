############################
# STEP 1 build executable binary
############################
FROM golang@sha256:25a6e3dfe35e1099ce674b1e4c2a1fbe1acf612f2989277e207489bb04c13a6f as builder
# Install git + SSL ca certificates.
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
RUN apk update && apk add --no-cache git ca-certificates tzdata make && update-ca-certificates

# Create appuser
RUN adduser -D -u 1001 -g '' secret-sync-operator
WORKDIR $GOPATH/src/github.com/menta2l/secret-sync-operator

COPY . .
# Using go get.
#RUN go get -d -v
# Fetch dependencies.
# Using go mod with go 1.11
#RUN GO111MODULE=on go mod download
#RUN cd $GOPATH/src/github.com/menta2l/secret-sync-operator/cmd/manager && GO111MODULE=on GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="-w -s" -tags netgo -installsuffix netgo -o /go/bin/secret-sync-operator 
RUN make build
RUN cp ./build/bin/amd64/secret-sync-operator /go/bin/secret-sync-operator 
RUN chmod 777 /go/bin/secret-sync-operator 

############################
# STEP 2 build a small image
############################
FROM scratch
# Import from builder.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
# Copy our static executable
COPY --from=builder  /go/bin/secret-sync-operator /go/bin/secret-sync-operator
 
ENV OPERATOR=/go/bin/secret-sync-operator \
    USER_UID=1001 \
    USER_NAME=secret-sync-operator

# Use an unprivileged user.
#USER appuser
# Run the hello binary.
ENTRYPOINT ["/go/bin/secret-sync-operator"]
