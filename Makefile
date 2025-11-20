.PHONY: all clean

OPENSCAD = openscad
SCAD_FILE = rugged-box.scad

STL_FILES = bottom.stl top.stl latch.stl

all: $(STL_FILES)

bottom.stl: $(SCAD_FILE) rugged-box-library.scad
	$(OPENSCAD) -o $@ -D 'flashlight_box("bottom");' $(SCAD_FILE)

top.stl: $(SCAD_FILE) rugged-box-library.scad
	$(OPENSCAD) -o $@ -D 'flashlight_box("top");' $(SCAD_FILE)

latch.stl: $(SCAD_FILE) rugged-box-library.scad
	$(OPENSCAD) -o $@ -D 'flashlight_box("latch");' $(SCAD_FILE)

clean:
	rm -f $(STL_FILES)
