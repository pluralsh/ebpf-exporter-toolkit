FROM ubuntu:22.04 AS libbpf_builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates gcc make pkg-config libelf-dev

COPY ./ /build/ebpf_exporter

RUN make -j $(nproc) -C /build/ebpf_exporter libbpf.a && \
    tar -C /build/ebpf_exporter/libbpf/dest -czf /build/libbpf.tar.gz .

FROM ubuntu:22.04 AS bpf_builder

# Install dependencies for building eBPF programs
RUN apt-get update && \
    apt-get install -y clang make

COPY --from=libbpf_builder /build/ebpf_exporter/libbpf /build/ebpf_exporter/libbpf

COPY ./ /build/ebpf_exporter

RUN make -j $(nproc) -C /build/ebpf_exporter/src CC=clang