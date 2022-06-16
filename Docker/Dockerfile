FROM julia

RUN apt-get update && apt-get install -y git qt5-default xvfb && git clone https://github.com/DanielRivasMD/MindReader.jl && git clone https://github.com/DanielRivasMD/HiddenMarkovModelReaders.jl
RUN julia --project=/MindReader/ -e 'import Pkg; Pkg.develop(path="../HiddenMarkovModelReaders"); Pkg.instantiate()'
COPY run_script.sh /
MAINTAINER Evgeny Akkuratov <akkuratov.evgeny@gmail.com>

ENTRYPOINT ["/bin/bash"]
