SOURCES = acoustic.c
OBJS = $(SOURCES:%.cpp=%.o)
DEPS = $(SOURCES:%.c=%.d)
OUTFILE = acoustic
LIBS = -lpthread -lrt -lm -lbluetooth -lasound `pkg-config --libs libgps`
CFLAGS = -march=armv8-a -mtune=cortex-a53 -mfpu=vfpv4 -O3 -MMD -g -Wall
LDFLAGS =
CC = gcc

$(OUTFILE): $(SOURCES)
	$(CC) $(LDFLAGS) $(CFLAGS) -o $(OUTFILE) $^ $(LIBS)

-include $(DEPS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(OUTFILE) $(OBJECTS) $(DEPS)

.PHONY: cleanlogs
cleanlogs:
	rm -f logfile.*.txt recording.*.pcm recording.*.wav

.PHONY: install
install: $(OUTFILE)
	sudo mkdir -p /opt/emvia/bin/
	sudo mkdir -p /opt/emvia/out/
	sudo chmod -R a+rwx /opt/emvia/
	sudo cp $(OUTFILE) /opt/emvia/bin/
	sudo cp scripts/pcm2wav.sh /opt/emvia/bin/
	sudo cp scripts/acoustic.service /etc/systemd/system/
	sudo systemctl daemon-reload
	sudo systemctl enable acoustic

.PHONY: uninstall
uninstall:
	sudo systemctl stop acoustic
	sudo systemctl disable acoustic
	sudo rm -f /etc/systemd/system/acoustic.service
	sudo systemctl daemon-reload
	sudo rm -f /opt/emvia/bin/acoustic
	sudo rm -f /opt/emvia/bin/pcm2wav.sh

