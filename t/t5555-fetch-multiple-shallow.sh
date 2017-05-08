#!/bin/sh

test_description='fetch --depth from multiple origins'

. ./test-lib.sh

commit() {
	echo "$1" >tracked &&
	git add tracked &&
	git commit -m "$1"
}

test_expect_success 'setup' '
	commit 1 &&
	commit 2 &&
	commit 3 &&
	commit 4 &&
	git config --global transfer.fsckObjects true
'

test_expect_success 'setup shallow clone' '
	git clone --no-local --depth=1 .git shallow &&
	git --git-dir=shallow/.git log --format=%s >actual &&
	cat <<EOF >expect &&
4
EOF
	test_cmp expect actual
'

test_expect_success 'fetch --depth --multiple' '
	(
	cd shallow &&
	git fetch --depth=2 --multiple origin &&
	git fsck &&
	git log --format=%s origin/master >actual &&
	cat <<EOF >expect &&
4
3
EOF
	test_cmp expect actual
	)
'

test_expect_success 'fetch --depth --all' '
	(
	cd shallow &&
	git fetch --depth=3 --all &&
	git fsck &&
	git log --format=%s origin/master >actual &&
	cat <<EOF >expect &&
4
3
EOF
	test_cmp expect actual
	)
'

test_done
