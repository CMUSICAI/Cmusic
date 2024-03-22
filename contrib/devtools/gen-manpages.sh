#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

CMUSICAID=${CMUSICAID:-$SRCDIR/cmusicaid}
CMUSICAICLI=${CMUSICAICLI:-$SRCDIR/cmusicai-cli}
CMUSICAITX=${CMUSICAITX:-$SRCDIR/cmusicai-tx}
CMUSICAIQT=${CMUSICAIQT:-$SRCDIR/qt/cmusicai-qt}

[ ! -x $CMUSICAID ] && echo "$CMUSICAID not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
cmusicaiVER=($($CMUSICAICLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for cmusicaid if --version-string is not set,
# but has different outcomes for cmusicai-qt and cmusicai-cli.
echo "[COPYRIGHT]" > footer.h2m
$CMUSICAID --version | sed -n '1!p' >> footer.h2m

for cmd in $CMUSICAID $CMUSICAICLI $CMUSICAITX $CMUSICAIQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${cmusicaiVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${cmusicaiVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
