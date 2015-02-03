#!/bin/sh
#
#
#

skip=$1

version=2.8.0-SNAPSHOT
version=2.8.0.JETTY9-SNAPSHOT
version=2.8.0.VCM-SNAPSHOT
# Compute working folder
snapshots=`dirname $0`
cd $snapshots
snapshots=`pwd`

# Check that gwt and tools are in place
gwt=$snapshots/../trunk
[ ! -d $gwt ] && gwt=$snapshots/../gwt
[ ! -d $gwt ] && echo "GWT sources not found: $gwt" && exit 1
[ ! -d $gwt/maven ] && echo "Invalid gwt trunk folder: $gwt" && exit 1
tools=$snapshots/../tools
[ ! -d $tools ] && echo "TOOLS not found: $tools" && exit 1

# Update tools
[ -z "$skip" ] && (cd $tools && git pull origin master)

# Update Gwt
cd $gwt || exit 1
[ -z "$skip" ] && git pull
# Use a tmp folder as local repo
rm -rf tmp && mkdir -p tmp
export GWT_MAVEN_REPO_URL=file://$PWD/tmp GWT_VERSION=$version
# Compile gwt
[ -z "$skip" ] && (ant clean elemental dist-dev || exit 1)
# Install artifacts locally
yes "" | maven/push-gwt.sh || exit 1
(cd tmp && tar cf /tmp/gwt.tar com)

# Update our snapshot git repo
cd $snapshots || exit 1
find . -name $GWT_VERSION -exec rm -rf '{}' ';' >/dev/null 2>&1
tar xf /tmp/gwt.tar || exit 1
git add . --all || exit 1
# use ammend so as the repo does not grow
git commit --amend -m 'Update Snapshot' -a || exit 1
git gc
git push origin master -f || exit 1

# remove temporary stuff
rm -rf /tmp/gwt.tar $gwt/tmp
