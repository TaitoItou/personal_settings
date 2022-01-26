#!/bin/sh

# engineについては、既存の行をコメントアウトしてから以下の行を追加するようにしたい
# vscodeのtaskで対象リポジトリのGemfileを一括で変更&bundle installしたい

# 期待するrepgitory以外の場合はvalidationエラーを吐くようにしたい
CORRECT_REPOS=(fril_api fril_web fril-admin)
ERROR=0

function usage() {
  echo "Usege: `basename $0` repogitory"
  echo "e.g.) `basename $0` fril_api"
  exit 1;
}

# 引数のvalidation(空)
if [ $# -lt 1 ]; then
  usage
fi

# 引数のvalidation(リポジトリ)
for i in "${CORRECT_REPOS[@]}"; do
  if [ $1 != ${i} ]; then
    ERROR=$((${ERROR} + 1))
  fi
done

# 引数のvalidationエラー表示
if [ ${ERROR} = 3 ]; then
  usage
fi

WORKSPACE=~/workspace/rakuma
PERSONAL_SETTING_PATH="${WORKSPACE}/.vscode/personal_settings"
REPOGITORY_PATH=${WORKSPACE}/$1
GEMFILE_PATH="${REPOGITORY_PATH}/Gemfile"

echo "Change ${GEMFILE_PATH}"
echo "\n"

# `fril-engine`と記述のある行を探して、行を修正/削除
echo "fril-engine   : start replacing"
sed -i -e "/fril-engine/c\gem 'fril-engine', git: 'https://github.com/Fablic/fril-engine.git', path: '~/workspace/rakuma/fril-engine'" ${GEMFILE_PATH}
(cd ${REPOGITORY_PATH} && bundle update --conservative fril-engine)
echo "fril-engine   : complete replacing"
echo "\n"

sed -i -e '/ruby-debug-ide/d' ${GEMFILE_PATH}
echo "gem 'ruby-debug-ide'" >> ${GEMFILE_PATH}
sed -i -e '/debase/d' ${GEMFILE_PATH}
echo "gem 'debase', '~> 0.2.5.beta2'" >> ${GEMFILE_PATH}

(cd ${REPOGITORY_PATH} && bundle install --path vendor/bundle)
echo "\n"
echo "ruby-debug-ide: added"
echo "debase        : added"
echo "\n"

echo "Complete: bundle install"
