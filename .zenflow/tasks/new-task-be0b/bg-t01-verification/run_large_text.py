import hashlib,json,os,pathlib,subprocess,sys,time
root=pathlib.Path(__file__).resolve().parent
base=json.loads((root/'ui-iphone/invocation.json').read_text())
devices=json.loads((root/'owned-simulators.json').read_text())
indices=[int(x) for x in sys.argv[1:]]
any_failed=False
for index in indices:
 d=devices[index]; key=d['family'].lower()+'-'+d['runtime_version'].replace('.','-')
 out=root/'large-text'/key
 out.mkdir(parents=True,exist_ok=False)
 build=root/'matrix/build'
 args=[a.replace(str(root/'ui-iphone'),str(build)) for a in base['args']]
 args[args.index('-only-testing:BattleshipGameUITests')]='-only-testing:BattleshipGameUITests/BoardInteractionTests/testLargeTextControlsAndBoardActions'
 args[args.index('-destination')+1]='platform=iOS Simulator,id='+d['udid']
 args[args.index('-resultBundlePath')+1]=str(out/'result.xcresult')
 env=os.environ.copy()
 isolated={k:v.replace(str(root/'ui-iphone'),str(build)) for k,v in base['isolated_environment'].items()}
 env.update(isolated)
 for value in isolated.values(): pathlib.Path(value).mkdir(parents=True,exist_ok=True)
 inputs={p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest() for p in base['input_sha256']}
 invocation={'args':args,'isolated_environment':isolated,'device':d,'input_sha256':inputs,'grant':'User delegates tests/builds; Simulator-only outside exception; mandatory iOS18.2 + iOS27'}
 (out/'invocation.json').write_text(json.dumps(invocation,indent=2)+'\n')
 simctl='/Applications/Xcode.app/Contents/Developer/usr/bin/simctl'
 def sim(arguments):
  return subprocess.run([simctl,*arguments],env=env,text=True,capture_output=True,timeout=120)
 boot=sim(['boot',d['udid']])
 if boot.returncode and 'current state: Booted' not in boot.stderr: raise RuntimeError(boot.stderr)
 ready=sim(['bootstatus',d['udid'],'-b'])
 if ready.returncode: raise RuntimeError(ready.stderr)
 original=sim(['ui',d['udid'],'content_size'])
 if original.returncode: raise RuntimeError(original.stderr)
 previous=original.stdout.strip()
 setting=sim(['ui',d['udid'],'content_size','accessibility-extra-extra-extra-large'])
 if setting.returncode: raise RuntimeError(setting.stderr)
 observed=sim(['ui',d['udid'],'content_size'])
 if observed.returncode or observed.stdout.strip()!='accessibility-extra-extra-extra-large': raise RuntimeError('Required AX5 size not observed')
 text_receipt={'original':previous,'selected':observed.stdout.strip(),'runtime':d['runtime_version'],'restored':False}
 (out/'text-size.json').write_text(json.dumps(text_receipt,indent=2)+'\n')
 print('START AX5 '+key,flush=True); t=time.time()
 try:
  with (out/'build-test.log').open('w') as log: result=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=600)
 finally:
  after=sim(['ui',d['udid'],'content_size']);text_receipt['after_test']=after.stdout.strip()
  restored=sim(['ui',d['udid'],'content_size',previous]);confirm=sim(['ui',d['udid'],'content_size'])
  text_receipt['restored']=restored.returncode==0 and confirm.returncode==0 and confirm.stdout.strip()==previous
  (out/'text-size.json').write_text(json.dumps(text_receipt,indent=2)+'\n')
  if not text_receipt['restored']: raise RuntimeError('Cannot confirm owned Simulator text setting restored')
 receipt={'exit_code':result.returncode,'elapsed_seconds':round(time.time()-t,2),'inputs_unchanged':all(hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()==h for p,h in inputs.items())}
 (out/'result.json').write_text(json.dumps(receipt,indent=2)+'\n')
 summary=subprocess.run(['xcrun','--no-cache','xcresulttool','get','test-results','summary','--path',str(out/'result.xcresult')],env=env,text=True,capture_output=True)
 (out/'summary.json').write_text(summary.stdout)
 try:
  s=json.loads(summary.stdout); print(json.dumps({'device':key,**receipt,'passed':s.get('passedTests'),'failed':s.get('failedTests'),'failures':s.get('testFailures')}),flush=True)
 except ValueError: print(summary.stderr[:1000],flush=True)
 if result.returncode: any_failed=True
sys.exit(65 if any_failed else 0)
