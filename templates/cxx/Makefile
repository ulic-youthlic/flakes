main.out: main.o
	$(CXX) -std=c++26 $^ -o $@

main.o: main.cxx
	$(CXX) -std=c++26 -c $^

compile_commands.json: clean
	bear -- make

.PHONY: run clean
run: main
	@echo Run:
	@./main

clean:
	-rm main.out main.o
