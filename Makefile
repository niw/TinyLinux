NAME = TinyLinux

BUILD_PATH = .build

XCODE_PROJECT_PATH = $(NAME).xcodeproj
XCODE_SCHEME = $(NAME)
XCODE_ARCHIVE_PATH = $(BUILD_PATH)/$(NAME).xcarchive

.PHONY: all
all: build

.PHONY: claen
clean:
	git clean -dfX

.PHONY: build
build:
	xcodebuild \
		-project "$(XCODE_PROJECT_PATH)" \
		-scheme "$(XCODE_SCHEME)" \
		-derivedDataPath "$(BUILD_PATH)" \
		-archivePath "$(XCODE_ARCHIVE_PATH)" \
		archive
