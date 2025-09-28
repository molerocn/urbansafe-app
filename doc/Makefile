SRC_DIR := diagrams
DIST_DIR := images/diagrams

DRAWIO_FILES := $(wildcard $(SRC_DIR)/*.drawio)
OUT_FILES := $(patsubst $(SRC_DIR)/%.drawio, $(DIST_DIR)/%.png, $(DRAWIO_FILES))

diagrams: clean_pngs $(OUT_FILES)

$(DIST_DIR)/%.png: $(SRC_DIR)/%.drawio
	@mkdir -p $(DIST_DIR)
	@drawio -x -f png $< -o $@

.PHONY: clean_pngs
clean_pngs:
	@rm -f $(DIST_DIR)/*.png

build:
	@typst compile main.typ dist/integrador.pdf

run: build
	@xdg-open dist/integrador.pdf
