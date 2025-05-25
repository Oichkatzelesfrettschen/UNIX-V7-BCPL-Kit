#include "helpers.h"
#include <fcntl.h>
#include <unistd.h>
#include <stdexcept>

namespace capnp_helpers {

void writeMessageToFile(::capnp::MessageBuilder& builder, const std::string& path) {
    int fd = open(path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) throw std::runtime_error("open failed");
    ::capnp::writePackedMessageToFd(fd, builder);
    close(fd);
}

::capnp::MallocMessageBuilder readMessageFromFile(const ::capnp::StructSchema& schema,
                                                  const std::string& path) {
    int fd = open(path.c_str(), O_RDONLY);
    if (fd < 0) throw std::runtime_error("open failed");
    ::capnp::PackedFdMessageReader reader(fd);
    ::capnp::MallocMessageBuilder builder;
    auto dst = builder.initRoot<capnp::DynamicStruct>(schema);
    auto src = reader.getRoot<capnp::DynamicStruct>(schema);
    dst.copyFrom(src);
    close(fd);
    return builder;
}

} // namespace capnp_helpers
