#! /bin/sh

PROG_NAME=$(basename $0)
COPY_SLINTEGRATIONTEST_TEMPLATE=false;

while getopts d OPTION
do
    case ${OPTION} in
        d) COPY_SLINTEGRATIONTEST_TEMPLATE=true;;
      [?]) echo >&2 "Usage: ./${PROG_NAME} [ -d ]"
           exit 2;;
    esac
done

TEMPLATE_DIR="${HOME}/Library/Developer/Xcode/Templates/File Templates/Subliminal"
mkdir -p "${TEMPLATE_DIR}"

cp -r "./Subliminal/Integration test class.xctemplate" "${TEMPLATE_DIR}"
if $COPY_SLINTEGRATIONTEST_TEMPLATE; then
	cp -r "./Subliminal/Subliminal Integration test class.xctemplate" "${TEMPLATE_DIR}"
fi
