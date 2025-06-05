FROM busybox

# Copy only the dist directory
COPY dist/ /ebpf