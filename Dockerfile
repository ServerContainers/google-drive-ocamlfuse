FROM alpine as builder

ENV OPAMYES=true

RUN apk --no-cache add opam m4 git make \
                       libc-dev ocaml-compiler-libs ocaml-ocamldoc \
                       sqlite fuse3-dev fuse-dev libunwind-dev curl-dev gmp-dev sqlite-dev zlib-dev \
\
&& opam init  --disable-sandboxing  -y \
\
&& opam update \
&& opam install -y ocamlfuse \
&& opam install -y google-drive-ocamlfuse

FROM alpine

COPY --from=builder /root/.opam/default/bin/google-drive-ocamlfuse /bin/google-drive-ocamlfuse

ENV PATH="/container/scripts:${PATH}"

RUN apk add --no-cache bash fuse3 fuse libunwind libgmpxx sqlite-libs libcurl libressl ncurses-libs

COPY . /container/
ENTRYPOINT ["/container/scripts/entrypoint.sh"]

