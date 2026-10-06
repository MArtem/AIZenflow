import pathlib,subprocess,json,os,sys,time
root=pathlib.Path(__file__).resolve().parent;stage=sys.argv[1];mode=sys.argv[2]
phones=[('18.2','BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'),('27.0','2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]
if mode=='before':phones=phones[:1]
app=root/stage/'TabDescriptionLocalizationProbe.app';base=json.loads((root/stage/'invocation.json').read_text());env=os.environ.copy();env.update(base['environment']);simctl='/Applications/Xcode.app/Contents/Developer/usr/bin/simctl'
failed=False
for version,udid in phones:
 out=root/stage/('runtime-'+version);out.mkdir(exist_ok=False)
 def sim(a):return subprocess.run([simctl,*a],env=env,capture_output=True,text=True,timeout=90)
 boot=sim(['boot',udid]);assert boot.returncode==0 or 'current state: Booted' in boot.stderr,boot.stderr
 ready=sim(['bootstatus',udid,'-b']);assert ready.returncode==0,ready.stderr
 results=[]
 try:
  for lang in (['en'] if mode=='before' else ['en','ru']):
   args=[simctl,'spawn',udid,str(app/'TabDescriptionLocalizationProbe'),lang,'-AppleLanguages','('+lang+')','-AppleLocale',lang+'_US' if lang=='en' else 'ru_RU']
   (out/(lang+'-invocation.json')).write_text(json.dumps({'args':args,'environment':base['environment'],'runtime':version,'udid':udid,'harness_inputs':base['input_sha256']},indent=2)+'\n')
   start=time.time()
   try:p=subprocess.run(args,env=env,capture_output=True,text=True,timeout=30)
   except subprocess.TimeoutExpired as e:p=subprocess.CompletedProcess(args,124,e.stdout or '',e.stderr or '')
   (out/(lang+'-stdout.log')).write_text(p.stdout);(out/(lang+'-stderr.log')).write_text(p.stderr)
   result={'language':lang,'exit_code':p.returncode,'elapsed_seconds':round(time.time()-start,2),'stdout':p.stdout[:1500],'stderr':p.stderr[:1200]};results.append(result)
   print(json.dumps({'runtime':version,**result}),flush=True)
   if p.returncode:failed=True
 finally:
  shutdown=sim(['shutdown',udid]);(out/'shutdown.json').write_text(json.dumps({'exit_code':shutdown.returncode,'stderr':shutdown.stderr},indent=2)+'\n');assert shutdown.returncode==0,shutdown.stderr
 (out/'result.json').write_text(json.dumps(results,indent=2)+'\n')
# Before patch is an expected failing observation, not a passing test run.
sys.exit(1 if failed else 0)
