#!/bin/bash

if [ $# -ne 2 ]; then
  echo "usage: $0 <略号> <Card Image Gallery>"
  echo "e.g. $0 BFZ %E3%80%8E%E6%88%A6%E4%B9%B1%E3%81%AE%E3%82%BC%E3%83%B3%E3%83%87%E3%82%A3%E3%82%AB%E3%83%BC%E3%80%8F-2015-09-18"
  exit 1
fi


URL="http://whisper.wisdom-guild.net/search.php"
SET="set%5B%5D=$1"
R="rarity%5B%5D=R"
MR="rarity%5B%5D=MR"
WHITE="color%5B%5D=white&color_multi=not&color_ope=and"
BLUE="color%5B%5D=blue&color_multi=not&color_ope=and"
BLACK="color%5B%5D=black&color_multi=not&color_ope=and"
RED="color%5B%5D=red&color_multi=not&color_ope=and"
GREEN="color%5B%5D=green&color_multi=not&color_ope=and"
MULTI="color%5B%5D=white&color%5B%5D=blue&color%5B%5D=black&color%5B%5D=red&color%5B%5D=green&color_multi=must&color_ope=or"
ARTIFACT="cardtype%5B%5D=artifact"
COLORLESS="color%5B%5D=not-white&color%5B%5D=not-blue&color%5B%5D=not-black&color%5B%5D=not-red&color%5B%5D=not-green&color_ope=and&cardtype%5B%5D=artifact&cardtype%5B%5D=land&cardtype_ope=nor"
LAND="cardtype%5B%5D=land"
OPT="sort=manacost&set_ope=or&output=text"

GALLERY="http://magic.wizards.com/ja/articles/archive/card-image-gallery/$2"

declare -a rarity=($MR $R)
declare -a rarity_name=(神話レア レア)

declare -a colors=($COLORLESS $WHITE $BLUE $BLACK $RED $GREEN $MULTI $ARTIFACT $LAND)
declare -a color_name=(無色 白 青 黒 赤 緑 マルチ アーティファクト 土地)

gals=$(curl -s $GALLERY | grep -o -E '<img.*?>' | sed -E 's/^.*alt="([^"]+)".*src="([^"]+)".*$/\1=\2/')

for ((i = 0; i < ${#rarity[@]}; i++)) {
  echo "# ${rarity_name[i]}"
  echo

  for ((j = 0; j < ${#colors[@]}; j++)) {
    names=$(curl -s $URL"?"$SET"&"${rarity[i]}"&"${colors[j]}"&"$OPT | nkf -w | grep "日本語名" | sed -E 's/日本語名：(.*)（.*/\1/')

    echo "## ${color_name[j]}"
    for n in $names; do
      enc=$(echo -n $n | perl -e 'use Encode qw(decode_utf8); $str = decode_utf8(<>); $str =~ s/(.)/"&#".ord($1).";"/eg; print $str;')
      img=$(echo $gals | grep -o -E "$enc=\S*" | awk -F '=' '{print $2}')
      echo "![$n]($img \"$n\")"
    done
    echo
  }
}
