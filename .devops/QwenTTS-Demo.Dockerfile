FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    wget \
    curl \
    sox \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    torch==2.6.0 torchaudio==2.6.0 \
    --index-url https://download.pytorch.org/whl/cu124

RUN pip install --no-cache-dir qwen-tts

ARG FA_WHEEL=flash_attn-2.8.3+cu12torch2.6cxx11abiTRUE-cp311-cp311-linux_x86_64.whl

RUN wget https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.3/${FA_WHEEL}
RUN pip install --no-dependencies ${FA_WHEEL}
RUN rm -rf ${FA_WHEEL}

VOLUME ["/root/.cache/huggingface"]

ENTRYPOINT ["qwen-tts-demo"]
