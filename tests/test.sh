#!/bin/sh

BINI=../bini
UNBINI=../unbini

fail=0
total=0

# Test valid inputs
for ini in valid/*; do
    $BINI $ini 1>/dev/null 2>/dev/null && true;
    case $? in
        0)  ;; # expected
        1)  printf 'rejected: %s\n' $ini 1>&2
            fail=$((fail + 1))
            ;;
        *)  printf 'crashing input: %s\n' $ini 1>&2
            fail=$((fail + 1))
            ;;
    esac
    total=$((total + 1))
done

# Test idompotency of valid inputs
for ini in valid/*; do
    hash0=$($BINI $ini | sha1sum)
    hash1=$($BINI $ini | $UNBINI | $BINI | sha1sum)
    if [ ! "$hash0" = "$hash1" ]; then
        printf 'not idempotent: %s\n' $ini 1>&2
        fail=$((fail + 1))
    fi
    total=$((total + 1))
done

# Test invalid inputs
for ini in invalid/*; do
    $BINI $ini 1>/dev/null 2>/dev/null && true;
    case $? in
        0)  printf 'not rejected: %s\n' $ini 1>&2
            fail=$((fail + 1))
            ;;
        1)  ;; # expected
        *)  printf 'crashing input: %s\n' $ini 1>&2
            fail=$((fail + 1))
            ;;
    esac
    total=$((total + 1))
done

# Print test report
if [ $fail -eq 0 ]; then
    printf '\033[1;92mPASS\033[0m'
    code=0
else
    printf '\033[1;91mFAIL\033[0m'
    code=1
fi
printf ': %d / %d\n' $((total - fail)) $total
exit $code
