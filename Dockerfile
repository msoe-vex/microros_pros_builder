FROM microros/micro_ros_static_library_builder:humble

RUN mkdir -p /uros_ws/build

COPY library_generation.sh /uros_ws/library_generation.sh

ENTRYPOINT ["bash", "./library_generation.sh"]
