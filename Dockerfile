ARG RUNPOD_BASE_TAG=5.7.1-base
FROM runpod/worker-comfyui:${RUNPOD_BASE_TAG}

# Volume-first strategy:
# do not bake models into the image. Models are expected on the attached network
# volume under /runpod-volume/models/...

# Ensure ComfyUI loads model paths from the attached RunPod volume.
COPY src/extra_model_paths.yaml /comfyui/extra_model_paths.yaml
