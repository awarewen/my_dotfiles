# rsync own dotfiles config

# 目标目录
DEST_DIR="${HOME}/Documents/my_dotfiles/"

# 源目录
SRC_IN_CONF=${HOME}/.config/
SRC_IN_HOME=${HOME}/

# ==================== List in $HOME ====================
HOME_LIST=(
           )

# ==================== List in $HOME/.config ====================
CONF_LIST=(
         )

SRC=$SRC_IN_HOME$HOME_LIST
SRC=$SRC_IN_CONF$CONF_LIST
LIST=$HOME_LIST
DEST=$DEST_DIR


# Function start
rsync-config-mirror(){

## 检测目标目录是否存在
if [[ ! -d $DEST_DIR ]]; then
  echo "Not Found $DEST_DIR,mkdir -p $DEST_DIR"
  command mkdir -p $DEST_DIR
fi

## 开始备份
  echo "开始备份 \"$SRC/\{$LIST\}\" ..."
  for list in $LIST
  do
  rsync -aHOxzvi --delete-after $SRC/ $DEST
  done
  echo "Done \"$SRC/\{$LIST\}\" ."

}
