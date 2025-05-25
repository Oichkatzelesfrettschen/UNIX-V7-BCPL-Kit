#pragma once
#include <capnp/dynamic.h>
#include <capnp/serialize-packed.h>
#include <string>

namespace capnp_helpers {

void writeMessageToFile(::capnp::MessageBuilder& builder, const std::string& path);
::capnp::MallocMessageBuilder readMessageFromFile(const ::capnp::StructSchema& schema,
                                                  const std::string& path);

} // namespace capnp_helpers
