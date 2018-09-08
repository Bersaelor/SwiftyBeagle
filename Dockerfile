FROM ibmcom/kitura-ubuntu:latest

MAINTAINER konrad@tactica.de

WORKDIR /app

COPY Package.swift ./
COPY Sources ./Sources
COPY Views ./Views
COPY static ./static
COPY Tests ./Tests

RUN swift package resolve
RUN swift build

ENV PATH ${PATH}:/app/.build/debug

ENTRYPOINT [ "/app/.build/debug/SwiftyBeagle" ]
CMD [ "live" ]
