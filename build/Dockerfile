FROM python:3.8 as builder

RUN pip install mkdocs-material

COPY . /go/src/github.com/codelingo/docs
WORKDIR /go/src/github.com/codelingo/docs

RUN mkdocs build --clean

FROM nginx:alpine

USER 0
COPY --from=builder /go/src/github.com/codelingo/docs/site  /usr/share/nginx/html
COPY --from=builder /go/src/github.com/codelingo/docs/build/mkdocs.conf  /etc/nginx/conf.d/

EXPOSE 80
