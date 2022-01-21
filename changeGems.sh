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

echo "Change ${REPOGITORY_PATH}/Gemfile"
echo "\n"

# `fril-engine`と記述のある行を探して、行を修正/削除
# forで回したい
sed -i -e "/fril-engine/c\gem 'fril-engine', path: '~/workspace/rakuma/fril-engine'" "${REPOGITORY_PATH}/Gemfile"
echo "fril-engine   : replaced"
sed -i -e '/ruby-debug-ide/d' "${REPOGITORY_PATH}/Gemfile"
echo "ruby-debug-ide: removed"
sed -i -e '/debase/d' "${REPOGITORY_PATH}/Gemfile"
echo "debase        : removed"
echo "\n"

# customGemfileの記述をGemfileの最終行にコピー
# cat ${PERSONAL_SETTING_PATH}/GemChange/CustomGemfile | sed -n '1, 5p' >> "${REPOGITORY_PATH}/Gemfile"
# echo "complete change Gem setting"

# Gemfile変更とbundle更新
echo "Start   : add Gems & bundle install"
cd ${REPOGITORY_PATH}
# echo "gem 'fril-engine', path: '~/workspace/rakuma/fril-engine'" >> "${REPOGITORY_PATH}/Gemfile"
bundle clean && bundle install --path vendor/bundle
gem install ruby-debug-ide
gem install debase -v '0.2.5.beta2'
echo "\n"
echo "Complete: bundle install"
