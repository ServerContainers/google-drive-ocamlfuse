FROM alpine as builder

ENV OPAMYES=true

RUN apk --no-cache add opam m4 git make \
                       libc-dev ocaml-compiler-libs ocaml-ocamldoc \
                       sqlite fuse3-dev fuse-dev libunwind-dev curl-dev gmp-dev sqlite-dev zlib-dev \
\
# pin ocaml 4.14 - ocaml 5 dropped native 32bit codegen so armv6/v7 would break
&& opam init  --disable-sandboxing  -y --compiler=ocaml-base-compiler.4.14.2 \
\
&& opam update \
&& opam install -y --no-depexts ocamlfuse \
&& opam install -y --no-depexts google-drive-ocamlfuse

FROM alpine

COPY --from=builder /root/.opam/ocaml-base-compiler.4.14.2/bin/google-drive-ocamlfuse /bin/google-drive-ocamlfuse

ENV PATH="/container/scripts:${PATH}"

RUN apk add --no-cache bash fuse3 fuse libunwind libgmpxx sqlite-libs libcurl libressl ncurses-libs

COPY . /container/
ENTRYPOINT ["/container/scripts/entrypoint.sh"]

