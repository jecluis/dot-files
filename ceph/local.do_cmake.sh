
do_commits=false
do_week=true
do_day=false
do_kept=false
do_update_kept_date=false
do_export=false

while [[ $# -gt 0 ]]; do

  case $1 in
    -k|--use-kept-date)
      do_kept=true
      ;;
    -u|--update-date)
      do_update_kept_date=true
      ;;
    -w|--week)
      do_week=true
      do_day=false
      ;;
    -d|--day)
      do_week=false
      do_day=true
      ;;
    --with-commits)
      do_commits=true
      ;;
    -h|--help)
      cat << EOF
usage: $0 [options]

 options:
  -k | --keep            keep used date (may have kinks)
  -e | --use-existing    use existing kept date
  -w | --week            build using a cache TTL of one week
  -d | --day             build using a cache TTL of one day
       --with-commits    build considering git commits (rebuilds often)
  -h | --help            this message

EOF
      exit 0
      ;;
  esac
  shift
done


# just keeps the cache for a day
#   adjust if you think you may need more than a day

base_date=""
$do_week && base_date="-dmonday"

if $do_kept ; then
  if [[ ! -e "$HOME/.ccache-kept-date" ]]; then
    echo "no previously kept date, ignore -k; a new date will be saved."
  else
    kept_date=$(cat $HOME/.ccache-kept-date)
    if [[ -z "$kept_date" ]]; then
      echo "kept date is empty, removing file"
      rm ~/.ccache-kept-date
    else
      base_date="--utc --date=@${kept_date}"
      echo "using kept date: ${kept_date}, $(date $base_date +%D)"
    fi
  fi
fi

src_date_epoch=$(date $base_date +%D |date -f- +%s)
bld_date=$(date --utc --date=@${src_date_epoch} +%Y-%m-%d)

echo "src date epoch: $src_date_epoch"
echo "      bld date: $bld_date"

if $do_update_kept_date; then
  echo $src_date_epoch > $HOME/.ccache-kept-date
  echo "kept date epoch $src_date_epoch in $HOME/.ccache-kept-date"
fi

if $do_update_kept_date; then
cat >> $HOME/.ccache-kept-exports << EOF
export SOURCE_DATE_EPOCH=$src_date_epoch
export BUILD_DATE=$bld_date
EOF
fi

source $HOME/.ccache-kept-exports

extra_opts="-DENABLE_GIT_VERSION=no"
$do_commits && extra_opts="$extra_opts -DENABLE_GIT_VERSION=yes"

./do_cmake.sh \
  -DWITH_LTTNG=no -DWITH_BABELTRACE=no -DWITH_MANPAGE=no \
  $extra_opts
