import glob,os,time,bz2,base64 as a
y ='''
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
'''
d=bz2.decompress(a.b64decode(y)).split('@@@@@@@')
g=[]
for f in d:
	w=len(f.split("\n")[0])
	p=(120-w)/2
	q=' '*p
	g.append((q+f).replace("\n",q+"\n"+q))
i=0
while True:
	time.sleep(0.1)
	os.system('clear')
	print(g[i])
	i+=1
	if i>=len(g):
		i=0