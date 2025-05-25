#include <capnp/schema-parser.h>
#include <capnp/dynamic.h>
#include <iostream>
#include "../libcapnp_helpers/helpers.h"

static const char PERSON_SCHEMA[] = R"(
struct Person {
  id @0 :UInt32;
  name @1 :Text;
}
)";

int main() {
    capnp::SchemaParser parser;
    auto schema = parser.parseFromString(PERSON_SCHEMA).getNested("Person");

    capnp::MallocMessageBuilder message;
    auto person = message.initRoot<capnp::DynamicStruct>(schema);
    person.set("id", 42);
    person.set("name", "Alice");

    capnp_helpers::writeMessageToFile(message, "person.bin");

    auto loaded = capnp_helpers::readMessageFromFile(schema, "person.bin");
    auto loadedPerson = loaded.getRoot<capnp::DynamicStruct>(schema);
    std::cout << "id=" << loadedPerson.get("id").as<uint32_t>()
              << " name=" << loadedPerson.get("name").as<kj::StringPtr>() << std::endl;
    return 0;
}
