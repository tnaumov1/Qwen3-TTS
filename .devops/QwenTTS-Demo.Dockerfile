FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ARG MAX_JOBS=4

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    ffmpeg \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir ninja psutil packaging

RUN pip install --no-cache-dir qwen-tts

RUN wget https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu12torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl

RUN pip install --no-dependencies flash_attn-2.8.3+cu12torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl

FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    ffmpeg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

VOLUME ["/root/.cache/huggingface"]

ENTRYPOINT ["qwen-tts-demo"]
