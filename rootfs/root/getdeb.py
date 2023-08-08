#!/usr/bin/python3

import requests
from bs4 import BeautifulSoup
from pathlib import Path

def go (theURL : str):
    arch = Path('arch.txt').read_text().split('\n')[0]
    response = requests.get(theURL)
    soup = BeautifulSoup(response.text,features="lxml")
    links = [str(a['href']) for a in soup.find_all('a')]
    linkFilter = [a for a in links if arch in a]
    if not linkFilter:
        raise Exception (f'{theURL} : no download found for {arch}')
    linkFilter.sort(key=lambda name: name.split('.')[-3:], reverse=True)
    debURL = '/'.join((theURL,linkFilter[0]))
    # print (f"# theURL : {debURL}")
    fname = '/tmp/msedge.deb'
    response = requests.get(debURL, stream=True)
    with open(fname, 'wb') as f:
        for chunk in response.iter_content(chunk_size=1024): 
            if chunk:
                f.write(chunk)

if __name__ == '__main__':
    go ("https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable")