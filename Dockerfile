FROM alpine:latest as builder

ENV OPAMYES=true

RUN apk --no-cache add opam m4 git make \
                       libc-dev ocaml-compiler-libs ocaml-ocamldoc \
\
&& opam init  --disable-sandboxing  -y \
\
&& opam update \
&& opam install -y depext \
&& opam depext -y google-drive-ocamlfuse \
&& opam install -y google-drive-ocamlfuse

FROM alpine:latest

COPY --from=builder /root/.opam/default/bin/google-drive-ocamlfuse /bin/google-drive-ocamlfuse

ENV PATH="/container/scripts:${PATH}"

RUN apk add --no-cache fuse libgmpxx sqlite-libs libcurl libressl ncurses-libs

COPY . /container/
ENTRYPOINT ["/container/scripts/entrypoint.sh"]

