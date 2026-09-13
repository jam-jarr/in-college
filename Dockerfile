FROM ubuntu:22.04

RUN apt-get update && apt-get install -y gnucobol build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["bash", "-c", "cobc -x -o InCollege InCollege.cob && ./InCollege"]
