import pathlib,json,subprocess,os,time,hashlib,sys
root=pathlib.Path(__file__).resolve().parent;worktree=root.parents[3]
outbase=root/('host-builds'+('-'+sys.argv[1] if len(sys.argv)>1 else ''));outbase.mkdir(exist_ok=False)
build=root/'host-build-cache';build.mkdir(exist_ok=True)
env=os.environ.copy();iso={'TMPDIR':str(root/'tmp'),'CFFIXED_USER_HOME':str(root/'cocoa-home'),'XDG_CACHE_HOME':str(root/'cache')};env.update(iso)
for p in iso.values():pathlib.Path(p).mkdir(exist_ok=True)
inputs=json.loads((root/'contract-before.json').read_text())['before_sha256']
inputs={p:hashlib.sha256((worktree/p).read_bytes()).hexdigest() for p in inputs}
failed=False
for runtime,udid in [('18.2','BE43D4FD-1B71-4E6F-9EE7-DB32BD2D4D7C'),('27.0','2BED6C3B-5DA5-4F43-A44E-FB1CC9BB8F8D')]:
 for scheme in ('TchopApp','TchopAppOcean'):
  out=outbase/(scheme+'-'+runtime);out.mkdir()
  args=['/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild','-project',str(worktree/'TchopApp.xcodeproj'),'-scheme',scheme,'-configuration','Debug','-sdk','iphonesimulator','-destination','platform=iOS Simulator,id='+udid,'-destination-timeout','30','-derivedDataPath',str(build/'derived-data'),'-clonedSourcePackagesDirPath',str(build/'source-packages'),'-packageCachePath',str(build/'cache/swiftpm'),'-disableAutomaticPackageResolution','-skipPackageUpdates','-resultBundlePath',str(out/'result.xcresult'),'-quiet','CODE_SIGNING_ALLOWED=NO','CODE_SIGNING_REQUIRED=NO','COMPILER_INDEX_STORE_ENABLE=NO','INDEX_ENABLE_DATA_STORE=NO','CLANG_MODULE_CACHE_PATH='+str(build/'cache/clang'),'SWIFT_MODULE_CACHE_PATH='+str(build/'cache/swift'),'SDK_STAT_CACHE_DIR='+str(build/'cache/sdk-stat'),'CACHE_ROOT='+str(build/'cache'),'build']
  (out/'invocation.json').write_text(json.dumps({'args':args,'environment':iso,'input_sha256':inputs,'question':'Compile exact host/embedded-target graph; no app launch/auth/network/inherited Library grant','runtime_destination':runtime,'SDK':'iPhoneSimulator27.0 separate from runtime'},indent=2)+'\n')
  print('BUILD START',scheme,runtime,flush=True);start=time.time()
  with (out/'build.log').open('w') as log:
   try:p=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=300)
   except subprocess.TimeoutExpired:p=subprocess.CompletedProcess(args,124)
  j={'exit_code':p.returncode,'elapsed_seconds':round(time.time()-start,2),'inputs_unchanged':all(hashlib.sha256((worktree/k).read_bytes()).hexdigest()==h for k,h in inputs.items())}
  (out/'result.json').write_text(json.dumps(j,indent=2)+'\n');print('BUILD RESULT',scheme,runtime,json.dumps(j),flush=True)
  if p.returncode:
   failed=True
   errors=[line for line in (out/'build.log').read_text(errors='replace').splitlines() if 'error:' in line or '** BUILD' in line]
   print('\n'.join(errors[:15]),flush=True)
   # A bounded verification failure is retained. Do not spend repeated identical builds on a known shared blocker.
   (outbase/'stopped.json').write_text(json.dumps({'reason':'First failure; remaining unchanged host/runtime build attempts withheld pending scoped diagnosis','failed_attempt':out.name,'remaining':'Not run, not PASS'},indent=2)+'\n')
   sys.exit(p.returncode)
sys.exit(0)
