set -e

mkdir test
INPUT="load(':foo.bzl', 'foo'); foo(tags=['b', 'a'],srcs=['d', 'c'])"  # formatted differently in build and bzl modes
echo -e "$INPUT" > test/BUILD
echo -e "$INPUT" > test/test.bzl

$1 < test/BUILD > stdout
$1 test/* && exit 3 # expect non-zero buildifier exit due to re-format
$2 test/test.bzl > test/test.bzl.out

cat > test/BUILD.golden <<EOF
load(":foo.bzl", "foo")

foo(
    srcs = [
        "c",
        "d",
    ],
    tags = [
        "a",
        "b",
    ],
)
EOF
cat > test/test.bzl.golden <<EOF
load(":foo.bzl", "foo")

foo(tags = ["b", "a"], srcs = ["d", "c"])
EOF

diff test/BUILD test/BUILD.golden
diff test/test.bzl test/test.bzl.golden
diff stdout test/BUILD.golden  # should use the build formatting mode by default

diff test/test.bzl.out test/test.bzl.golden

