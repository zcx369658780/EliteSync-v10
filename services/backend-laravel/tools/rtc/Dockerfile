# Reuse an existing approved Python runtime; replace the SFU with the pinned image.
ARG LIVEKIT_IMAGE
ARG PYTHON_IMAGE
FROM ${LIVEKIT_IMAGE} AS sfu
FROM ${PYTHON_IMAGE}
COPY --from=sfu /livekit-server /usr/local/bin/livekit-server
COPY rtc_gateway.py /opt/current-rtc-gateway.py
COPY rtc_watchdog.py /opt/current-rtc-watchdog.py
ENTRYPOINT ["python", "-u", "/opt/current-rtc-gateway.py"]
