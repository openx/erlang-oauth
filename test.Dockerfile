FROM erlang:22
COPY . /code
WORKDIR /code
RUN make compile
RUN make test