"""Prepare only the frozen v10.0.0 test dependency closure; never modify source root."""
import argparse, hashlib, json, pathlib, re, shutil, subprocess
p=argparse.ArgumentParser(); p.add_argument("--source-root",required=True); p.add_argument("--candidate-root",required=True); a=p.parse_args()
src=pathlib.Path(a.source_root).resolve(); dst=pathlib.Path(a.candidate_root).resolve()
assert src != dst and str(src).lower() == r"D:\EliteSync-v10".lower()
BASE="4bebc8f394248e254c1368a06fbdee5d2c883301"
def git(root,*args):
    return subprocess.check_output(["git","--no-optional-locks","-C",str(root),*args],text=True).strip()
assert git(src,"rev-parse","HEAD")==BASE and git(dst,"rev-parse","HEAD")==BASE
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
ev=dst/"docs/versions/v10.0.0/evidence"; ev.mkdir(parents=True,exist_ok=True)
tests=["ProductConnectionPersistenceApplicationAdapterTest","ProductConnectionPersistenceFamilyTest","ProductConnectionStateTransitionEvaluatorTest","CanonicalMatchPersistenceFamilyTest","CanonicalMatchPersistenceApplicationAdapterTest","InMemoryLogicalPersistenceRepositoryContractTest","SqliteInMemoryLogicalPersistenceAdapterTest","PersistenceBoundaryApplicationInterfaceIntegrationContractTest","LogicalPersistenceAdapterConformanceContractTest","MessagingConsentPersistenceFamilyTest","MessagingConsentPersistenceApplicationAdapterTest"]
prefix="services/backend-laravel/"
selected={prefix+"tests/Unit/"+n+".php" for n in tests}
domain={x.stem:x for x in (src/(prefix+"app/Domain")).glob("*.php")}
pending=list(selected)
while pending:
    rel=pending.pop(); text=(src/rel).read_text(encoding="utf-8-sig")
    for name,path in domain.items():
        if re.search(r"\b"+re.escape(name)+r"\b",text):
            dr=path.relative_to(src).as_posix()
            if dr not in selected: selected.add(dr); pending.append(dr)
selected.update(prefix+x for x in ("composer.json","composer.lock","phpunit.xml"))
tracked=git(src,"diff","--name-only").splitlines()
status=git(src,"status","--porcelain=v1","--untracked-files=normal")
index=pathlib.Path(git(src,"rev-parse","--path-format=absolute","--git-path","index"))
protection=json.loads((src/"EVIDENCE/SECOND-PHASE-SYNC-HANDOFF-20261012/protected-files-before.json").read_text(encoding="utf-8-sig"))
protected=[]
for entry in protection:
    file=(src/entry["path"]).resolve(); assert file.is_relative_to(src)
    protected.append({"path":entry["path"],"sha256":sha(file),"bytes":file.stat().st_size,"matches_prior":sha(file)==entry["sha256"]})
before={"head":git(src,"rev-parse","HEAD"),"branch":git(src,"branch","--show-current"),"index_sha256":sha(index),"status_sha256":hashlib.sha256(status.encode()).hexdigest(),"tracked_changed":len(tracked),"staged":git(src,"diff","--cached","--name-only"),"untracked_normal":sum(x.startswith("??") for x in status.splitlines()),"tracked_files":[{"path":x,"sha256":sha(src/x)} for x in tracked],"protected_files":protected,"existing_worktrees_sha256":hashlib.sha256(git(src,"worktree","list","--porcelain").encode()).hexdigest()}
(ev/"root-before.json").write_text(json.dumps(before,indent=2)+"\n",encoding="utf-8")
assert all(x["matches_prior"] for x in protected), "Protected baseline mismatch"
records=[]; owned=prefix+"tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php"
for rel in sorted(selected):
    source=src/rel; target=dst/rel
    if rel != owned and (not target.exists() or sha(source)!=sha(target)):
        target.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(source,target)
    tracked_path=bool(git(src,"ls-files","--",rel))
    records.append({"path":rel,"source":"TRACKED_BASELINE" if tracked_path and git(src,"hash-object","--",rel)==git(src,"rev-parse","HEAD:"+rel) else "LOCAL_ONLY_SELECTED","source_sha256":sha(source),"source_git_blob":git(src,"hash-object","--",rel),"purpose":"FROZEN_11_TEST_DEPENDENCY","copied":rel != owned and sha(target)==sha(source)})
(ev/"source-intake.json").write_text(json.dumps({"code_parent":BASE,"files":records,"test_names":tests},indent=2)+"\n",encoding="utf-8")
vendor=dst/(prefix+"vendor")
assert not vendor.exists(), "Do not replace candidate vendor"
shutil.copytree(src/(prefix+"vendor"),vendor)
print(json.dumps({"selected_files":len(records),"domain_files":sum("/app/Domain/" in x["path"] for x in records),"protected_verified":len(protected),"vendor":"COPIED_EXISTING_IGNORED_DEPENDENCIES_NO_INSTALL","test_files":11}))
