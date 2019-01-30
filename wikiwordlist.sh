#!/bin/bash

DATEFILE=$(date +%Y%m%d)

#location of the prep folder
cd /mnt/s/Wordlists/prep

if [[ $# -eq 0 ]] ; then
    echo 'No file date specified, using todays date'
	today=$DATEFILE
else 
	today=$1
fi
echo "looking for $today in dump file"

if wget -q --show-progress http://wikimedia.bytemark.co.uk/enwiki/$today/enwiki-$today-pages-articles.xml.bz2; then
		echo  "downloaded enwiki-$today-pages-articles.xml.bz2"
	else
		echo "there is no file for $today. append the date from wikimedia.bytemark.co.uk/enwiki/ to the script to download an alternative"
	exit 1
fi

echo unzipping downloaded file 
#zip2 -d enwiki-20190101-pages-articles.xml.bz2
bzip2 -d enwiki-$today-pages-articles.xml.bz2
XMLFILE=$(ls enwiki*)

echo "Splitting File "$XMLFILE" ...."
if [ -d wikitmp ]; then
	rm -rf wikitmp
fi

if [ ! -d wikitmp ]; then
	mkdir wikitmp
fi

split -l 300000 $XMLFILE wikitmp/wiki_
echo ""

cd wikitmp

echo making all spaces into linefeeds
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 's/\s+/\n/g' wiki_*

#echo "Removing words with a digit"
#/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 's/\S*\d+\S*//g' wiki_*
#the reverse of above perl -pi -e 's/\b[^\d\W]+\b//g' wiki_*
#echo ""

echo "Removing non Alpha Characters"
#might want to remove all characters 
#perl -pi -e 's/[\W_$\[\]]+/\n/g' wiki_*
#this removes the whole word including the digit
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 's/\w*([^\w\s]|\d)+\w* ?//g' wiki_*
echo ""

echo "Removing long words"
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 's/.{31,}//g' wiki_*
echo ""

echo "Mutating UC to LC"
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 'tr/A-Z/a-z/' wiki_*
echo ""

echo "Removing words less than 3 characters long"
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e 's/\b.{1,3}\b//g' wiki_*
echo ""



echo "Removing words without vowels"
/usr/bin/time --format=' \n---- \nelapsed time is %e' perl -pi -e "s/\b[^aeiouy]*\b//g" wiki_*
echo ""

echo "Removing words with more than two consecutive letters"



echo "Merging wordlist out 2x directories"
sort -u -S 30% wiki_* > wikiwordlist.lst
sort -u wikiwordlist.lst ../../wikiwordlist.lst -o ../../wikiwordlist.lst
cd ..
echo ""

echo "Cleaning temporary file"
rm -rf wikitmp
echo ""

echo "Operation Completed"
echo "WordLists Dictionary wikiwordlist.lst Succesfully Created."
echo "You must delete the downloaded file yourself"

