CXXFLAGS=-O2 -std=c++20
LDLIBS=-lcapnp_helpers -lcapnp -lkj

all: capnpdemo

capnpdemo: demo.o example.capnp
capnp compile -oc++ example.capnp
$(CXX) $(CXXFLAGS) -c demo.cpp
$(CXX) $(CXXFLAGS) -o capnpdemo demo.o $(LDLIBS)

cp: all
cp capnpdemo /bin/capnpdemo
rm -f capnpdemo demo.o example.capnp.c++ example.capnp.h

cmp: all
cmp capnpdemo /bin/capnpdemo
rm -f capnpdemo demo.o example.capnp.c++ example.capnp.h

clean:
rm -f capnpdemo demo.o example.capnp.c++ example.capnp.h
