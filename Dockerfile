ARG RUNPOD_BASE_TAG=5.7.1-base
FROM runpod/worker-comfyui:${RUNPOD_BASE_TAG}

# Volume-first strategy:
# do not bake models into the image. Models are expected on the attached network
# volume under /runpod-volume/models/...
