#!/usr/bin/env python3

"""text.py: Helper script to do text analysis and transformation."""
import re

with open('../Quijotica/texts/don_quixote.txt','r') as text:
    for line in text:
        for word in re.compile('\w+').findall(line):
            print(word)
