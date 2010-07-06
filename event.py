#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2010 András Veres-Szentkirályi
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

from BeautifulSoup import BeautifulSoup
import urllib2
import re
import unicodedata
import sys

def strip_accents(s):
   return ''.join((c for c in unicodedata.normalize('NFD', s) if unicodedata.category(c) != 'Mn'))

try:
	req = urllib2.Request("http://hspbp.org/")
	response = urllib2.urlopen(req)
	soup = BeautifulSoup(response.read())
	event = soup.find(attrs={'class': re.compile(r'\bvevent\b')})

	start = event.find(attrs={'class': re.compile(r'\bdtstart\b')})
	summary = event.find(attrs={'class': re.compile(r'\bsummary\b')})
	title = start['title']
	sum = strip_accents(unicode(summary.string).strip())
	sys.stdout.write(title[0:10] + ' ' + title[11:16] + ' ' + sum)
except:
	pass
