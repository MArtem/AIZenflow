import pathlib,subprocess,os,json,hashlib,plistlib,sys
root=pathlib.Path(__file__).resolve().parent
worktree=root.parents[3]
stage=sys.argv[1]
out=root/stage;out.mkdir(exist_ok=False)
app=out/'TabDescriptionLocalizationProbe.app';app.mkdir()
source_rel=['TchopApp/Models/AppTab.swift','TchopApp/App/AppLocalization.swift','PackagesInUse/AppLocalization/Sources/AppLocalization/AppLocalizationCore.swift','PackagesInUse/TchopProductLocalizationResources/Sources/TchopProductLocalizationResources/TchopProductLocalizationResources.swift']
inputs={p:hashlib.sha256((worktree/p).read_bytes()).hexdigest() for p in source_rel}
resources=worktree/'PackagesInUse/TchopProductLocalizationResources/Sources/TchopProductLocalizationResources/Resources'
for lang in ('en','ru'):
 dest=app/(lang+'.lproj');dest.mkdir();(dest/'Localizable.strings').write_bytes((resources/(lang+'.lproj')/'Localizable.strings').read_bytes())
(app/'Info.plist').write_bytes(plistlib.dumps({'CFBundleExecutable':'TabDescriptionLocalizationProbe','CFBundleIdentifier':'com.zenflow.TCW4.LocalizationProbe','CFBundleName':'TabDescriptionLocalizationProbe','CFBundlePackageType':'APPL','CFBundleDevelopmentRegion':'en','CFBundleLocalizations':['en','ru']}))
env=os.environ.copy();iso={'TMPDIR':str(root/'tmp'),'CFFIXED_USER_HOME':str(root/'cocoa-home'),'XDG_CACHE_HOME':str(root/'cache')};env.update(iso)
for p in iso.values():pathlib.Path(p).mkdir(exist_ok=True)
sdk='/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator27.0.sdk'
args=['/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc','-parse-as-library','-swift-version','6','-strict-concurrency=complete','-warnings-as-errors','-target','arm64-apple-ios17.0-simulator','-sdk',sdk,'-module-cache-path',str(root/'cache/modules'),'-o',str(app/'TabDescriptionLocalizationProbe'),*[str(worktree/p) for p in source_rel],str(root/'TabDescriptionLocalizationProbe.swift')]
(out/'invocation.json').write_text(json.dumps({'args':args,'input_sha256':inputs,'environment':iso,'scope':'Actual four Foundation sources + one nonshipping ephemeral probe; bundle copied exact product language resources, not full host app'},indent=2)+'\n')
with (out/'compile.log').open('w') as log:p=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=120)
(out/'compile-result.json').write_text(json.dumps({'exit_code':p.returncode,'inputs_unchanged':all(hashlib.sha256((worktree/k).read_bytes()).hexdigest()==h for k,h in inputs.items())},indent=2)+'\n')
print('COMPILE',stage,p.returncode)
if p.returncode:print((out/'compile.log').read_text()[:6000])
sys.exit(p.returncode)
